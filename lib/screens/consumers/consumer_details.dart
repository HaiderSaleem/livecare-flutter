import 'package:flutter/material.dart';
import 'package:livecare/components/listView/consumer_accounts_listview.dart';
import 'package:livecare/listeners/consumer_account_button_listener.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/financialAccount/financial_account_manager.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/consumers/account_details.dart';
import 'package:livecare/screens/consumers/audit_amount_dialog.dart';
import 'package:livecare/screens/consumers/consumer_transaction_list.dart';
import 'package:livecare/screens/consumers/viewModel/audit_view_model.dart';
import 'package:livecare/screens/consumers/viewModel/financial_account_view_model.dart';
import 'package:livecare/screens/transaction/deposit_screen.dart';
import 'package:livecare/screens/transaction/purchase/purchase_screen.dart';
import 'package:livecare/screens/transaction/viewModel/deposit_view_model.dart';
import 'package:livecare/screens/transaction/viewModel/purchase_view_model.dart';
import 'package:livecare/screens/transaction/viewModel/withdrawal_view_model.dart';
import 'package:livecare/screens/transaction/withdrawal_screen.dart';

import '../../models/consumer/dataModel/consumer_ref_data_model.dart';

class ConsumerDetailsScreen extends BaseScreen {
  final ConsumerDataModel? modelConsumer;
  final LocationDataModel? modelLocation;
  final bool? isSharedFinancialAccount;

  const ConsumerDetailsScreen({Key? key, this.modelConsumer, this.modelLocation, this.isSharedFinancialAccount}) : super(key: key);

  @override
  _ConsumerDetailsScreenState createState() => _ConsumerDetailsScreenState();
}

