import 'dart:async';
import 'dart:collection';

import 'package:get/get.dart';
import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/transaction/dataModel/transaction_data_model.dart';
import 'package:livecare/utils/utils_general.dart';

import '../consumer/dataModel/consumer_data_model.dart';
import '../consumer/dataModel/consumer_ref_data_model.dart';
import '../request/dataModel/location_data_model.dart';
import '../request/dataModel/location_ref_data_model.dart';

class TransactionManager {
  List<TransactionDataModel> arrayTransactions = [];

  static final TransactionManager _sharedInstance = TransactionManager._internal();

  factory TransactionManager() {
    return _sharedInstance;
  }

  TransactionManager._internal();

  static TransactionManager get sharedInstance => _sharedInstance;

  void initialize() {
    arrayTransactions.clear();
  }

  void addTransactionIfNeeded(TransactionDataModel newTransaction) {
    if (!newTransaction.isValid() && arrayTransactions.every((transaction) => transaction.id != newTransaction.id)) {
      arrayTransactions.add(newTransaction);
    }
  }

  TransactionDataModel? getPendingTransactionForAccount(String consumerId, String accountId) {
    return arrayTransactions.firstWhereOrNull((transaction) =>
        transaction.refConsumer.consumerId == consumerId &&
        transaction.refAccount.accountId == accountId &&
        transaction.enumStatus == EnumTransactionStatus.pending &&
        transaction.enumType == EnumTransactionType.debit);
  }

