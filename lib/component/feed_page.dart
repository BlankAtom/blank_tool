import 'package:blank_tool/pages/quick_release.dart';
import 'package:blank_tool/pages/settings_page.dart';
import 'package:flutter/cupertino.dart';

import '../pages/main_page.dart';

class FeedPage extends StatefulWidget {
  FeedPage({super.key, required this.pageIndex});

  int pageIndex = 1;

  @override
  State<StatefulWidget> createState() {
    return _FeedPage();
  }
}

class _FeedPage extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.pageIndex == 0) {
      return MainPage();
    } else if (widget.pageIndex == 1) {
      return QuickReleaseNugetPage();
    } else if (widget.pageIndex == 2) {
      return const SettingsPage();
    } else {
      return const Text("123");
    }
  }
}
