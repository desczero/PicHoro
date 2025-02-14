import 'dart:io' as io;
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/webdav_configure.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

class WebdavManageAPI {
  static Future<io.File> get _localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return io.File('$path/${defaultUser}_webdav_config.txt');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readWebdavConfig() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'WebdavManageAPI',
          methodName: 'readWebdavConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readWebdavConfig();
    Map configMap = json.decode(configStr);
    return configMap;
  }

  static isString(var variable) {
    return variable is String;
  }

  static isFile(var variable) {
    return variable is io.File;
  }

  static getWebdavClient() async {
    Map configMap = await getConfigMap();
    String host = configMap['host'];
    String webdavusername = configMap['webdavusername'];
    String password = configMap['password'];
    webdav.Client client = webdav.newClient(
      host,
      user: webdavusername,
      password: password,
    );
    client.setHeaders({'accept-charset': 'utf-8'});
    client.setConnectTimeout(8000);
    client.setSendTimeout(8000);
    client.setReceiveTimeout(8000);
    return client;
  }

  static getFileList(String path) async {
    webdav.Client client = await getWebdavClient();

    try {
      var response = await client.readDir(path);
      List fileList = [];
      for (var item in response) {
        Map<String, dynamic> element = {};
        element['path'] = item.path;
        element['isDir'] = item.isDir;
        element['name'] = item.name;
        element['mimeType'] = item.mimeType;
        element['size'] = item.size;
        element['eTag'] = item.eTag;
        element['cTime'] = item.cTime;
        element['mTime'] = item.mTime;
        fileList.add(element);
      }
      return ['success', fileList];
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "getFileList",
            text: formatErrorMessage({}, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "getFileList",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static createDir(String path) async {
    webdav.Client client = await getWebdavClient();
    try {
      await client.mkdirAll(path);
      return ['success'];
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "createDir",
            text: formatErrorMessage({}, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "createDir",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static deleteFile(String path) async {
    webdav.Client client = await getWebdavClient();
    try {
      await client.remove(path);
      return ['success'];
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "deleteFile",
            text: formatErrorMessage({}, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "deleteFile",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static renameFile(
    String path,
    String newName,
  ) async {
    webdav.Client client = await getWebdavClient();
    try {
      await client.rename(path, newName, true);
      return ['success'];
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "renameFile",
            text: formatErrorMessage({}, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "renameFile",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static setDefaultBucket(String folder) async {
    try {
      Map configMap = await getConfigMap();
      String host = configMap['host'];
      String webdavusername = configMap['webdavusername'];
      String password = configMap['password'];
      String uploadPath = folder;

      final webdavConfig = WebdavConfigModel(host, webdavusername, password, uploadPath);
      final webdavConfigJson = jsonEncode(webdavConfig);
      final webdavConfigFile = await _localFile;
      await webdavConfigFile.writeAsString(webdavConfigJson);
      return ['success'];
    } catch (e) {
      FLog.error(
          className: "WebdavManageAPI",
          methodName: "setDefaultBucket",
          text: formatErrorMessage({'folder': folder}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ['failed'];
    }
  }

  //上传文件
  static uploadFile(
    String filename,
    String filepath,
    String prefix,
  ) async {
    try {
      webdav.Client client = await getWebdavClient();
      await client.writeFromFile(filepath, prefix + filename);
      return ['success'];
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "uploadFile",
            text: formatErrorMessage({'filename': filename, 'filepath': filepath, 'prefix': prefix}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "uploadFile",
            text: formatErrorMessage({'filename': filename, 'filepath': filepath, 'prefix': prefix}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return ['error'];
    }
  }

  //从网络链接下载文件后上传
  static uploadNetworkFile(String fileLink, String prefix) async {
    try {
      String filename = fileLink.substring(fileLink.lastIndexOf("/") + 1, fileLink.length);
      filename = filename.substring(0, !filename.contains("?") ? filename.length : filename.indexOf("?"));
      String savePath = await getTemporaryDirectory().then((value) {
        return value.path;
      });
      String saveFilePath = '$savePath/$filename';
      Dio dio = Dio();
      Response response = await dio.download(fileLink, saveFilePath);
      if (response.statusCode == 200) {
        var uploadResult = await uploadFile(
          filename,
          saveFilePath,
          prefix,
        );
        if (uploadResult[0] == "success") {
          return ['success'];
        } else {
          return ['failed'];
        }
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "uploadNetworkFile",
            text: formatErrorMessage({'fileLink': fileLink, 'prefix': prefix}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "WebdavManageAPI",
            methodName: "uploadNetworkFile",
            text: formatErrorMessage({'fileLink': fileLink, 'prefix': prefix}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return ['failed'];
    }
  }

  static uploadNetworkFileEntry(List fileList, String prefix) async {
    int successCount = 0;
    int failCount = 0;

    for (String fileLink in fileList) {
      if (fileLink.isEmpty) {
        continue;
      }
      var uploadResult = await uploadNetworkFile(fileLink, prefix);
      if (uploadResult[0] == "success") {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (successCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传失败', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    } else if (failCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传成功', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    } else {
      return Fluttertoast.showToast(
          msg: '成功$successCount,失败$failCount', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    }
  }
}
