import 'package:flutter/material.dart';

class AppSettings {
  bool isDarkTheme;

  AppSettings({this.isDarkTheme = false});
}

class AppSettingsProvider with ChangeNotifier {
  //Load Getters
  AppSettings appSettings;
  AppSettingsProvider({required this.appSettings});

  void toggleDarkTheme() {
    this.appSettings.isDarkTheme = !this.appSettings.isDarkTheme;
    notifyListeners();
  }
}
