import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/constant.configs.dart';
import 'package:sam_status_saver/functions/error.catcher.data.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

//Our video model
class VideoFile {
  late String thumbnailName;
  late String thumbnailPath;
  late String videoPath;
  VideoFile({required this.thumbnailName, required this.thumbnailPath, required this.videoPath});

  VideoFile.fromJson(Map<String, dynamic> json) {
    videoPath = json['videoPath'];
    thumbnailPath = json['thumbnailPath'];
    thumbnailName = json['thumbnailName'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['videoPath'] = videoPath;
    data['thumbnailPath'] = thumbnailPath;
    data['thumbnailName'] = thumbnailName;
    return data;
  }
}

//Our data provider model
@immutable
class DataStatus {
  //Status Params
  final String? errorMsg;
  final bool isLoading;
  //Settings Params
  final bool newSource;
  final String sourcePath;
  final bool isBusinessMode;
  final bool isWhatsAppInstalled;
  final bool whatsAppStandardReady;
  final bool whatsAppBusinessReady;
  //Data Params
  final List<String> images;
  final String? videos;
  final List<VideoFile> trackerVideos;
  final List<String> savedImages;
  final String? savedVideos;
  final List<VideoFile> trackerSavedVideos;

  const DataStatus({
    this.errorMsg,
    this.isLoading = true,
    this.images = const [],
    this.videos,
    this.savedImages = const [],
    this.savedVideos,
    this.newSource = false,
    this.isBusinessMode = false,
    this.isWhatsAppInstalled = false,
    this.whatsAppBusinessReady = false,
    this.whatsAppStandardReady = false,
    this.sourcePath = ConstantFolderPaths.standardStatuses,
    this.trackerVideos = const [],
    this.trackerSavedVideos = const [],
  });

  DataStatus copyWith({
    String? errorMsg,
    bool? isLoading,
    bool? newSource,
    String? sourcePath,
    bool? isBusinessMode,
    bool? isWhatsAppInstalled,
    bool? whatsAppStandardReady,
    bool? whatsAppBusinessReady,
    List<String>? images,
    String? videos,
    List<VideoFile>? trackerVideos,
    List<String>? savedImages,
    String? savedVideos,
    List<VideoFile>? trackerSavedVideos,
  }) {
    return DataStatus(
        errorMsg: errorMsg ?? this.errorMsg,
        isLoading: isLoading ?? this.isLoading,
        newSource: newSource ?? this.newSource,
        sourcePath: sourcePath ?? this.sourcePath,
        isBusinessMode: isBusinessMode ?? this.isBusinessMode,
        isWhatsAppInstalled: isWhatsAppInstalled ?? this.isWhatsAppInstalled,
        whatsAppBusinessReady: whatsAppBusinessReady ?? this.whatsAppBusinessReady,
        whatsAppStandardReady: whatsAppStandardReady ?? this.whatsAppStandardReady,
        images: images ?? this.images,
        videos: videos ?? this.videos,
        trackerVideos: trackerSavedVideos ?? this.trackerVideos,
        savedImages: savedImages ?? this.savedImages,
        savedVideos: savedVideos ?? this.savedVideos,
        trackerSavedVideos: trackerSavedVideos ?? this.trackerSavedVideos);
  }
}

class DataProvider extends StateNotifier<DataStatus> {
  List<VideoFile> trackerVideos = [];
  List<VideoFile> trackerSavedVideos = [];
  DataProvider() : super(const DataStatus()) {
    Future(() => _loadData());
  }

  void _loadData() {
    //This function will set up required directories and also identify various options available
    bootupAngie();
  }

