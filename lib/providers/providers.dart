import 'package:flutter/Material.dart';
import 'package:provider/provider.dart';

import '../app.dart';

class Providers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DarkThemeState>.value(
          value: DarkThemeState(),
        ),
        ChangeNotifierProvider<PermissionProvider>.value(
          value: PermissionProvider(),
        ),
        ChangeNotifierProvider<AppDirectoryState>.value(
          value: AppDirectoryState(),
        ),
        ChangeNotifierProvider<StatusDirectoryState>.value(
          value: StatusDirectoryState(),
        ),
        ChangeNotifierProvider<RefreshControl>.value(
          value: RefreshControl(),
        ),
      ],
      child: App(),
    );
  }
}

//Dark theme Provider
class DarkThemeState with ChangeNotifier {
  bool _darktheme = false;
  get darkThemeState => _darktheme;

  void setDarkTheme(newDarkTheme) {
    _darktheme = newDarkTheme;
    notifyListeners();
  }
}

//Dark theme Provider
class PermissionProvider with ChangeNotifier {
  bool _readEnable = false;
  get readEnabled => _readEnable;

  void setNewPermission() {
    _readEnable = true;
    notifyListeners();
  }
}

//Dark theme Provider
class AppDirectoryState with ChangeNotifier {
  bool _directoryExists = false;
  get directoryExists => _directoryExists;

  void setDirectoryState() {
    _directoryExists = true;
    notifyListeners();
  }
}

//Dark theme Provider
class StatusDirectoryState with ChangeNotifier {
  bool _directoryExists = false;
  get directoryExists => _directoryExists;

  void setDirectoryState() {
    _directoryExists = true;
    notifyListeners();
  }
}
class RefreshControl with ChangeNotifier {
  bool _refresh = true;
  get refresh => _refresh;

  void setRefreshState(state) {
    _refresh = state;
    notifyListeners();
  }
}