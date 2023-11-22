import 'package:livecare/utils/utils_date.dart';
import 'package:test/test.dart';
import 'dart:core';

class UtilsDateTest {}

void main() {
  group('UtilsDate', () {
    test('getStringFromDateTimeWithFormatToApi', () async {
      DateTime dt = DateTime(2023, 6, 26);
      print(dt.isUtc);
      String formated = UtilsDate.getStringFromDateTimeWithFormatToApi(dt, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
      print("getStringFromDateTimeWithFormatToApi: " + formated);
      expect('2023-06-26T04:00:00.000Z', formated);
    });
    test('getStringFromDateTimeWithFormat', () async {
      DateTime dt = DateTime.utc(2023, 6, 26, 4);
      print(dt.isUtc);
      String formated = UtilsDate.getStringFromDateTimeWithFormat(dt, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
      print("getStringFromDateTimeWithFormat: " + formated);
      expect('2023-06-26T00:00:00.000Z', formated);
    });
  });
}
