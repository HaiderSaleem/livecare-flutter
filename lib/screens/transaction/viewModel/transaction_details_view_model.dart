import 'dart:io';

import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/transaction/dataModel/transaction_data_model.dart';
import 'package:livecare/models/transaction/transaction_manager.dart';

class TransactionDetailsViewModel {
  ConsumerDataModel? modelConsumer;
  FinancialAccountDataModel? modelAccount;
  TransactionDataModel? modelPendingTransaction;
  bool isSharedAccount = false;

  double fAmount = 0.0;
  double fRemainingDeposit = 0.0;
  File? imageConsumerSignature;

  initialize() {
    modelConsumer = null;
    modelAccount = null;
    modelPendingTransaction = null;
    isSharedAccount = false;

    fAmount = 0;
    fRemainingDeposit = 0.0;
    imageConsumerSignature = null;
  }

  setModelAccount(FinancialAccountDataModel? account) {
    modelAccount = account;
    if (isSharedAccount) {
      if (account != null) {
        if (account.refLocation.isValid()) {
          modelPendingTransaction = TransactionManager.sharedInstance.getPendingTransactionForLocationAccount(account.refLocation.id, account.id);
        }
      }
    } else {
      if (modelConsumer != null && modelAccount != null) {
        modelPendingTransaction = TransactionManager.sharedInstance.getPendingTransactionForAccount(modelConsumer!.id, modelAccount!.id);
      }
    }
  }

  FinancialAccountDataModel? getModelAccount() {
    return modelAccount;
  }

  String getConsumerName() {
    if (modelConsumer == null) return "";
    return modelConsumer!.szName;
  }

  String getAccountName() {
    if (modelAccount == null) return "";
    return modelAccount!.szName;
  }

  // Returns pending amount of the account which current transaction (self) is tied with.
  double getPendingAmount() {
    return modelPendingTransaction?.fAmount ?? 0;
  }

  bool hasConsumerSigned() {
    return imageConsumerSignature != null;
  }

  bool hasValidAmount() {
    return fAmount > 0.01;
  }

  refreshPendingTransaction() {
    // Re-assigning itself: This will re-detect pending transaction
    setModelAccount(modelAccount!);
  }
}
