import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/appStrings.dart';
import 'package:sam_status_saver/providers/appProviders.dart';
import 'package:sam_status_saver/providers/dataProvider.dart';

import 'package:sam_status_saver/widgets/DefaultErrorPanel.dart';
import 'package:sam_status_saver/functions/pageRouter.dart';
import 'package:sam_status_saver/screens/contentViewScreens/videoContent.dart';

class StatusVideos extends ConsumerWidget {
  final bool isSavedFiles;
  const StatusVideos({Key? key, required this.isSavedFiles}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    //Get our provider watcher and functions
    final _isLoading = watch(dataProvider).dataStatus.isLoading;
    final _dataError = watch(dataProvider).dataStatus.errorMsg;
    final _permissionStatus = watch(permissionProvider).permissionStatus;
    //
    Future<void> _pullToRefresh() => context.read(dataProvider).refreshData();
    void _pressToRefresh() => context.read(dataProvider).refreshData();

    //
    if (!_permissionStatus.isGranted || _dataError != null) {
      return DefaultErrorPanel(); //Show our default Error Widget incase as we cant read or whatsapp folders dont exist
    }
    //////////////////////////////////////////////////////////////////////////////
    //Load our videos
    final _videoJson = isSavedFiles
        ? jsonDecode(watch(dataProvider).dataStatus.savedVideos!) as List
        : jsonDecode(watch(dataProvider).dataStatus.videos!) as List;
    final _videos = _videoJson.map((data) => VideoFile.fromJson(data)).toList();

    ///
    ///
    if (_isLoading) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        const CircularProgressIndicator(),
        const SizedBox(
          height: 30,
        ),
        const Text('Keep calm.\nGrabbing them Videos',
            textAlign: TextAlign.center, textScaleFactor: 1.2, style: TextStyle(color: Colors.white)),
      ]);
    }

    ///
    ///
    if (_videos.isEmpty) {
      String infoString = AppStrings.noVideos;
      if (isSavedFiles) infoString = AppStrings.noSavedVideos;
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          const Icon(
            Icons.sentiment_satisfied,
            size: 56,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            infoString,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _pressToRefresh,
            icon: Icon(Icons.refresh, color: Colors.black87),
            label: Text(
              'Refresh',
              style: TextStyle(color: Colors.black87),
            ),
            style: ElevatedButton.styleFrom(primary: Colors.white),
          )
        ]),
      );
    }

    return RefreshIndicator(
        onRefresh: _pullToRefresh,
        child: GridView.builder(
          key: PageStorageKey(key),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 150),
          itemCount: _videos.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(1.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(pageRouter(
                      VideoContentView(videoFiles: _videos, currentIndex: index, isSavedFiles: isSavedFiles)));
                },
                child: Image.file(
                  File(_videos[index].thumbnailPath),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ));
  }
}
