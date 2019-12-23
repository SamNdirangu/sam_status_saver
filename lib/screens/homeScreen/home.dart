import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sam_status_saver/constants/paths.dart';
import 'package:sam_status_saver/providers/providers.dart';
import 'package:sam_status_saver/screens/homeScreen/tabs/statusImages.dart';
import 'package:sam_status_saver/screens/homeScreen/tabs/statusVideos.dart';
import 'package:sam_status_saver/views/backdropPanel.dart';
import 'package:sam_status_saver/widgets/backdrop.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class HomeScreen extends StatefulWidget {
  final bool isReadEnabled;
  const HomeScreen({Key key, @required this.isReadEnabled}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController _tabController;
  AnimationController _animationController;

  bool loadGetters = true;

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
  Directory statusDirectory;
  Directory statusTempDirectory;
  String appDirectoryTempPath;

  List<FileSystemEntity> statusTempFiles;
  List<FileSystemEntity> statusImages;
  List<String> imagePaths = List();

  bool isImageLoading = false;
  bool scanningDone = false;

  String ext = '';

  Future<void> getImages() async {
    bool _inTemp;
    String _imageName;
    String _fileName;

    statusTempDirectory = await getApplicationDocumentsDirectory();
    appDirectoryTempPath = statusTempDirectory.path;
    isImageLoading = true;

    imagePaths = List();
    

    statusFiles = statusDirectory.listSync(followLinks: false);
    statusTempFiles = statusTempDirectory.listSync(followLinks: false);
    //Sort newest to old
    statusFiles.sort((a, b) => File(b.path)
        .lastModifiedSync()
        .toString()
        .compareTo(File(a.path).lastModifiedSync().toString()));

    for (var file in statusFiles) {
      _fileName = ext + basename(file.path);

      if (_fileName.contains('.jpg')) {
        _inTemp = false;
        for (var image in statusTempFiles) {
          _imageName = basename(image.path);
          if (_fileName == _imageName) {
            _inTemp = true;
            break;
          }
        }
        if (!_inTemp) {
          await File(file.path).copy(appDirectoryTempPath + '/' + _fileName);
        }
        imagePaths.add(appDirectoryTempPath + '/' + _fileName);
      }
    }
    setState(() {
      imagePaths = imagePaths;
      isImageLoading = false;
      scanningDone = true;
    });
  }

  //----------------ImageEnd-------------------------------------------------------------
//---------------------------------------------------------------------------------------
  //Video Preparation
  Directory thumbDirectory;
  List<FileSystemEntity> statusFiles;
  List<FileSystemEntity> statusVideos;
  List<FileSystemEntity> videoThumbnails;
  List<String> videoPaths = List();
  List<String> thumbnailPaths = List();

  bool isVideoLoading = false;
  bool scanningVideosDone = false;

  Future<void> getVideos() async {
    if (thumbnailPaths.isEmpty) {
      setState(() {
        scanningVideosDone = false;
      });
    }

    isVideoLoading = true;
    statusTempDirectory = await getApplicationDocumentsDirectory();
    appDirectoryTempPath = statusTempDirectory.path;

    int _refreshCount = 0;
    String _fileName;
    String _thumbnailTempPath;
    String _videoName;

    bool _inTemp;
    thumbnailPaths = List();
    videoPaths = List();
    
    

    statusFiles = statusDirectory.listSync(followLinks: false);
    statusTempFiles = statusTempDirectory.listSync(followLinks: false);

    statusFiles.sort((a, b) => File(b.path)
        .lastModifiedSync()
        .toString()
        .compareTo(File(a.path).lastModifiedSync().toString()));

    for (var file in statusFiles) {
      _fileName = ext + basename(file.path);
      if (_fileName.contains('.mp4')) {
        _inTemp = false;
        for (var videos in statusTempFiles) {
          _videoName = basename(videos.path); //Already has ext
          if (_fileName == _videoName) {
            _inTemp = true;
            break;
          }
        }

        ///================================
        _thumbnailTempPath = appDirectoryTempPath +
            '/' +
            ext +
            basenameWithoutExtension(file.path) +
            '.png';
        if (!_inTemp) {
          await File(file.path).copy(appDirectoryTempPath + '/' + _fileName);

          await VideoThumbnail.thumbnailFile(
            video: file.path,
            thumbnailPath: _thumbnailTempPath,
            imageFormat: ImageFormat.PNG,
            quality: 10,
          );
          _refreshCount++;
          print('thumbail');
        }
        videoPaths.add(appDirectoryTempPath + '/' + _fileName);
        thumbnailPaths.add(_thumbnailTempPath);

        //Dont show loading for long
        if (_refreshCount > 3) {
          setState(() {
            scanningVideosDone = true;
            thumbnailPaths = thumbnailPaths;
            videoPaths = videoPaths;
          });
        }
      }
    }
    setState(() {
      isVideoLoading = false;
      scanningVideosDone = true;
    });

    cleanUpGarbage();
  }

  void cleanUpGarbage() async {
    bool _isDelete;
    String _thumbName;
    String _videoName;
    String _fileName;
    String _imageName;

    statusTempFiles = statusTempDirectory.listSync(followLinks: false);

    for (var file in statusTempFiles) {
      _isDelete = true;
      _fileName = basename(file.path);
      if (_fileName.contains(ext)) {
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
            print('deleted: ' + _fileName);
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
            print('deleted: ' + _fileName);
            file.delete();
          }
        }

        if (_fileName.contains('.png')) {
          for (var thumbnail in thumbnailPaths) {
            _thumbName = basename(thumbnail);
            if (_fileName == _thumbName) {
              _isDelete = false;
              break;
            }
          }
          if (_isDelete) {
            print('deleted: ' + _fileName);
            file.delete();
          }
        }
      }
    }
  }

  callGetters(statusPath) {
    statusDirectory = Directory(statusPath);
    if (statusPath == statusPathStandard) {
      ext = 'standard-';
    } else if (statusPath == statusPathGB) {
      ext = 'gb-';
    } else {
      ext = 'business-';
    }

    if (!isImageLoading) {
      getImages();
    }
    if (!isVideoLoading) {
      getVideos();
    }
  }

  //--------------------Video End--------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (widget.isReadEnabled && loadGetters) {
      final statusPath =
          Provider.of<StatusDirectoryFavourite>(context).statusPathsFavourite;
      setState(() {
        loadGetters = false;
        callGetters(statusPath);
      });
    }

    print(videoPaths.length);
    print(imagePaths.length);

    return Backdrop(
        controller: _animationController,
        backTitle: Text('More'),
        backLayer: BackdropPanel(
          callGetters: callGetters,
        ),
        frontTitle: Text("Sam's Status Saver"),
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
          backgroundColor: Colors.black87,
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              StatusImages(
                imagePaths: imagePaths,
                scanningDone: scanningDone,
                readEnabled: widget.isReadEnabled,
                getImagesCallBack: getImages,
              ),
              StatusVideos(
                  videoPaths: videoPaths,
                  thumbnailPaths: thumbnailPaths,
                  scanningDone: scanningVideosDone,
                  readEnabled: widget.isReadEnabled,
                  getVideosCallBack: getVideos)
            ],
          ),
        ));
  }
}
