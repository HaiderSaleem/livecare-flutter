import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class RestrictionDataModel extends BaseDataModel {
  double fMaxSpend = 0.0;
  double fDiscretionarySpend = 0.0;
  EnumDiscretionarySpendPeriod enumSpendPeriod =
      EnumDiscretionarySpendPeriod.daily;
  DateTime? dateEffective;
  DateTime? dateExpiration;

  @override
  initialize() {
    super.initialize();

    fMaxSpend = 0.0;
    fDiscretionarySpend = 0.0;
    enumSpendPeriod = EnumDiscretionarySpendPeriod.daily;
    dateEffective = null;
    dateExpiration = null;
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "maxSpend")) {
      fMaxSpend = UtilsString.parseDouble(dictionary["maxSpend"], 0.0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "discretionarySpend")) {
      fDiscretionarySpend =
          UtilsString.parseDouble(dictionary["discretionarySpend"], 0.0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "discretionarySpendPeriod")) {
      enumSpendPeriod = DiscretionarySpendPeriodExtension.fromString(
          UtilsString.parseString(dictionary["discretionarySpendPeriod"]));
    }
    if (UtilsBaseFunction.containsKey(dictionary, "effectiveDate")) {
      dateEffective = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["effectiveDate"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "expirationDate")) {
      dateExpiration = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["expirationDate"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
  }
}

enum EnumDiscretionarySpendPeriod {
  weekly,
  daily,
}

extension DiscretionarySpendPeriodExtension on EnumDiscretionarySpendPeriod {
  static EnumDiscretionarySpendPeriod fromString(String? period) {
    if (period == null || period == ("")) {
      return EnumDiscretionarySpendPeriod.daily;
    }

    if (period.toLowerCase() ==
        EnumDiscretionarySpendPeriod.daily.toString().toLowerCase()) {
      return EnumDiscretionarySpendPeriod.daily;
    }
    if (period.toLowerCase() ==
        EnumDiscretionarySpendPeriod.weekly.toString().toLowerCase()) {
      return EnumDiscretionarySpendPeriod.weekly;
    }

    return EnumDiscretionarySpendPeriod.daily;
  }

  String get value {
    switch (this) {
      case EnumDiscretionarySpendPeriod.weekly:
        return "Weekly";
      case EnumDiscretionarySpendPeriod.daily:
        return "Daily";
    }
  }
}
