import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/splash.dart';
import 'package:livecare/utils/location_manager.dart';
import 'package:new_version/new_version.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load();
    // debugPrintRebuildDirtyWidgets = true;

    LCLocationManager.sharedInstance.initializeLocationManager();
    NetworkReachabilityManager.sharedInstance.initializeNetworkReachabilityManager();

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Initialize Firebase before any other Firebase services are accessed
    await Firebase.initializeApp();

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: AppColors.primaryColor, statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.light));

    runApp(const MyApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkForNewVersion();
    setupTimezone();
  }

  // Method to decide which check to perform
  void _checkForNewVersion() {
    final newVersion = NewVersion();
    const simpleBehavior = true;

    if (simpleBehavior) {
      _basicStatusCheck(newVersion);
    } else {
      _advancedStatusCheck(newVersion);
    }
  }

  void _basicStatusCheck(NewVersion newVersion) {
    newVersion.showAlertIfNecessary(context: context);
  }

  Future<void> _advancedStatusCheck(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      debugPrint(status.releaseNotes);
      debugPrint(status.appStoreLink);
      debugPrint(status.localVersion);
      debugPrint(status.storeVersion);
      debugPrint(status.canUpdate.toString());

      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'Update Available',
        dialogText: 'You can now update this app from version '
            '${status.localVersion} to ${status.storeVersion}',
      );
    }
  }

  void setupTimezone() {
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppStyles.appTheme,
      home: const SplashScreen(),
    );
  }
}
