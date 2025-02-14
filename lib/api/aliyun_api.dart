import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path/path.dart' as my_path;

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class AliyunImageUploadUtils {
  //上传接口
  static uploadApi({required String path, required String name, required Map configMap}) async {
    String keyId = configMap['keyId'];
    String keySecret = configMap['keySecret'];
    String bucket = configMap['bucket'];
    String area = configMap['area'];
    String aliyunpath = configMap['path'];
    String customUrl = configMap['customUrl'];
    String options = configMap['options'];
    //格式化
    if (customUrl != "None") {
      if (!customUrl.startsWith(RegExp(r'http(s)?://'))) {
        customUrl = 'http://$customUrl';
      }
    }
    //格式化
    if (aliyunpath != 'None') {
      aliyunpath = '${aliyunpath.replaceAll(RegExp(r'^/*'), '').replaceAll(RegExp(r'/*$'), '')}/';
    }
    String host = '$bucket.$area.aliyuncs.com';
    //云存储的路径
    String urlpath = '';
    //阿里云不能以/开头
    if (aliyunpath != 'None') {
      urlpath = '$aliyunpath$name';
    } else {
      urlpath = name;
    }

    Map<String, dynamic> uploadPolicy = {
      "expiration": "2034-12-01T12:00:00.000Z",
      "conditions": [
        {"bucket": bucket},
        ["content-length-range", 0, 104857600],
        {"key": urlpath}
      ]
    };
    String base64Policy = base64.encode(utf8.encode(json.encode(uploadPolicy)));
    String singature = base64.encode(Hmac(sha1, utf8.encode(keySecret)).convert(utf8.encode(base64Policy)).bytes);
    Map<String, dynamic> formMap = {
      'key': urlpath,
      'OSSAccessKeyId': keyId,
      'policy': base64Policy,
      'Signature': singature,
      'file': await MultipartFile.fromFile(path, filename: name),
    };
    if (getContentType(my_path.extension(path)) != null) {
      formMap['x-oss-content-type'] = getContentType(my_path.extension(path));
    }
    FormData formData = FormData.fromMap(formMap);
    BaseOptions baseoptions = setBaseOptions();
    File uploadFile = File(path);
    String contentLength = await uploadFile.length().then((value) {
      return value.toString();
    });
    baseoptions.headers = {
      'Host': host,
      'Content-Type': Global.multipartString,
      'Content-Length': contentLength,
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.post(
        'https://$host',
        data: formData,
      );

      if (response.statusCode == 204) {
        String returnUrl = '';
        String displayUrl = '';

        if (customUrl != 'None') {
          if (!customUrl.endsWith('/')) {
            returnUrl = '$customUrl/$urlpath';
            displayUrl = '$customUrl/$urlpath';
          } else {
            customUrl = customUrl.substring(0, customUrl.length - 1);
            returnUrl = '$customUrl/$urlpath';
            displayUrl = '$customUrl/$urlpath';
          }
        } else {
          returnUrl = 'https://$host/$urlpath';
          displayUrl = 'https://$host/$urlpath';
        }

        if (options == 'None') {
          displayUrl = "$displayUrl?x-oss-process=image/resize,m_lfit,h_500,w_500";
        } else {
          //网站后缀以?开头
          if (!options.startsWith('?')) {
            options = '?$options';
          }
          returnUrl = '$returnUrl$options';
          displayUrl = '$displayUrl$options';
        }

        String formatedURL = '';
        if (Global.isCopyLink == true) {
          formatedURL = linkGenerateDict[Global.defaultLKformat]!(returnUrl, name);
        } else {
          formatedURL = returnUrl;
        }
        String pictureKey = jsonEncode(configMap);
        return ["success", formatedURL, returnUrl, pictureKey, displayUrl];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "AliyunImageUploadUtils",
            methodName: "uploadApi",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "AliyunImageUploadUtils",
            methodName: "uploadApi",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    try {
      String fileName = deleteMap['name'];
      Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
      String keyId = configMapFromPictureKey['keyId'];
      String keySecret = configMapFromPictureKey['keySecret'];
      String bucket = configMapFromPictureKey['bucket'];
      String area = configMapFromPictureKey['area'];
      String aliyunpath = configMapFromPictureKey['path'];
      String deleteHost = 'https://$bucket.$area.aliyuncs.com';
      String urlpath = '';
      if (aliyunpath != 'None') {
        if (aliyunpath.startsWith('/')) {
          aliyunpath = aliyunpath.substring(1);
        }
        if (!aliyunpath.endsWith('/')) {
          aliyunpath = '$aliyunpath/';
        }
        deleteHost = '$deleteHost/$aliyunpath$fileName';
        urlpath = '$aliyunpath$fileName';
      } else {
        deleteHost = '$deleteHost/$fileName';
        urlpath = fileName;
      }
      BaseOptions baseOptions = setBaseOptions();
      String authorization = 'OSS $keyId:';
      var date = HttpDate.format(DateTime.now());
      String verb = 'DELETE';
      String contentMD5 = '';
      String contentType = 'application/json';
      String canonicalizedOSSHeaders = '';
      String canonicalizedResource = '/$bucket/$urlpath';
      String stringToSign = '$verb\n$contentMD5\n$contentType\n$date\n$canonicalizedOSSHeaders$canonicalizedResource';
      String signature = base64.encode(Hmac(sha1, utf8.encode(keySecret)).convert(utf8.encode(stringToSign)).bytes);

      baseOptions.headers = {
        'Host': '$bucket.$area.aliyuncs.com',
        'Authorization': '$authorization$signature',
        'Date': HttpDate.format(DateTime.now()),
        'Content-type': 'application/json',
      };
      Dio dio = Dio(baseOptions);

      try {
        var response = await dio.delete(
          deleteHost,
        );
        if (response.statusCode == 204) {
          return [
            "success",
          ];
        } else {
          return ["failed"];
        }
      } catch (e) {
        if (e is DioError) {
          FLog.error(
              className: "AliyunImageUploadUtils",
              methodName: "deleteApi",
              text: formatErrorMessage({
                'fileName': fileName,
              }, e.toString(), isDioError: true, dioErrorMessage: e),
              dataLogType: DataLogType.ERRORS.toString());
        } else {
          FLog.error(
              className: "AliyunImageUploadUtils",
              methodName: "deleteApi",
              text: formatErrorMessage({
                'fileName': fileName,
              }, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
        }
        return [e.toString()];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "AliyunImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "AliyunImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }
}
