import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/constant.strings.dart';
import 'package:sam_status_saver/providers/all.providers.dart';
import 'package:sam_status_saver/providers/provider.data.dart';

import 'package:sam_status_saver/widgets/error.panel.default.dart';
import 'package:sam_status_saver/functions/router.page.dart';
import 'package:sam_status_saver/screens/contentViewScreens/content.video.dart';

class StatusVideos extends HookConsumerWidget {
  final bool isSavedFiles;
  const StatusVideos({Key? key, required this.isSavedFiles}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Get our provider watcher and functions
    final dataStatus = ref.watch(dataProvider);
    final isLoading = dataStatus.isLoading;
    final dataError = dataStatus.errorMsg;
    final permissionStatus = ref.watch(permissionProvider);
    //
     final funcRefreshData = ref.read(dataProvider.notifier).refreshData;

    //
    if (!permissionStatus.isGranted || dataError != null) {
      return const DefaultErrorPanel(); //Show our default Error Widget incase as we cant read or whatsapp folders dont exist
    }
    //////////////////////////////////////////////////////////////////////////////
    //Load our videos
    final videoJson = isSavedFiles
        ? jsonDecode(dataStatus.savedVideos!) as List
        : jsonDecode(dataStatus.videos!) as List;
    final videos = videoJson.map((data) => VideoFile.fromJson(data)).toList();

    ///
    ///
    if (isLoading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(
            height: 30,
          ),
          Text(
            'Keep calm.\nGrabbing them Videos',
            textAlign: TextAlign.center,
            textScaleFactor: 1.2,
            style: TextStyle(color: Colors.white),
          ),
        ],
      );
    }

    ///
    ///
    if (videos.isEmpty) {
      String infoString = ConstantAppStrings.noVideos;
      if (isSavedFiles) infoString = ConstantAppStrings.noSavedVideos;
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.sentiment_satisfied,
                size: 56,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                infoString,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: funcRefreshData,
                icon: const Icon(Icons.refresh, color: Colors.black87),
                label: const Text(
                  'Refresh',
                  style: TextStyle(color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              )
            ]),
      );
    }

    return RefreshIndicator(
        onRefresh: funcRefreshData,
        child: GridView.builder(
          key: PageStorageKey(key),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150),
          itemCount: videos.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(1.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(pageRouter(VideoContentView(
                      videoFiles: videos,
                      currentIndex: index,
                      isSavedFiles: isSavedFiles)));
                },
                child: Image.file(
                  File(videos[index].thumbnailPath),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ));
  }
}
