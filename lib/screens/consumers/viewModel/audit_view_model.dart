import 'dart:io';

import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/financialAccount/financial_account_manager.dart';
import 'package:livecare/models/transaction/dataModel/audit_data_model.dart';

class AuditViewModel {
  ConsumerDataModel? modelConsumer;
  FinancialAccountDataModel? modelAccount;
  bool isSharedAccount = false;

  double fAmount = 0.0;
  bool isApproved = false;
  int nTries = 0;
  bool isOverride = false;
  File? imagePhoto;

  initialize() {
    modelConsumer = null;
    modelAccount = null;
    isSharedAccount = false;

    fAmount = 0.0;
    imagePhoto = null;
    isApproved = false;
    isOverride = false;
    nTries = 0;
  }

  Future<void> toDataModel(Function(AuditDataModel? audit, String message) callback) async {
    final audit = AuditDataModel();
    audit.fBalance = fAmount;
    audit.isOverride = isOverride;

    try {
      await uploadAllPhotos(audit);
      callback(audit, "");
    } catch (e) {
      callback(null, "Upload has failed.");
    }
  }

  Future<void> uploadAllPhotos(AuditDataModel audit) async {
    try {
      await uploadSnapshot(audit);
    } catch (e) {
      throw Exception("Upload of all photos failed: $e");
    }
  }

  Future<void> uploadSnapshot(AuditDataModel audit) async {
    if (modelAccount == null || imagePhoto == null) {
      throw Exception("Model account or image photo missing");
    }

    try {
      final responseDataModel = await FinancialAccountManager.sharedInstance.requestUploadPhotoForAccount(modelConsumer, modelAccount!, imagePhoto!, true);

      if (responseDataModel.isSuccess) {
        audit.modelSnapshot = responseDataModel.parsedObject as MediaDataModel;
        return;
      } else {
        throw Exception("Upload failed");
      }
    } catch (e) {
      throw Exception("Error uploading snapshot: $e");
    }
  }
}
