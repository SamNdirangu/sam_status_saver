import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gesture_zoom_box/gesture_zoom_box.dart';
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

  PageController _pageController;
  String filePath = '';
  bool hideFab = false; //Hide the fab button
  double _fabOpacity = 1.0; // Control Opacity animation

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.currentIndex, keepPage: true);
    filePath = widget.imagePaths[widget.currentIndex];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _togglehideFab() {
    setState(() {
      _fabOpacity = 1.0 - _fabOpacity;
    });
  }

  listener(page) {
    setState(() {
      filePath = widget.imagePaths[page];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: _pageController,
          onPageChanged: (page) => listener(page),
          dragStartBehavior: DragStartBehavior.start,
          itemCount: widget.imagePaths.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: _togglehideFab,
              child: Center(
                  child: GestureZoomBox(
                      child: Image.file(File(widget.imagePaths[index])))),
            );
          },
        ),
        floatingActionButton: AnimatedOpacity(
            opacity: _fabOpacity,
            duration: const Duration(milliseconds: 300),
            child: FunctionButtons(
              scaffoldKey: _scaffoldKey,
              snackBar: snackBar,
              isImage: true,
              filePath: filePath,
            )));
  }
}
