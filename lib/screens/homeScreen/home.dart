import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
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
  Directory tempDirectory = Directory(appDirectoryTempPath);
  List<FileSystemEntity> statusVideos;
  List<FileSystemEntity> videoThumbnails;
  List<String> videoPaths = List();
  List<String> thumbnailPaths = List();

  String ext = '';

  bool isVideoLoading = false;
  bool scanningVideosDone = false;

  Future<void> getVideos() async {
    isVideoLoading = true;
    int refreshCount = 0;
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

    for (var file in statusVideos) {
      if (file.path.contains('.mp4')) {
        videoPaths.add(file.path);
        fileName = basenameWithoutExtension(file.path);
        thumbReady = false;

        for (var thumbnail in videoThumbnails) {
          thumbnailName = basenameWithoutExtension(thumbnail.path);
          if (thumbnailName.contains(fileName + ext)) {
            thumbnailPaths.add(thumbnail.path);
            thumbReady = true;
            break;
          }
        }
        if (thumbReady == false) {
          print('ohoh');
          final path = await VideoThumbnail.thumbnailFile(
            video: file.path,
            thumbnailPath: appDirectoryTempPath + '/' + fileName + ext + '.png',
            imageFormat: ImageFormat.PNG,
            quality: 10,
          );
          thumbnailPaths.add(path);
          refreshCount++;
        }
        //Dont show loading for long
        if (refreshCount > 3) {
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
    cleanUpThumbs();
  }

  void cleanUpThumbs() {
    bool isDelete;
    String thumbName;
    String thumbName2;

    print(videoThumbnails.length.toString());
    print(thumbnailPaths.length.toString());
    if (thumbnailPaths.isNotEmpty) {
      for (var thumbanail in videoThumbnails) {
        isDelete = true;
        thumbName = basenameWithoutExtension(thumbanail.path);
        for (var path in thumbnailPaths) {
          thumbName2 = basenameWithoutExtension(path);
          if (thumbName.contains(ext)) {
            print(thumbName);
            print(ext);
            if (thumbName.contains(thumbName2)) {
              print(thumbName2);
              isDelete = false;
              break;
            }
          } else {
            isDelete = false;
          }
        }
        if (isDelete) {
          print('deleted');
          print(thumbName2);
          print('');
          thumbanail.delete();
        }
      }
    }
  }

  callGetters(statusPath) {
    statusDirectory = Directory(statusPath);
    if (statusPath == statusPathStandard) {
      ext = 'standard';
    } else if (statusPath == statusPathGB) {
      ext = 'v-gb';
    } else {
      ext = 'business';
    }

    if (!isImageLoading) {
      getImages();
    }
    if (!isVideoLoading) {
      setState(() {
        scanningVideosDone = false;
      });
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
