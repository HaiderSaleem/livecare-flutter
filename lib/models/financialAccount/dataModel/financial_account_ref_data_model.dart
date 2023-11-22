import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class FinancialAccountRefDataModel {
  String accountId = "";
  EnumFinancialAccountType enumType = EnumFinancialAccountType.cash;
  String szName = "";

  initialize() {
    accountId = "";
    enumType = EnumFinancialAccountType.cash;
    szName = "";
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    if (UtilsBaseFunction.containsKey(dictionary, "accountId")) {
      accountId = UtilsString.parseString(dictionary["accountId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "type")) {
      enumType = FinancialAccountTypeExtension.fromString(
          UtilsString.parseString(dictionary["type"]));
    }
    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
  }
}
