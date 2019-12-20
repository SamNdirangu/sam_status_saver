import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:sam_status_saver/assets/customColor.dart';
import 'package:sam_status_saver/constants/paths.dart';
import 'package:sam_status_saver/providers/providers.dart';
import 'package:sam_status_saver/screens/homeScreen/home.dart';

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);


  requestWritePermission(context) async {
    PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    print(permissionStatus.value.toString());
    if(permissionStatus.value == 2) {
      
      Provider.of<PermissionProvider>(context).setNewPermission();
    } else {
      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      if(permissions.values.first.value == 2){
        Provider.of<PermissionProvider>(context).setNewPermission();
      }
    }
  }

  appInitializer(BuildContext context) async {
    Directory appDirectory;
    //Check if status folder exists
    appDirectory = Directory(statusPath);
    bool isExist = await appDirectory.exists();
    if (isExist) {
      Provider.of<StatusDirectoryState>(context).setDirectoryState();
    }

    appDirectory = Directory(appDirectoryPath);
    isExist = await appDirectory.exists();
    if (isExist) {
      appDirectory = Directory(appDirectoryVideoPath);
      isExist = await appDirectory.exists();
      if (!isExist) {
        appDirectory.create();
      }
      appDirectory = Directory(appDirectoryImagePath);
      isExist = await appDirectory.exists();
      if (!isExist) {
        appDirectory.create();
      }
      appDirectory = Directory(appDirectoryTempPath);
      isExist = await appDirectory.exists();
      if (!isExist) {
        appDirectory.create();
      }
    } else {
      appDirectory.create();
      appDirectory = Directory(appDirectoryVideoPath);
      appDirectory.create();
      appDirectory = Directory(appDirectoryImagePath);
      appDirectory.create();
      appDirectory = Directory(appDirectoryTempPath);
      appDirectory.create();
    }
    Provider.of<AppDirectoryState>(context).setDirectoryState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeState>(context); 

    if(Provider.of<RefreshControl>(context).refresh) {      
      if (!Provider.of<PermissionProvider>(context).readEnabled) {
        requestWritePermission(context);
        
      }
      if (Provider.of<PermissionProvider>(context).readEnabled) {
        appInitializer(context);
        Provider.of<RefreshControl>(context).setRefreshState(false);
      }
    }
    final readEnabled = Provider.of<PermissionProvider>(context).readEnabled;
    final isWhatsAppInstalled = Provider.of<StatusDirectoryState>(context).directoryExists;

    

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Saver',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      theme: ThemeData(
        primarySwatch: colorCustom,
        brightness: themeProvider.darkThemeState ? Brightness.dark : Brightness.light
        ),
      themeMode:
          themeProvider.darkThemeState ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        isReadEnabled: readEnabled && isWhatsAppInstalled
      ),
    );
  }
}
