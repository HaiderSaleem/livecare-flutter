import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/consumer/dataModel/consumer_ref_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_ref_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/transaction/dataModel/receipt_data_model.dart';
import 'package:livecare/models/user/dataModel/user_data_model.dart';
import 'package:livecare/models/user/dataModel/user_re_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

import '../../request/dataModel/location_ref_data_model.dart';

class TransactionDataModel extends BaseDataModel {
  String organizationId = "";
  String szDescription = "";
  double fAmount = 0.0;
  double fTotal = 0.0;
  double fBalance = 0.0;
  bool isExceedsMaxSpendForPeriod = false;
  bool isDiscretionarySpend = false;
  bool hasDepositRemaining = false;
  DateTime? dateTransaction;
  String returnReason = "";
  bool overrideImageCheck = false;
  String szCategory = "";
  String message = "";

  EnumTransactionType enumType = EnumTransactionType.debit;
  EnumTransactionStatus enumStatus = EnumTransactionStatus.pending;

  FinancialAccountRefDataModel refAccount = FinancialAccountRefDataModel();
  ConsumerRefDataModel refConsumer = ConsumerRefDataModel();
  LocationRefDataModel refLocation = LocationRefDataModel();
  UserRefDataModel refUser = UserRefDataModel();

  FinancialAccountDataModel? modelAccount;

  UserDataModel? modelUser;

  MediaDataModel? modelConsumerSignature;
  MediaDataModel? modelCaregiverSignature;
  List<ReceiptDataModel> arrayReceipts = [];

  @override
  void initialize() {
    super.initialize();

    organizationId = "";
    szDescription = "";
    fAmount = 0;
    fTotal = 0.0;
    fBalance = 0.0;
    isExceedsMaxSpendForPeriod = false;
    isDiscretionarySpend = false;
    hasDepositRemaining = false;
    dateTransaction = null;
    returnReason = "";
    szCategory = "";
    enumType = EnumTransactionType.debit;
    enumStatus = EnumTransactionStatus.pending;

    refAccount = FinancialAccountRefDataModel();
    refConsumer = ConsumerRefDataModel();
    refLocation = LocationRefDataModel();
    refUser = UserRefDataModel();

    modelAccount = null;

    modelUser = null;

    modelConsumerSignature = null;
    modelCaregiverSignature = null;

    arrayReceipts = [];
  }

