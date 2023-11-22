import 'package:flutter/material.dart';
import 'package:flutter_picker/picker.dart';
import 'package:livecare/listeners/purchase_receipts_listener.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/financialAccount/financial_account_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/transaction/viewModel/transaction_details_view_model.dart';
import 'package:livecare/utils/decimal_text_input_formatter.dart';
import 'package:livecare/utils/utils_string.dart';

class PurchaseReceiptListView extends BaseScreen {
  final List<TransactionDetailsViewModel> arrayTransactions;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final PurchaseReceiptsListener? itemClickListener;

  const PurchaseReceiptListView({Key? key, required this.arrayTransactions, required this.scaffoldKey, required this.itemClickListener}) : super(key: key);

  @override
  _PurchaseReceiptListViewState createState() => _PurchaseReceiptListViewState();
}

class _PurchaseReceiptListViewState extends BaseScreenState<PurchaseReceiptListView> {
  final List<TextEditingController> _controllers = [];

  @override
  dispose() {
    super.dispose();
    for (TextEditingController c in _controllers) {
      c.dispose();
    }
  }

  _didTransactionDetailsConsumerSelected(int indexConsumer, int position) {
    final consumer = ConsumerManager.sharedInstance.arrayConsumers[indexConsumer];
    showProgressHUD();
    FinancialAccountManager.sharedInstance.requestGetAccountsForConsumer(consumer, false, (responseDataModel) {
      hideProgressHUD();
    });
  }

  _showConsumerPicker(List<String> arrayConsumers, int indexConsumer, int indexRow) {
    Picker picker = Picker(
      adapter: PickerDataAdapter<String>(pickerData: arrayConsumers),
      selecteds: [indexConsumer],
      changeToFirst: false,
      textAlign: TextAlign.left,
      looping: false,
      cancelTextStyle: AppStyles.textCellHeaderStyle.copyWith(color: AppColors.primaryColor),
      confirmTextStyle: AppStyles.textCellHeaderStyle.copyWith(color: AppColors.primaryColor),
      confirmText: "Done",
      textStyle: AppStyles.textStyle.copyWith(color: Colors.grey),
      selectedTextStyle: const TextStyle(color: AppColors.textBlack, fontSize: 18, fontFamily: 'Lato'),
      columnPadding: const EdgeInsets.all(10.0),
      onConfirm: (Picker picker, List value) {
        setState(() {
          widget.itemClickListener?.didTransactionDetailsConsumerSelected(value.first, indexRow);
        });
        _didTransactionDetailsConsumerSelected(value.first, indexRow);
      },
    );
    picker.show(widget.scaffoldKey.currentState!);
  }

