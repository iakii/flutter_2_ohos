/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     Musify is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Musify is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Musify, including how to contribute,
 *     please visit: https://github.com/gokadzev/Musify
 */

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:musify/services/audio_service.dart';
import 'package:musify/services/data_manager.dart';
import 'package:musify/services/logger_service.dart';
import 'package:musify/services/router_service.dart';
import 'package:musify/services/settings_manager.dart';
import 'package:musify/services/update_manager.dart';
import 'package:musify/style/app_themes.dart';
import 'package:musify/utilities/proxy.dart';
import 'package:path_provider/path_provider.dart';

late MusifyAudioHandler audioHandler;

final logger = Logger();

bool isFdroidBuild = false;
bool isUpdateChecked = false;

final appLanguages = <String, String>{
  'Chinese': 'zh',
  'English': 'en',
  'Arabic': 'ar',
  'French': 'fr',
  'Galician': 'gl',
  'Georgian': 'ka',
  'German': 'de',
  'Greek': 'el',
  'Indonesian': 'id',
  'Italian': 'it',
  'Japanese': 'ja',
  'Korean': 'ko',
  'Russian': 'ru',
  'Polish': 'pl',
  'Portuguese': 'pt',
  'Spanish': 'es',
  'Turkish': 'tr',
  'Ukrainian': 'uk',
};

final appSupportedLocales = appLanguages.values
    .map((languageCode) => Locale.fromSubtags(languageCode: languageCode))
    .toList();

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class Musify extends StatefulWidget {
  const Musify({super.key});

  static Future<void> updateAppState(
    BuildContext context, {
    ThemeMode? newThemeMode,
    Locale? newLocale,
    Color? newAccentColor,
    bool? useSystemColor,
  }) async {
    context.findAncestorStateOfType<_MusifyState>()!.changeSettings(
          newThemeMode: newThemeMode,
          newLocale: newLocale,
          newAccentColor: newAccentColor,
          systemColorStatus: useSystemColor,
        );
  }

  @override
  _MusifyState createState() => _MusifyState();
}

class _MusifyState extends State<Musify> {
  void changeSettings({
    ThemeMode? newThemeMode,
    Locale? newLocale,
    Color? newAccentColor,
    bool? systemColorStatus,
  }) {
    setState(() {
      if (newThemeMode != null) {
        themeMode = newThemeMode;
        brightness = getBrightnessFromThemeMode(newThemeMode);
      }
      if (newLocale != null) {
        languageSetting = newLocale;
      }
      if (newAccentColor != null) {
        if (systemColorStatus != null &&
            useSystemColor.value != systemColorStatus) {
          useSystemColor.value = systemColorStatus;
          addOrUpdateData(
            'settings',
            'useSystemColor',
            systemColorStatus,
          );
        }
        primaryColorSetting = newAccentColor;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });

    try {
      LicenseRegistry.addLicense(() async* {
        final license =
            await rootBundle.loadString('assets/licenses/paytone.txt');
        yield LicenseEntryWithLineBreaks(['paytoneOne'], license);
      });
    } catch (e, stackTrace) {
      logger.log('License Registration Error', e, stackTrace);
    }

    if (!isFdroidBuild &&
        !isUpdateChecked &&
        !offlineMode.value &&
        kReleaseMode) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        checkAppUpdates();
        isUpdateChecked = true;
      });
    }
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        final colorScheme =
            getAppColorScheme(lightColorScheme, darkColorScheme);

        return MaterialApp.router(
          themeMode: themeMode,
          scrollBehavior: MyCustomScrollBehavior(),
          darkTheme: getAppTheme(colorScheme),
          theme: getAppTheme(colorScheme),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: appSupportedLocales,
          locale: languageSetting,
          routerConfig: NavigationManager.router,
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  JustAudioMediaKit.ensureInitialized(
    android: true, // default: false - dependency: media_kit_libs_android_audio
    iOS: true, // default: false - dependency: media_kit_libs_ios_audio
    macOS: true, // default: false - dependency: media_kit_libs_macos_audio
  );
  JustAudioMediaKit.bufferSize = 12 * 1024 * 1024;
  JustAudioMediaKit.prefetchPlaylist = false;
  JustAudioMediaKit.pitch = true;
  JustAudioMediaKit.protocolWhitelist = const [
    ...['udp', 'rtp', 'tcp', 'tls', 'data', 'file', 'http', 'https', 'crypto'],
  ];

  // JustAudioMediaKit.mpvLogLevel = MPVLogLevel.debug;
  await initialisation();

  ProxyClient.toggle();

  runApp(const Musify());
}

Future<void> initialisation() async {
  try {
    final dir = await getApplicationSupportDirectory();

    await Hive.initFlutter(dir.path);

    final boxNames = ['settings', 'user', 'userNoBackup', 'cache'];

    for (final boxName in boxNames) {
      await Hive.openBox(boxName);
    }

    audioHandler = await AudioService.init(
      builder: MusifyAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.gokadzev.musify',
        androidNotificationChannelName: 'Musify',
        androidNotificationIcon: 'drawable/ic_launcher_foreground',
        androidShowNotificationBadge: true,
      ),
    );

    // Init router
    NavigationManager.instance;
  } catch (e, stackTrace) {
    logger.log('Initialization Error', e, stackTrace);
  }
}
