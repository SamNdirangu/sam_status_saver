import 'dart:io';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sam_status_saver/assets/customColor.dart';
import 'package:sam_status_saver/constants/paths.dart';
import 'package:unicorndial/unicorndial.dart';

class AppActions {
  saveFile(String filePath, bool isImage) {
    String fileName = new DateTime.now().toString();
    if (isImage) {
      File(filePath).copy(appDirectoryImagePath + '/' + fileName + '.jpg');
    } else {
      File(filePath).copy(appDirectoryVideoPath + '/' + fileName + '.mp4');
    }
  }

  shareFile(String filePath, bool repost, bool isImage) async {
    String memeType = 'video/mp4';
    String repostTo = 'com.whatsapp';

    if (isImage) memeType = 'image/jpg';
    if (!repost) repostTo = '';
    try {
      final fileBytes = File(filePath).readAsBytesSync();
      await Share.shareFile(fileBytes, basename(filePath), memeType,
          shareTitle: 'Share with',
          appToShare: repostTo,
          captionText:
              "Shared via Sam's Status Saver get it here \n\nhttps://github.com/SamNdirangu/SamNdirangu.github.io/blob/master/assets/SamsStatusSaver-v1.0.5.apk");
    } catch (e) {
      print('error: $e');
    }
  }
}

class FunctionButtons extends StatelessWidget {
  const FunctionButtons({
    Key key,
    @required GlobalKey<ScaffoldState> scaffoldKey,
    @required this.snackBar,
    @required this.filePath,
    @required this.isImage,
  })  : _scaffoldKey = scaffoldKey,
        super(key: key);

  final bool isImage;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final SnackBar snackBar;
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return UnicornDialer(
      animationDuration: 200,
      parentHeroTag: 'mainFab',
      hasBackground: false,
      hasNotch: false,
      parentButtonBackground: colorCustom,
      parentButton: Icon(
        Icons.add,
        color: Colors.white,
      ),
      childButtons: [
        UnicornButton(
          hasLabel: false,
          currentButton: FloatingActionButton(
            backgroundColor: colorCustom,
            heroTag: 'saveFab',
            onPressed: () {
              AppActions().saveFile(filePath, isImage);
              _scaffoldKey.currentState.showSnackBar(snackBar);
            },
            tooltip: 'Save',
            mini: true,
            child: Icon(
              Icons.save,
              color: Colors.white,
            ),
          ),
        ),
        UnicornButton(
          hasLabel: false,
          currentButton: FloatingActionButton(
            backgroundColor: colorCustom,
            heroTag: 'repostFab',
            onPressed: () {
              AppActions().shareFile(filePath, true, isImage);
            },
            tooltip: 'repost',
            mini: true,
            child: Icon(
              Icons.reply,
              color: Colors.white,
            ),
          ),
        ),
        UnicornButton(
          hasLabel: false,
          currentButton: FloatingActionButton(
            backgroundColor: colorCustom,
            heroTag: 'shareFab',
            onPressed: () {
              AppActions().shareFile(filePath, false, isImage);
            },
            tooltip: 'Share',
            mini: true,
            child: Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
