import 'package:flutter/material.dart';
import 'package:livecare/components/listView/receipt_items_listview.dart';
import 'package:livecare/listeners/receipt_items_listener.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/transaction/purchase/purchase_summary.dart';
import 'package:livecare/screens/transaction/viewModel/purchase_view_model.dart';
import 'package:livecare/utils/decimal_text_input_formatter.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class ReceiptDetailsScreen extends BaseScreen {
  final PurchaseViewModel? vmPurchase;
  final String selectedBillCategory;

  const ReceiptDetailsScreen({Key? key, required this.vmPurchase,
  required this.selectedBillCategory}) : super(key: key);

  @override
  _ReceiptDetailsScreenState createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends BaseScreenState<ReceiptDetailsScreen> with ReceiptItemsListener {
  String _txtDate = "";
  final edtAmount = TextEditingController();
  final edtDescription = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  _refreshFields() {
    if (widget.vmPurchase == null) return;

    widget.vmPurchase!.vmManualReceipt.szVendor = widget.vmPurchase!.szMerchant;

    if (widget.vmPurchase!.vmManualReceipt.date == null) {
      widget.vmPurchase!.vmManualReceipt.date = widget.vmPurchase!.date;
    }
    // Current Date
    _refreshDatePanel();
  }

  _refreshDatePanel() {
    if (widget.vmPurchase == null) return;

    setState(() {
      _txtDate = (UtilsDate.getStringFromDateTimeWithFormat(widget.vmPurchase!.vmManualReceipt.date, EnumDateTimeFormat.EEEEMMMMdyyyy.value, false));
    });
  }

  _showCalendar(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: widget.vmPurchase!.vmManualReceipt.date!, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value == null) return;

      final today = DateTime.now();
      if (today.isBefore(value)) {
        showToast("You cannot select future date.");
      } else {
        widget.vmPurchase!.vmManualReceipt.date = value;
        _refreshDatePanel();
      }
    });
  }

  bool _validateFields() {
    if (widget.vmPurchase == null) return false;

    // Amount
    final amount = UtilsString.parseDouble(edtAmount.text, 0.0);
    if (amount < 0.1) {
      showToast("Please enter amount.");
      return false;
    }

    // Item names
    if (widget.vmPurchase!.vmManualReceipt.arrayNames.isEmpty) {
      showToast("Please add at least one item.");
      return false;
    }

    for (var name in widget.vmPurchase!.vmManualReceipt.arrayNames) {
      if (name.isEmpty) {
        showToast("Please enter items.");
        return false;
      }
    }

    widget.vmPurchase!.vmManualReceipt.fAmount = amount;
    return true;
  }

  _gotoSummaryScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PurchaseSummaryScreen(
          vmPurchase: widget.vmPurchase,
          isSharedFinancialAccount: widget.vmPurchase!.isSharedAccount,
      billingCategory: widget.selectedBillCategory)),
    ).then((val) {
      Navigator.pop(context);
    });

  }

  @override
  didReceiptItemDeleteClick(int indexRow) {
    if (widget.vmPurchase == null) return;

    setState(() {
      widget.vmPurchase!.vmManualReceipt.arrayNames.removeAt(indexRow);
    });
  }

  @override
  didReceiptItemNameChanged(String name, int indexRow) {
    if (widget.vmPurchase == null) return;

    if (indexRow < widget.vmPurchase!.vmManualReceipt.arrayNames.length) {
      widget.vmPurchase!.vmManualReceipt.arrayNames[indexRow] = name;
    }
  }

  _addReceiptItem() {
    setState(() {
      widget.vmPurchase!.vmManualReceipt.arrayNames.add("");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.buttonReceipt,
          style: AppStyles.textCellHeaderStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                if (!_validateFields()) return;
                _gotoSummaryScreen();
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.buttonNext, style: AppStyles.buttonTextStyle),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            child: Container(
              margin: AppDimens.kMarginBig,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(AppStrings.labelEnterReceiptDetail, style: AppStyles.totalTransactionText),
                  const SizedBox(height: 15),
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
                          controller: edtAmount,
                          cursorColor: Colors.grey,
                          textAlign: TextAlign.left,
                          onChanged: (value) {},
                          style: AppStyles.headingValue,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                          // inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]')),],

                          decoration: AppStyles.transactionInputDecoration.copyWith(hintText: AppStrings.hintEnterAmount),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 0.5, color: Colors.grey),
                  Row(
                    children: [
                      Container(
                        height: AppDimens.kEdittextHeight,
                        alignment: Alignment.centerRight,
                        margin: AppDimens.kMarginSsmall.copyWith(left: 0),
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: const Text(AppStrings.labelDate, textAlign: TextAlign.right, style: AppStyles.textGrey),
                      ),
                      Expanded(
                        child: InkWell(
                            onTap: () {
                              _showCalendar(context);
                            },
                            child: Text(
                              _txtDate,
                              style: AppStyles.headingValue,
                            )),
                      ),
                    ],
                  ),
                  const Divider(height: 0.5, color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(AppStrings.receiptDetails, textAlign: TextAlign.left, style: AppStyles.totalTransactionText),
                      Container(
                        margin: AppDimens.kVerticalMarginNormal,
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: AppColors.buttonBackground,
                        ),
                        child: InkWell(
                          onTap: () {
                            _addReceiptItem();
                          },
                          child: const Icon(
                            Icons.add,
                            color: AppColors.textWhite,
                            size: 30.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 0.5, color: Colors.grey),
                  ReceiptItemsListView(arrayReceipts: widget.vmPurchase!.vmManualReceipt.arrayNames, itemClickListener: this)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
