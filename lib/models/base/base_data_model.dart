import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class BaseDataModel {
  String id = "";
  DateTime? dateCreatedAt;
  DateTime? dateUpdatedAt;

  void initialize() {
    id = "";
    dateCreatedAt = null;
    dateUpdatedAt = null;
  }

  void deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;
    if (UtilsBaseFunction.containsKey(dictionary, "id")) {
      id = UtilsString.parseString(dictionary["id"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "createdAt")) {
      dateCreatedAt = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["createdAt"]), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "updatedAt")) {
      dateUpdatedAt = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["updatedAt"]), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    }
  }

  Map<String, dynamic> serialize() {
    return {};
  }

  bool isValid() {
    return id.isNotEmpty;
  }
}