class _ConsumerDetailsScreenState extends BaseScreenState<ConsumerDetailsScreen> with ConsumerAccountButtonListener {
  List<FinancialAccountDataModel> arrayAccounts = [];
  final enteredAmount = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestFinancialAccounts(true);
    });
  }

  String getNavTitle() {
    if (widget.modelConsumer != null) {
      return widget.modelConsumer!.szName;
    }
    if (widget.modelLocation != null) {
      return widget.modelLocation!.szName;
    }
    return "Consumer Details";
  }

  _requestFinancialAccounts(bool showHUD) {
    if (!widget.isSharedFinancialAccount! && widget.modelConsumer != null) {
      if (showHUD) {
        showProgressHUD();
      }

      FinancialAccountManager.sharedInstance.requestGetAccountsForConsumer(widget.modelConsumer!, true, (responseDataModel) {
        if (responseDataModel.isSuccess) {
          setState(() {
            if (showHUD) {
              hideProgressHUD();
            }
            arrayAccounts = widget.modelConsumer!.arrayAccounts ?? [];
          });
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else if (widget.isSharedFinancialAccount! && widget.modelLocation != null) {
      if (showHUD) {
        showProgressHUD();
      }
      FinancialAccountManager.sharedInstance.requestGetAccountsForLocation(widget.modelLocation!, (responseDataModel) {
        if (showHUD) {
          hideProgressHUD();
        }
        if (responseDataModel.isSuccess) {
          setState(() {
            arrayAccounts = responseDataModel.parsedObject ?? [];
          });
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    }
  }

  _gotoAccountDetailsScreen() {
    if (widget.isSharedFinancialAccount!) {
      showToast("You cannot add new shared account.");
      return;
    }

    final account = FinancialAccountViewModel();
    account.refConsumer = ConsumerRefDataModel.fromConsumerDataModel(widget.modelConsumer);
    Navigator.push(
      context,
      createRoute(AccountDetailsScreen(
        vmAccount: account,
      )),
    ).then((value) {
      _requestFinancialAccounts(true);
    });
  }

  _gotoDepositScreen(FinancialAccountDataModel? account) {
    if (account == null) return;

    final DepositViewModel deposit = DepositViewModel();
    deposit.date = DateTime.now();
    deposit.modelConsumer = widget.modelConsumer;
    deposit.modelAccount = account;
    deposit.isSharedAccount = widget.isSharedFinancialAccount!;

    Navigator.push(
      context,
      createRoute(DepositScreen(vmDeposit: deposit)),
    ).then((value) {
      _requestFinancialAccounts(true);
    });
  }

  _gotoPurchaseScreen(FinancialAccountDataModel? account) {
    if (account == null) {
      return;
    }

    final purchase = PurchaseViewModel();

    purchase.isSharedAccount = widget.isSharedFinancialAccount!;
    purchase.arrayTransactionDetails[0].modelConsumer = widget.modelConsumer;
    purchase.arrayTransactionDetails[0].setModelAccount(account);
    purchase.arrayTransactionDetails[0].isSharedAccount = widget.isSharedFinancialAccount!;

    Navigator.push(
      context,
      createRoute(PurchaseScreen(vmPurchase: purchase)),
    ).then((value) {
      _requestFinancialAccounts(true);
    });
  }

  _gotoWithdrawalScreen(FinancialAccountDataModel account) {
    final WithdrawalViewModel withdrawal = WithdrawalViewModel();
    withdrawal.date = DateTime.now();
    withdrawal.setModelConsumer(widget.modelConsumer);
    withdrawal.modelAccount = account;
    withdrawal.selectedAccountId = withdrawal.modelAccount!.id;
    withdrawal.isSharedAccount = widget.isSharedFinancialAccount!;

    Navigator.push(
      context,
      createRoute(WithdrawalScreen(vmWithdrawal: withdrawal)),
    ).then((value) {
      _requestFinancialAccounts(true);
    });
  }

  _gotoTransactionsListScreen(FinancialAccountDataModel? account) {
    Navigator.push(
      context,
      createRoute(ConsumerTransactionListScreen(
          modelConsumer: widget.modelConsumer,
          modelLocation: widget.modelLocation,
          isSharedFinancialAccount: widget.isSharedFinancialAccount!,
          modelAccount: account)),
    );
  }

  _didFinancialAccountAuditClick(FinancialAccountDataModel? account) {
    final AuditViewModel audit = AuditViewModel();
    audit.modelConsumer = widget.modelConsumer;
    audit.modelAccount = account;
    audit.isSharedAccount = widget.isSharedFinancialAccount!;

    showDialog(
      context: context,
      builder: (BuildContext context) => AuditAmountDialog(vmAudit: audit),
    );
  }

  _didFinancialAccountNewTransactionClick(FinancialAccountDataModel? account) {
    if (account == null) return;
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          margin: AppDimens.kMarginSmall,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // New Transaction
              Container(
                padding: AppDimens.kVerticalMarginSssmall,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    AppStrings.newTransaction,
                    textAlign: TextAlign.center,
                    style: AppStyles.boldText.copyWith(color: AppColors.hintColor),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              /*   account.enumType == EnumFinancialAccountType.cash
                  ? const Divider(height: 0.5, color: Colors.grey)
                  : Container(),*/
              const Divider(height: 0.5, color: Colors.grey),
              if (account.enumType.value == EnumFinancialAccountType.cash.value || account.enumType.value == EnumFinancialAccountType.bankLedger.value)
                //Withdrawal
                Container(
                  color: Colors.white,
                  child: ListTile(
                    title: const Text(
                      AppStrings.buttonWithdrawal,
                      textAlign: TextAlign.center,
                      style: AppStyles.bottomMenuText,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _gotoWithdrawalScreen(account);
                    },
                  ),
                ),

              const Divider(height: 0.5, color: Colors.grey),
              Container(
                color: Colors.white,
                child: ListTile(
                  title: const Text(
                    AppStrings.buttonDeposit,
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _gotoDepositScreen(account);
                  },
                ),
              ),
              const Divider(height: 0.5, color: Colors.grey),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
                child: ListTile(
                  title: const Text(
                    AppStrings.buttonPurchase,
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _gotoPurchaseScreen(account);
                  },
                ),
              ),
              const Divider(height: 8, color: Colors.transparent),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                child: ListTile(
                  title: const Text(
                    AppStrings.buttonCancel,
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuCancelText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  onClickedAudit(FinancialAccountDataModel account, int position) {
    _didFinancialAccountAuditClick(account);
  }

  @override
  onClickedHistory(FinancialAccountDataModel account, int position) {
    _gotoTransactionsListScreen(account);
  }

  @override
  onClickedNewTransaction(FinancialAccountDataModel account, int position) {
    _didFinancialAccountNewTransactionClick(account);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Action Bar
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          getNavTitle(),
          style: AppStyles.textCellHeaderStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: AppDimens.kHorizontalMarginBig.copyWith(left: 0),
            child: GestureDetector(
              onTap: () {
                _gotoAccountDetailsScreen();
              },
              child: const Icon(
                Icons.add,
                size: 30.0,
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        bottom: true,

        //Consumer Accounts Listview
        child: Container(
          margin: AppDimens.kHorizontalMarginNormal,
          child: RefreshIndicator(
            onRefresh: () {
              _requestFinancialAccounts(false);
              return Future.delayed(const Duration(milliseconds: 1000));
            },
            child: ConsumerAccountsListView(arrayAccounts: arrayAccounts, buttonListener: this),
          ),
        ),
      ),
    );
  }
}
