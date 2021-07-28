import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sam_status_saver/app.dart';
import 'package:sam_status_saver/providers/dataProvider.dart';
import 'package:sam_status_saver/providers/permissionProvider.dart';
import 'package:sam_status_saver/providers/appSettingsProvider.dart';

class AppProviders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppSettingsProvider(appSettings: AppSettings())),
        ChangeNotifierProvider(create: (_) => PermissionProvider(permissionStatus: PermissionStatus())),
        ChangeNotifierProvider<DataProvider>(create: (context) => DataProvider()),
      ],
      child: AppBooter(),
    );
  }
}
