import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/constants/configs.dart';
import 'package:path/path.dart';
import 'package:share/share.dart';

class ShareSaveFile {
  String memeType;
  String filePath;

  ShareSaveFile({required this.memeType, required this.filePath});
}

saveFile({List<ShareSaveFile>? files, String? filePath, required BuildContext context, required SnackBar snackBar}) {
  if (files == null) {
    File(filePath!).copy(FolderPaths.savesFolder + '/' + basename(filePath));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else {
    for (var file in files) {
      File(file.filePath).copy(FolderPaths.savesFolder);
    }
  }
}

shareFiles({List<ShareSaveFile>? files, String? filePath, bool? repost, required bool isImage}) async {
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
