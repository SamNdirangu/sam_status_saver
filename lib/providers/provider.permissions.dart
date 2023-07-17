import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

//Our provider model
@immutable
class PermissionStatus {
  //Desc Params
  final bool isLoading;
  final String? errorMsg;
  //Core params
  final bool isGranted;
  final bool isDenied;
  final bool isPermanentlyDenied;

  const PermissionStatus({
    this.isLoading = true,
    this.errorMsg,
    this.isGranted = false,
    this.isDenied = false,
    this.isPermanentlyDenied = false,
  });

  PermissionStatus copyWith({
    bool? isLoading,
    String? errorMsg,
    bool? isGranted,
    bool? isDenied,
    bool? isPermanentlyDenied,
  }) {
    return PermissionStatus(
      isLoading: isLoading ?? this.isLoading,
      errorMsg: errorMsg ?? this.errorMsg,
      isGranted: isGranted ?? this.isGranted,
      isDenied: isDenied ?? this.isDenied,
      isPermanentlyDenied: isPermanentlyDenied ?? this.isPermanentlyDenied,
    );
  }
}

class PermissionProvider extends StateNotifier<PermissionStatus> {
  //Declare our globals and getters
  int androidSDK = 30;
  //Add our constructor to load our permissions.
  PermissionProvider() : super(const PermissionStatus()) {
   Future(() => _loadPermission());
  }

  Future<void> requestPermission() async {
    if (androidSDK >= 30) {
      //request management permissions for android 11 and higher devices
      final requestStatusManaged = await Permission.manageExternalStorage.request();
      //Update Provider model
      state = state.copyWith(
        isLoading: false,
        isGranted: requestStatusManaged.isGranted,
        isDenied: requestStatusManaged.isDenied,
        isPermanentlyDenied: requestStatusManaged.isPermanentlyDenied,
      );
    } else {
      final requestStatusStorage = await Permission.storage.request();
      //Update provider model
      state = state.copyWith(
        isLoading: false,
        isGranted: requestStatusStorage.isGranted,
        isDenied: requestStatusStorage.isDenied,
        isPermanentlyDenied: requestStatusStorage.isPermanentlyDenied,
      );
    }
    return;
  }

  Future<void> _loadPermission() async {
    //Get phone SDK version first inorder to request correct permissions.
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    androidSDK = androidInfo.version.sdkInt;
    //
    if (androidSDK >= 30) {
      //Check first if we already have the permissions
      final currentStatusManaged = await Permission.manageExternalStorage.status;
      if (currentStatusManaged.isGranted) {
        //Update
        state = state.copyWith(
          isLoading: false,
          isGranted: true,
          isDenied: currentStatusManaged.isDenied,
          isPermanentlyDenied: currentStatusManaged.isPermanentlyDenied,
        );
      } else {
        //Do nothing will show permission error
        //requestPermission();
        return;
      }
    } else {
      //For older phones simply request the typical storage permissions
      //Check first if we already have the permissions
      final currentStatusStorage = await Permission.storage.status;
      if (currentStatusStorage.isGranted) {
        //Update provider
        state = state.copyWith(
          isLoading: false,
          isGranted: true,
          isDenied: currentStatusStorage.isDenied,
          isPermanentlyDenied: currentStatusStorage.isPermanentlyDenied,
        );
      } else {
        requestPermission();
        return;
      }
    }
  }
}
