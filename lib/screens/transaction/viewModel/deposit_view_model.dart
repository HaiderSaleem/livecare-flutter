import 'dart:io';

import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/financialAccount/financial_account_manager.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/transaction/dataModel/receipt_data_model.dart';
import 'package:livecare/models/transaction/dataModel/transaction_data_model.dart';

import '../../../models/consumer/dataModel/consumer_ref_data_model.dart';
import '../../../models/request/dataModel/location_ref_data_model.dart';

class DepositViewModel {
  DateTime date = DateTime.now();
  ConsumerDataModel? modelConsumer;
  LocationDataModel? modelLocation;
  FinancialAccountDataModel? modelAccount;
  bool isSharedAccount = false;
  double fAmount = 0.0;
  String szDescription = "";
  String szCategory = "";
  List<File> arrayPhotos = [];
  File? imageConsumerSignature;
  File? imageCaregiverSignature;

  initialize() {
    date = DateTime.now();
    modelConsumer = null;
    modelLocation = null;
    modelAccount = null;
    isSharedAccount = false;
    fAmount = 0.0;
    szDescription = "";
    szCategory = "";
    arrayPhotos = [];
    imageConsumerSignature = null;
    imageCaregiverSignature = null;
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
    transaction.szCategory = szCategory;
    transaction.fAmount = fAmount;
    transaction.isDiscretionarySpend = false;
    transaction.overrideImageCheck = true;
    transaction.enumType = EnumTransactionType.credit;
    transaction.enumStatus = EnumTransactionStatus.submitted;
    transaction.dateTransaction = date;

    transaction.refConsumer = ConsumerRefDataModel.fromConsumerDataModel(modelConsumer);
    transaction.refLocation = LocationRefDataModel.fromLocationDataModel(modelLocation);
    transaction.modelAccount = modelAccount;

    await uploadAllPhotos(transaction);

    return transaction; // Returning the constructed transaction
  }

  Future<void> uploadAllPhotos(TransactionDataModel transaction) async {
    await uploadPhotos(transaction);
  }

  Future<void> uploadPhotos(TransactionDataModel transaction) async {
    if (transaction.modelAccount == null) throw Exception("Model account is missing.");

    final response = await FinancialAccountManager.sharedInstance
        .requestUploadMultiplePhotosForAccount(transaction.refConsumer, transaction.modelAccount!, true, arrayPhotos);

    if (response.isSuccess) {
      transaction.arrayReceipts.clear();
      transaction.arrayReceipts.addAll(ReceiptDataModel.generateReceiptsFromMedia(response.parsedObject as List<MediaDataModel>));
    } else {
      throw Exception("Upload failed");
    }
  }
}
