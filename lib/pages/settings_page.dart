import 'package:blank_tool/helpers/download_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import '../component/update_component.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SettingsPage();
  }
}

class _SettingsPage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () async {
              // DownloaderHelper.testDownload();
              await Dio().download("https://img.shields.io/pub/v/dio.svg",
                  (Headers headers) async {
                // Extra info: redirect counts
                print(headers.value('redirects'));
                // Extra info: real uri
                print(headers.value('uri'));
                // ...
                print((await getDownloadsDirectory())!.path);
                return (await getDownloadsDirectory())!.path + '/test.svg';
              });
            },
            child: Text("Test")),
        // UpdateDownloader(
        //   downLoadUrl:
        //       "https://www.notion.so/Flutter-0fb10414595342b187b551f040674411?pvs=4#221d0a291add46a3b90cece2ca50fd91",
        //   message: "Message",
        //   isForce: false,
        // ),
      ],
    );
  }
}
