import 'package:intl/intl.dart';

class UtilsDate {
/*
  old code
  static DateTime? getDateTimeFromStringWithFormat(
      String? value, String? format,
      [bool timeZone = false]) {
    if (value == null || value == "") return null;
    final strFormat = format ?? EnumDateTimeFormat.MMddyyyy_hhmma.value;
    final df = DateFormat(strFormat, "en_US");
    final DateTime date = df.parse(value, timeZone);
    return date;
  }

  */

//new code

  static DateTime? getDateTimeFromStringWithFormatToApi(String? value, String? format, [bool timeZone = false]) {
    if (value == null || value == "") return null;
    final strFormat = format ?? EnumDateTimeFormat.MMddyyyy_hhmma.value;
    final df = DateFormat(strFormat, "en_US");
    var date = df.parse(value, timeZone);
    return date.toLocal().toUtc();
  }

  static String getStringFromDateTimeWithFormatToApi(DateTime? dateTime, String? format, [bool timeZone = false]) {
    if (dateTime == null) return "";
    final strFormat = format ?? EnumDateTimeFormat.MMddyyyy_hhmma.value;
    final df = DateFormat(strFormat, "en_US");
    return df.format(dateTime.toUtc());
  }

  static String getStringFromDateTimeWithFormat(DateTime? dateTime, String? format, [bool timeZone = false]) {
    if (dateTime == null) return "";
    final strFormat = format ?? EnumDateTimeFormat.MMddyyyy_hhmma.value;
    final df = DateFormat(strFormat, "en_US");
    return df.format(dateTime.toLocal());
  }

  static DateTime? getDateTimeFromStringWithFormatFromApi(String? value, String? format, [bool timeZone = false]) {
    if (value == null || value == "") return null;
    final strFormat = format ?? EnumDateTimeFormat.MMddyyyy_hhmma.value;
    final df = DateFormat(strFormat, "en_US");
    final DateTime date = df.parse(value, timeZone).toLocal();
    return date;
  }

  /* fun getDateTimeFromStringWithFormat(
  value: String?,
  format: String?,
  timeZone: TimeZone?
  ): Date? {
  if (value == null || value == "") return null

  val strFormat = format ?: EnumDateTimeFormat.MMddyyyy_hhmma.value

  val parseFormat = SimpleDateFormat(strFormat, Locale.US)
  parseFormat.timeZone = timeZone ?: TimeZone.getDefault()

  val date = parseFormat.parse(value)
  return date
  }*/

/*  static DateTime? getDateTimeFromStringWithFormatN(String? value, String? format, [bool timeZone = false]) {
    if (value == null || value == "") return null;
    var dateTime = DateFormat(format).parse(value, true);
    var dateLocal = dateTime.toLocal();

    return dateLocal;
  }*/

/*
  fun getStringFromDateTimeWithFormat(
  dateTime: Date?,
  format: String?,
  timeZone: TimeZone?
  ): String {

  if (dateTime == null) return ""
  val df = SimpleDateFormat(format ?: EnumDateTimeFormat.MMddyyyy_hhmma.value, Locale.US)
  df.timeZone = timeZone ?: TimeZone.getDefault()

  return df.format(dateTime)
  }*/

  static DateTime addHoursToDate(DateTime date, int hours) {
    if (hours < 0) {
      return date.subtract(Duration(hours: hours));
    } else {
      return date.add(Duration(hours: hours));
    }
  }

  static DateTime addMinutesToDate(DateTime date, int minutes) {
    return date.add(Duration(minutes: minutes));
  }

  static DateTime addDaysToDate(DateTime date, int days) {
    if (days < 0) {
      //-1
      date.subtract(const Duration(days: 1));
    } else {
      date.add(Duration(days: days.abs()));
    }
    return date;
  }

  static DateTime addSecondsToDate(DateTime date, int seconds) {
    date.add(Duration(seconds: seconds));
    return date;
  }

  static bool isSameDate(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;

    final String dateString1 = getStringFromDateTimeWithFormat(date1, EnumDateTimeFormat.yyyyMMdd.value, false);
    final String dateString2 = getStringFromDateTimeWithFormat(date2, EnumDateTimeFormat.yyyyMMdd.value, false);

    return dateString1 == dateString2;
  }

  static DateTime? mergeDateTime(DateTime? date, String time) {
    var sz = UtilsDate.getStringFromDateTimeWithFormat(date, EnumDateTimeFormat.MMddyyyy1.value, false);
    sz = sz + " " + time;
    return UtilsDate.getDateTimeFromStringWithFormatToApi(sz, EnumDateTimeFormat.MMddyyyy_hhmma.value, false);
  }
/* fun mergeDateTime(date: Date?, time: String): Date? {
  var sz = getStringFromDateTimeWithFormat(date, EnumDateTimeFormat.MMddyyyy1.value, null)
  sz = "$sz $time"
  return getDateTimeFromStringWithFormat(
  sz,
  EnumDateTimeFormat.MMddyyyy_hhmma.value,
  null)
}*/
}

enum EnumDateTimeFormat {
  yyyyMMdd_HHmmss_UTC, // 1989-03-17T11:00:00.000Z
  yyyyMMdd_HHmmss, // 1989-03-17T11:00:00
  yyyyMMdd, // 1989-03-17
  MMddyyyy_hhmma, // 03-17-1989 02:00 AM
  MMddyyyy, // 03-17-1989
  MMddyyyy1, // 03-17-1989
  MMdd, // 03/17
  EEEEMMMMdyyyy, // Friday, March 17, 1989
  MMMdyyyy, // Mar 17, 1989
  MMMMdd, // March 17
  hhmma, // 02:00 AM
  hhmma_MMMd, // 02:00 AM, Mar 17
  yyyyMMdd_HH00, //  1989-03-17 00:00:00.000
  MMMdyyyyhhmma // Mar 17, 1989
}

extension DateTimeFormatExtension on EnumDateTimeFormat {
  String get value {
    switch (this) {
      case EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC:
        return "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
      case EnumDateTimeFormat.yyyyMMdd_HHmmss:
        return "yyyy-MM-dd'T'HH:mm:ss";
      case EnumDateTimeFormat.yyyyMMdd:
        return "yyyy-MM-dd";
      case EnumDateTimeFormat.MMddyyyy_hhmma:
        return "MM-dd-yyyy hh:mm a";
      case EnumDateTimeFormat.MMddyyyy:
        return "MM/dd/yyyy";
      case EnumDateTimeFormat.MMddyyyy1:
        return "MM-dd-yyyy";
      case EnumDateTimeFormat.MMdd:
        return "MM/dd";
      case EnumDateTimeFormat.EEEEMMMMdyyyy:
        return "EEEE, MMMM d, yyyy";
      case EnumDateTimeFormat.MMMdyyyy:
        return "MMM d, yyyy";
      case EnumDateTimeFormat.MMMMdd:
        return "MMMM dd";
      case EnumDateTimeFormat.hhmma:
        return "hh:mm a";
      case EnumDateTimeFormat.hhmma_MMMd:
        return "hh:mm a, MMM d";
      case EnumDateTimeFormat.yyyyMMdd_HH00:
        return "yyyy-MM-dd";
      case EnumDateTimeFormat.MMMdyyyyhhmma:
        return "MMM d, yyyy, hh:mm a";
      default:
        return "";
    }
  }
}
