import 'package:livecare/utils/utils_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UtilsGeneral {

  static void log(String text) {
    if (UtilsConfig.shouldLogForDebugging) {
      print("[livecare] : $text");
    } else {
      print("[livecare] : $text");
    }
  }

  static String getApiBaseUrl() {
    if (UtilsConfig.enumAppEnvironment == EnumAppEnvironment.dev) {
      return "http://localhost:3000";
    }
    if (UtilsConfig.enumAppEnvironment == EnumAppEnvironment.sandbox) {
      return "https://sandbox-livecare-api.onseen.com";
    }
    if (UtilsConfig.enumAppEnvironment == EnumAppEnvironment.staging) {
      return "https://staging-livecare-api.onseen.com";
    }

    if (UtilsConfig.enumAppEnvironment == EnumAppEnvironment.production) {
      //return "https://livecare-api.onseen.com";
      return "https://livecare-api-prd.onseen.com";
    }

    return "https://sandbox-livecare-api.onseen.com";

  }

  static Future<String> getAppVersionString() async {
    final info = await PackageInfo.fromPlatform();
    var appVersion = info.version;
    return appVersion;
  }

  static Future<String> getAppBuildString() async {
    final info = await PackageInfo.fromPlatform();
    return info.buildNumber;
  }


  static Future<String> getBeautifiedAppVersionInfo() async {
    if (UtilsConfig.enumAppEnvironment == EnumAppEnvironment.sandbox) {
      return "Version " +
          await getAppVersionString() +
          " - " +
          await getAppBuildString() +
          " - DEV";
    } else if (UtilsConfig.enumAppEnvironment == EnumAppEnvironment.staging) {
      return "Version " + await getAppVersionString() + " - QA";
    } else if (UtilsConfig.enumAppEnvironment ==
        EnumAppEnvironment.production) {
      return "Version " + await getAppVersionString();
    } else {
      return "Version " + await getAppVersionString() + " - DEV";
    }
  }

  static const String consumersListUpdated = "LiveCare.Consumers.ListUpdated";
  static const String transactionsListUpdated = "LiveCare.Transactions.ListUpdated";
  static const String inviteListUpdated = "LiveCare.invite.ListUpdated";
  static const String organizationListUpdated = "LiveCare.Organizations.ListUpdated";
  static const String routesListUpdated = "LiveCare.routes.ListUpdated";
  static const String experienceListUpdated = "LiveCare.Experiences.ListUpdated";

}

enum EnumAppEnvironment {
  dev,
  sandbox,
  staging,
  production
}


extension AppEnviromentExtension on EnumAppEnvironment {
  static EnumAppEnvironment fromString(int? status) {
    if (status == null) {
      return EnumAppEnvironment.sandbox;
    }
    for (EnumAppEnvironment t in EnumAppEnvironment.values) {
      if (status == t.value) return t;
    }
    return EnumAppEnvironment.sandbox;
  }


  int get value {
    switch (this) {
      case EnumAppEnvironment.dev:
        return -1;
      case EnumAppEnvironment.sandbox:
        return 0;
      case EnumAppEnvironment.staging:
        return 1;
      case EnumAppEnvironment.production:
        return 2;
      default:
        return 0;
    }
  }
}
