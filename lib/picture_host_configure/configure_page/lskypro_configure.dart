import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';

class HostConfig extends StatefulWidget {
  const HostConfig({Key? key}) : super(key: key);

  @override
  HostConfigState createState() => HostConfigState();
}

class HostConfigState extends State<HostConfig> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwdController = TextEditingController();
  final _strategyIdController = TextEditingController();
  final _albumIdController = TextEditingController();
  String _tokenController = '';

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await LskyproManageAPI.getConfigMap();
      _hostController.text = configMap['host'];
      _strategyIdController.text = configMap['strategy_id'];
      if (configMap['album_id'] != 'None' && configMap['album_id'] != null) {
        _albumIdController.text = configMap['album_id'];
      } else {
        _albumIdController.clear();
      }
      _tokenController = configMap['token'];
      setState(() {});
    } catch (e) {
      FLog.error(
          className: 'LskyproConfigState',
          methodName: '_initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _usernameController.dispose();
    _passwdController.dispose();
    _strategyIdController.dispose();
    _albumIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('兰空图床参数配置'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, '/configureStorePage?psHost=lsky.pro', transition: TransitionType.cupertino);
              await _initConfig();
              setState(() {});
            },
            icon: const Icon(Icons.save_as_outlined, color: Color.fromARGB(255, 255, 255, 255), size: 35),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                label: Center(child: Text('域名')),
                hintText: '例如: https://imgx.horosama.com',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入域名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                label: Center(child: Text('用户名')),
                hintText: '设定用户名',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _passwdController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Center(child: Text('密码')),
                hintText: '输入密码',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _strategyIdController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('储存策略ID')),
                hintText: '输入用户名和密码获取列表,一般是1',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入储存策略Id';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _albumIdController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:相册ID')),
                hintText: '仅对付费版和修改了代码的免费版有效',
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return NetLoadingDialog(
                          outsideDismiss: false,
                          loading: true,
                          loadingText: "配置中...",
                          requestCallBack: _saveHostConfig(),
                        );
                      });
                }
              },
              child: titleText('提交表单', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _getStrategyId();
              },
              child: titleText('获取储存策略Id列表', fontsize: null),
            )),
            ListTile(
              title: ElevatedButton(
                onPressed: () {
                  _getAlbumId();
                },
                child: titleText('获取相册Id列表', fontsize: null),
              ),
            ),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return NetLoadingDialog(
                        outsideDismiss: false,
                        loading: true,
                        loadingText: "检查中...",
                        requestCallBack: checkHostConfig(),
                      );
                    });
              },
              child: titleText('检查当前配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router
                    .navigateTo(context, '/configureStorePage?psHost=lsky.pro', transition: TransitionType.cupertino);
                await _initConfig();
                setState(() {});
              },
              child: titleText('设置备用配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _setdefault();
              },
              child: titleText('设为默认图床', fontsize: null),
            )),
            ListTile(
              title: const Center(
                child: Text(
                  '当前token',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              subtitle: Center(
                child: SelectableText(
                  _tokenController == '' ? '未配置' : _tokenController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _getStrategyId() async {
    if (_tokenController.isEmpty && (_usernameController.text.isEmpty || _passwdController.text.isEmpty)) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('用户名或密码为空'),
              content: Text('请先输入用户名和密码'),
            );
          });
      return;
    }
    if (_usernameController.text.isNotEmpty && _passwdController.text.isNotEmpty) {
      final host = _hostController.text;
      String token = 'Bearer ';
      final username = _usernameController.text;
      final passwd = _passwdController.text;
      BaseOptions options = setBaseOptions();
      options.headers = {
        "Accept": "application/json",
      };
      Dio dio = Dio(options);
      String fullUrl = '$host/api/v1/tokens';
      FormData formData = FormData.fromMap({
        'email': username,
        'password': passwd,
      });
      try {
        var response = await dio.post(
          fullUrl,
          data: formData,
        );
        if (response.statusCode == 200 && response.data['status'] == true) {
          token = token + response.data['data']['token'].toString();
          String strategiesUrl = '$host/api/v1/strategies';
          BaseOptions strategiesOptions = setBaseOptions();
          strategiesOptions.headers = {
            "Accept": "application/json",
            "Authorization": token,
          };
          dio = Dio(strategiesOptions);
          response = await dio.get(strategiesUrl);
          if (response.statusCode == 200 && response.data['status'] == true) {
            String strategyId = '';
            List strategies = response.data['data']['strategies'];
            for (int i = 0; i < strategies.length; i++) {
              strategyId = '${strategyId}id : ${strategies[i]['id']}  :  ${strategies[i]['name']}\n';
            }

            showCupertinoAlertDialog(
                barrierDismissible: false, context: context, title: '储存策略Id列表', content: strategyId);
          } else {
            showToast('获取储存策略Id列表失败');
          }
        } else {
          if (response.statusCode == 403) {
            showCupertinoAlertDialog(context: context, title: '错误', content: '管理员关闭了接口功能');
            return;
          } else if (response.statusCode == 401) {
            showCupertinoAlertDialog(context: context, title: '错误', content: '授权失败');
            return;
          } else if (response.statusCode == 500) {
            showCupertinoAlertDialog(context: context, title: '错误', content: '服务器异常');
            return;
          } else if (response.statusCode == 404) {
            showCupertinoAlertDialog(context: context, title: '错误', content: '接口不存在');
            return;
          }
          if (response.data['status'] == false) {
            showCupertinoAlertDialog(context: context, title: '错误', content: response.data['message']);
            return;
          }
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getStrategyId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    } else {
      try {
        String host = _hostController.text;
        String strategiesUrl = '$host/api/v1/strategies';
        BaseOptions strategiesOptions = setBaseOptions();
        strategiesOptions.headers = {
          "Accept": "application/json",
          "Authorization": _tokenController,
        };
        Dio dio = Dio(strategiesOptions);
        var response = await dio.get(strategiesUrl);

        if (response.statusCode == 200 && response.data['status'] == true) {
          String strategyId = '';
          List strategies = response.data['data']['strategies'];
          for (int i = 0; i < strategies.length; i++) {
            strategyId = '${strategyId}id : ${strategies[i]['id']}  :  ${strategies[i]['name']}\n';
          }

          showCupertinoAlertDialog(barrierDismissible: false, context: context, title: '储存策略Id列表', content: strategyId);
        } else {
          showToast('获取储存策略Id列表失败');
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getStrategyId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  void _getAlbumId() async {
    if (_tokenController.isEmpty && (_usernameController.text.isEmpty || _passwdController.text.isEmpty)) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('用户名或密码为空'),
              content: Text('请先输入用户名和密码'),
            );
          });
      return;
    }
    if (_usernameController.text.isNotEmpty && _passwdController.text.isNotEmpty) {
      final host = _hostController.text;
      String token = 'Bearer ';
      final username = _usernameController.text;
      final passwd = _passwdController.text;
      BaseOptions options = setBaseOptions();
      options.headers = {
        "Accept": "application/json",
      };
      Dio dio = Dio(options);
      String fullUrl = '$host/api/v1/tokens';
      FormData formData = FormData.fromMap({
        'email': username,
        'password': passwd,
      });
      try {
        var response = await dio.post(
          fullUrl,
          data: formData,
        );
        if (response.statusCode == 200 && response.data['status'] == true) {
          token = token + response.data['data']['token'].toString();
          String strategiesUrl = '$host/api/v1/albums';
          BaseOptions strategiesOptions = setBaseOptions();
          strategiesOptions.headers = {
            "Accept": "application/json",
            "Authorization": token,
          };
          dio = Dio(strategiesOptions);
          response = await dio.get(strategiesUrl);

          if (response.statusCode == 200 && response.data['status'] == true) {
            String albumID = '';
            List albumIDs = response.data['data']['data'];
            for (int i = 0; i < albumIDs.length; i++) {
              albumID = '${albumID}id : ${albumIDs[i]['id']}  :  ${albumIDs[i]['name']}\n';
            }

            showCupertinoAlertDialog(barrierDismissible: false, context: context, title: '相册Id列表', content: albumID);
          } else {
            showToast('获取相册Id列表失败');
          }
        } else {
          if (response.statusCode == 403) {
            showCupertinoAlertDialog(context: context, title: '错误', content: '管理员关闭了接口功能');
            return;
          } else if (response.statusCode == 401) {
            showCupertinoAlertDialog(context: context, title: '错误', content: '授权失败');
            return;
          } else if (response.statusCode == 500) {
            showCupertinoAlertDialog(context: context, title: '错误', content: '服务器异常');
            return;
          } else if (response.statusCode == 404) {
            showCupertinoAlertDialog(context: context, title: '错误', content: '接口不存在');
            return;
          }
          if (response.data['status'] == false) {
            showCupertinoAlertDialog(context: context, title: '错误', content: response.data['message']);
            return;
          }
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getAlbumId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    } else {
      try {
        String host = _hostController.text;
        String strategiesUrl = '$host/api/v1/albums';
        BaseOptions strategiesOptions = setBaseOptions();
        strategiesOptions.headers = {
          "Accept": "application/json",
          "Authorization": _tokenController,
        };
        Dio dio = Dio(strategiesOptions);
        var response = await dio.get(strategiesUrl);

        if (response.statusCode == 200 && response.data['status'] == true) {
          String albumID = '';
          List albumIDs = response.data['data']['data'];
          for (int i = 0; i < albumIDs.length; i++) {
            albumID = '${albumID}id : ${albumIDs[i]['id']}  :  ${albumIDs[i]['name']}\n';
          }

          showCupertinoAlertDialog(barrierDismissible: false, context: context, title: '相册Id列表', content: albumID);
        } else {
          showToast('获取相册Id列表失败');
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getAlbumId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  Future _saveHostConfig() async {
    final host = _hostController.text;
    String token = 'Bearer ';
    if (_tokenController.isEmpty && (_usernameController.text.isEmpty || _passwdController.text.isEmpty)) {
      showToast('用户名或密码为空');
      return;
    }
    if (_usernameController.text.isNotEmpty && _passwdController.text.isNotEmpty) {
      String albumID = 'None';
      if (_albumIdController.text.isNotEmpty) {
        albumID = _albumIdController.text;
      }
      final username = _usernameController.text;
      final passwd = _passwdController.text;

      final strategyId = _strategyIdController.text;
      BaseOptions options = setBaseOptions();
      options.headers = {
        "Accept": "application/json",
      };
      Dio dio = Dio(options);
      String fullUrl = '$host/api/v1/tokens';
      FormData formData = FormData.fromMap({
        'email': username,
        'password': passwd,
      });
      try {
        var response = await dio.post(
          fullUrl,
          data: formData,
        );
        if (response.statusCode == 200 && response.data['status'] == true) {
          token = token + response.data['data']['token'].toString();
          _tokenController = token;
          final hostConfig = HostConfigModel(host, token, strategyId.toString(), albumID.toString());
          final hostConfigJson = jsonEncode(hostConfig);
          final hostConfigFile = await localFile;
          hostConfigFile.writeAsString(hostConfigJson);
          setState(() {});
          return showCupertinoAlertDialog(
              context: context, barrierDismissible: false, title: '配置成功', content: '您的密钥为：\n$token,\n请妥善保管，不要泄露给他人');
        } else {
          if (response.statusCode == 403) {
            return showCupertinoAlertDialog(context: context, title: '错误', content: '管理员关闭了接口功能');
          } else if (response.statusCode == 401) {
            return showCupertinoAlertDialog(context: context, title: '错误', content: '授权失败');
          } else if (response.statusCode == 500) {
            return showCupertinoAlertDialog(context: context, title: '错误', content: '服务器异常');
          } else if (response.statusCode == 404) {
            return showCupertinoAlertDialog(context: context, title: '错误', content: '接口不存在');
          }
          if (response.data['status'] == false) {
            return showCupertinoAlertDialog(context: context, title: '错误', content: response.data['message']);
          }
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_saveHostConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    } else {
      String albumID = 'None';
      if (_albumIdController.text.isNotEmpty) {
        albumID = _albumIdController.text;
      }
      final strategyId = _strategyIdController.text;
      BaseOptions options = setBaseOptions();
      options.headers = {
        "Accept": "application/json",
        "Authorization": _tokenController,
      };
      Dio dio = Dio(options);
      try {
        var response = await dio.get('$host/api/v1/profile');
        if (response.statusCode == 200 && response.data['status'] == true) {
          final hostConfig = HostConfigModel(host, _tokenController, strategyId.toString(), albumID.toString());
          final hostConfigJson = jsonEncode(hostConfig);
          final hostConfigFile = await localFile;
          hostConfigFile.writeAsString(hostConfigJson);

          return showCupertinoAlertDialog(
              context: context,
              barrierDismissible: false,
              title: '配置成功',
              content: '您的密钥为：\n$_tokenController,\n请妥善保管，不要泄露给他人');
        } else {
          showToast('配置失败');
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_saveHostConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkHostConfig() async {
    try {
      final hostConfigFile = await localFile;
      String configData = await hostConfigFile.readAsString();
      if (configData == "Error") {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
      }
      Map configMap = jsonDecode(configData);
      BaseOptions options = setBaseOptions();
      options.headers = {
        "Authorization": configMap["token"],
        "Accept": "application/json",
      };
      String profileUrl = configMap["host"] + "/api/v1/profile";
      Dio dio = Dio(options);
      var response = await dio.get(
        profileUrl,
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return showCupertinoAlertDialog(
            context: context,
            title: '通知',
            content:
                '检测通过，您的配置信息为：\nhost:\n${configMap["host"]}\nstrategyId:\n${configMap["strategy_id"]}\nalbumId:\n${configMap["album_id"]}\ntoken:\n${configMap["token"]}');
      } else {
        if (response.statusCode == 403) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: '管理员关闭了接口功能');
        } else if (response.statusCode == 401) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: '授权失败');
        } else if (response.statusCode == 500) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: '服务器异常');
        } else if (response.statusCode == 404) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: '接口不存在');
        }
        if (response.data['status'] == false) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: response.data['message']);
        }
      }
    } catch (e) {
      FLog.error(
          className: 'ConfigPage',
          methodName: 'checkHostConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_host_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readHostConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'HostConfigPage',
          methodName: 'readHostConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  _setdefault() async {
    try {
      await Global.setPShost('lsky.pro');
      await Global.setShowedPBhost('lskypro');
      eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
      eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
      showToast('已设置兰空图床为默认图床');
    } catch (e) {
      FLog.error(
          className: 'LskyproPage',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '错误');
    }
  }
}

class HostConfigModel {
  final String host;
  final String token;
  final String strategyId;
  final String albumId;

  HostConfigModel(this.host, this.token, this.strategyId, this.albumId);

  Map<String, dynamic> toJson() => {
        'host': host,
        'token': token,
        'strategy_id': strategyId,
        'album_id': albumId,
      };

  static List keysList = [
    'remarkName',
    'host',
    'token',
    'strategy_id',
    'album_id',
  ];
}
