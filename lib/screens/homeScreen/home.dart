import 'dart:io';

import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:sam_status_saver/widgets/adMob.dart';
import 'package:sam_status_saver/constants/paths.dart';
import 'package:sam_status_saver/constants/strings.dart';
import 'package:sam_status_saver/widgets/backdrop.dart';
import 'package:sam_status_saver/providers/providers.dart';
import 'package:sam_status_saver/views/backdropPanel.dart';
import 'package:sam_status_saver/screens/homeScreen/tabs/statusImages.dart';
import 'package:sam_status_saver/screens/homeScreen/tabs/statusVideos.dart';

class HomeScreen extends StatefulWidget {
  final bool isReadEnabled;
  const HomeScreen({Key key, @required this.isReadEnabled}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController _tabController;
  AnimationController _animationController;
  
  bool isReadEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
        duration: Duration(milliseconds: 300), value: 1.0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

//-----------------------------------------------------------------------------------
  //Image Preparation
  Directory statusDirectory; //To store our status directory

  List<FileSystemEntity>
      statusFiles; //List to store our files in the status folder
  List<FileSystemEntity>
      statusTempFiles; //List for all files in the temp folder

  List<String> imagePaths = List(); //List to store the image paths of pictures
  List<String> videoPaths = List(); //List to store the video paths of videos
  List<String> thumbnailPaths =
      List(); //List to store the paths of thumbanils of videos

  String appDirectoryTempPath; //String to hold the temp directory path

  bool _changePresent = true;
  bool loadGetter = true; //Whether to load getContent function automatically
  bool isScanningBegan = false; //To store the state of scanning progress.
  bool isContentLoading =
      false; //Store the state whether th getContent function is still running

  String versionExt =
      ''; //To store the version whatsapp extension to distinguish between different versions

  //Get out contnet
  Future<void> getContent() async {
    isContentLoading = true; //Store our content loading status
    if (statusDirectory.existsSync()) {
      if (!isReadEnabled) {
        setState(() {
          isReadEnabled = true;
        });
      }
      int _refreshCount = 0;
      bool _inTemp = false; //Store whhether a file is present in temp directory
      String _fileName; //Store file name without file extension
      String _fileNameExt; //store our file name with extension

      //Reset our lists
      imagePaths = List();
      videoPaths = List();
      thumbnailPaths = List();

      //Get our temp directory
      appDirectoryTempPath = (await getApplicationDocumentsDirectory()).path;

      //generate list of our status and temp directories
      statusFiles = statusDirectory.listSync(followLinks: false);
      statusTempFiles =
          Directory(appDirectoryTempPath).listSync(followLinks: false);

      //Sort newest to old files.
      statusFiles.sort((a, b) => File(b.path)
          .lastModifiedSync()
          .toString()
          .compareTo(File(a.path).lastModifiedSync().toString()));

      //Start looping through each of the files
      for (var file in statusFiles) {
        _fileName = versionExt + basenameWithoutExtension(file.path);
        _fileNameExt = versionExt +
            basename(
                file.path); //add the version textension to the name string.

        final _thumbnailTempPath =
            appDirectoryTempPath + '/' + _fileName + '.png';

        //Check if file exist in temp directory
        _inTemp = false;
        for (var tempFile in statusTempFiles) {
          final tempFileName = basenameWithoutExtension(tempFile.path);
          if (_fileName == tempFileName) {
            _inTemp = true;
            break;
          }
        }
        //if file was found in temp directory
        if (_inTemp) {
          //Check if file is an image
          if (_fileNameExt.contains('.jpg')) {
            imagePaths.add(appDirectoryTempPath + '/' + _fileNameExt);
          }
          if (_fileNameExt.contains('.mp4')) {
            videoPaths.add(appDirectoryTempPath + '/' + _fileNameExt);
            thumbnailPaths.add(_thumbnailTempPath);
          }
        } else {
          //If file wasnt found in temp

          //Check the file type
          if (_fileNameExt.contains('.jpg')) {
            _changePresent = true;
            //Copy the file to the temp directory
            await File(file.path)
                .copy(appDirectoryTempPath + '/' + _fileNameExt);
            imagePaths.add(appDirectoryTempPath + '/' + _fileNameExt);
          }

          if (_fileNameExt.contains('.mp4')) {
            _changePresent = true;
            //Copy the file to the temp directory
            await File(file.path)
                .copy(appDirectoryTempPath + '/' + _fileNameExt);
            //Create a thumbanil of the video
            await VideoThumbnail.thumbnailFile(
              video: file.path,
              thumbnailPath: _thumbnailTempPath,
              imageFormat: ImageFormat.PNG,
              quality: 10,
            );

            videoPaths.add(appDirectoryTempPath + '/' + _fileNameExt);
            thumbnailPaths.add(_thumbnailTempPath);
            _refreshCount++;
          }
        }
        if (_refreshCount > 1) {
          _refreshCount = 0;
          setState(() {
            isScanningBegan = true;
            imagePaths = imagePaths;
            videoPaths = videoPaths;
          });
        }
      }
      isContentLoading = false;
      
      if (_changePresent) {
        _changePresent = false;
        setState(() {
          isScanningBegan = true;
          imagePaths = imagePaths;
          videoPaths = videoPaths;
        });
      }
      cleanUpGarbage();
    } else {
      setState(() {
        isContentLoading = false;
        isScanningBegan = true;
        isReadEnabled = false;
      });
    }
  }
  //=======================Garbage Cleanup=======================================
  void cleanUpGarbage() async {
    bool _isDelete;
    String _thumbName;
    String _videoName;
    String _fileName;
    String _imageName;

    for (var file in statusTempFiles) {
      _isDelete = true;
      _fileName = basename(file.path);
      if (_fileName.contains(versionExt)) {
        //print(_fileName);
        if (_fileName.contains('.mp4')) {
          for (var videos in videoPaths) {
            _videoName = basename(videos);
            if (_fileName == _videoName) {
              _isDelete = false;
              break;
            }
          }
          if (_isDelete) {
            //print('deleted: ' + _fileName);
            file.delete();
          }
        }

        if (_fileName.contains('.jpg')) {
          for (var image in imagePaths) {
            _imageName = basename(image);
            if (_fileName == _imageName) {
              _isDelete = false;
              break;
            }
          }
          if (_isDelete) {
            //print('deleted: ' + _fileName);
            file.delete();
          }
        }

        if (_fileName.contains('.png')) {
          //print('');
          //print('FileCheck: '+_fileName);
          for (var thumbnail in thumbnailPaths) {
            _thumbName = basename(thumbnail);
            //print(_thumbName);
            if (_fileName == _thumbName) {
              _isDelete = false;
              break;
            }
          }
          if (_isDelete) {
            //print('deleted: ' + _fileName);
            file.delete();
          }
        }
      }
    }
  }
  //=======================Garbage Cleanup End=======================================
  
  //=======================Call Getters=======================================
  callGetter(statusPath) {
    statusDirectory = Directory(statusPath);
    if (statusPath == statusPathStandard) {
      versionExt = 'standard-';
    } else if (statusPath == statusPathGB) {
      versionExt = 'gb-';
    } else {
      versionExt = 'business-';
    }

    if (!isContentLoading) {
      setState(() {
        isScanningBegan = false;
        _changePresent = true;
      });
      getContent();
    }
  }
  //=======================Call Getters=======================================

  @override
  Widget build(BuildContext context) {
    if (widget.isReadEnabled && loadGetter) {
      final statusPath =
          Provider.of<StatusDirectoryFavourite>(context).statusPathsFavourite;
      loadGetter = false;
      if (Directory(statusPath).existsSync()) {
        isReadEnabled = true;
      }
      callGetter(statusPath);
    }

    return Backdrop(
      controller: _animationController,
      backTitle: Text('More'),
      backLayer: BackdropPanel(
        callContentGetter: callGetter,
      ),
      frontTitle: Text(appTitle),
      frontLayer: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Material(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorWeight: 3,
              indicatorColor: Colors.white,
              tabs: <Widget>[
                Tab(
                  text: 'Images',
                ),
                Tab(text: 'Videos')
              ],
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            TabBarView(
              controller: _tabController,
              children: <Widget>[
                StatusImages(
                  imagePaths: imagePaths,
                  isScanningBegan: isScanningBegan,
                  readEnabled: isReadEnabled,
                  getContentCallBack: getContent,
                ),
                StatusVideos(
                  videoPaths: videoPaths,
                  thumbnailPaths: thumbnailPaths,
                  isScanningBegan: isScanningBegan,
                  readEnabled: isReadEnabled,
                  getContentCallBack: getContent),
              ],
            ),
            Align(
                alignment: Alignment.bottomLeft,
                child: !isContentLoading
                  ? AdmobBanner(
                      adUnitId: getBannerAdUnitId(),
                      adSize: AdmobBannerSize(
                        width: MediaQuery.of(context).size.width.toInt(),
                        height: 90,
                        name: 'HOME_CUSTOM_BANNER'),
                    )
                  : Container()),
          ],
        ),
      )
    );
  }
}
