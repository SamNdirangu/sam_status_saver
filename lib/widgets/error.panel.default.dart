import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sam_status_saver/constants/constant.strings.dart';
import 'package:sam_status_saver/providers/all.providers.dart';

class DefaultErrorPanel extends HookConsumerWidget {
  const DefaultErrorPanel({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionStatus = ref.watch(permissionProvider);
    final dataError = ref.watch(dataProvider).errorMsg;
    final requestPermission = ref.read(permissionProvider.notifier).requestPermission;

    if (permissionStatus.errorMsg != null || dataError != null) {
      String? appError;
      appError = permissionStatus.errorMsg ?? dataError;
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        const Icon(
          Icons.sentiment_dissatisfied,
          size: 56,
          color: Colors.white,
        ),
        const SizedBox(height: 10),
        Text(
          appError.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ]));
    }

    if (!permissionStatus.isGranted) {
      var permissionError = ConstantMessageStrings.permEnablePermissions;
      if (permissionStatus.isPermanentlyDenied) permissionError = ConstantMessageStrings.permOpenPermissionSettings;
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
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
          child: Text(
            permissionError,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          autofocus: true,
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () => permissionStatus.isPermanentlyDenied ? openAppSettings() : requestPermission(),
          child: const Text(
            'Enable Permissions',
            style: TextStyle(color: Colors.black),
          ),
        )
      ]));
    }
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Icon(
          Icons.sentiment_satisfied,
          size: 56,
          color: Colors.white,
        ),
        SizedBox(height: 30),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            ConstantMessageStrings.errWhatsappNotInstalled,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ]),
    );
  }
}
