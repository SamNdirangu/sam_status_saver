import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/constant.keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class SettingsRepoFutureObject {
  final String error;
  final bool isError;
  final bool isLoading;

  final bool isDarkTheme;
  final double fontScale;

  const SettingsRepoFutureObject({
    this.isDarkTheme = true,
    this.fontScale = 1.1,
    this.isError = false,
    this.isLoading = true,
    this.error = "",
  });

  SettingsRepoFutureObject copyWith({
    String? error,
    bool? isError,
    bool? isLoading,
    bool? isDarkTheme,
    double? fontScale,
  }) {
    return SettingsRepoFutureObject(
      error: error ?? this.error,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  factory SettingsRepoFutureObject.fromJson(Map<String, dynamic> parsedJson) {
    return SettingsRepoFutureObject(
      isDarkTheme: parsedJson['isDarkTheme'],
      fontScale: parsedJson['fontScale'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'isDarkTheme': isDarkTheme,
      'fontScale': fontScale,
    };
  }
}

class AppSettingsProvider extends StateNotifier<SettingsRepoFutureObject> {
  final _prefsKey = ConstantKeys.storageKeyForSettings;
  AppSettingsProvider() : super(const SettingsRepoFutureObject()) {
    Future(() => _loadSettings());
  }

  void _loadSettings() {
    SharedPreferences.getInstance().then((prefs) {
      final value = prefs.getString(_prefsKey);
      //get stored map setting string
      if (value != null) {
        state = SettingsRepoFutureObject.fromJson(jsonDecode(value));
      } else {
        //Initialize settings
        prefs.setString(_prefsKey, jsonEncode(state.toJson()));
      }
    }).catchError((e) {
      state = state.copyWith(error: e.toString(), isError: true);
    });
  }

  //toggleDarkTheme
  void toggleDarkTheme() {
    state = state.copyWith(isDarkTheme: !state.isDarkTheme);
    SharedPreferences.getInstance().then((prefs) => prefs.setString(_prefsKey, jsonEncode(state.toJson())));
  }

  //Update Font scale
  void setFontScale(newScale) {
    //Update font scale
    state = state.copyWith(fontScale: newScale);
    //Store the new appSettings
    SharedPreferences.getInstance().then((prefs) => prefs.setString(_prefsKey, jsonEncode(state.toJson())));
  }
}
