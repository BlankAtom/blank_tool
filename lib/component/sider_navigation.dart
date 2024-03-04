import 'dart:developer' as developer;

import 'package:flutter/material.dart';

class SideNavigation extends StatefulWidget {
  // SideNavigation({required this.destinations});
  //
  // List<Widget> destinations;

  SideNavigation({
    super.key,
    required this.selectedIndex,
    this.onDestinationSelected,
  }) {
    expanded = false;
  }

  int selectedIndex;

  late bool expanded;
  final ValueChanged<int>? onDestinationSelected;

  @override
  State<StatefulWidget> createState() {
    return _SideNavigation();
  }
}

class _SideNavigation extends State<SideNavigation> {
  // bool expanded = false;
  late VoidCallback menuChange = widget.expanded == true
      ? () {
          widget.expanded = false;
          developer.log('1');
        }
      : () {
          widget.expanded = true;
          developer.log('2');
        };

  List<NavigationRailDestination> getDestinations() {
    List<NavigationRailDestination> list = <NavigationRailDestination>[
      const NavigationRailDestination(
        icon: Icon(
          Icons.home,
          size: 24,
        ),
        label: Text(""),
      ),
      const NavigationRailDestination(
        icon: Icon(
          Icons.push_pin,
          size: 24,
        ),
        label: Text(""),
      ),
      const NavigationRailDestination(
        icon: Icon(
          Icons.import_contacts_sharp,
          size: 24,
        ),
        label: Text(""),
      ),
    ];

    return list;
  }

  final double minWidth = 72;
  final double minExtendedWidth = 216;
  double _width = 72 * 0.8;

  void toggleExtended() {
    setState(() {
      widget.expanded = !widget.expanded;
      widget.expanded ? _width = minExtendedWidth - 32 : _width = minWidth - 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    var duration = const Duration(seconds: 0, milliseconds: 240);
    return AnimatedContainer(
      duration: duration,
      curve: Curves.fastOutSlowIn,
      child: NavigationRail(
        useIndicator: true,
        minWidth: minWidth,
        minExtendedWidth: minExtendedWidth,
        extended: widget.expanded,
        elevation: 3,
        backgroundColor: Theme.of(context).navigationRailTheme.backgroundColor,
        destinations: getDestinations(),
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onDestinationSelected,
        indicatorShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        trailing: const Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: FlutterLogo(),
            ),
          ),
        ),
        leading: AnimatedContainer(
          duration: duration,
          curve: Curves.fastOutSlowIn,
          width: _width,
          child: TextButton(
            onPressed: toggleExtended,
            child: const Icon(Icons.menu_open),
          ),
        ),
      ),
    );
  }
}
