import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/screens/contentViewScreens/widgetActions.dart';

class ImageContentView extends StatefulWidget {
  final currentIndex;
  final List<String> imagePaths;
  const ImageContentView(
      {Key key, @required this.currentIndex, this.imagePaths})
      : super(key: key);

  @override
  _ImageContentViewState createState() => _ImageContentViewState();
}

class _ImageContentViewState extends State<ImageContentView>
    with TickerProviderStateMixin {
  //
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final snackBar = SnackBar(
    content: Text('Pic saved!'),
    duration: Duration(seconds: 1),
  );

  TabController tabController;
  List<Widget> imageTabs = List();
  bool hideFab = false; //Hide the fab button
  double _fabOpacity = 1.0; // Control Opacity animation

  @override
  void initState() {
    super.initState();
    renderListTabs();
    tabController = TabController(
      vsync: this,
      length: widget.imagePaths.length,
      initialIndex: widget.currentIndex
    );

    tabController.addListener(listener);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  _togglehideFab() {
    setState(() {
      _fabOpacity = 1.0 - _fabOpacity;
    });
  }

  List<Widget> renderListTabs() {
    if (imageTabs.length != widget.imagePaths.length) {
      for (var path in widget.imagePaths) {
        imageTabs.add(
          renderImageTab(path),
        );
      }
    }
    return imageTabs;
  }

  Widget renderImageTab(path) {
    return GestureDetector(
        onTap: _togglehideFab,
        child: Center(
          child: Image.file(File(path)),
        ));
  }

  listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        body: Hero(
            tag: widget.imagePaths[tabController.index],
            child: TabBarView(
              controller: tabController,
              children: imageTabs,
              dragStartBehavior: DragStartBehavior.down,
            )),
        floatingActionButton: AnimatedOpacity(
            opacity: _fabOpacity,
            duration: Duration(milliseconds: 300),
            child: FunctionButtons(
              scaffoldKey: _scaffoldKey,
              snackBar: snackBar,
              isImage: true,
              filePath: widget.imagePaths[tabController.index],
            )));
  }
}
