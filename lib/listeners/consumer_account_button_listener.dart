import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';

abstract class ConsumerAccountButtonListener {
  onClickedNewTransaction(FinancialAccountDataModel account, int position);

  onClickedHistory(FinancialAccountDataModel account, int position);

  onClickedAudit(FinancialAccountDataModel account, int position);
}
