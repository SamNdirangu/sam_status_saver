import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/constant.colors.dart';
import 'package:sam_status_saver/constants/constant.strings.dart';
import 'package:sam_status_saver/providers/all.providers.dart';
import 'package:sam_status_saver/screens/home/screen.home.dart';

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Get our dark theme Status
    final isDarkTheme = ref.watch(appSettingsProvider).isDarkTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ConstantAppStrings.appTitle,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.black54,
        ),
      ),
      theme: ThemeData(
        primaryColor: colorCustom,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: colorCustom,
          accentColor: colorCustom,
        ),
      ),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
