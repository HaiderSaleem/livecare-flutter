import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/financialAccount/financial_account_manager.dart';
import 'package:livecare/models/transaction/dataModel/receipt_data_model.dart';
import 'package:livecare/models/transaction/dataModel/transaction_data_model.dart';
import 'package:livecare/screens/transaction/viewModel/manual_receipt_view_model.dart';
import 'package:livecare/screens/transaction/viewModel/transaction_details_view_model.dart';

import '../../../models/consumer/dataModel/consumer_ref_data_model.dart';

class PurchaseViewModel {
  DateTime date = DateTime.now();
  String szMerchant = "";
  String szDescription = "";
  bool hasReceiptPhotos = true;
  bool hasRemainingDeposit = false;
  bool isSharedAccount = false;
  String szCategory = "";

  List<TransactionDetailsViewModel> arrayTransactionDetails = [TransactionDetailsViewModel()];
  ManualReceiptViewModel vmManualReceipt = ManualReceiptViewModel();
  List<ReceiptDataModel> arrayReceipt = [];
  List<File> arrayReceiptPhotos = [];
  File? imageCaregiverSignature;

  initialize() {
    date = DateTime.now();
    szMerchant = "";
    szDescription = "";
    szCategory = "";
    hasReceiptPhotos = true;
    hasRemainingDeposit = false;
    isSharedAccount = false;
    arrayTransactionDetails = [TransactionDetailsViewModel()];
    vmManualReceipt = ManualReceiptViewModel();
    arrayReceipt = [];
    arrayReceiptPhotos = [];
    imageCaregiverSignature = null;
  }

  double getTotalAmount() {
    double total = 0.0;
    for (var transaction in arrayTransactionDetails) {
      total = total + transaction.fAmount;
    }
    return total;
  }

  bool hasCaregiverSigned() {
    return imageCaregiverSignature != null;
  }

  bool hasConsumersSigned() {
    for (var transaction in arrayTransactionDetails) {
      if (!transaction.hasConsumerSigned()) {
        return false;
      }
    }
    return true;
  }

  List<TransactionDetailsViewModel> getTransactionDetailsForCashAccount() {
    final List<TransactionDetailsViewModel> array = [];
    for (var transaction in arrayTransactionDetails) {
      if (transaction.getModelAccount() != null) {
        if (transaction.getModelAccount()!.enumType == EnumFinancialAccountType.cash) {
          array.add(transaction);
        }
      }
    }
    return array;
  }

  Future<void> toDataModel(Function(List<TransactionDataModel>? transactions, String message) callback) async {
    final List<TransactionDataModel> transactions = [];
    var errorMessage = "";

    for (var t in arrayTransactionDetails) {
      final transaction = TransactionDataModel();

      transaction.id = (t.modelPendingTransaction?.id.isEmpty == false) ? t.modelPendingTransaction!.id : "";
      transaction.szDescription = szDescription;
      transaction.szCategory = szCategory;
      transaction.fAmount = t.fAmount;
      transaction.isDiscretionarySpend = false;
      transaction.enumType = EnumTransactionType.debit;
      transaction.overrideImageCheck = false;
      transaction.refConsumer = ConsumerRefDataModel.fromConsumerDataModel(t.modelConsumer);
      transaction.modelAccount = t.getModelAccount();
      transaction.hasDepositRemaining = hasRemainingDeposit;

      transaction.dateTransaction = date;

      final updatedTransaction = await uploadAllPhotosForTransaction(transaction);
      errorMessage = updatedTransaction!.message;

      if (updatedTransaction != null) {
        if (!hasReceiptPhotos) {
          updatedTransaction.arrayReceipts.add(vmManualReceipt.toDataModel());
        }
        transactions.add(updatedTransaction);
      }
    }
    callback(transactions, errorMessage);
  }

  getReceiptsImages(Function(TransactionDataModel? transactionA, String message) callback) {
    final valueNotifier = ValueNotifier(0);
    var errorMessage = "";

    downloadAllPhotosForTransaction(arrayReceipt, (updatedTransaction, message) {
      errorMessage = message;
      if (updatedTransaction != null) {
        if (!hasReceiptPhotos) {
          updatedTransaction.arrayReceipts.add(vmManualReceipt.toDataModel());
        }
      }
      valueNotifier.value++;
    });

    valueNotifier.addListener(() {
      callback(null, errorMessage);
    });
  }

  Future<TransactionDataModel?> uploadAllPhotosForTransaction(TransactionDataModel transaction) async {
    return await uploadPhotos(transaction);
  }

  downloadAllPhotosForTransaction(List<ReceiptDataModel> arrayReceipt, Function(TransactionDataModel? transaction, String message) callback) {
    downloadPhotos(arrayReceipt, (success, message) {
      if (success) {
        callback(null, message);
      } else {
        callback(null, message);
      }
    });
  }

  Future<TransactionDataModel> uploadPhotos(TransactionDataModel transaction) async {
    if (transaction.modelAccount == null) {
      throw Exception("Model account is null");
    }

    if (!hasReceiptPhotos) {
      return transaction;
    }

    final responseDataModel = await FinancialAccountManager.sharedInstance
        .requestUploadMultiplePhotosForAccount(transaction.refConsumer, transaction.modelAccount!, transaction.overrideImageCheck, arrayReceiptPhotos);

    if (responseDataModel.isSuccess) {
      transaction.arrayReceipts.clear();
      transaction.arrayReceipts.addAll(ReceiptDataModel.generateReceiptsFromMedia((responseDataModel.parsedObject as List<MediaDataModel>)));
      for (var receipt in transaction.arrayReceipts) {
        receipt.date = transaction.dateTransaction;
        receipt.szVendor = szMerchant;
      }
    } else {
      transaction.message = responseDataModel.errorMessage;
    }
    return transaction;
  }

  downloadPhotos(List<ReceiptDataModel> arrayReceipt, Function(bool success, String message) callback) {
    if (!hasReceiptPhotos) {
      callback(true, "");
      return;
    }

    FinancialAccountManager.sharedInstance.requestDownloadMultiplePhotosForAccount(
        arrayTransactionDetails[0].modelConsumer, arrayTransactionDetails[0].getModelAccount()!, arrayReceipt, (responseDataModel) {
      if (responseDataModel.isSuccess) {
        callback(true, "");
      } else {
        callback(false, responseDataModel.errorMessage);
      }
    });
  }
}

class UploadPhotosResult {
  final bool success;
  final String message;

  UploadPhotosResult({required this.success, required this.message});
}
