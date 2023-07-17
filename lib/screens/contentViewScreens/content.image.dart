import 'dart:io';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:sam_status_saver/widgets/widget.actions.dart';

class ImageContentView extends StatefulWidget {
  final int currentIndex;
  final bool isSavedFiles;
  final List<String> imagePaths;
  const ImageContentView({Key? key, required this.currentIndex, required this.imagePaths, required this.isSavedFiles})
      : super(key: key);

  @override
  ImageContentViewState createState() => ImageContentViewState();
}

class ImageContentViewState extends State<ImageContentView> with TickerProviderStateMixin {
  //
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final snackBar = const SnackBar(
    content: Text('Pic saved!'),
    duration: Duration(seconds: 1),
  );

  late ExtendedPageController _pageController;
  String filePath = '';
  bool hideFab = false; //Hide the fab button
  double _fabOpacity = 1.0; // Control Opacity animation

  @override
  void initState() {
    super.initState();
    _pageController = ExtendedPageController(initialPage: widget.currentIndex, keepPage: true);
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
        body: ExtendedImageGesturePageView.builder(
            controller: _pageController,
            onPageChanged: (page) => listener(page),
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index) {
              Widget image = GestureDetector(
                onTap: _togglehideFab,
                child: Center(
                  child: ExtendedImage.file(
                    File(widget.imagePaths[index]),
                    mode: ExtendedImageMode.gesture,
                  ),
                ),
              );
              if (index == widget.currentIndex) {
                return Hero(
                  tag: widget.imagePaths[index],
                  child: image,
                );
              } else {
                return image;
              }
            }),
        floatingActionButton: AnimatedOpacity(
            opacity: _fabOpacity,
            duration: const Duration(milliseconds: 300),
            child: FunctionButtons(
                snackBar: snackBar, isImage: true, filePath: filePath, isSavedFiles: widget.isSavedFiles)));
  }
}
