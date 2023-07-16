import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/constant.strings.dart';
import 'package:sam_status_saver/providers/all.providers.dart';
import 'package:sam_status_saver/widgets/error.panel.default.dart';
import 'package:sam_status_saver/functions/router.page.dart';
import 'package:sam_status_saver/screens/contentViewScreens/content.image.dart';

class StatusImages extends HookConsumerWidget {
  final bool isSavedFiles;
  const StatusImages({Key? key, required this.isSavedFiles}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataStatus = ref.watch(dataProvider);

    final imagePaths = isSavedFiles ? dataStatus.savedImages : dataStatus.images;
    final isLoading = dataStatus.isLoading;
    final dataError = dataStatus.errorMsg;
    final permissionStatus = ref.watch(permissionProvider);
    //
    Future<void> pullToRefresh() => ref.read(dataProvider.notifier).refreshData();
    void pressToRefresh() => ref.read(dataProvider.notifier).refreshData();

    //
    if (!permissionStatus.isGranted || dataError != null) {
      return const DefaultErrorPanel(); //Show our default Error Widget incase as we cant read or whatsapp folders dont exist
    }

    //
    if (isLoading) {
      return const Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        CircularProgressIndicator(),
        SizedBox(
          height: 30,
        ),
        Text('Keep calm.\nGrabbing them pics',
            textAlign: TextAlign.center, textScaleFactor: 1.2, style: TextStyle(color: Colors.white)),
      ]);
    }
    //
    if (imagePaths.isEmpty) {
      String infoString = ConstantAppStrings.noPictures;
      if (isSavedFiles) infoString = ConstantAppStrings.noSavedPictures;

      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          const Icon(
            Icons.sentiment_satisfied,
            size: 56,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Text(
              infoString,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: pressToRefresh,
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
        onRefresh: pullToRefresh,
        child: GridView.builder(
          key: PageStorageKey(key),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 150),
          itemCount: imagePaths.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.all(1.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(pageRouter(
                        ImageContentView(imagePaths: imagePaths, currentIndex: index, isSavedFiles: isSavedFiles)));
                  },
                  child: Image.file(
                    File(imagePaths[index]),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                ));
          },
        ));
  }
}
