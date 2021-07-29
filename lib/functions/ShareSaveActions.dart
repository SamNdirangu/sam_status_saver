import 'dart:io';
import 'package:path/path.dart';
import 'package:sam_status_saver/providers/appProviders.dart';
import 'package:sams_flutter_share/sams_flutter_share.dart';
import 'package:share/share.dart';
import 'package:flutter/material.dart';

import 'package:sam_status_saver/constants/configs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ShareSaveFile {
  String memeType;
  String filePath;

  ShareSaveFile({required this.memeType, required this.filePath});
}

saveDeleteFile({
  List<ShareSaveFile>? files,
  String? filePath,
  required BuildContext context,
  required SnackBar snackBar,
  required bool isSavedFiles,
}) {
  if (isSavedFiles) {
    //delete file
    File(filePath!).delete().then((value) {
      Navigator.of(context).pop();
    }).catchError((e) {
      //do nothing;
    });
  } else {
    if (files == null) {
      File(filePath!).copy(FolderPaths.savesFolder + '/' + basename(filePath));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      for (var file in files) {
        File(file.filePath).copy(FolderPaths.savesFolder);
      }
    }
  }
  context.read(dataProvider).refreshData();
}

repostFile({required String filePath}) {
  final fileBytes = File(filePath).readAsBytesSync();
  SamsFlutterShare.shareFile(fileBytes, basename(filePath), '*/*', shareTitle: 'Share with', appToShare: 'com.whatsapp')
      .catchError((e) {
    print(e);
  });
}

shareFiles({List<ShareSaveFile>? files, String? filePath, required bool isImage}) async {
  String memeType = 'video/mp4';
  //String repostTo = 'com.whatsapp';
  if (isImage) memeType = 'image/jpg';

  if (files == null)
    Share.shareFiles(
      [filePath!],
      mimeTypes: [memeType],
    ).catchError((e) => {});
  else {
    List<String> _filePathList = [];
    List<String> _memeTypeList = [];
    for (var file in files) {
      _filePathList.add(file.filePath);
      _memeTypeList.add(file.memeType);
    }
    Share.shareFiles(_filePathList, mimeTypes: _memeTypeList).catchError((e) => {});
  }
}
