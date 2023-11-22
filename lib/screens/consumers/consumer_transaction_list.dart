import 'package:flutter/material.dart';
import 'package:livecare/components/listView/transactions_section_listview.dart';
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

class ConsumerTransactionListScreen extends BaseScreen {
  final ConsumerDataModel? modelConsumer;
  final LocationDataModel? modelLocation;
  final bool isSharedFinancialAccount;
  final FinancialAccountDataModel? modelAccount;

  const ConsumerTransactionListScreen(
      {Key? key, required this.modelConsumer, required this.modelLocation, required this.isSharedFinancialAccount, required this.modelAccount})
      : super(key: key);

  @override
  _ConsumerTransactionListScreenState createState() => _ConsumerTransactionListScreenState();
}

class _ConsumerTransactionListScreenState extends BaseScreenState<ConsumerTransactionListScreen> {
  List<TransactionsSectionModel> arrayTransactionSections = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _requestGetTransactions();
      } catch (error) {
        print('Error in _requestGetTransactions: $error');
      }
    });
  }

  String _getNavTitle() {
    if (widget.modelAccount != null) {
      return widget.modelAccount!.szName;
    }
    return "Consumer Transactions";
  }

  Future<void> _requestGetTransactions() async {
    final currentUser = UserManager.sharedInstance.currentUser;
    if (currentUser == null) return;

    final consumerId = widget.modelConsumer?.id ?? "";
    final accountId = widget.modelAccount?.id ?? "";

    showProgressHUD();
    if (widget.isSharedFinancialAccount) {
      if (widget.modelLocation == null) {
        hideProgressHUD();
        return;
      }
      await TransactionManager.sharedInstance.requestGetTransactionsByLocation(widget.modelLocation!, (responseDataModel) {
        hideProgressHUD();
        final array = responseDataModel.parsedObject as List<TransactionDataModel>?;
        if (responseDataModel.isSuccess && array != null) {
          final filteredArray = array.where((element) => element.refAccount.accountId == accountId).toList();
          setState(() {
            arrayTransactionSections = generateSections(filteredArray);
          });
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else if (widget.modelConsumer != null) {
      await TransactionManager.sharedInstance.requestGetTransactionsByAccount(widget.modelConsumer!, accountId, (responseDataModel) {
        hideProgressHUD();
        final array = responseDataModel.parsedObject as List<TransactionDataModel>?;
        if (responseDataModel.isSuccess && array != null) {
          final filteredArray = array.where((element) => element.refAccount.accountId == accountId).toList();
          setState(() {
            arrayTransactionSections = generateSections(filteredArray);
          });
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      hideProgressHUD();
    }
  }

  List<TransactionsSectionModel> generateSections(List<TransactionDataModel> transactions) {
    transactions.sort((a, b) => b.getTransactionDate()!.compareTo(a.getTransactionDate()!));
    final sortedList = transactions;
    if (sortedList.isEmpty) return [];

    final List<TransactionsSectionModel> arraySectionModels = [];

    var cal1 = DateTime.now();
    var cal2 = DateTime.now();
    cal1 = sortedList[0].getTransactionDate()!;

    var sectionModel = TransactionsSectionModel();
    sectionModel.sectionDate = cal1;

    for (var model in sortedList) {
      final temp = model.getTransactionDate();
      cal2 = temp!;
      if (cal1.year == cal2.year && cal1.month == cal2.month && cal1.day == cal2.day) {
        sectionModel.arrayTransactions.add(model);
      } else {
        arraySectionModels.add(sectionModel);
        cal1 = temp;
        sectionModel = TransactionsSectionModel();
        sectionModel.sectionDate = cal1;
        sectionModel.arrayTransactions.add(model);
      }
    }

    arraySectionModels.add(sectionModel);
    return arraySectionModels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            _getNavTitle(),
            style: AppStyles.textCellHeaderStyle,
          )),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - (appBarHeight + MediaQuery.of(context).padding.top),
            width: MediaQuery.of(context).size.width,
            child: Container(
              margin: AppDimens.kHorizontalMarginNormal,
              child: RefreshIndicator(
                  onRefresh: () {
                    _requestGetTransactions();
                    return Future.delayed(const Duration(milliseconds: 1000));
                  },
                  child: TransactionsSectionListView(arrayTransactionSections: arrayTransactionSections)),
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