  _showAccountPicker(List<String> arrayAccounts, int indexRow) {
    Picker picker = Picker(
      adapter: PickerDataAdapter<String>(pickerData: arrayAccounts),
      changeToFirst: false,
      textAlign: TextAlign.left,
      looping: false,
      cancelTextStyle: AppStyles.textCellHeaderStyle.copyWith(color: AppColors.primaryColor),
      confirmTextStyle: AppStyles.textCellHeaderStyle.copyWith(color: AppColors.primaryColor),
      confirmText: "Done",
      textStyle: AppStyles.textStyle.copyWith(color: Colors.grey),
      selectedTextStyle: const TextStyle(color: AppColors.textBlack, fontSize: 18, fontFamily: 'Lato'),
      columnPadding: const EdgeInsets.all(10.0),
      onConfirm: (Picker picker, List value) {
        setState(() {
          widget.itemClickListener?.didTransactionDetailsAccountSelected(value.first, indexRow);
        });
      },
    );
    picker.show(widget.scaffoldKey.currentState!);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.arrayTransactions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        //textField controllers
        _controllers.add(TextEditingController());

        final transaction = widget.arrayTransactions[index];
        final selectedConsumer = transaction.modelConsumer;

        // Select Consumer
        final arrayConsumers = ConsumerManager.sharedInstance.arrayConsumers;
        final List<String> arrayConsumerNames = [];
        arrayConsumerNames.addAll(arrayConsumers.map((e) => e.szName));

        String _consumerName = "";
        String _accountName = "";

        var indexConsumer = 0;
        var found = false;
        for (var c in arrayConsumers) {
          if (selectedConsumer != null && c.id == selectedConsumer.id) {
            _consumerName = arrayConsumerNames[indexConsumer];
            found = true;
            break;
          }
          indexConsumer += 1;
        }

        if (!found) {
          _consumerName = AppStrings.selectConsumer;
        }

        final selectedAccount = transaction.getModelAccount();
        if (selectedAccount != null) {
          _accountName = selectedAccount.szName;
        } else {
          _accountName = AppStrings.selectAccount;
        }

        if (transaction.isSharedAccount) {
          _consumerName = "Shared";
        } else {
          final selectedAccount = transaction.getModelAccount();
          if (selectedAccount != null) {
            _accountName = selectedAccount.szName;
            _consumerName = selectedAccount.refConsumer.szName;
          } else {
            _accountName = AppStrings.selectAccount;
          }
        }

        // if (transaction.fAmount > 0) {
        //   _controllers[index].text = transaction.fAmount.toStringAsFixed(2);
        // }

        final List<String> arrayAccounts = [];

        if (selectedConsumer != null) {
          widget.itemClickListener?.didTransactionDetailsConsumerSelected(indexConsumer, index);
          FinancialAccountManager.sharedInstance.requestGetAccountsForConsumer(selectedConsumer, false, (responseDataModel) {
            if (responseDataModel.isSuccess) {
              // Select Account
              arrayAccounts.addAll(selectedConsumer.arrayAccounts!.map((e) => e.szName));
              var indexAccount = 0;
              var found = false;
              final transaction = widget.arrayTransactions[index];
              final selectedAccount = transaction.getModelAccount();
              for (var c in selectedConsumer.arrayAccounts!) {
                if (selectedAccount == null) break;
                if (c.id == selectedAccount.id) {
                  _accountName = arrayAccounts[indexAccount];
                  found = true;
                  break;
                }
                indexAccount += 1;
              }

              if (!found) {
                _accountName = AppStrings.selectAccount;
              }
            } else {
              _accountName = AppStrings.selectAccount;
            }
          });
        }

        return Column(
          children: [
            transaction.isSharedAccount
                ? Container()
                : Container(
                    alignment: Alignment.centerRight,
                    margin: AppDimens.kVerticalMarginSmall.copyWith(bottom: 0),
                    child: ElevatedButton(
                      onPressed: () {
                        _controllers.removeAt(index);
                        widget.itemClickListener?.didTransactionDetailsDeleteClick(index);
                      },
                      style: AppStyles.deleteButtonStyle,
                      child: const Text(
                        AppStrings.buttonDelete,
                        textAlign: TextAlign.center,
                        style: AppStyles.buttonTextStyle,
                      ),
                    ),
                  ),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  margin: AppDimens.kMarginSsmall.copyWith(left: 0),
                  height: AppDimens.kEdittextHeight,
                  alignment: Alignment.centerRight,
                  child: const Text(AppStrings.labelConsumer, textAlign: TextAlign.right, style: AppStyles.textGrey),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (transaction.isSharedAccount) return;
                      _showConsumerPicker(arrayConsumerNames, indexConsumer, index);
                    },
                    child: Text(_consumerName, style: AppStyles.headingValue),
                  ),
                ),
              ],
            ),
            const Divider(height: 0.5, color: Colors.grey),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  margin: AppDimens.kMarginSsmall.copyWith(left: 0),
                  height: AppDimens.kEdittextHeight,
                  alignment: Alignment.centerRight,
                  child: const Text(AppStrings.labelAccount, textAlign: TextAlign.right, style: AppStyles.textGrey),
                ),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    if (transaction.isSharedAccount) return;
                    _showAccountPicker(arrayAccounts, index);
                  },
                  child: Text(_accountName, style: AppStyles.headingValue),
                )),
              ],
            ),
            const Divider(height: 0.5, color: Colors.grey),
            Row(
              children: [
                Container(
                  height: AppDimens.kEdittextHeight,
                  alignment: Alignment.centerRight,
                  margin: AppDimens.kVerticalMarginSsmall,
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: const Text(AppStrings.labelAmount, textAlign: TextAlign.right, style: AppStyles.textGrey),
                ),
                Expanded(
                  child: TextFormField(
                    // controller: _controllers[index],
                    initialValue: transaction.fAmount > 0 ? transaction.fAmount.toStringAsFixed(2) : "",
                    cursorColor: Colors.grey,
                    textAlign: TextAlign.left,
                    onChanged: (value) {
                      final double amount = UtilsString.parseDouble(value, 0.0);
                      transaction.fAmount = amount;
                      widget.itemClickListener?.didTransactionDetailsAmountChanged(amount, index);
                    },
                    style: AppStyles.textGrey,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                    //inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]')),],
                    textInputAction: TextInputAction.done,
                    decoration: AppStyles.transactionInputDecoration.copyWith(hintText: AppStrings.hintEnterAmount),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
