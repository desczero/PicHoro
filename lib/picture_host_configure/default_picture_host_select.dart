import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:horopic/utils/event_bus_utils.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class DefaultPShostSelect extends StatefulWidget {
  const DefaultPShostSelect({Key? key}) : super(key: key);

  @override
  DefaultPShostSelectState createState() => DefaultPShostSelectState();
}

class DefaultPShostSelectState extends State<DefaultPShostSelect> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> allPBhostToSelect = [
    'lsky.pro',
    'sm.ms',
    'github',
    'imgur',
    'qiniu',
    'tencent',
    'aliyun',
    'upyun',
    'ftp',
    'aws',
    'alist',
    'webdav',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('默认图床选择'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Alist V3'),
            trailing: Global.defaultPShost == 'alist' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('alist');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('阿里云'),
            trailing: Global.defaultPShost == 'aliyun' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('aliyun');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('FTP-SSH/SFTP'),
            trailing: Global.defaultPShost == 'ftp' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('ftp');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('Github图床'),
            trailing: Global.defaultPShost == 'github' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('github');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('Imgur图床'),
            trailing: Global.defaultPShost == 'imgur' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('imgur');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('兰空图床'),
            trailing: Global.defaultPShost == 'lsky.pro' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('lsky.pro');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('七牛云'),
            trailing: Global.defaultPShost == 'qiniu' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('qiniu');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('S3兼容平台'),
            trailing: Global.defaultPShost == 'aws' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('aws');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('SM.MS'),
            trailing: Global.defaultPShost == 'sm.ms' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('sm.ms');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('腾讯云'),
            trailing: Global.defaultPShost == 'tencent' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('tencent');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('又拍云'),
            trailing: Global.defaultPShost == 'upyun' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('upyun');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('WebDAV'),
            trailing: Global.defaultPShost == 'webdav' ? const Icon(Icons.check) : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('webdav');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

setdefaultPShostRemoteAndLocal(String psHost) async {
  try {
    await Global.setPShost(psHost);
    if (psHost == 'lsky.pro') {
      await Global.setShowedPBhost('lskypro');
    } else if (psHost == 'sm.ms') {
      await Global.setShowedPBhost('smms');
    } else if (psHost == 'github') {
      await Global.setShowedPBhost('github');
    } else if (psHost == 'imgur') {
      await Global.setShowedPBhost('imgur');
    } else if (psHost == 'qiniu') {
      await Global.setShowedPBhost('qiniu');
    } else if (psHost == 'tencent') {
      await Global.setShowedPBhost('tencent');
    } else if (psHost == 'aliyun') {
      await Global.setShowedPBhost('aliyun');
    } else if (psHost == 'upyun') {
      await Global.setShowedPBhost('upyun');
    } else if (psHost == 'ftp') {
      await Global.setShowedPBhost('PBhostExtend1');
    } else if (psHost == 'aws') {
      await Global.setShowedPBhost('PBhostExtend2');
    } else if (psHost == 'alist') {
      await Global.setShowedPBhost('PBhostExtend3');
    } else if (psHost == 'webdav') {
      await Global.setShowedPBhost('PBhostExtend4');
    }
    showToast('已设置$psHost为默认图床');
  } catch (e) {
    FLog.error(
        className: 'setdefaultPShostRemoteAndLocal',
        methodName: 'setdefaultPShostRemoteAndLocal',
        text: formatErrorMessage({
          'psHost': psHost,
        }, e.toString()),
        dataLogType: DataLogType.ERRORS.toString());
    showToast('错误');
  }
}
