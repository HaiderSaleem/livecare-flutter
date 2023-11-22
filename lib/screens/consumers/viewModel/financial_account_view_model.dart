import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';

import '../../../models/consumer/dataModel/consumer_ref_data_model.dart';
import '../../../models/request/dataModel/location_ref_data_model.dart';

class FinancialAccountViewModel {
  ConsumerRefDataModel refConsumer = ConsumerRefDataModel();
  LocationRefDataModel refLocation = LocationRefDataModel();

  String szName = "";
  String szMerchant = "";
  String szLast4 = "";
  double fStartingBalance = 0.0;
  String szDescription = "";

  initialize() {
    refConsumer = ConsumerRefDataModel();
    refLocation = LocationRefDataModel();
    szName = "";
    szLast4 = "";
    fStartingBalance = 0.0;
    szDescription = "";
  }

  FinancialAccountDataModel toDataModel() {
    final account = FinancialAccountDataModel();
    account.szName = szName;
    account.szLast4 = szLast4;
    account.szMerchant = szMerchant;
    account.enumType = EnumFinancialAccountType.giftCard;
    account.fBalance = fStartingBalance;
    account.refConsumer = refConsumer;
    account.refLocation = refLocation;
    return account;
  }
}
