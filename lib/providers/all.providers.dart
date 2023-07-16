import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/providers/provider.data.dart';
import 'package:sam_status_saver/providers/provider.permissions.dart';
import 'package:sam_status_saver/providers/provider.settings.dart';

final appSettingsProvider = StateNotifierProvider<AppSettingsProvider, SettingsRepoFutureObject>((ref) {
  return AppSettingsProvider();
});

final dataProvider = StateNotifierProvider<DataProvider, DataStatus>((ref) {
  return DataProvider();
});

final permissionProvider = StateNotifierProvider<PermissionProvider, PermissionStatus>((ref) {
  return PermissionProvider();
});