  //---------------------------------------------------------------------------------------------------
  void bootupAngie() {
    //Create our App directory if not exists
    if (!Directory(ConstantFolderPaths.savesFolder).existsSync()) {
      Directory(ConstantFolderPaths.savesFolder).createSync();
    }
    //Create our temp directory if not exists
    if (!Directory(ConstantFolderPaths.tempFolder).existsSync()) Directory(ConstantFolderPaths.tempFolder).createSync();
    //Check if there are business status
    if (Directory(ConstantFolderPaths.businessStatuses).existsSync()) {
      state = state.copyWith(
          isBusinessMode: true,
          isWhatsAppInstalled: true,
          whatsAppBusinessReady: true,
          sourcePath: ConstantFolderPaths.businessStatuses);
    } else if (Directory(ConstantFolderPaths.standardStatuses).existsSync()) {
      //Start our app in standard mode
      state = state.copyWith(
        isBusinessMode: false,
        isWhatsAppInstalled: true,
        whatsAppStandardReady: true,
        sourcePath: ConstantFolderPaths.standardStatuses,
      );
    }
    refreshData();
  }

  //------------------------------------------------------------------------
  Future<void> refreshData() async {
    //Error handling
    final errorData = dataErrorCatcher(state);
    if (errorData.isError) {
      state = state.copyWith(isLoading: false, errorMsg: errorData.errorMsg);
      return;
    }
    //Get our data
    List<FileSystemEntity> statusFiles;
    List<FileSystemEntity> savedFiles;
    List<FileSystemEntity> temporaryFiles;
    try {
      statusFiles = Directory(state.sourcePath).listSync();
      statusFiles.removeWhere((element) => element is Directory);

      savedFiles = Directory(ConstantFolderPaths.savesFolder).listSync();
      savedFiles.removeWhere((element) => element is Directory);

      temporaryFiles = Directory(ConstantFolderPaths.tempFolder).listSync();
      temporaryFiles.removeWhere((element) => element is Directory);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMsg: e.toString());
      return;
    }

    //Generate our images and videos
    await _statusFilesGen(statusFiles, temporaryFiles);
    await _savedFilesListGen(savedFiles, temporaryFiles);
    _garbageCollector(temporaryFiles);
    return;
  }

