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

  initialize() {
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
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;

    if (!UtilsBaseFunction.containsKey(dictionary, "transferId")) {
      return;
    }
    transferId = UtilsString.parseString(dictionary["transferId"]);

    if (UtilsBaseFunction.containsKey(dictionary, "companions")) {
      final List<dynamic> companions = dictionary["companions"];
      for (int i in Iterable.generate(companions.length)) {
        final Map<String, dynamic> json = companions[i];
        final c = CompanionDataModel();
        c.deserialize(json);
        arrayCompanions.add(c);
      }
    }
    enumType = TransferTypeExtension.fromString(
        UtilsString.parseString(dictionary["type"]));

    szName = UtilsString.parseString(dictionary["name"]);
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
    final Map<String, dynamic> needs = dictionary["specialNeeds"];

    modelSpecialNeeds.deserialize(needs);
  }

  Map<String, dynamic> serializeForCreateRequest() {
    final Map<String, dynamic> jsonObject = {};
    jsonObject["transferId"] = transferId;
    jsonObject["type"] = enumType;
    List<dynamic> array = [];
    for (var c in arrayCompanions) {
      array.add(c.serializeForUpdate());
    }
    jsonObject["companions"] = array;
    return jsonObject;
  }

  String getBestContactNumber() {
    if (szPhone.isNotEmpty) {
      return UtilsString.beautifyPhoneNumber(szPhone);
    } else if (szEmail.isNotEmpty) {
      return szEmail;
    }
    return "N/A";
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
