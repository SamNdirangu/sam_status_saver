import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/screens/contentViewScreens/videoContent.dart';
import 'package:sam_status_saver/widgets/permRequester.dart';

class StatusVideos extends StatelessWidget {
  final List<String> videoPaths;
  final List<String> thumbnailPaths;
  final VideosCallBack getVideosCallBack;
  final bool scanningDone;
  final bool readEnabled;

  const StatusVideos(
      {Key key,
      @required this.videoPaths,
      @required this.thumbnailPaths,
      @required this.scanningDone,
      @required this.readEnabled,
      @required this.getVideosCallBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (readEnabled) {
      if (!scanningDone) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 30,
              ),
              Text('Loading... Building video cache for first time',
                  textScaleFactor: 1.2, style: TextStyle(color: Colors.white)),
            ]);
      }
      if (thumbnailPaths.isEmpty) {
        return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.sentiment_satisfied,
                  size: 56,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  'Hey it seems you dont have any status videos yet.\n\n Once you view a few come back and see them here',
                  style: TextStyle(color: Colors.white),
                ),
              ]),
        );
      }
      return RefreshIndicator(
          onRefresh: getVideosCallBack,
          child: GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: thumbnailPaths.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(1.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VideoContentView(
                            videoPaths: videoPaths, currentIndex: index)));
                  },
                  child: Hero(
                    tag: index.toString(),
                    child: Image.file(
                      File(thumbnailPaths[index]),
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

typedef VideosCallBack = Future<void> Function();
