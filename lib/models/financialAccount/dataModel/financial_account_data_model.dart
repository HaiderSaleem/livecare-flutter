import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/consumer/dataModel/consumer_ref_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/restriction_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

import '../../request/dataModel/location_ref_data_model.dart';

class FinancialAccountDataModel extends BaseDataModel {
  String organizationId = "";

  String szName = "";
  String szLast4 = "";
  String szMerchant = "";
  EnumFinancialAccountType enumType = EnumFinancialAccountType.cash;
  bool isClosed = false;
  double fBalance = 0.0;

  ConsumerRefDataModel refConsumer = ConsumerRefDataModel();
  LocationRefDataModel refLocation = LocationRefDataModel();

  List<RestrictionDataModel> arrayRestrictions = [];

  @override
  void initialize() {
    super.initialize();

    organizationId = "";
    szName = "";
    szLast4 = "";
    szMerchant = "";

    enumType = EnumFinancialAccountType.cash;
    isClosed = false;
    fBalance = 0.0;
    refLocation = LocationRefDataModel();
    refConsumer = ConsumerRefDataModel();
    arrayRestrictions = [];
  }

  @override
  void deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "lastFour")) {
      szLast4 = UtilsString.parseString(dictionary["lastFour"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "marchant")) {
      szMerchant = UtilsString.parseString(dictionary["marchant"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "type")) {
      enumType = FinancialAccountTypeExtension.fromString(UtilsString.parseString(dictionary["type"]));
    }
    if (UtilsBaseFunction.containsKey(dictionary, "closed")) {
      isClosed = UtilsString.parseBool(dictionary["closed"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "balance")) {
      fBalance = UtilsString.parseDouble(dictionary["balance"], 0.0);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "organization")) {
      final Map<String, dynamic> organization = dictionary["organization"];
      if (UtilsBaseFunction.containsKey(organization, "organizationId")) {
        organizationId = UtilsString.parseString(organization["organizationId"]);
      }
    }
    if (UtilsBaseFunction.containsKey(dictionary, "consumer")) {
      final Map<String, dynamic> consumer = dictionary["consumer"];
      refConsumer.deserialize(consumer);
      refConsumer.organizationId = organizationId;
    }
    if (UtilsBaseFunction.containsKey(dictionary, "location")) {
      final Map<String, dynamic> location = dictionary["location"];
      refLocation.deserialize(location);
      refLocation.organizationId = organizationId;
    }

    if (UtilsBaseFunction.containsKey(dictionary, "restrictions")) {
      final List<dynamic> restrictions = dictionary["restrictions"];
      for (int i in Iterable.generate(restrictions.length)) {
        final dict = restrictions[i];
        final r = RestrictionDataModel();
        r.deserialize(dict);
        if (r.isValid()) {
          arrayRestrictions.add(r);
        }
      }
    }
  }

  Map<String, dynamic> serializeForCreate() {
    return {"type": enumType.value, "name": szName, "merchant": szMerchant, "lastFour": szLast4, "startingBalance": fBalance};
  }

  bool isSharedAccount() {
    return refLocation.isValid();
  }

  String getGiftCardNumber() {
    if (enumType == EnumFinancialAccountType.giftCard) {
      final cardNumber = szLast4;
      return "(...$cardNumber)"; //String.format("(...%s)", cardNumber.subSequence(cardNumber.length - 4, 4))
    } else {
      return "";
    }
  }
}

enum EnumFinancialAccountType { unknown, cash, foodStamp, giftCard, spendDown, bankLedger }

extension FinancialAccountTypeExtension on EnumFinancialAccountType {
  static EnumFinancialAccountType fromString(String? type) {
    if (type == null || type == "") return EnumFinancialAccountType.unknown;

    if (type.toLowerCase() == EnumFinancialAccountType.cash.value.toLowerCase()) {
      return EnumFinancialAccountType.cash;
    }
    if (type.toLowerCase() == EnumFinancialAccountType.foodStamp.value.toLowerCase()) {
      return EnumFinancialAccountType.foodStamp;
    }
    if (type.toLowerCase() == EnumFinancialAccountType.giftCard.value.toLowerCase()) {
      return EnumFinancialAccountType.giftCard;
    }
    if (type.toLowerCase() == EnumFinancialAccountType.spendDown.value.toLowerCase()) {
      return EnumFinancialAccountType.spendDown;
    }
    if (type.toLowerCase() == EnumFinancialAccountType.bankLedger.value.toLowerCase()) {
      return EnumFinancialAccountType.bankLedger;
    }

    return EnumFinancialAccountType.unknown;
  }

  String get value {
    switch (this) {
      case EnumFinancialAccountType.unknown:
        return "";
      case EnumFinancialAccountType.cash:
        return "Cash";
      case EnumFinancialAccountType.foodStamp:
        return "Food Stamp";
      case EnumFinancialAccountType.giftCard:
        return "Gift Card";
      case EnumFinancialAccountType.spendDown:
        return "Spend Down";
      case EnumFinancialAccountType.bankLedger:
        return "Bank Ledger";
    }
  }
}
