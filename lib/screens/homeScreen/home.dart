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

//-----------------------------------------------------------------------------------
  //Image Preparation
  Directory statusDirectory;
  List<FileSystemEntity> statusImages;
  List<String> imagePaths;

  bool isImageLoading = false;
  bool scanningDone = false;

  Future<void> getImages() async {
    isImageLoading = true;
    statusImages = statusDirectory.listSync(followLinks: false);
    imagePaths = List();
    //Sort newest to old
    statusImages.sort((a, b) => File(b.path)
        .lastModifiedSync()
        .toString()
        .compareTo(File(a.path).lastModifiedSync().toString()));

    for (var file in statusImages) {
      if (file.path.contains('.jpg')) {
        imagePaths.add(file.path);
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
  List<FileSystemEntity> statusVideos;
  List<FileSystemEntity> videoThumbnails;
  List<String> videoPaths = List();
  List<String> thumbnailPaths = List();

  bool isVideoLoading = false;
  bool scanningVideosDone = false;

  Future<void> getVideos() async {
    isVideoLoading = true;
    Directory tempDirectory = await getApplicationDocumentsDirectory();

    String fileName;
    String thumbnailName;
    bool thumbReady;
    thumbnailPaths = List();

    statusVideos = statusDirectory.listSync(followLinks: false);
    statusVideos.sort((a, b) => File(b.path)
        .lastModifiedSync()
        .toString()
        .compareTo(File(a.path).lastModifiedSync().toString()));

    videoThumbnails = tempDirectory.listSync(followLinks: false);
    int refreshCount = 0;
    for (var file in statusVideos) {
      if (file.path.contains('.mp4')) {
        videoPaths.add(file.path);
        fileName = basenameWithoutExtension(file.path);
        thumbReady = false;

        for (var thumbnail in videoThumbnails) {
          thumbnailName = basenameWithoutExtension(thumbnail.path);
          if (thumbnailName.compareTo(fileName) == 0) {
            thumbnailPaths.add(thumbnail.path);
            thumbReady = true;
            break;
          }
        }
        if (thumbReady == false) {
          final path = await VideoThumbnail.thumbnailFile(
            video: file.path,
            thumbnailPath: appDirectoryTempPath,
            imageFormat: ImageFormat.PNG,
            quality: 10,
          );
          thumbnailPaths.add(path);
        }
        refreshCount ++;
        if(refreshCount>4){
          setState(() {
            videoPaths = videoPaths;
            scanningVideosDone = true;
            thumbnailPaths = thumbnailPaths;
          });

        }
      }
    }
    setState(() {
      videoPaths = videoPaths;
      isVideoLoading = false;
      scanningVideosDone = true;
      thumbnailPaths = thumbnailPaths;
    });
  }

  void cleanUpThumbs() {
    bool isDelete;
    for (var thumbanail in videoThumbnails) {
      isDelete = true;
      for (var path in thumbnailPaths) {
        if (thumbanail.path.compareTo(path) == 0) {
          isDelete = false;
          break;
        }
      }
      if (isDelete) {
        thumbanail.delete();
      }
    }
  }

  callGetters(statusPath) {
    statusDirectory = Directory(statusPath);
    if (!isImageLoading) {
      getImages();
    }
    if (!isVideoLoading) {
      getVideos();
      cleanUpThumbs();
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
                getImages: getImages,
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
