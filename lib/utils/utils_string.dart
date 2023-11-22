import 'dart:math';
import 'package:intl/intl.dart';
import 'package:livecare/utils/string_extensions.dart';


class UtilsString {
  static String parseString(dynamic value, {String defaultValue = ""}) {
    String szResult = defaultValue;

    if (value == null) {
      return szResult;
    } else if (value == "null") {
      return szResult;
    }
    szResult = value.toString();
    return szResult;
  }



  static int parseInt(dynamic value, int? defaultValue) {
    int defValue = defaultValue ?? 0;

    if (value == null || value.toString().isEmpty) return defValue;

    if (value is int) return value;

    defValue = double.parse(value.toString()).round();
    return defValue;
  }



  static double parseDouble(dynamic value, double? defaultValue) {
    double defValue = defaultValue ?? 0.0;

    if (value == null ||
        value.toString().isEmpty ||
        value.toString() == "null" ||
        value == ".") return defValue;

    if (value is double) return value;

    defValue = double.parse(value.toString());
    return defValue;
  }

  static bool parseBool(dynamic value, bool? defaultValue) {
    bool defValue = defaultValue ?? false;

    if (value == null) return defValue;

    if (value is bool) return value;

    defValue = value.toString().toBool();
    return defValue;
  }



  static String padLeadingZerosForTwoDigits(int value) {
    if (value > 9) {
      return value.toString();
    }
    return "0${value.toString()}";
  }

  static String generateRandomString(int length) {
    String letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => letters.codeUnitAt(_rnd.nextInt(letters.length))));
  }



  static bool isLetterOrDigit(String s) =>
      s.contains(RegExp(r'[\da-zA-Z]'));

  static String stripNonNumericsFromString(String? text) {
    if (text == null) return "";
    return text.codeUnits
        .map((e) => String.fromCharCode(e))
        .where((element) => isLetterOrDigit(element))
        .join("");
  }


  static String beautifyPhoneNumber(String? phone) {
    String phoneNumber = stripNonNumericsFromString(phone);
    String szPattern = "(xxx) xxx-xxxx";
    int nMaxLength = szPattern.length;
    String szFormattedNumber = "";
    if (phoneNumber.length > 10) {
      phoneNumber = phoneNumber.substring(phoneNumber.length - 10);
    }
    int index = 0;
    for (int i in Iterable.generate(phoneNumber.length)) {
      int r = szPattern.indexOf("x", index);
      if (r <= 0) break;
      if (r != index) {
        szFormattedNumber += szPattern.substring(index, r);
      }
      szFormattedNumber += phoneNumber.substring(i, i + 1);
      index = r + 1;
    }
    if (phoneNumber.isNotEmpty && (phoneNumber.length < szPattern.length)) {
      int r = szPattern.indexOf("x", szFormattedNumber.length);
      if (r > 0) {
        szFormattedNumber += szPattern.substring(szFormattedNumber.length, r);
      } else {
        szFormattedNumber +=
            szPattern.substring(szFormattedNumber.length, szPattern.length);
      }
    }
    if (szFormattedNumber.length > nMaxLength) {
      szFormattedNumber = szFormattedNumber.substring(0, nMaxLength);
    }
    return szFormattedNumber;
  }

  static String beautifyAmount(double? amount) {
    if (amount == null) return "\$0.00";
    return NumberFormat.currency(locale: "en_US", symbol: "\$").format(amount);
  }

  static String getStringForDictionary(Map<String, dynamic>? data) {
    if (data == null) return "{}";
    List<String> contents = [];
    Iterator<String> keys = data.keys as Iterator<String>;
    while (keys.moveNext()) {
      String cKey = keys.current;
      if (data.containsKey(cKey)) {
        dynamic value = data[cKey];
        String? v = getStringForValue(value);
        contents.add("\"$cKey\": $v");
      }
    }
    if (contents.isEmpty) return "{}";
    String result = contents[0];
    for (int i in Iterable.generate(contents.length)) {
      String item = contents[i];
      result = "$result, $item";
    }
    return "{$result}";
  }

  static String? getStringForValue(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is int) {
      return "$value";
    } else if (value is String) {
      String s = value.toString();
      s = s.replaceAll("\n", "\\n");
      return "\"" + s + "\"";
    } else if (value is bool) {
      if (value.toString().toBool()) {
        return "true";
      } else {
        return "false";
      }
    } else if (value is double) {
      return "$value";
    } else if (value is List<dynamic>) {
      List<String?> arrayString = [];
      List<dynamic> arr = value;

      for (int i in Iterable.generate(arr.length)) {
        dynamic obj = arr[i];
        arrayString.add(getStringForValue(obj));
      }
      if (arrayString.isEmpty) return "[]";
      dynamic result = arrayString[0];
      for (int i in Iterable.generate(arrayString.length)) {
        if (i == 0) continue;
        dynamic item = arrayString[i];
        result = "$result, $item";
      }
      return '[' + result + ']';
    } else if (value is List<Map<String, dynamic>>) {
      List<String?> arrayString = [];
      for (int i in Iterable.generate(value.length)) {
        dynamic obj = value[i];
        arrayString.add(getStringForValue(obj));
      }
      if (arrayString.isEmpty) return "[]";
      dynamic result = arrayString[0];
      for (int i in Iterable.generate(arrayString.length)) {
        if (i == 0) continue;
        dynamic item = arrayString[i];
        result = "$result, $item";
      }
      return '[' + result + ']';
    } else if (value is Map<String, dynamic>) {
      return getStringForDictionary(value);
    }
    return value.toString();
  }

  static double roundDouble2(double value) {
    return (value * 100).round() / 100;
  }

  static bool compareDouble2(double value1, double value2) {
    double v1 = (value1 * 100).round() / 100;
    double v2 = (value2 * 100).round() / 100;
    if ((v1 - v2).abs() < 0.001) {
      return true;
    }
    return false;
  }
}

enum ErrorCode { userLoginInvalidCredentials }

extension ErrorCodeExtension on ErrorCode {
  String get name {
    switch (this) {
      case ErrorCode.userLoginInvalidCredentials:
        return 'INVALID_CREDENTIALS_ERROR';
      default:
        return "";
    }
  }
}
