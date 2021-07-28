import 'package:flutter/material.dart';
import 'package:sam_status_saver/assets/customColor.dart';
import 'package:sam_status_saver/constants/appStrings.dart';
import 'package:sam_status_saver/providers/dataProvider.dart';
import 'package:sam_status_saver/screens/home/homeScreen.dart';
import 'package:provider/provider.dart';

import 'package:sam_status_saver/providers/appSettingsProvider.dart';
import 'package:sam_status_saver/providers/permissionProvider.dart';

class AppBooter extends StatelessWidget {
  const AppBooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PermissionStatus _permissionStatus = context.watch<PermissionProvider>().permissionStatus;
    final _loadData = context.read<DataProvider>().loadData;
    //Load app data provider only once
    if (_permissionStatus.isGranted) _loadData();
    //
    return App();
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Get our dark theme Status
    final _isDarkTheme = context.watch<AppSettingsProvider>().appSettings.isDarkTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        buttonColor: Colors.black54,
      ),
      theme: ThemeData(
        primarySwatch: colorCustom,
        accentColor: colorCustom,
        brightness: _isDarkTheme ? Brightness.dark : Brightness.light,
      ),
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(),
    );
  }
}