  //////////////////////////////////////////////////////////////////////////
  Future<void> _statusFilesGen(List<FileSystemEntity> statusFiles, List<FileSystemEntity> temporaryFiles) async {
    //Decalare our local variables
    List<String> statusImages = [];
    List<VideoFile> statusVideos = [];

    //int refreshCount = 0;
    //Sort newest to old files.
    statusFiles.sort(
        (a, b) => File(b.path).lastModifiedSync().toString().compareTo(File(a.path).lastModifiedSync().toString()));

    for (var file in statusFiles) {
      final String fileName = basename(file.path);
      final String fileNameNoExt = basenameWithoutExtension(file.path);
      //
      if (fileName.contains('.jpg')) {
        //an image file add it to our list
        statusImages.add(file.path);
        //
      } else if (fileName.contains('.mp4')) {
        //A video
        bool isThumbnail = false;
        for (var tempFile in temporaryFiles) {
          //loop through to find thumbnail
          final String tempFileNameNoExt = basenameWithoutExtension(tempFile.path);
          //

          if (fileNameNoExt == tempFileNameNoExt) {
            //foundone
            statusVideos.add(VideoFile(
              videoPath: file.path,
              thumbnailPath: tempFile.path,
              thumbnailName: tempFileNameNoExt + Configs.thumbnailExt,
            ));
            isThumbnail = true;
            break;
          }
        }
        if (!isThumbnail) {
          //create one
          final tempFilePath = '${ConstantFolderPaths.tempFolder}/$fileNameNoExt${Configs.thumbnailExt}';
          await VideoThumbnail.thumbnailFile(
            video: file.path,
            quality: 1,
            imageFormat: ImageFormat.WEBP,
            thumbnailPath: tempFilePath,
          );
          statusVideos.add(VideoFile(
            videoPath: file.path,
            thumbnailPath: tempFilePath,
            thumbnailName: fileNameNoExt + Configs.thumbnailExt,
          ));
        }
      }
    }
    trackerVideos = statusVideos;
    state = state.copyWith(
      isLoading: false,
      images: statusImages,
      videos: jsonEncode(statusVideos),
      trackerVideos: statusVideos,
    );
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> _savedFilesListGen(List<FileSystemEntity> savedFiles, List<FileSystemEntity> temporaryFiles) async {
    List<String> savedStatusImages = [];
    List<VideoFile> savedStatusVideos = [];
    //Sort newest to old files.
    savedFiles.sort(
        (a, b) => File(b.path).lastModifiedSync().toString().compareTo(File(a.path).lastModifiedSync().toString()));
    //Start our matching
    for (var file in savedFiles) {
      final String fileName = basename(file.path);
      final String fileNameNoExt = basenameWithoutExtension(file.path);
      //
      if (fileName.contains('.jpg')) {
        //an image file add it to our list
        savedStatusImages.add(file.path);
        //
      } else if (fileName.contains('.mp4')) {
        //A video
        bool isThumbnail = false;
        for (var tempFile in temporaryFiles) {
          //loop through to find thumbnail
          final String tempFileName = basenameWithoutExtension(tempFile.path);
          //
          if ((fileNameNoExt + Configs.savedExt) == tempFileName) {
            //foundone
            savedStatusVideos.add(VideoFile(
              thumbnailName: tempFileName,
              videoPath: file.path,
              thumbnailPath: tempFile.path,
            ));
            isThumbnail = true;
            break;
          }
        }
        if (!isThumbnail) {
          //If no thumbnail found create one
          final tempFilePath =
              '${ConstantFolderPaths.tempFolder}/$fileNameNoExt${Configs.savedExt}${Configs.thumbnailExt}';
          //
          await VideoThumbnail.thumbnailFile(
            video: file.path,
            quality: 1,
            imageFormat: ImageFormat.WEBP,
            thumbnailPath: tempFilePath,
          );
          savedStatusVideos.add(VideoFile(
            thumbnailName: fileNameNoExt + Configs.savedExt,
            videoPath: file.path,
            thumbnailPath: tempFilePath,
          ));
        }
      }
    }
    trackerSavedVideos = savedStatusVideos;
    state = state.copyWith(
      savedImages: savedStatusImages,
      savedVideos: jsonEncode(savedStatusVideos),
      trackerSavedVideos: savedStatusVideos,
    );
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  void _garbageCollector(List<FileSystemEntity> temporaryFiles) {
    //Go through each of our temporary files deleting trash
   // developer.log("Garbage Collector Started");

    //Sort newest to old files.
    List<VideoFile> statusThumbnails = trackerVideos;
    List<VideoFile> savedThumbnails = trackerSavedVideos;
    for (var file in temporaryFiles) {
      final String fileName = basename(file.path);
      //
      bool deleteFile = true;
      //Loop through video thumbnails of statuses

      String? statusThumbnailName;
      for (var status in statusThumbnails) {
        if (status.thumbnailName == fileName) {
          deleteFile = false;
          statusThumbnailName = status.thumbnailName;
          break;
        }
      }
      //Delete already matched thumbnailes to reduce our loop.
      if (statusThumbnailName != null) {
        statusThumbnails.removeWhere((element) => statusThumbnailName == element.thumbnailName);
      }

      //loop through savedfiles
      String? savedThumbnailName;
      for (var saved in savedThumbnails) {
        final thumbName = basename(saved.thumbnailPath);
        if (thumbName == fileName) {
          deleteFile = false;
          savedThumbnailName = thumbName;
          break;
        }
      }
      //Delete already matched thumbnailes to reduce our loop.
      if (savedThumbnailName != null) {
        savedThumbnails.removeWhere((element) => savedThumbnailName == basename(element.thumbnailPath));
      }

      if (deleteFile) {
        //developer.log('Deleted:: Filename $fileName deleted');
        file.delete();
      }
    }
  }

  /////////////////////////////////////////////////////////////////////////
  //App mode toggle
  //Called when toggling status mode
  void toggleStatusMode() {
    state = state.copyWith(
      isBusinessMode: !state.isBusinessMode,
      sourcePath: state.isBusinessMode ? ConstantFolderPaths.businessStatuses : ConstantFolderPaths.standardStatuses,
    );
    refreshData();
  }
}
