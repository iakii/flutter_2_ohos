// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

// Package imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'managers/settings_manager.dart';
import 'pages/home.dart';
import 'widgets/custom_underline_tab_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  timeDilation = 1;

  if (Platform.isAndroid || defaultTargetPlatform == TargetPlatform.ohos) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  if (Platform.isWindows) {}

  runApp(Phoenix(child: const MyHomePage()));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SettingsManager? settingsManager;
  bool ready = false;

  @override
  void initState() {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      getApplicationSupportDirectory().then((path) {
        applyPath(path);
      });
    } else {
      getExternalStorageDirectory().then((path) {
        applyPath(path!);
      });
    }

    super.initState();
  }

  applyPath(Directory directory) async {
    settingsManager = SettingsManager(
      directory: directory,
    );
    await settingsManager!.initialize();

    setState(() {
      ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const lightScheme = [
      Color.fromARGB(255, 238, 235, 255),
      Color.fromARGB(255, 13, 71, 161),
    ];

    const darkScheme = [
      Color.fromARGB(255, 28, 28, 28),
      Color.fromARGB(255, 122, 104, 212),
    ];

    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      themeMode: settingsManager?.config.themeMode ?? ThemeMode.system,
      darkTheme: ThemeData.dark().copyWith(
        //  brightness: Brightness.dark,
        primaryColor: darkScheme[0],
        dialogBackgroundColor: darkScheme[0],
        scaffoldBackgroundColor: Colors.black87,
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: CustomUnderlineTabIndicator(
            borderSide: BorderSide(
              color: darkScheme[1],
              width: 3,
            ),
          ),
          unselectedLabelColor: Colors.white.withOpacity(0.5),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: darkScheme[0],
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: darkScheme[1],
            padding: const EdgeInsets.all(00),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          circularTrackColor: const Color.fromARGB(255, 44, 37, 78),
          color: darkScheme[1],
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkScheme[0],
          foregroundColor: Colors.white,
        ),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: darkScheme[1]),
        // colorScheme: ColorScheme(background: Colors.black87),
        bottomAppBarTheme: BottomAppBarTheme(color: darkScheme[0]),
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: lightScheme[0],
        dialogBackgroundColor: lightScheme[0],
        scaffoldBackgroundColor: Colors.white,
        tabBarTheme: TabBarTheme(
          labelColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: CustomUnderlineTabIndicator(
            borderSide: BorderSide(
              color: lightScheme[1],
              width: 3,
            ),
          ),
          unselectedLabelColor: Colors.black.withOpacity(0.5),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: lightScheme[0],
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: lightScheme[1],
            padding: const EdgeInsets.all(00),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          circularTrackColor: const Color.fromARGB(255, 203, 201, 218),
          color: lightScheme[1],
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightScheme[0],
          foregroundColor: Colors.black,
        ),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: lightScheme[1]),
        // colorScheme: ColorScheme(background: Colors.white),
        bottomAppBarTheme: BottomAppBarTheme(color: lightScheme[0]),
      ),
      debugShowCheckedModeBanner: false,
      home: ready
          ? Home(
              settingsManager: settingsManager!,
            )
          : const Scaffold(
              backgroundColor: Colors.black,
            ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
