import 'package:flutter/material.dart';
import 'package:admob_flutter/admob_flutter.dart';

import 'package:sam_status_saver/widgets/adMob.dart';
import 'package:sam_status_saver/providers/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  Admob.initialize(getAppId());
  runApp(Providers());
}
