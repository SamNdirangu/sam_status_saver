import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/constants/configs.dart';
import 'package:sam_status_saver/functions/dataErrorCatcher.dart';
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['videoPath'] = this.videoPath;
    data['thumbnailPath'] = this.thumbnailPath;
    data['thumbnailName'] = this.thumbnailName;
    return data;
  }
}

//Our data provider model
class DataStatus {
  //Status Params
  String? errorMsg;
  bool isLoading;
  //Settings Params
  bool newSource;
  String sourcePath = FolderPaths.standardStatuses;
  bool isBusinessMode;
  bool isWhatsAppInstalled;
  bool whatsAppStandardReady;
  bool whatsAppBusinessReady;
  //Data Params
  List<String>? images;
  String? videos;
  List<VideoFile>? trackerVideos;
  List<String>? savedImages;
  String? savedVideos;
  List<VideoFile>? trackerSavedVideos;

  DataStatus({
    this.errorMsg,
    this.isLoading = true,
    this.images,
    this.videos,
    this.savedImages,
    this.savedVideos,
    this.newSource = false,
    this.isBusinessMode = false,
    this.isWhatsAppInstalled = false,
    this.whatsAppBusinessReady = false,
    this.whatsAppStandardReady = false,
  });
}

class DataProvider with ChangeNotifier {
  //Declare our getters and globals
  DataStatus dataStatus;
  DataProvider({required this.dataStatus});

  //////////////////////////////////////////////////////////////////////////
  void loadData() {
    //This function will set up required directories and also identify various options available
    bootupAngie();
    refreshData();
  }

  /////////////////////////////////////////////////////////////////////////
  void bootupAngie() {
    //Create our App directory if not exists
    if (!Directory(FolderPaths.savesFolder).existsSync()) Directory(FolderPaths.savesFolder).createSync();
    //Create our temp directory if not exists
    if (!Directory(FolderPaths.tempFolder).existsSync()) Directory(FolderPaths.tempFolder).createSync();
    //Check if there are business status
    if (Directory(FolderPaths.businessStatuses).existsSync()) {
      dataStatus.isBusinessMode = true;
      dataStatus.isWhatsAppInstalled = true;
      dataStatus.whatsAppBusinessReady = true;
      dataStatus.sourcePath = FolderPaths.businessStatuses;
    } else if (Directory(FolderPaths.businessStatusesFB).existsSync()) {
      dataStatus.newSource = true;
      dataStatus.isBusinessMode = true;
      dataStatus.isWhatsAppInstalled = true;
      dataStatus.whatsAppBusinessReady = true;
      dataStatus.sourcePath = FolderPaths.businessStatusesFB;
    }
    if (Directory(FolderPaths.standardStatuses).existsSync()) {
      //Start our app in standard mode
      dataStatus.isBusinessMode = false;
      dataStatus.isWhatsAppInstalled = true;
      dataStatus.whatsAppStandardReady = true;
      dataStatus.sourcePath = FolderPaths.standardStatuses;
    } else if (Directory(FolderPaths.standardStatusesFB).existsSync()) {
      //Start our app in standard mode
      dataStatus.newSource = true;
      dataStatus.isBusinessMode = false;
      dataStatus.isWhatsAppInstalled = true;
      dataStatus.whatsAppStandardReady = true;
      dataStatus.sourcePath = FolderPaths.standardStatusesFB;
    }
    return;
  }

  ///
  Future<void> refreshData() async {
    //  print(dataStatus.videos!.length.toString());
    //Error handling
    final errorData = dataErrorCatcher(dataStatus);
    if (errorData.isError) {
      dataStatus.isLoading = false;
      dataStatus.errorMsg = errorData.errorMsg;
      //Notify our listeners
      notifyListeners();
      return;
    }
    //Get our data
    List<FileSystemEntity> statusFiles;
    List<FileSystemEntity> savedFiles;
    List<FileSystemEntity> temporaryFiles;
    try {
      statusFiles = Directory(dataStatus.sourcePath).listSync();
      statusFiles.removeWhere((element) => element is Directory);

      savedFiles = Directory(FolderPaths.savesFolder).listSync();
      savedFiles.removeWhere((element) => element is Directory);

      temporaryFiles = Directory(FolderPaths.tempFolder).listSync();
      temporaryFiles.removeWhere((element) => element is Directory);
    } catch (e) {
      dataStatus.isLoading = false;
      dataStatus.errorMsg = e.toString();
      //Notify listeners
      notifyListeners();
      return;
    }

    //Generate our images and videos
    _statusFilesGen(statusFiles, temporaryFiles).then((value) {
      //Get our savedFiles then Delete unused thumbnails
      _savedFilesListGen(savedFiles, temporaryFiles).then((value) => _garbageCollector(temporaryFiles));
    });

    return;
  }

