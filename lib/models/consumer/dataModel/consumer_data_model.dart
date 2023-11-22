import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/consumer/dataModel/document_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/shared/companion_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class ConsumerDataModel extends BaseDataModel {
  String organizationId = "";
  String consumerId = "";

  // String szOrganizationName = "";
  String organizationName = "";
  String szExternalKey = "";
  String szName = "";
  String szNickname = "";
  String szRegion = "";

  // EnumConsumerStatus enumStatus = EnumConsumerStatus.active;
  ConsumerStatus enumStatus = ConsumerStatus.active;
  String szNotes = "";
  LocationDataModel? modelPrimaryLocation;

  // Additional Properties
  List<FinancialAccountDataModel>? arrayAccounts;
  List<DocumentDataModel> arrayDocuments = [];
  List<CompanionDataModel> arrayCompanions = [];
  List<CompanionDataModel> arrayConsumerCompanions = [];

  @override
  initialize() {
    super.initialize();
    organizationId = "";
    // szOrganizationName = "";
    organizationName = "";
    szExternalKey = "";
    szName = "";
    szNotes = "";
    szNickname = "";
    szRegion = "";
    enumStatus = ConsumerStatus.active;
    modelPrimaryLocation = null;
    arrayAccounts = null;
    arrayDocuments = [];
    arrayCompanions = [];
    arrayConsumerCompanions = [];
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "id")) {
      consumerId = UtilsString.parseString(dictionary["id"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "externalKey")) {
      szExternalKey = UtilsString.parseString(dictionary["externalKey"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "notes")) {
      szNotes = UtilsString.parseString(dictionary["notes"]);
    }
    // "nickname": null,
    if (UtilsBaseFunction.containsKey(dictionary, "nickname")) {
      szNickname = UtilsString.parseString(dictionary["nickname"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "region")) {
      szRegion = UtilsString.parseString(dictionary["region"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = ConsumerStatusExtension.fromString(UtilsString.parseString(dictionary["status"] ?? ''));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "organization")) {
      final Map<String, dynamic> org = dictionary["organization"];
      organizationId = UtilsString.parseString(org["organizationId"]);
      organizationName = UtilsString.parseString(org["name"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "primaryLocation")) {
      final Map<String, dynamic> primaryLocation = dictionary["primaryLocation"];
      modelPrimaryLocation = LocationDataModel();
      modelPrimaryLocation!.deserialize(primaryLocation);
      modelPrimaryLocation!.organizationId = organizationId;
    }

    if (UtilsBaseFunction.containsKey(dictionary, "documents")) {
      final List<dynamic> array = dictionary["documents"];
      for (int i in Iterable.generate(array.length)) {
        final json = array[i];
        final document = DocumentDataModel();
        document.deserialize(json);
        arrayDocuments.add(document);
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "companions")) {
      final List<dynamic> array = dictionary["companions"];
      for (int i in Iterable.generate(array.length)) {
        final json = array[i];
        final companion = CompanionDataModel();
        companion.deserialize(json);
        arrayCompanions.add(companion);
      }
    }
  }

  @override
  bool isValid() {
    return (id.isNotEmpty && enumStatus == ConsumerStatus.active);
  }

  // Financial Account Methods
  bool isFinancialAccountLoaded() {
    return (arrayAccounts != null);
  }

  FinancialAccountDataModel? getCashAccount() {
    if (!isFinancialAccountLoaded()) return null;
    return arrayAccounts!.firstWhere((element) => element.enumType == EnumFinancialAccountType.cash);
  }

  setAccountsWithSort(List<FinancialAccountDataModel>? newArray) {
    arrayAccounts = [];
    if (newArray == null) return;
    final baseArray = newArray;

    EnumOrganizationUserRole role = UserManager.sharedInstance.currentUser!.getPrimaryRole();

    if (role == EnumOrganizationUserRole.administrator || role == EnumOrganizationUserRole.pm) {
      arrayAccounts!.addAll(baseArray.where((element) => element.enumType == EnumFinancialAccountType.bankLedger && !element.isSharedAccount()));
    }

    /// Sort by: Petty-Cash, Food-Stamp, {{other types}} then Gift-Cards by alphabetical order
    /// Do not add Bank Ledger, Shared Account
    arrayAccounts!.addAll(baseArray.where((element) => element.enumType == EnumFinancialAccountType.cash && !element.isSharedAccount()));
    arrayAccounts!.addAll(baseArray.where((element) => element.enumType == EnumFinancialAccountType.foodStamp && !element.isSharedAccount()));
    arrayAccounts!.addAll(baseArray.where((element) => element.enumType == EnumFinancialAccountType.spendDown && !element.isSharedAccount()));

    var sortedArray = baseArray.where((element) => element.enumType == EnumFinancialAccountType.giftCard && !element.isSharedAccount()).toList();
    sortedArray.sort((a, b) => a.szName.toLowerCase().compareTo(b.szName.toLowerCase()));

    arrayAccounts!.addAll(sortedArray);
  }

  //Search Methods
  bool searchWithKeyword(String? keyword) {
    if (keyword == null) return true;
    final String queryText = keyword;

    if (queryText.trim().isEmpty) return true;

    var text = "$szName $szNickname $szExternalKey";
    if (modelPrimaryLocation != null) {
      final primaryLocationName = modelPrimaryLocation!.szName;
      final primaryLocationAddress = modelPrimaryLocation!.szAddress;
      text = "$szName $primaryLocationName $primaryLocationAddress";
    }
    return text.toLowerCase().contains(queryText.toLowerCase());
  }

  bool isValidRegion() {
    if (!UserManager.sharedInstance.isLoggedIn()) {
      return false;
    }

    if (UserManager.sharedInstance.currentUser == null) return false;
    final currentUser = UserManager.sharedInstance.currentUser;

    final role = currentUser!.getRoleByOrganizationId(organizationId);
    if (role == EnumOrganizationUserRole.administrator || role == EnumOrganizationUserRole.leadDSP) {
      return true;
    }

    final regions = currentUser.getRegionsByOrganizationId(organizationId);
    for (var region in regions) {
      if (region.toLowerCase() == szRegion.toLowerCase()) return true;
    }
    return false;
  }
}

//enum EnumConsumerStatus { active, deleted }
enum ConsumerStatus { active, deleted }

extension ConsumerStatusExtension on ConsumerStatus {
  static ConsumerStatus fromString(String? status) {
    if (status == null || status == "") return ConsumerStatus.active;
    if (status.toLowerCase() == ConsumerStatus.active.value.toLowerCase()) {
      return ConsumerStatus.active;
    }
    if (status.toLowerCase() == ConsumerStatus.deleted.value.toLowerCase()) {
      return ConsumerStatus.deleted;
    }
    return ConsumerStatus.active;
  }

  String get value {
    switch (this) {
      case ConsumerStatus.active:
        return "Active";
      case ConsumerStatus.deleted:
        return "Deleted";
    }
  }
}
