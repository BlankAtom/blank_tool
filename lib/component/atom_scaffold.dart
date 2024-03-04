import 'package:blank_tool/component/sider_navigation.dart';
import 'package:flutter/material.dart';

import '../pages/main_page.dart';
import '../pages/quick_release.dart';
import '../pages/settings_page.dart';

class AtomScaffold extends StatefulWidget {
  int pageSelected = 1;

  AtomScaffold({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AtomScaffold();
  }
}

class _AtomScaffold extends State<AtomScaffold> {
  @override
  Widget build(BuildContext context) {
    var page = getPage(widget.pageSelected);
    return Scaffold(
      body: Row(
        children: [
          SideNavigation(
            selectedIndex: widget.pageSelected,
            onDestinationSelected: (index) => setState(() {
              widget.pageSelected = index;
            }),
          ),
          Expanded(child: page),
        ],
      ),
    );
  }

  Widget getPage(int pageIndex) {
    if (pageIndex == 0) {
      return MainPage();
    } else if (pageIndex == 1) {
      return QuickReleaseNugetPage();
    } else if (pageIndex == 2) {
      return SettingsPage();
    } else {
      return Text("123");
    }
  }
}
