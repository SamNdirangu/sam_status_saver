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
    PermissionStatus permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permissionStatus.value == 2) {
      Provider.of<PermissionProvider>(context).setNewPermission();
    } else {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions.values.first.value == 2) {
        Provider.of<PermissionProvider>(context).setNewPermission();
      }
    }
  }

  appInitializer(BuildContext context) async {
    bool isExist = Directory(appDirectoryPath).existsSync();
    if (isExist) {
      isExist = Directory(appDirectoryVideoPath).existsSync();
      if (!isExist) {
        Directory(appDirectoryVideoPath).createSync();
      }
      isExist = Directory(appDirectoryImagePath).existsSync();
      if (!isExist) {
        Directory(appDirectoryImagePath).createSync();
      }
    } else {
      Directory(appDirectoryPath).createSync();
      Directory(appDirectoryVideoPath).createSync();
      Directory(appDirectoryImagePath).createSync();
    }
    Provider.of<AppDirectoryState>(context).setDirectoryState();

    final statusPaths = Provider.of<StatusDirectoryPath>(context);
    //Check which status folder exists
    isExist = Directory(statusPathStandard).existsSync();
    if (isExist) {
      statusPaths.addStatusPath(statusPathStandard);
    }

    isExist = Directory(statusPathGB).existsSync();
    if (isExist) {
      statusPaths.addStatusPath(statusPathGB);
    }

    isExist = Directory(statusPathBusiness).existsSync();
    if (isExist) {
      statusPaths.addStatusPath(statusPathBusiness);
    }

    if (statusPaths.statusPathsAvailable.isNotEmpty) {
      if (await Provider.of<StatusDirectoryFavourite>(context)
          .getFavouritePath()) {
        Provider.of<StatusDirectoryFavourite>(context)
            .setFavouritePath(statusPaths.statusPathsAvailable[0]);
      }
      Provider.of<StatusDirectoryState>(context).setDirectoryState();
      Provider.of<RefreshControl>(context).setRefreshState(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeState>(context);

    if (Provider.of<RefreshControl>(context).refresh) {
      if (!Provider.of<PermissionProvider>(context).readEnabled) {
        requestWritePermission(context);
      } else if (Provider.of<PermissionProvider>(context).readEnabled) {
        appInitializer(context);
      }
    }

    final readEnabled = Provider.of<PermissionProvider>(context).readEnabled;
    final isWhatsAppInstalled =
        Provider.of<StatusDirectoryState>(context).directoryExists;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Saver',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        buttonColor: Colors.black54,
      ),
      theme: ThemeData(
          primarySwatch: colorCustom,
          accentColor: colorCustom,
          brightness: themeProvider.darkThemeState
              ? Brightness.dark
              : Brightness.light),
      themeMode:
          themeProvider.darkThemeState ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        isReadEnabled: readEnabled && isWhatsAppInstalled,
      ),
    );
  }
}
