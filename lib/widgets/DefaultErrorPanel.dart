import 'package:flutter/material.dart';
import 'package:sam_status_saver/providers/dataProvider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sam_status_saver/providers/permissionProvider.dart';

class DefaultErrorPanel extends StatelessWidget {
  const DefaultErrorPanel({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _permissionStatus = context.watch<PermissionProvider>().permissionStatus;
    final _dataError = context.watch<DataProvider>().dataStatus.errorMsg;
    final _requestPermission = context.read<PermissionProvider>().requestPermission;

    if (_permissionStatus.errorMsg != null || _dataError != null) {
      var _appError;
      _appError = _permissionStatus.errorMsg ?? _dataError;
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        const Icon(
          Icons.sentiment_dissatisfied,
          size: 56,
          color: Colors.white,
        ),
        const SizedBox(height: 10),
        Text(
          _appError.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ]));
    }

    if (!_permissionStatus.isGranted) {
      var permissionError = 'Please enable Permissions to access storage';
      if (_permissionStatus.isPermanentlyDenied)
        permissionError = 'Please go to settings and enable Permissions to access storage';
      //

      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        const Icon(
          Icons.sentiment_dissatisfied,
          size: 56,
          color: Colors.white,
        ),
        const SizedBox(height: 10),
        Text(
          permissionError,
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          autofocus: true,
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () => _permissionStatus.isPermanentlyDenied ? openAppSettings() : _requestPermission(),
          child: const Text(
            'Enable Permissions',
            style: TextStyle(color: Colors.black),
          ),
        )
      ]));
    }
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        const Icon(
          Icons.sentiment_satisfied,
          size: 56,
          color: Colors.white,
        ),
        const SizedBox(height: 30),
        const Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'Hey it seems you might have not yet installed Whastapp on your phone\n\nThis app requires Whatsapp',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ]),
    );
  }
}
