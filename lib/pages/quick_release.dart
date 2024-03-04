import 'dart:developer' as developer;

import 'package:blank_tool/helpers/logging.dart';
import 'package:blank_tool/models/repo_feature_data.dart';
import 'package:flutter/material.dart';

// Page class
class QuickReleaseNugetPage extends StatefulWidget {
  QuickReleaseNugetPage({super.key});

  RepoScheme? _selectedScheme;

  @override
  State<StatefulWidget> createState() {
    return _QuickReleaseNugetPage();
  }
}

// Page State class
class _QuickReleaseNugetPage extends State<QuickReleaseNugetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Card(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: RepoListBarView(
              maxHeight: 32,
              maxWidth: 64 * 4,
              onRepoSchemeChanged: (value) {
                info("Tap: ${value.name}");
                setState(() {
                  widget._selectedScheme = value;
                });
              },
            ),
          ),
          // VerticalDivider(),
          Expanded(
            child: RepoListDetailView(
              scheme: widget._selectedScheme,
            ),
          ),
        ],
      ),
    );
  }
}

class RepoListDetailView extends StatefulWidget {
  late RepoScheme? scheme;

  ValueChanged<RepoScheme>? onChanged;

  RepoListDetailView({super.key, this.scheme, this.onChanged});

  @override
  State<StatefulWidget> createState() {
    return _RepoListDetailView();
  }
}

class _RepoListDetailView extends State<RepoListDetailView> {
  @override
  Widget build(BuildContext context) {
    return widget.scheme == null
        ? Text('Select a scheme')
        : Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.scheme!.name,
                  textAlign: TextAlign.left,
                ),
              ),
              TextField(),
            ],
          );
  }
}

class RepoListBarView extends StatefulWidget {
  final double buttonWidth = 72;
  final double maxWidth;
  final double maxHeight;
  final bool showSearchTextField = false;

  final ValueChanged<RepoScheme>? onRepoSchemeChanged;

  const RepoListBarView({
    super.key,
    required this.maxWidth,
    required this.maxHeight,
    this.onRepoSchemeChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return _RepoListBarView();
  }
}

class _RepoListBarView extends State<RepoListBarView>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  List<RepoScheme> getRepoSchemes() {
    return <RepoScheme>[
      RepoScheme(name: "BlankAtom"),
      RepoScheme(name: "Flutter"),
      RepoScheme(name: "Github"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var buttonContainer = getButtonContainer();
    var repoSchemes = getRepoSchemes();
    return SizedBox(
      width: widget.maxWidth,
      // height: widget.maxHeight,
      child: Column(
        children: [
          buttonContainer,
          Divider(
            indent: 16,
            endIndent: 16,
            height: 0,
            color: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: repoSchemes.length,
              itemBuilder: (context, index) {
                var repoScheme = repoSchemes[index];
                return ListTile(
                  onTap: () {
                    if (widget.onRepoSchemeChanged != null) {
                      widget.onRepoSchemeChanged!(repoScheme);
                    }
                  },
                  title: Text(repoScheme.name),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget getButtonContainer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          AnimatorButtonToSearch(
            width: widget.buttonWidth,
            height: widget.maxHeight,
            widthTimes: 2,
            onExpended: () {
              setState(() {
                _isExpanded = true;
              });
            },
            onReverse: () {
              setState(() {
                _isExpanded = false;
              });
            },
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => {developer.log('123')},
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
          _isExpanded
              ? const Expanded(child: Text(''))
              : ElevatedButton(
                  onPressed: () => {developer.log('123')},
                  child: const Icon(Icons.edit),
                ),
        ],
      ),
    );
  }
}

class AnimatorButtonToSearch extends StatefulWidget {
  final double width;
  final double height;
  final double widthTimes;
  final VoidCallback? onReverse;
  final VoidCallback? onExpended;
  final Color? searchFilledColor;

  const AnimatorButtonToSearch({
    super.key,
    required this.width,
    required this.height,
    required this.widthTimes,
    this.onExpended,
    this.onReverse,
    this.searchFilledColor,
  });

  @override
  State<StatefulWidget> createState() {
    return _AnimatorButtonToSearch();
  }
}

class _AnimatorButtonToSearch extends State<AnimatorButtonToSearch>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {});
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300, seconds: 0),
    );
    _widthAnimation = Tween<double>(
      begin: widget.width,
      end: widget.width * widget.widthTimes,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.decelerate,
      ),
    );

    _animationController.addStatusListener((status) {
      // developer.log(status.toString());
      if (status == AnimationStatus.dismissed) {
        if (widget.onReverse != null) {
          widget.onReverse!();
        }
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void toggleSearchButton() {
    if (_isExpanded) {
      _animationController.reverse();
      setState(() {
        _isExpanded = false;
      });
    } else {
      setState(() {
        _isExpanded = true;
      });
      _animationController.forward();
      if (widget.onExpended != null) {
        widget.onExpended!();
      }
    }

    // FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _widthAnimation,
        builder: (animatorContext, child) {
          return SizedBox(
            width: _widthAnimation.value,
            height: widget.height,
            child: _isExpanded
                ? TextField(
                    autofocus: true,
                    focusNode: _focusNode,
                    onTapOutside: (value) {
                      toggleSearchButton();
                    },
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).indicatorColor,
                      // labelText: "Search",
                      hintText: "Hint Text",
                      hintFadeDuration: const Duration(milliseconds: 300),
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(24.0),
                        ),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: toggleSearchButton,
                    child: const Icon(Icons.search),
                  ),
          );
        });
  }
}
