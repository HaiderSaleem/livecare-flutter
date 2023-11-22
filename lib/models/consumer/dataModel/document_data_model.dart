import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class DocumentDataModel {
  String documentId = "";
  String szName = "";

  MediaDataModel? modelMedia = MediaDataModel();
  DateTime? dateUploadedAt;

  initialize() {
    documentId = "";
    szName = "";
    modelMedia = MediaDataModel();
    dateUploadedAt = null;
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "documentId")) {
      documentId = UtilsString.parseString(dictionary["documentId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "media")) {
      final Map<String, dynamic> user = dictionary["media"];
      modelMedia!.deserialize(user);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "uploadDate")) {
      dateUploadedAt = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["uploadDate"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
  }

  bool isValid() {
    return documentId.isNotEmpty;
  }
}
