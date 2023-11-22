import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/transaction/dataModel/audit_data_model.dart';
import 'package:livecare/models/transaction/dataModel/receipt_data_model.dart';
import 'package:livecare/utils/utils_general.dart';

import '../request/dataModel/location_data_model.dart';
import '../request/dataModel/location_ref_data_model.dart';

class FinancialAccountManager {
  static FinancialAccountManager sharedInstance = FinancialAccountManager();

  Future<void> requestCreateAccount(FinancialAccountDataModel? account, ConsumerDataModel? consumer, NetworkManagerResponse callback) async {
    final urlString = UrlManager.financialAccountApi.createAccount(consumer!.organizationId, consumer.id);

    NetworkManager.post(urlString, account!.serializeForCreate(), EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      requestGetAccountsForConsumer(consumer, true, callback);
    });
  }

  Future<void> requestGetAccountsForConsumer(ConsumerDataModel consumer, bool forceLoad, NetworkManagerResponse callback) async {
    if (consumer.isFinancialAccountLoaded() && !forceLoad) {
      callback.call(NetworkResponseDataModel.forSuccess());
      return;
    }

    final String urlString = UrlManager.financialAccountApi.getFinancialAccounts(consumer.organizationId, consumer.id);

    NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data") && (responseDataModel.payload["data"] != null)) {
        final List<dynamic> data = responseDataModel.payload["data"];
        final List<FinancialAccountDataModel> array = [];
        for (int i in Iterable.generate(data.length)) {
          final Map<String, dynamic> dict = data[i];
          final account = FinancialAccountDataModel();
          account.deserialize(dict);
          if (account.isValid()) {
            array.add(account);
          }
        }
        consumer.setAccountsWithSort(array);
      }
      callback.call(responseDataModel);
    });
  }

  Future<void> requestGetAccountsForLocation(LocationDataModel location, NetworkManagerResponse callback) async {
    final String urlString = UrlManager.financialAccountApi.getFinancialAccountsByLocationId(location.organizationId, location.id);

    NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data") && (responseDataModel.payload["data"] != null)) {
        final List<dynamic> data = responseDataModel.payload["data"];
        final List<FinancialAccountDataModel> array = [];
        for (int i in Iterable.generate(data.length)) {
          final Map<String, dynamic> dict = data[i];
          final account = FinancialAccountDataModel();
          account.deserialize(dict);
          if (account.isValid()) {
            array.add(account);
          }
        }
        responseDataModel.parsedObject = array;
      }
      callback.call(responseDataModel);
    });
  }

  Future<void> requestAuditForAccount(
      AuditDataModel audit, ConsumerDataModel? consumer, FinancialAccountDataModel account, NetworkManagerResponse callback) async {
    String urlString;
    if (account.isSharedAccount() && account.refLocation.isValid()) {
      // location-shared account
      final LocationRefDataModel location = account.refLocation;
      urlString = UrlManager.financialAccountApi.auditForLocationFinancialAccount(location.organizationId, location.id, account.id);
    } else if (consumer != null) {
      urlString = UrlManager.financialAccountApi.audit(consumer.organizationId, consumer.id, account.id);
    } else {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    NetworkManager.post(urlString, audit.serializeForAudit(), EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      callback.call(responseDataModel);
    });
  }

  Future<NetworkResponseDataModel> requestUploadPhotoForAccount(
      ConsumerDataModel? consumer, FinancialAccountDataModel account, File image, bool overrideImageCheck) async {
    String urlString;
    if (account.isSharedAccount() && account.refLocation.isValid()) {
      // location-shared account
      final LocationRefDataModel location = account.refLocation;
      urlString = UrlManager.financialAccountApi.uploadMediaForLocationFinancialAccount(location.organizationId, location.id, account.id);
    } else if (consumer != null) {
      urlString = UrlManager.financialAccountApi.uploadMediaForFinancialAccount(consumer.organizationId, consumer.id, account.id);
    } else {
      return NetworkResponseDataModel.forFailure();
    }

    final responseDataModel = await NetworkManager.upload(urlString, "file", overrideImageCheck, image, EnumNetworkAuthOptions.authRequired.value);
    if (responseDataModel.isSuccess) {
      UtilsGeneral.log(responseDataModel.payload.toString());
      final medium = MediaDataModel();
      medium.deserialize(responseDataModel.payload);
      responseDataModel.parsedObject = medium;
    }
    return responseDataModel;
  }

  Future<NetworkResponseDataModel> requestUploadMultiplePhotosForAccount(
      ConsumerDataModel? consumer, FinancialAccountDataModel account, bool overrideImageCheck, List<File> images) async {
    final List<MediaDataModel> media = [];
    var result = NetworkResponseDataModel();

    for (var image in images) {
      final responseDataModel = await requestUploadPhotoForAccount(consumer, account, image, overrideImageCheck);
      result = responseDataModel;
      if (responseDataModel.isSuccess && responseDataModel.parsedObject != null) {
        final medium = responseDataModel.parsedObject as MediaDataModel;
        media.add(medium);
      } else {
        return result;
      }
    }
    result.parsedObject = media;
    return result;
  }

  Future<void> requestDownloadPhotoForAccount(
      ConsumerDataModel? consumer, FinancialAccountDataModel account, ReceiptDataModel receipt, NetworkManagerResponse callback,
      {bool overrideImageCheck = false}) async {
    String urlString;
    if (account.isSharedAccount() && account.refLocation.isValid()) {
      // location-shared account
      final LocationRefDataModel location = account.refLocation;
      urlString = UrlManager.financialAccountApi
          .downloadMediaForLocationFinancialAccount(location.organizationId, location.id, account.id, receipt.modelMedia!.mediaId);
    } else if (consumer != null) {
      urlString =
          UrlManager.financialAccountApi.downloadMediaForFinancialAccount(consumer.organizationId, consumer.id, account.id, receipt.modelMedia!.mediaId);
    } else {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    NetworkManager.download(urlString, "PNG", receipt.modelMedia!.mediaId, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        UtilsGeneral.log(responseDataModel.payload.toString());
        final medium = MediaDataModel();
        medium.deserialize(responseDataModel.payload);
        responseDataModel.parsedObject = medium;
      }
      callback.call(responseDataModel);
    });
  }

  Future<void> requestDownloadMultiplePhotosForAccount(
      ConsumerDataModel? consumer, FinancialAccountDataModel account, List<ReceiptDataModel> receipts, NetworkManagerResponse callback) async {
    final valueNotifier = ValueNotifier(0);
    final List<MediaDataModel> media = [];
    var result = NetworkResponseDataModel();

    for (var receipt in receipts) {
      requestDownloadPhotoForAccount(consumer, account, receipt, (responseDataModel) {
        result = responseDataModel;
        if (responseDataModel.isSuccess && responseDataModel.parsedObject != null) {
          final medium = responseDataModel.parsedObject as MediaDataModel;
          media.add(medium);
        }
        valueNotifier.value++;
      });
    }

    valueNotifier.addListener(() {
      if (valueNotifier.value == receipts.length) {
        result.parsedObject = media;
        callback.call(result);
      }
    });
  }
}
