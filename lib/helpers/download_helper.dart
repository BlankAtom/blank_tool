import 'package:flutter_downloader/flutter_downloader.dart';

class DownloaderHelper {
  static Future<void> testDownload() async {
    await FlutterDownloader.enqueue(
      url:
          "https://www.notion.so/Flutter-0fb10414595342b187b551f040674411?pvs=4#221d0a291add46a3b90cece2ca50fd91",
      headers: {},
      savedDir: '',
      showNotification: true,
      openFileFromNotification: true,
    );
  }
}
