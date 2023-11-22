import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:get/get.dart';
import 'package:livecare/models/organization/organization_manager.dart';
import 'package:livecare/models/transaction/dataModel/transaction_data_model.dart';
import 'package:livecare/models/transaction/transaction_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/transaction/viewModel/purchase_view_model.dart';
import 'package:livecare/utils/utils_date.dart';

class PurchaseSummaryScreen extends BaseScreen {
  final PurchaseViewModel? vmPurchase;
  final bool? isSharedFinancialAccount;
  String billingCategory = "";

  PurchaseSummaryScreen({Key? key, required this.vmPurchase,
    required this.isSharedFinancialAccount, required this.billingCategory}) : super(key: key);

  @override
  _PurchaseSummaryScreenState createState() => _PurchaseSummaryScreenState();
}

class _PurchaseSummaryScreenState extends BaseScreenState<PurchaseSummaryScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _indexBillingCategory = -1;

  List<String> _arrayBillingCategories = [];
  bool showHideBillingCategories = false;

  @override
  void initState() {
    super.initState();

    _arrayBillingCategories = OrganizationManager.sharedInstance.arrayOrganizations[0].arrayBillingCategories;

    if (_arrayBillingCategories.isNotEmpty) {
      showHideBillingCategories = true;
    } else {
      showHideBillingCategories = false;
    }
  }

  bool _validateFields() {
    return true;
  }

  _preparePurchase() {
    if (!_validateFields()) return;
    showProgressHUD();
    widget.vmPurchase!.toDataModel((transactions, message) {
      hideProgressHUD();
      if (transactions != null && transactions.isNotEmpty) {
        _requestPurchase(transactions);
      } else {
        showToast(message);
      }
    });
  }

  _requestPurchase(List<TransactionDataModel> transactions) {
    showProgressHUD();
    TransactionManager.sharedInstance.requestMultiplePurchases(transactions,
            (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        gotoConsumerDetailsScreen();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  gotoConsumerDetailsScreen() {
    Get.back();
    Get.back();
  }

  gotopConsumerDetailsScreen() {
    Navigator.pop(context);
  }

  Widget _purchaseSummaryInfo(BuildContext context, int index) {
    String _txtTotalAmount = "\$${widget.vmPurchase!.getTotalAmount().toStringAsFixed(02)}";
    String _txtDate = UtilsDate.getStringFromDateTimeWithFormat(widget.vmPurchase!.date, EnumDateTimeFormat.MMMdyyyy.value, false);
    String _txtMerchant = widget.vmPurchase!.szMerchant;
    String _txtDescription = widget.vmPurchase!.szDescription;
    String _txtCategory = widget.vmPurchase!.szCategory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.totalTransactionAmount + _txtTotalAmount, style: AppStyles.totalTransactionText),
        const SizedBox(height: 15),
        const Divider(height: 0.5, color: Colors.grey),
        Row(children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.30,
            margin: AppDimens.kMarginSsmall.copyWith(left: 0),
            height: AppDimens.kEdittextHeight,
            alignment: Alignment.centerRight,
            child: const Text(AppStrings.labelDate, textAlign: TextAlign.right, style: AppStyles.textGrey),
          ),
          Expanded(
            child: Text(_txtDate, style: AppStyles.headingValue),
          ),
        ]),
        const Divider(height: 0.5, color: Colors.grey),
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.30,
              margin: AppDimens.kMarginSsmall.copyWith(left: 0),
              height: AppDimens.kEdittextHeight,
              alignment: Alignment.centerRight,
              child: const Text(AppStrings.labelMerchant, textAlign: TextAlign.right, style: AppStyles.textGrey),
            ),
            Expanded(child: Text(_txtMerchant, style: AppStyles.headingValue)),
          ],
        ),
        const Divider(height: 0.5, color: Colors.grey),
        Visibility(
          visible: showHideBillingCategories,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.30,
                      margin: AppDimens.kMarginSsmall.copyWith(left: 0),
                      height: AppDimens.kEdittextHeight,
                      alignment: Alignment.centerRight,
                      child: const Text(AppStrings.labelCategory, textAlign: TextAlign.right, style: AppStyles.textGrey)),
                  Expanded(
                    child: Text(_txtCategory, style: AppStyles.headingValue),
                  ),
                ],
              ),
              const Divider(height: 0.5, color: Colors.grey),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.30,
              margin: AppDimens.kMarginSsmall.copyWith(left: 0),
              height: AppDimens.kEdittextHeight,
              alignment: Alignment.centerRight,
              child: const Text(AppStrings.labelDescription, textAlign: TextAlign.right, style: AppStyles.textGrey),
            ),
            Expanded(
              child: Text(_txtDescription, textAlign: TextAlign.left, style: AppStyles.headingValue),
            ),
          ],
        ),
        const Divider(height: 0.5, color: Colors.grey),
        const SizedBox(
          height: 16,
        )
      ],
    );
  }

  _showBillCategoryPicker(BuildContext context) {
    Picker picker = Picker(
      adapter: PickerDataAdapter<String>(pickerData: _arrayBillingCategories),
      changeToFirst: false,
      textAlign: TextAlign.left,
      looping: false,
      confirmTextStyle: AppStyles.bottomMenuCancelText,
      confirmText: AppStrings.done,
      textStyle: const TextStyle(color: Colors.grey, fontFamily: "Lato"),
      selectedTextStyle: const TextStyle(color: AppColors.textBlack, fontSize: 20),
      columnPadding: const EdgeInsets.all(10.0),
      onConfirm: (Picker picker, List value) {
        // final consumer = ConsumerManager.sharedInstance.arrayConsumers[value.first];
        // widget.vmWithdrawal!.setModelConsumer(consumer);
        // _requestFinancialAccounts(consumer, (success) {});
        setState(
          () {
            _indexBillingCategory = value.first;
            widget.billingCategory = picker.getSelectedValues().first;
          },
        );
      },
    );
    picker.show(_scaffoldKey.currentState!);
  }

  Widget _purchaseSignature(BuildContext context, int index) {
    final transaction = widget.vmPurchase!.arrayTransactionDetails[index - 1];
    if (transaction.getModelAccount() == null) return Container();
    String _txtTitle = "";
    String _txtSpend = "\$${transaction.fAmount.toStringAsFixed(2)}";
    if (transaction.isSharedAccount) {
      _txtTitle = transaction.getAccountName();
    } else {
      _txtTitle = transaction.getConsumerName() + " - " + transaction.getAccountName();
    }
    return Container(
      margin: AppDimens.kMarginSmall,
      padding: AppDimens.kHorizontalMarginNormal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_txtTitle, textAlign: TextAlign.left, style: AppStyles.boldText),
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.30,
                margin: AppDimens.kMarginSsmall.copyWith(bottom: 0),
                height: AppDimens.kEdittextHeight,
                alignment: Alignment.centerRight,
                child: const Text(AppStrings.labelSpend, textAlign: TextAlign.right, style: AppStyles.textGrey),
              ),
              Expanded(
                child: TextFormField(
                  initialValue: _txtSpend,
                  enabled: false,
                  cursorColor: Colors.grey,
                  textAlign: TextAlign.left,
                  onChanged: (value) {},
                  style: AppStyles.headingValue,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: AppStyles.transactionInputDecoration,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _purchaseSummaryImagesSignature(BuildContext context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.labelReceipt, textAlign: TextAlign.left, style: AppStyles.boldText),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 1.0,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            maxCrossAxisExtent: 100,
          ),
          itemCount: widget.vmPurchase!.arrayReceiptPhotos.length,
          itemBuilder: (BuildContext ctx, index) {
            final item = widget.vmPurchase!.arrayReceiptPhotos[index];
            return InkWell(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(item, fit: BoxFit.fill),
              ),
            );
          },
        ),
      ],
    );
  }

  int _getItemCount() {
    return widget.vmPurchase!.hasReceiptPhotos ? widget.vmPurchase!.arrayTransactionDetails.length + 2 : widget.vmPurchase!.arrayTransactionDetails.length + 1;
  }

  Widget _getItemViewType(int index) {
    return index == 0
        ? _purchaseSummaryInfo(context, index)
        : index == widget.vmPurchase!.arrayTransactionDetails.length + 1
            ? _purchaseSummaryImagesSignature(context, index)
            : _purchaseSignature(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(AppStrings.buttonSummary, style: AppStyles.textCellHeaderStyle),
        actions: <Widget>[
          //Submit
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                _preparePurchase();
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.buttonSubmit, style: AppStyles.buttonTextStyle),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Container(
          margin: AppDimens.kMarginBig,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _getItemCount(),
            itemBuilder: (context, index) {
              return _getItemViewType(index);
            },
          ),
        ),
      ),
    );
  }
}
