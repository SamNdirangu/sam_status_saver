import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/providers/all.providers.dart';
import 'package:share/share.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/constant.configs.dart';
import 'package:share_whatsapp/share_whatsapp.dart';

class ShareSaveFile {
  String memeType;
  String filePath;

  ShareSaveFile({required this.memeType, required this.filePath});
}

saveDeleteFile({
  List<ShareSaveFile>? files,
  String? filePath,
  required WidgetRef ref,
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
      File(filePath!).copy('${ConstantFolderPaths.savesFolder}/${basename(filePath)}');
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      for (var file in files) {
        File(file.filePath).copy(ConstantFolderPaths.savesFolder);
      }
    }
  }
  ref.read(dataProvider.notifier).refreshData();
}

repostFile({required String filePath}) {
  shareWhatsapp.shareFile(XFile(filePath));
}

shareFiles({List<ShareSaveFile>? files, String? filePath, required bool isImage}) async {
  String memeType = 'video/mp4';
  //String repostTo = 'com.whatsapp';
  if (isImage) memeType = 'image/jpg';

  if (files == null) {
    Share.shareFiles(
      [filePath!],
      mimeTypes: [memeType],
    ).catchError((e) => {});
  } else {
    List<String> filePathList = [];
    List<String> memeTypeList = [];
    for (var file in files) {
      filePathList.add(file.filePath);
      memeTypeList.add(file.memeType);
    }
    Share.shareFiles(filePathList, mimeTypes: memeTypeList).catchError((e) => {});
  }
}
