import 'package:flutter/material.dart';
import 'package:livecare/components/listView/returned_transactions_listview.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/transaction/dataModel/transaction_data_model.dart';
import 'package:livecare/models/transaction/transaction_manager.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/transaction/purchase/purchase_screen.dart';
import 'package:livecare/screens/transaction/viewModel/purchase_view_model.dart';

class ReturnedTransactionsListScreen extends BaseScreen {
  const ReturnedTransactionsListScreen({Key? key,}) : super(key: key);

  @override
  _ReturnedTransactionsListScreenState createState() => _ReturnedTransactionsListScreenState();
}

class _ReturnedTransactionsListScreenState extends BaseScreenState<ReturnedTransactionsListScreen> {
  ConsumerDataModel? modelConsumer;
  LocationDataModel? modelLocation;
  bool isSharedFinancialAccount = false;
  FinancialAccountDataModel? modelAccount;

  List<TransactionDataModel> arrayReturnedTransaction = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
     // _requestGetTransactions();
    });
  }

  _requestGetTransactions() {

    final currentUser = UserManager.sharedInstance.currentUser;
    if (currentUser == null) return;
    showProgressHUD();

    var consumerId = modelConsumer?.id;
    var accountId = modelAccount?.id;



    if (currentUser == null) return;
    showProgressHUD();
    TransactionManager.sharedInstance.requestGetMyPendingTransactions((responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data") && responseDataModel.payload["data"] != null) {
        final List<TransactionDataModel> array = [];
        final List<dynamic> data = responseDataModel.payload["data"];
        for (int i in Iterable.generate(data.length)) {
          final dict = data[i];
          final transaction = TransactionDataModel();
          transaction.deserialize(dict);
          if (transaction.isValid()) {
            array.add(transaction);
          }
        }

        setState(() {
          arrayReturnedTransaction = array;
        });
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _gotoPurchaseScreen(TransactionDataModel? transaction) {
    final purchase = PurchaseViewModel();

    var consumer = ConsumerDataModel();
    consumer.id = transaction?.refConsumer.consumerId ?? "";
    consumer.organizationId = transaction?.organizationId ?? "";

    var account = FinancialAccountDataModel();
    account.id = transaction?.refAccount.accountId ?? "";
    account.szName = transaction?.refAccount.szName ?? "";


    purchase.arrayTransactionDetails[0].modelConsumer = consumer;
    purchase.arrayTransactionDetails[0].setModelAccount(account);
    purchase.arrayTransactionDetails[0].modelPendingTransaction = transaction;
    purchase.arrayTransactionDetails[0].isSharedAccount = isSharedFinancialAccount;
    purchase.arrayTransactionDetails[0].fAmount = transaction?.fAmount ?? 0;
    purchase.szDescription = transaction?.szDescription ?? "";
    purchase.date = transaction!.dateTransaction!;
    if (transaction.arrayReceipts.isNotEmpty) {
      purchase.arrayReceipt = transaction.arrayReceipts;
      purchase.szMerchant = transaction.arrayReceipts[0].szVendor;
    }

    Navigator.push(
      context,
      createRoute(PurchaseScreen(vmPurchase: purchase)),
    ).then((value) {
      _requestGetTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      body: SafeArea(
        bottom: true,
        child: Container(
          color: AppColors.defaultBackground,
          padding: AppDimens.kMarginSsmall,
          child: arrayReturnedTransaction.isEmpty
              ? Center(
                  child: Text(
                    "No transactions found",
                    style: AppStyles.tripInformation.copyWith(color: AppColors.textBlack),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () {
                    _requestGetTransactions();
                    return Future.delayed(const Duration(milliseconds: 1000));
                  },
                  child: ReturnedTransactionsListView(
                    arrayTransactions: arrayReturnedTransaction,
                    itemClickListener: (transaction, position) {
                      _gotoPurchaseScreen(transaction);
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class TransactionsSectionModel {
  DateTime? sectionDate;
  List<TransactionDataModel> arrayTransactions = [];
}
