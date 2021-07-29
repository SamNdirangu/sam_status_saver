import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/app.dart';
import 'package:sam_status_saver/providers/dataProvider.dart';
import 'package:sam_status_saver/providers/permissionProvider.dart';
import 'package:sam_status_saver/providers/appSettingsProvider.dart';

final appSettingsProvider = ChangeNotifierProvider<AppSettingsProvider>((ref) {
  return AppSettingsProvider(appSettings: AppSettings());
});

final permissionProvider = ChangeNotifierProvider<PermissionProvider>((ref) {
  return PermissionProvider(permissionStatus: PermissionStatus());
});

final dataProvider = ChangeNotifierProvider<DataProvider>((ref) {
  return DataProvider(dataStatus: DataStatus());
});

class AppProviders extends ConsumerWidget {
  const AppProviders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final PermissionStatus _permissionStatus = watch(permissionProvider).permissionStatus;
    final _loadData = context.read(dataProvider).loadData;
    //Load app data provider only once
    if (_permissionStatus.isGranted) _loadData();
    //
    return App();
  }
}
