import 'package:livecare/models/shared/companion_data_model.dart';
import 'package:livecare/models/shared/special_needs_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class TransferDataModel {
  String transferId = "";
  List<CompanionDataModel> arrayCompanions = [];
  bool isNotificationMessageEnabled = true;
  bool isNotificationEmailEnabled = true;
  bool isNotificationSmsEnabled = true;

  List<String> arrayRestrictions = [];

  SpecialNeedsDataModel modelSpecialNeeds = SpecialNeedsDataModel();
  EnumTransferType enumType = EnumTransferType.consumer;

  String szName = "";
  String szNickname = "";
  String szPhone = "";
  String szEmail = "";
  String szExternalKey = "";
  String szNotes = "";

  int nLoadTime = 0;
  int nUnloadTime = 0;

  _initialize() {
    transferId = "";
    arrayCompanions = [];
    isNotificationMessageEnabled = true;
    isNotificationEmailEnabled = true;
    isNotificationSmsEnabled = true;

    arrayRestrictions = [];

    modelSpecialNeeds = SpecialNeedsDataModel();
    enumType = EnumTransferType.consumer;

    szName = "";
    szNickname = "";
    szPhone = "";
    szEmail = "";
    szExternalKey = "";
    szNotes = "";

    nLoadTime = 0;
    nUnloadTime = 0;
  }

  deserialize(Map<String, dynamic>? dictionary) {
    _initialize();

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "transferId")) {
      transferId = UtilsString.parseString(dictionary["transferId"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "companions")) {
      final List<dynamic> companions = dictionary["companions"];
      for (int i in Iterable.generate(companions.length)) {
        final Map<String, dynamic> json = companions[i];
        final c = CompanionDataModel();
        c.deserialize(json);
        arrayCompanions.add(c);
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "type")) {
      enumType = TransferTypeExtension.fromString(
          UtilsString.parseString(dictionary["type"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "nickname")) {
      szNickname = UtilsString.parseString(dictionary["nickname"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "phone")) {
      szPhone = UtilsString.parseString(dictionary["phone"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "email")) {
      szEmail = UtilsString.parseString(dictionary["email"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "externalKey")) {
      szExternalKey = UtilsString.parseString(dictionary["externalKey"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "notes")) {
      szNotes = UtilsString.parseString(dictionary["notes"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "loadTime")) {
      nLoadTime = UtilsString.parseInt(dictionary["loadTime"], 0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "unloadTime")) {
      nUnloadTime = UtilsString.parseInt(dictionary["unloadTime"], 0);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "restrictions")) {
      final List<dynamic> array = dictionary["restrictions"];
      for (int i in Iterable.generate(array.length)) {
        final String str = array[i];
        arrayRestrictions.add(str);
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "notifications")) {
      final Map<String, dynamic> json = dictionary["notifications"];
      isNotificationMessageEnabled =
          UtilsString.parseBool(json["message"], true);
      isNotificationSmsEnabled = UtilsString.parseBool(json["sms"], true);
      isNotificationEmailEnabled = UtilsString.parseBool(json["email"], true);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "specialNeeds")) {
      final Map<String, dynamic> json = dictionary["specialNeeds"];
      modelSpecialNeeds.deserialize(json);
    }
  }

  Map<String, dynamic> serializeForCreateRequest() {
    final Map<String, dynamic> jsonObject = {};
    jsonObject["transferId"] = transferId;
    jsonObject["type"] = enumType.value;
    //arrayCompanions
    final List<dynamic> arrayCompanionsDict = [];
    for (var companion in arrayCompanions) {
      arrayCompanionsDict.add(companion.serializeForCreate());
    }
    jsonObject["companions"] = arrayCompanionsDict;
    return jsonObject;
  }
}

enum EnumTransferType {
  consumer,
  user,
  package,
}

extension TransferTypeExtension on EnumTransferType {
  static EnumTransferType fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumTransferType.consumer;
    }
    for (var t in EnumTransferType.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumTransferType.consumer;
  }

  String get value {
    switch (this) {
      case EnumTransferType.consumer:
        return "Consumer";
      case EnumTransferType.user:
        return "User";
      case EnumTransferType.package:
        return "Package";
    }
  }
}
