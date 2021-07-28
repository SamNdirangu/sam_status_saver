import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/providers/permissionProvider.dart';
import 'package:sam_status_saver/widgets/DefaultErrorPanel.dart';
import 'package:provider/provider.dart';
import 'package:sam_status_saver/functions/pageRouter.dart';
import 'package:sam_status_saver/providers/dataProvider.dart';
import 'package:sam_status_saver/screens/contentViewScreens/Imagecontent.dart';

class StatusImages extends StatelessWidget {
  const StatusImages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Get our provider watcher and functions
    final _imagePaths = context.watch<DataProvider>().dataStatus.images;
    final _isLoading = context.watch<DataProvider>().dataStatus.isLoading;
    final _dataError = context.watch<DataProvider>().dataStatus.errorMsg;
    final _permissionStatus = context.watch<PermissionProvider>().permissionStatus;
    //
    Future<void> _pullToRefresh() => context.read<DataProvider>().refreshData();
    void _pressToRefresh() => context.read<DataProvider>().refreshData;

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
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          const Icon(
            Icons.sentiment_satisfied,
            size: 56,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          const Text(
            'Hey it seems you dont have any status pictues yet.\n\n Once you view a few come back and see them here',
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
          itemCount: _imagePaths.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.all(1.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(pageRouter(ImageContentView(imagePaths: _imagePaths, currentIndex: index)));
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
