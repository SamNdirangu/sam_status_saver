import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/screens/contentViewScreens/Imagecontent.dart';
import 'package:sam_status_saver/widgets/permRequester.dart';

class StatusImages extends StatelessWidget {
  final List<String> imagePaths;
  final ImagesCallBack getImages;
  final bool scanningDone;
  final bool readEnabled;

  const StatusImages(
      {Key key,
      @required this.imagePaths,
      @required this.scanningDone,
      @required this.readEnabled,
      this.getImages})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (readEnabled) {
      if (!scanningDone) {
        return Center(child: CircularProgressIndicator());
      }
      return RefreshIndicator(
          onRefresh: getImages,
          child: GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: imagePaths.length,
            itemBuilder: (BuildContext context, int index) {

              return Padding(
                padding: const EdgeInsets.all(1.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ImageContentView(
                            imagePaths: imagePaths, currentIndex: index)));
                  },
                  child: Hero(
                    tag: index.toString(),
                    child: Image.file(
                      File(imagePaths[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ));
    } else {
      return PermRequester();
    }
  }
}

typedef ImagesCallBack = Future<void> Function();