  @override
  void deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "description")) {
      szDescription = UtilsString.parseString(dictionary["description"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "category")) {
      szCategory = UtilsString.parseString(dictionary["category"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "amount")) {
      fAmount = UtilsString.parseDouble(dictionary["amount"], 0.0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "total")) {
      fTotal = UtilsString.parseDouble(dictionary["total"], 0.0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "balance")) {
      fBalance = UtilsString.parseDouble(dictionary["balance"], 0.0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "exceedsMaxSpendForPeriod")) {
      isExceedsMaxSpendForPeriod = UtilsString.parseBool(dictionary["exceedsMaxSpendForPeriod"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "discretionarySpend")) {
      isDiscretionarySpend = UtilsString.parseBool(dictionary["discretionarySpend"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "transactionDate")) {
      dateTransaction = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["transactionDate"]), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "reason")) {
      returnReason = UtilsString.parseString(dictionary["reason"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "type")) {
      enumType = TransactionTypeExtension.fromString(UtilsString.parseString(dictionary["type"]));
    }
    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = TransactionStatusExtension.fromString(UtilsString.parseString(dictionary["status"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "organization")) {
      final Map<String, dynamic> org = dictionary["organization"];
      if (UtilsBaseFunction.containsKey(org, "organizationId")) {
        organizationId = UtilsString.parseString(org["organizationId"]);
      }
    }
    if (UtilsBaseFunction.containsKey(dictionary, "account")) {
      final Map<String, dynamic> account = dictionary["account"];
      refAccount.deserialize(account);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "consumer")) {
      final Map<String, dynamic> consumer = dictionary["consumer"];
      refConsumer.deserialize(consumer);
      refConsumer.organizationId = organizationId;
    }
    if (UtilsBaseFunction.containsKey(dictionary, "location")) {
      final Map<String, dynamic> location = dictionary["location"];
      refLocation.deserialize(location);
      refLocation.organizationId = organizationId;
    }
    if (UtilsBaseFunction.containsKey(dictionary, "user")) {
      final Map<String, dynamic> user = dictionary["user"];
      refUser.deserialize(user);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "receipts")) {
      final List<dynamic> receipts = dictionary["receipts"];
      for (int i in Iterable.generate(receipts.length)) {
        final dict = receipts[i];
        final r = ReceiptDataModel();
        r.deserialize(dict);
        if (r.isValid()) {
          arrayReceipts.add(r);
        }
      }
    }
  }

  Map<String, dynamic> serializeForDeposit() {
    final Map<String, dynamic> result = {};
    result["amount"] = fAmount;
    result["description"] = szDescription;
    result["status"] = enumStatus.value;
    result["type"] = enumType.value;
    result["category"] = szCategory;
    result["transactionDate"] = UtilsDate.getStringFromDateTimeWithFormatToApi(dateTransaction,
        EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);

    final List<dynamic> receipts = [];
    for (int i in Iterable.generate(arrayReceipts.length)) {
      final r = arrayReceipts[i];
      receipts.add(r.serialize());
    }

    result["receipts"] = receipts;
    return result;
  }

  Map<String, dynamic> serializeForWithdrawal() {
    final Map<String, dynamic> result = {};

    result["amount"] = fAmount;
    result["description"] = szDescription;
    result["category"] = szCategory;
    result["status"] = enumStatus.value;
    result["type"] = enumType.value;
    result["discretionarySpend"] = isDiscretionarySpend;
    result["transactionDate"] = UtilsDate.getStringFromDateTimeWithFormatToApi(dateTransaction, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);

    if (modelConsumerSignature != null) {
      result["consumerSignature"] = modelConsumerSignature!.serializeForCreateTransactionMedia();
    }

    if (modelCaregiverSignature != null) {
      result["userSignature"] = modelCaregiverSignature!.serializeForCreateTransactionMedia();
    }

    final List<dynamic> receipts = [];
    for (var r in arrayReceipts) {
      receipts.add(r.serialize());
    }

    result["receipts"] = receipts;
    return result;
  }

  Map<String, dynamic> serializeForPurchase() {
    final Map<String, dynamic> result = {};
    result["amount"] = fAmount;
    result["description"] = szDescription;
    result["type"] = enumType.value;
    result["depositRemaining"] = hasDepositRemaining;
    result["category"] = szCategory;
    result["transactionDate"] = UtilsDate.getStringFromDateTimeWithFormatToApi(dateTransaction,
        EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);

    if (modelConsumerSignature != null) {
      result["consumerSignature"] = modelConsumerSignature!.serializeForCreateTransactionMedia();
    }
    if (modelCaregiverSignature != null) {
      result["userSignature"] = modelCaregiverSignature!.serializeForCreateTransactionMedia();
    }

    final List<dynamic> receipts = [];
    for (int i in Iterable.generate(arrayReceipts.length)) {
      final r = arrayReceipts[i];
      receipts.add(r.serialize());
    }

    result["receipts"] = receipts;
    return result;
  }

  bool isForLocationAccount() {
    return refLocation.isValid() && !refConsumer.isValid();
  }

  DateTime? getTransactionDate() {
    // firstly, check transactionDate and return if valid
    // if transactionDate is not valid, check updatedAt and return if valid
    // otherwise, return createdAt
    return dateTransaction ?? (dateUpdatedAt ?? dateCreatedAt);
  }
}

enum EnumTransactionType { credit, debit }

extension TransactionTypeExtension on EnumTransactionType {
  static EnumTransactionType fromString(String? type) {
    if (type == null || type == "") return EnumTransactionType.debit;

    if (type.toLowerCase() == EnumTransactionType.credit.value.toLowerCase()) {
      return EnumTransactionType.credit;
    }
    if (type.toLowerCase() == EnumTransactionType.debit.value.toLowerCase()) {
      return EnumTransactionType.debit;
    }
    return EnumTransactionType.debit;
  }

  String get getBeautifiedText {
    switch (this) {
      case EnumTransactionType.credit:
        return "Deposit";
      case EnumTransactionType.debit:
        return "Withdraw";
    }
  }

  String get value {
    switch (this) {
      case EnumTransactionType.credit:
        return "Credit";
      case EnumTransactionType.debit:
        return "Debit";
    }
  }
}

enum EnumTransactionStatus { pending, submitted, approved, cancelled }

extension TransactionStatusExtension on EnumTransactionStatus {
  static EnumTransactionStatus fromString(String? type) {
    if (type == null || type == "") return EnumTransactionStatus.cancelled;

    if (type.toLowerCase() == EnumTransactionStatus.pending.value.toLowerCase()) {
      return EnumTransactionStatus.pending;
    }
    if (type.toLowerCase() == EnumTransactionStatus.submitted.value.toLowerCase()) {
      return EnumTransactionStatus.submitted;
    }
    if (type.toLowerCase() == EnumTransactionStatus.approved.value.toLowerCase()) {
      return EnumTransactionStatus.approved;
    }
    if (type.toLowerCase() == EnumTransactionStatus.cancelled.value.toLowerCase()) {
      return EnumTransactionStatus.cancelled;
    }
    return EnumTransactionStatus.cancelled;
  }

  String get value {
    switch (this) {
      case EnumTransactionStatus.pending:
        return "Pending";
      case EnumTransactionStatus.submitted:
        return "Submitted";
      case EnumTransactionStatus.approved:
        return "Approved";
      case EnumTransactionStatus.cancelled:
        return "Cancelled";
    }
  }
}
