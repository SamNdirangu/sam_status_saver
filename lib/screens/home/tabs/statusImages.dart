import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/appStrings.dart';
import 'package:sam_status_saver/providers/appProviders.dart';
import 'package:sam_status_saver/widgets/DefaultErrorPanel.dart';
import 'package:sam_status_saver/functions/pageRouter.dart';
import 'package:sam_status_saver/screens/contentViewScreens/Imagecontent.dart';

class StatusImages extends ConsumerWidget {
  final bool isSavedFiles;
  const StatusImages({Key? key, required this.isSavedFiles}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    //Get our provider watcher and functions

    final _imagePaths =
        isSavedFiles ? watch(dataProvider).dataStatus.savedImages : watch(dataProvider).dataStatus.images;
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

    //
    if (_isLoading) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        const CircularProgressIndicator(),
        const SizedBox(
          height: 30,
        ),
        const Text('Keep calm.\nGrabbing them pics',
            textAlign: TextAlign.center, textScaleFactor: 1.2, style: TextStyle(color: Colors.white)),
      ]);
    }
    //
    if (_imagePaths!.isEmpty) {
      String infoString = AppStrings.noPictures;
      if (isSavedFiles) infoString = AppStrings.noSavedPictures;

      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          const Icon(
            Icons.sentiment_satisfied,
            size: 56,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Text(
              infoString,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
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
          itemCount: _imagePaths.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.all(1.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(pageRouter(
                        ImageContentView(imagePaths: _imagePaths, currentIndex: index, isSavedFiles: isSavedFiles)));
                  },
                  child: Image.file(
                    File(_imagePaths[index]),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                ));
          },
        ));
  }
}