  void requestGetMyPendingTransactions(NetworkManagerResponse? callback) {
    final urlString = UrlManager.transactionApi.getTransactions();
    final params = {
      "\$top": "1000",
      "\$skip": "0",
      "\$filter": "(status eq 'Pending')",
    };

    NetworkManager.get(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      // Successful response
      callback?.call(responseDataModel);
    }).catchError((error) {
      // Handle any exceptions or errors here
      print("Error occurred during get request: $error");
      // Create an error response model and pass it to the callback
      final errorResponseModel = NetworkResponseDataModel.errorResponse(error);
      callback?.call(errorResponseModel);
    });
  }

  TransactionDataModel? getPendingTransactionForLocationAccount(String locationId, String accountId) {
    for (var transaction in arrayTransactions) {
      if (transaction.isForLocationAccount() && transaction.refLocation.isValid()) {
        if (transaction.refLocation.id == locationId &&
            transaction.refAccount.accountId == accountId &&
            transaction.enumStatus == EnumTransactionStatus.pending &&
            transaction.enumType == EnumTransactionType.debit) {
          return transaction;
        }
      }
    }
    return null;
  }

  Future<void> _requestGetTransactions(String urlString, NetworkManagerResponse? callback) async {
    NetworkResponseDataModel? responseDataModel; // Declare outside to make it accessible outside the try-catch block
    try {
      responseDataModel = await NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value);
      if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data")) {
        // Removed () from isSuccess
        final List<dynamic> data = responseDataModel.payload["data"] ?? [];
        arrayTransactions = data
            .map((dict) {
              final transaction = TransactionDataModel()..deserialize(dict);
              return transaction.isValid() ? transaction : null;
            })
            .whereType<TransactionDataModel>()
            .toList();
      }
      responseDataModel.parsedObject = arrayTransactions;
      LocalNotificationManager.sharedInstance.notifyLocalNotification(UtilsGeneral.transactionsListUpdated);
    } catch (error) {
      responseDataModel = NetworkResponseDataModel.forFailure();
    }
    callback?.call(responseDataModel); // Moved outside of try-catch block
  }

  Future<void> requestGetTransactions(NetworkManagerResponse? callback) async {
    final urlString = UrlManager.transactionApi.getTransactions();
    await _requestGetTransactions(urlString, callback);
  }

  Future<void> requestGetTransactionsByAccount(ConsumerDataModel consumer, String accountId, NetworkManagerResponse? callback) async {
    final urlString = UrlManager.transactionApi.getTransactionsByAccountId(consumer.organizationId, consumer.id, accountId);
    await _requestGetTransactions(urlString, callback);
  }

  Future<void> requestGetTransactionsByConsumer(ConsumerDataModel consumer, NetworkManagerResponse? callback) async {
    final urlString = UrlManager.transactionApi.getTransactionsByConsumerId(consumer.organizationId, consumer.id);
    await _requestGetTransactions(urlString, callback);
  }

  Future<void> requestGetTransactionsByLocation(LocationDataModel location, NetworkManagerResponse? callback) async {
    final urlString = UrlManager.transactionApi.getTransactionsByLocationId(location.organizationId, location.id);
    await _requestGetTransactions(urlString, callback);
  }

  Future<void> requestDeposit(TransactionDataModel deposit, NetworkManagerResponse callback) async {
    final account = deposit.modelAccount;

    if (account == null) {
      callback(NetworkResponseDataModel.forFailure());
      return;
    }

    final urlString = buildTransactionUrlString(deposit);

    try {
      final responseDataModel = await NetworkManager.post(urlString, deposit.serializeForDeposit(), EnumNetworkAuthOptions.authRequired.value);

      if (responseDataModel.isSuccess) {
        await requestGetTransactionsByAccount(deposit.refConsumer, account.id, callback);
      } else {
        callback(responseDataModel);
      }
    } catch (error) {
      callback(NetworkResponseDataModel.forFailure());
    }
  }

  Future<NetworkResponseDataModel> requestWithdrawal(String accountId, TransactionDataModel withdrawal) async {
    final consumer = withdrawal.refConsumer;
    final account = withdrawal.modelAccount;

    if (account == null) {
      return NetworkResponseDataModel.forFailure();
    }

    String urlString = buildTransactionUrlString(withdrawal);
    if (urlString.isEmpty) {
      return NetworkResponseDataModel.forFailure();
    }

    try {
      NetworkResponseDataModel responseDataModel =
          await NetworkManager.post(urlString, withdrawal.serializeForWithdrawal(), EnumNetworkAuthOptions.authRequired.value);

      if (responseDataModel.isSuccess) {
        final newTransaction = TransactionDataModel();
        newTransaction.deserialize(responseDataModel.payload);
        responseDataModel.parsedObject = newTransaction;
      }
      return responseDataModel;
    } catch (e) {
      return NetworkResponseDataModel.forFailure();
    }
  }

  Future<void> requestMultiplePurchases(List<TransactionDataModel> purchases,
      NetworkManagerResponse callback) async {
    List<Future<NetworkResponseDataModel>> futureList =
    purchases.map<Future<NetworkResponseDataModel>>((purchase) async {
      final urlString = buildPurchaseUrlString(purchase);
      if (urlString.isEmpty) {
        return NetworkResponseDataModel.forFailure();
      }
      try {
        return await NetworkManager.post(urlString,
            purchase.serializeForPurchase(), EnumNetworkAuthOptions.authRequired.value);
      } catch (e) {
        return NetworkResponseDataModel.forFailure();
      }
    }).toList();

    try {
      List<NetworkResponseDataModel> results = await Future.wait(futureList);
      bool allSucceeded = results.every((result) => result.isSuccess);
      callback.call(allSucceeded ? NetworkResponseDataModel.forSuccess() :
      NetworkResponseDataModel.forFailure());
    } catch (e) {
      callback.call(NetworkResponseDataModel.forFailure());
    }
  }

  String buildPurchaseUrlString(TransactionDataModel purchase) {
    final account = purchase.modelAccount;
    if (account == null) {
      return '';
    }
    if (account.isSharedAccount() && account.refLocation.isValid()) {
      final LocationRefDataModel location = account.refLocation;
      return (purchase.id.isEmpty)
          ? UrlManager.transactionApi.createPurchaseForLocationAccount(location.organizationId,
          location.locationId, account.id)
          : UrlManager.transactionApi.updateTransactionForLocationAccount(location.organizationId, location.locationId, account.id, purchase.id);
    }
    final ConsumerRefDataModel consumer = account.refConsumer;
    return (purchase.id.isEmpty)
        ? UrlManager.transactionApi.createPurchaseForConsumerId(consumer.organizationId, consumer.consumerId, account.id)
        : UrlManager.transactionApi.updateTransaction(consumer.organizationId, consumer.consumerId, account.id, purchase.id);
  }

  String buildTransactionUrlString(TransactionDataModel transaction) {
    final account = transaction.modelAccount!;
    if (account.isSharedAccount() && account.refLocation.isValid()) {
      final location = account.refLocation;
      return UrlManager.transactionApi.createTransactionForLocationAccount(location.organizationId, location.locationId, account.id);
    }
    final ConsumerRefDataModel consumer = account.refConsumer;
    return UrlManager.transactionApi.createTransaction(consumer.organizationId, consumer.consumerId, account.id);
  }
}

class Semaphore {
  final int maxConcurrentRequests;
  int _currentCount = 0;
  final Queue<Completer> _queue = Queue<Completer>();

  Semaphore({required this.maxConcurrentRequests});

  Future<T> run<T>(Future<T> Function() task) {
    if (_currentCount < maxConcurrentRequests) {
      _currentCount++;
      return task().whenComplete(() {
        _currentCount--;
        if (_queue.isNotEmpty) {
          _queue.removeFirst().complete();
        }
      });
    } else {
      var completer = Completer();
      _queue.add(completer);
      return completer.future.then((_) => run(task));
    }
  }
}
