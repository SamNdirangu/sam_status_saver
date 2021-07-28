import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';

//Our provider model
class PermissionStatus {
  //Desc Params
  bool isLoading;
  String? errorMsg;
  //Core params
  bool isGranted;
  bool isDenied;
  bool isPermanentlyDenied;

  PermissionStatus({
    this.isLoading = true,
    this.errorMsg,
    this.isGranted = false,
    this.isDenied = false,
    this.isPermanentlyDenied = false,
  });
}

class PermissionProvider with ChangeNotifier {
  //Declare our globals and getters
  int androidSDK = 30;
  PermissionStatus permissionStatus;
  //Add our constructor to load our permissions.
  PermissionProvider({required this.permissionStatus}) {
    _loadPermission();
  }

  Future<void> requestPermission() async {
    if (androidSDK >= 30) {
      //request management permissions for android 11 and higher devices
      final _requestStatusManaged = await Permission.manageExternalStorage.request();
      //Update Provider model
      permissionStatus.isGranted = _requestStatusManaged.isGranted;
      permissionStatus.isDenied = _requestStatusManaged.isDenied;
      permissionStatus.isPermanentlyDenied = _requestStatusManaged.isPermanentlyDenied;
    } else {
      final _requestStatusStorage = await Permission.storage.request();
      //Update provider model
      permissionStatus.isGranted = _requestStatusStorage.isGranted;
      permissionStatus.isDenied = _requestStatusStorage.isDenied;
      permissionStatus.isPermanentlyDenied = _requestStatusStorage.isPermanentlyDenied;
    }
    permissionStatus.isLoading = false;
    //notify our listerners
    notifyListeners();
    return;
  }

  Future<void> _loadPermission() async {
    //Get phone SDK version first inorder to request correct permissions.
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    androidSDK = androidInfo.version.sdkInt;
    //
    if (androidSDK >= 30) {
      //Check first if we already have the permissions
      final _currentStatusManaged = await Permission.manageExternalStorage.status;
      if (_currentStatusManaged.isGranted) {
        //Update
        permissionStatus.isLoading = false;
        permissionStatus.isGranted = true;
        permissionStatus.isDenied = _currentStatusManaged.isDenied;
        permissionStatus.isPermanentlyDenied = _currentStatusManaged.isPermanentlyDenied;
      } else {
        //TODO:Show page indicating user will be redirected to the permisssion settings menu
        requestPermission();
        return;
      }
    } else {
      //For older phones simply request the typical storage permissions
      //Check first if we already have the permissions
      final _currentStatusStorage = await Permission.storage.status;
      if (_currentStatusStorage.isGranted) {
        //Update provider
        permissionStatus.isLoading = false;
        permissionStatus.isGranted = true;
        permissionStatus.isDenied = _currentStatusStorage.isDenied;
        permissionStatus.isPermanentlyDenied = _currentStatusStorage.isPermanentlyDenied;
      } else {
        requestPermission();
        return;
      }
    }
    //Notify our listeners
    notifyListeners();
  }
}
