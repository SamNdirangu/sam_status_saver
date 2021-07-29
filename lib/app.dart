import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/assets/customColor.dart';
import 'package:sam_status_saver/constants/appStrings.dart';
import 'package:sam_status_saver/providers/appProviders.dart';
import 'package:sam_status_saver/screens/home/homeScreen.dart';

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    //Get our dark theme Status
    final _isDarkTheme = watch(appSettingsProvider).appSettings.isDarkTheme;
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