  //////////////////////////////////////////////////////////////////////////
  Future<void> _statusFilesGen(List<FileSystemEntity> statusFiles, List<FileSystemEntity> temporaryFiles) async {
    //Decalare our local variables
    List<String> _statusImages = [];
    List<VideoFile> _statusVideos = [];

    int _refreshCount = 0;
    //Sort newest to old files.
    statusFiles.sort(
        (a, b) => File(b.path).lastModifiedSync().toString().compareTo(File(a.path).lastModifiedSync().toString()));

    for (var file in statusFiles) {
      final String _fileName = basename(file.path);
      final String _fileNameNoExt = basenameWithoutExtension(file.path);
      //
      if (_fileName.contains('.jpg')) {
        //an image file add it to our list
        _statusImages.add(file.path);
        //
      } else if (_fileName.contains('.mp4')) {
        //A video
        bool isThumbnail = false;
        for (var tempFile in temporaryFiles) {
          //loop through to find thumbnail
          final String _tempFileNameNoExt = basenameWithoutExtension(tempFile.path);
          //
          if (_fileName.contains(_tempFileNameNoExt)) {
            //foundone
            _statusVideos.add(VideoFile(
              videoPath: file.path,
              thumbnailPath: tempFile.path,
              thumbnailName: _tempFileNameNoExt + Configs.thumbnailExt,
            ));
            isThumbnail = true;
            break;
          }
        }
        if (!isThumbnail) {
          //create one
          final _tempFilePath = FolderPaths.tempFolder + '/' + _fileNameNoExt + Configs.thumbnailExt;
          await VideoThumbnail.thumbnailFile(
            video: file.path,
            quality: 1,
            imageFormat: ImageFormat.WEBP,
            thumbnailPath: _tempFilePath,
          );
          _statusVideos.add(VideoFile(
            videoPath: file.path,
            thumbnailPath: _tempFilePath,
            thumbnailName: _fileNameNoExt + Configs.thumbnailExt,
          ));
          _refreshCount++;
          if (_refreshCount > Configs.refreshLimit) {
            _refreshCount = 0;
            dataStatus.isLoading = false;
            dataStatus.images = _statusImages;
            dataStatus.videos = jsonEncode(_statusVideos);
            notifyListeners();
          }
        }
      }
    }
    dataStatus.isLoading = false;
    dataStatus.images = _statusImages;
    dataStatus.videos = jsonEncode(_statusVideos);
    dataStatus.trackerVideos = _statusVideos;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> _savedFilesListGen(List<FileSystemEntity> savedFiles, List<FileSystemEntity> temporaryFiles) async {
    List<String> _savedStatusImages = [];
    List<VideoFile> _savedStatusVideos = [];
    //Sort newest to old files.
    savedFiles.sort(
        (a, b) => File(b.path).lastModifiedSync().toString().compareTo(File(a.path).lastModifiedSync().toString()));
    //Start our matching
    for (var file in savedFiles) {
      final String _fileName = basename(file.path);
      final String _fileNameNoExt = basenameWithoutExtension(file.path);
      //
      if (_fileName.contains('.jpg')) {
        //an image file add it to our list
        _savedStatusImages.add(file.path);
        //
        //
      } else if (_fileName.contains('.mp4')) {
        //A video
        bool isThumbnail = false;
        for (var tempFile in temporaryFiles) {
          //loop through to find thumbnail
          final String _tempFileName = basenameWithoutExtension(tempFile.path);
          //
          if ((_fileNameNoExt + Configs.savedExt) == _tempFileName) {
            //foundone
            _savedStatusVideos.add(VideoFile(
              thumbnailName: _tempFileName,
              videoPath: file.path,
              thumbnailPath: tempFile.path,
            ));
            isThumbnail = true;
            break;
          }
        }
        if (!isThumbnail) {
          //If no thumbnail found create one
          final _tempFilePath = FolderPaths.tempFolder + '/' + _fileNameNoExt + Configs.savedExt + Configs.thumbnailExt;
          //
          await VideoThumbnail.thumbnailFile(
            video: file.path,
            quality: 1,
            imageFormat: ImageFormat.WEBP,
            thumbnailPath: _tempFilePath,
          );
          _savedStatusVideos.add(VideoFile(
            thumbnailName: _fileNameNoExt + Configs.savedExt,
            videoPath: file.path,
            thumbnailPath: _tempFilePath,
          ));
        }
      }
    }
    dataStatus.savedImages = _savedStatusImages;
    dataStatus.savedVideos = jsonEncode(_savedStatusVideos);
    dataStatus.trackerSavedVideos = _savedStatusVideos;
    notifyListeners();
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  void _garbageCollector(List<FileSystemEntity> temporaryFiles) {
    //Go through each of our temporary files deleting trash
    //Sort newest to old files.
    List<VideoFile>? statusThumbnails = dataStatus.trackerVideos;
    List<VideoFile>? savedThumbnails = dataStatus.trackerSavedVideos;
    for (var file in temporaryFiles) {
      final String _fileName = basename(file.path);
      //
      bool deleteFile = true;
      //Loop through video thumbnails of statuses
      var statusThumbnailName;
      for (var status in statusThumbnails!) {
        if (status.thumbnailName == _fileName) {
          deleteFile = false;
          statusThumbnailName = status.thumbnailName;
          break;
        }
      }
      //Delete already matched thumbnailes to reduce our loop.
      if (statusThumbnailName != null)
        statusThumbnails.removeWhere((element) => statusThumbnailName == element.thumbnailName);

      //loop through savedfiles
      var savedThumbnailName;
      for (var saved in savedThumbnails!) {
        final thumbName = basename(saved.thumbnailPath);
        if (thumbName == _fileName) {
          deleteFile = false;
          savedThumbnailName = thumbName;
          break;
        }
      }
      //Delete already matched thumbnailes to reduce our loop.
      if (savedThumbnailName != null)
        savedThumbnails.removeWhere((element) => savedThumbnailName == basename(element.thumbnailPath));

      if (deleteFile) {
        file.delete();
      }
    }
  }

  //////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////
  //App mode toggle
  //Called when toggling status mode
  void toggleStatusMode() {
    dataStatus.isBusinessMode = !dataStatus.isBusinessMode;
    dataStatus.isBusinessMode
        ? dataStatus.sourcePath = dataStatus.newSource ? FolderPaths.businessStatusesFB : FolderPaths.businessStatuses
        : dataStatus.sourcePath = dataStatus.newSource ? FolderPaths.standardStatusesFB : FolderPaths.standardStatuses;
    //Refresh data
    refreshData();
  }
}
