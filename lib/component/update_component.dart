import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class UpgradeCard extends StatefulWidget {
  ///标题
  String title;

  ///更新内容
  String message;

  ///确认按钮
  String positiveBtn;

  ///取消按钮
  String negativeBtn;

  ///确定按钮回调
  final GestureTapCallback positiveCallback;

  ///取消按钮回调
  final GestureTapCallback negativeCallback;

  ///条形下载进度条，默认不展示
  bool hasLinearProgress;

  UpgradeCard(
      {this.title = "",
      this.message = "",
      this.positiveBtn = "",
      this.negativeBtn = "",
      required this.positiveCallback,
      required this.negativeCallback,
      this.hasLinearProgress = false});

  final _upgradeCardState = _UpgradeCardState();

  @override
  _UpgradeCardState createState() => _upgradeCardState;

  /// 外部更新函数
  void updateProgress(String title, String message, String positiveBtn,
          String negativeBtn, bool hasLinearProgress, double progress) =>
      _upgradeCardState.updateProgress(title, message, positiveBtn, negativeBtn,
          hasLinearProgress, progress);
}

class _UpgradeCardState extends State<UpgradeCard> {
  /// 进度条数值
  double progress = 0;

  /// 内部更新函数
  void updateProgress(String title, String message, String positiveBtn,
      String negativeBtn, bool hasLinearProgress, double progress) {
    setState(() {
      widget.title = title;
      widget.message = message;
      widget.positiveBtn = positiveBtn;
      widget.negativeBtn = negativeBtn;
      widget.hasLinearProgress = hasLinearProgress;
      progress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    var messageStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
        color: Color(0xFF333130),
        height: 1.6);

    return Center(
      child: Container(
        width: 320,
        padding: EdgeInsets.only(bottom: 17),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            //背景图片
            // Container(
            //   padding: EdgeInsets.only(bottom: 8),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(8),
            //     child: Image.asset(
            //       "assets/images/updateBg.png",
            //       width: 320,
            //     ),
            //   ),
            // ),

            ///标题
            Visibility(
              visible: widget.title.isNotEmpty,
              child: Container(
                padding: EdgeInsets.only(top: 25),
                child: Text(
                  widget.title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                      color: Color(0xFF333130)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            ///更新内容
            Container(
                width: 280,
                margin: EdgeInsets.only(top: 20, bottom: 20),
                child: Text(
                  widget.message,
                  style: messageStyle,
                  textAlign: TextAlign.left,
                )),

            // 进度条
            Visibility(
              visible: widget.hasLinearProgress,
              child: Container(
                  height: 6,
                  width: 290,
                  margin: EdgeInsets.only(bottom: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Color(0xFFFAF8F7),
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 64, 75, 130)),
                    ),
                  )),
            ),

            ///按钮列表
            Container(
              height: 60,
              child: Row(
                children: <Widget>[
                  Visibility(
                    visible: widget.negativeBtn.isNotEmpty,
                    child: Expanded(
                        child: Container(
                      child: TextButton(
                          onPressed: widget.negativeCallback,
                          child: Text(
                            widget.negativeBtn,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xffDFE2F0)),
                          )),
                    )),
                  ),
                  Container(
                    height: 60,
                    width: 0.5,
                    color: Color(0xffC0C5D6),
                  ),
                  Visibility(
                      visible: widget.positiveBtn.isNotEmpty,
                      child: Expanded(
                        child: Container(
                            child: TextButton(
                          onPressed: widget.positiveBtn != "下载中"
                              ? widget.positiveCallback
                              : () {},
                          child: Text(widget.positiveBtn,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 64, 75, 130),
                              )),
                        )),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateDownloader extends StatefulWidget {
  /// apk更新url
  final String downLoadUrl;

  /// apk更新描述
  final String message;

  /// apk是否强制更新
  final bool isForce;

  UpdateDownloader(
      {required this.downLoadUrl,
      required this.message,
      required this.isForce});

  @override
  _UpdateDownloaderState createState() => _UpdateDownloaderState();
}

class DownloadTaskStatus {
  final String statusText;

  const DownloadTaskStatus({required this.statusText});

  static const DownloadTaskStatus waitConnection =
      DownloadTaskStatus(statusText: "Waiting");
  static const DownloadTaskStatus failed =
      DownloadTaskStatus(statusText: "Waiting");
  static const DownloadTaskStatus complete =
      DownloadTaskStatus(statusText: "Waiting");
}

class _UpdateDownloaderState extends State<UpdateDownloader> {
  int progress = 0;
  String _localPath = '';
  String downloadId = '';
  DownloadTaskStatus? status;
  final ReceivePort _port = ReceivePort();
  UpgradeCard? _upgradeCard;

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback((String id, int status, int progress) {
      IsolateNameServer.lookupPortByName("downloader_send_port")
          ?.send([id, status, progress]);
    });
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping("download_key");
    super.dispose();
  }

  //开启监听 两个隔离之间的通信
  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, "downloader_send_port");
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      final taskId = (data as List<dynamic>)[0] as String;
      status = data[1] as DownloadTaskStatus;
      progress = data[2] as int;

      setState(() {
        downloadId = taskId;
      });

      // 更新进度条
      _upgradeCard?.updateProgress("检查更新", widget.message, "进行升级", "取消", true,
          double.parse((progress / 100).toStringAsFixed(1)));

      // 处理结果 - 异常
      if (status == DownloadTaskStatus.failed) {
        _upgradeCard?.updateProgress(
            "失败确认", "应用程序下载失败，请重试", "重新下载", "取消", false, 0);
      }
      // 处理结果 - 完成
      if (status == DownloadTaskStatus.complete) {
        Future.delayed(new Duration(milliseconds: 500), () async {
          Navigator.of(context).pop();
          openAPK();
        });
      }
    });
  }

  //关闭 两个隔离之间的通信
  void _unbindBackgroundIsolate() {
    // IsolateNameServer.removePortNameMapping(download_key);
  }

  // 初始化弹框文案
  initGeneral() {
    _upgradeCard?.updateProgress(
        "检查更新", "widget.description", "进行升级", "取消", widget.isForce, 0);
  }

  // 获取下载地址
  Future<String> get _apkLocalPath async {
    // final directory = ""; await getExternalStorageDirectory();
    // _localPath = directory!.path.toString();
    return "./";
  }

  //检查权限
  Future<bool> _checkPermission() async {
    // PermissionStatus statuses = await Permission.storage.status;
    // if (statuses != PermissionStatus.granted) {
    //   Map<Permission, PermissionStatus> statuses =
    //       await [Permission.storage].request();
    //   if (statuses[Permission.storage] == PermissionStatus.granted) {
    //     return true;
    //   }
    // } else {
    //   return true;
    // }
    return true;
  }

  // 停止下载器运行（注销当前taskID）
  closeCallback() {
    Navigator.of(context).pop();
    if (downloadId != '') FlutterDownloader.cancel(taskId: downloadId);
  }

  //第一步：点击更新按钮
  _updateApplication() async {
    if (status == DownloadTaskStatus.failed) return againDownloader();
    _requestDownload(context, widget.downLoadUrl);
  }

  //第二步：flutterDownLoader新建Task
  void _requestDownload(BuildContext context, url) async {
    // if (await _checkPermission()) {
    //   initGeneral();
    downloadId = (await FlutterDownloader.enqueue(
      url: url, // 服务端提供apk下载路径
      savedDir: await _apkLocalPath, // 本地存放路径
      showNotification: true, // 是否显示在通知栏
      openFileFromNotification: true, // 是否在通知栏可以点击打开此文件
    ))!;
    // } else {
    //   // ToastUtil.show("权限获取失败");
    // }
  }

  //第三步：下载失败或开始安装
  void againDownloader() async {
    initGeneral();
    downloadId = (await FlutterDownloader.retry(taskId: downloadId))!;
  }

  openAPK() async {
    // String path = await _apkLocalPath;
    // String last =
    //     widget.downLoadUrl.substring(widget.downLoadUrl.lastIndexOf("/") + 1);
    // AppInstaller.installApk(path + "/" + last)
    //     .then((result) {})
    //     .catchError((error) {
    //   ToastUtil.show(error);
    // });
  }

  @override
  Widget build(BuildContext context) {
    if (_upgradeCard != null) {
      return _upgradeCard!;
    }
    return _upgradeCard = UpgradeCard(
      title: "检查更新",
      message: widget.message,
      positiveBtn: "进行升级",
      negativeBtn: widget.isForce ? "" : "取消",
      positiveCallback: () => _updateApplication(),
      negativeCallback: () => closeCallback(),
      // closeCallback: () => closeCallback(),
    );
  }
}
