import 'dart:io';

import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/financialAccount/financial_account_manager.dart';
import 'package:livecare/models/transaction/dataModel/receipt_data_model.dart';
import 'package:livecare/models/transaction/dataModel/transaction_data_model.dart';

import '../../../models/consumer/dataModel/consumer_ref_data_model.dart';

class WithdrawalViewModel {
  DateTime? date;

  ConsumerDataModel? modelConsumer;

  FinancialAccountDataModel? modelAccount;
  bool isSharedAccount = false;

  double fAmount = 0.0;
  String szDescription = "";
  String selectedAccountId = "";
  List<File> arrayPhotos = [];
  File? imageConsumerSignature;
  File? imageCaregiverSignature;
  bool isDiscretionarySpending = true;
  String szCategory = "";

  initialize() {
    date = null;
    modelConsumer = null;
    modelAccount = null;
    isSharedAccount = false;

    fAmount = 0;
    szDescription = "";
    selectedAccountId = "";
    arrayPhotos = [];
    imageConsumerSignature = null;
    imageCaregiverSignature = null;
    isDiscretionarySpending = true;
  }

  setModelConsumer(ConsumerDataModel? consumer) {
    modelConsumer = consumer;
    if (modelConsumer != null) {
      modelAccount = modelConsumer!.getCashAccount();
    }
  }

  ConsumerDataModel? getModelConsumer() {
    return modelConsumer;
  }

  bool hasConsumerSigned() {
    return imageConsumerSignature != null;
  }

  bool hasCaregiverSigned() {
    return imageCaregiverSignature != null;
  }

  Future<TransactionDataModel?> toDataModel() async {
    final transaction = TransactionDataModel();

    transaction.szDescription = szDescription;
    transaction.fAmount = fAmount;

    transaction.enumType = EnumTransactionType.debit;
    transaction.overrideImageCheck = false;
    transaction.refConsumer = ConsumerRefDataModel.fromConsumerDataModel(modelConsumer);
    transaction.modelAccount = modelAccount;
    transaction.dateTransaction = date;
    transaction.szCategory = szCategory;

    transaction.isDiscretionarySpend = isDiscretionarySpending;
    if (isDiscretionarySpending == true) {
      transaction.overrideImageCheck = true;
      transaction.enumStatus = EnumTransactionStatus.submitted;
    } else {
      // No need to upload photos / signatures
      transaction.enumStatus = EnumTransactionStatus.pending;
    }

    await uploadAllPhotos(transaction);

    return transaction; // Returning the constructed transaction
  }

  Future<void> uploadAllPhotos(TransactionDataModel transaction) async {
    try {
      await uploadPhotos(transaction);
      if (isDiscretionarySpending) {
        await uploadConsumerSignature(transaction);
        await uploadCaregiverSignature(transaction);
      }
    } catch (e) {
      throw Exception("Upload has failed: $e");
    }
  }

  Future<void> uploadConsumerSignature(TransactionDataModel transaction) async {
    bool override = true;

    if (modelAccount == null || imageConsumerSignature == null) {
      return Future.error("Model account or signature image missing");
    }

    var response =
        await FinancialAccountManager.sharedInstance.requestUploadPhotoForAccount(transaction.refConsumer, modelAccount!, imageConsumerSignature!, override);

    if (response.isSuccess) {
      transaction.modelConsumerSignature = response.parsedObject as MediaDataModel;
    } else {
      throw Exception("Upload failed");
    }
  }

  Future<void> uploadCaregiverSignature(TransactionDataModel transaction) async {
    bool override = true;

    if (modelAccount == null || imageCaregiverSignature == null) {
      return Future.error("Model account or signature image missing");
    }

    var response =
        await FinancialAccountManager.sharedInstance.requestUploadPhotoForAccount(transaction.refConsumer, modelAccount!, imageCaregiverSignature!, override);

    if (response.isSuccess) {
      transaction.modelCaregiverSignature = response.parsedObject as MediaDataModel;
    } else {
      // Either handle the error or ignore it, based on your requirement.
    }
  }

  Future<void> uploadPhotos(TransactionDataModel transaction) async {
    if (modelAccount == null) {
      return Future.error("Model account missing");
    }

    var response = await FinancialAccountManager.sharedInstance
        .requestUploadMultiplePhotosForAccount(transaction.refConsumer, modelAccount!, transaction.overrideImageCheck, arrayPhotos);

    if (response.isSuccess) {
      transaction.arrayReceipts.clear();
      transaction.arrayReceipts.addAll(ReceiptDataModel.generateReceiptsFromMedia(response.parsedObject as List<MediaDataModel>));
    } else {
      throw Exception("Upload failed");
    }
  }
}
