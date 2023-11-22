import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageManager {
  static const String LOCALSTORAGE_PREFIX = "LIVECARE.LOCALSTORAGE.V2";

  static saveGlobalObject(String? data, String keySuffix) async {
    final String key = LOCALSTORAGE_PREFIX + "." + keySuffix;
    final prefs = await SharedPreferences.getInstance();
    if (data == null) {
      prefs.remove(key);
    } else {
      prefs.setString(key, data);
    }
  }



  static Future<String?>? loadGlobalObject(String keySuffix) async {
    final String key = LOCALSTORAGE_PREFIX + "." + keySuffix;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static deleteGlobalObject(String keySuffix) async {
    final String key = LOCALSTORAGE_PREFIX + "." + keySuffix;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  static Future<bool> addStringToSF(String name, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(name, value);
  }

  static Future<String?> getStringFromSF(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(name) ?? '';
  }

  static Future<bool> addBoolToSF(String name, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(name, value);
  }

  static Future<bool?> getBoolFromSF(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(name) ?? false;
  }

}
