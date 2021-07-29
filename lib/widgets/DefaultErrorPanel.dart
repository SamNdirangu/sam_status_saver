import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/configs.dart';
import 'package:sam_status_saver/providers/appProviders.dart';
import 'package:permission_handler/permission_handler.dart';

class DefaultErrorPanel extends ConsumerWidget {
  const DefaultErrorPanel({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _permissionStatus = watch(permissionProvider).permissionStatus;
    final _dataError = watch(dataProvider).dataStatus.errorMsg;
    final _requestPermission = context.read(permissionProvider).requestPermission;

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
      var permissionError = AppMessageStrings.permEnablePermissions;
      if (_permissionStatus.isPermanentlyDenied) permissionError = AppMessageStrings.permOpenPermissionSettings;
      //

      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        const Icon(
          Icons.sentiment_dissatisfied,
          size: 56,
          color: Colors.white,
        ),
        const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
          child: Text(
            permissionError,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
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
            AppMessageStrings.errWhatsappNotInstalled,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ]),
    );
  }
}
