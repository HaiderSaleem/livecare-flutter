import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class ReceiptDataModel extends BaseDataModel {
  String szVendor = "";
  DateTime? date;
  MediaDataModel? modelMedia = MediaDataModel();
  List<String> arrayItems = [];

  @override
  initialize() {
    super.initialize();
    szVendor = "";
    date = null;
    modelMedia = MediaDataModel();
    arrayItems = [];
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "vendor")) {
      szVendor = UtilsString.parseString(dictionary["vendor"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "date")) {
      date = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["date"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "items")) {
      final List<dynamic> arrItems = dictionary["items"];
      for (int i in Iterable.generate(arrItems.length)) {
        final String item = UtilsString.parseString(arrItems[i]);
        arrayItems.add(item);
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "media")) {
      final Map<String, dynamic> media = dictionary["media"];
      modelMedia!.deserialize(media);
    }
  }

  @override
  Map<String, dynamic> serialize() {
    final Map<String, dynamic> result = {};

    result["vendor"] = szVendor;
    result["date"] = UtilsDate.getStringFromDateTimeWithFormatToApi(
        date ?? DateTime.now(),
        EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
        true);

    final List<dynamic> arr = [];
    for (var item in arrayItems) {
      arr.add(item);
    }
    result["items"] = arr;

    if (modelMedia?.id != "") {
      result["media"] = modelMedia!.serializeForCreateTransactionMedia();
    }

    return result;
  }

  static List<ReceiptDataModel> generateReceiptsFromMedia(
      List<MediaDataModel>? media) {
    if (media == null) return [];

    final List<ReceiptDataModel> receipts = [];
    for (var medium in media) {
      final r = ReceiptDataModel();
      r.modelMedia = medium;
      receipts.add(r);
    }

    return receipts;
  }
}
