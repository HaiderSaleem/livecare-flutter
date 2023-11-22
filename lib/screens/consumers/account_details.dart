import 'package:flutter/material.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/financialAccount/financial_account_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/consumers/viewModel/financial_account_view_model.dart';
import 'package:livecare/utils/decimal_text_input_formatter.dart';
import 'package:livecare/utils/string_extensions.dart';
import 'package:livecare/utils/utils_string.dart';

class AccountDetailsScreen extends BaseScreen {
  final FinancialAccountViewModel? vmAccount;

  const AccountDetailsScreen({Key? key, required this.vmAccount}) : super(key: key);

  @override
  _AccountDetailsScreenState createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends BaseScreenState<AccountDetailsScreen> {
  String txtAccountName = AppStrings.newGiftCard;
  final edtMerchant = TextEditingController();
  final edtCardNumber = TextEditingController();
  final edtAmount = TextEditingController();
  final edtDescription = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshAccountName();
  }

  _getNavTitle() {
    if (widget.vmAccount == null || !widget.vmAccount!.refConsumer.isValid()) {
      return "New Gift Card";
    }
    return widget.vmAccount!.refConsumer!.szName;
  }

  _refreshAccountName() {
    var merchant = edtMerchant.text;
    var card = edtCardNumber.text;
    if (merchant.isEmpty || card.isEmpty) {
      setState(() {
        txtAccountName = "New Gift Card";
      });
    } else {
      merchant.take(24);
      card = card.take(4);
      merchant = merchant.capitalize();
      setState(() {
        txtAccountName = merchant + " (" + card + ")";
      });
    }
  }

  bool _validateFields() {
    if (widget.vmAccount == null) return false;

    // Account Name
    _refreshAccountName();
    final accountName = txtAccountName;

    final merchant = edtMerchant.text;
    if (merchant.isEmpty) {
      showToast("Please enter merchant name.");
      return false;
    }

    final last4 = edtCardNumber.text;
    if (last4.isEmpty) {
      showToast("Please enter last 4 digits of your gift card.");
      return false;
    }

    final amount = UtilsString.parseDouble(edtAmount.text, -1.0);
    if (amount < 0) {
      showToast("Please enter starting balance.");
      return false;
    }

    final desc = edtDescription.text.toString();
    if (desc.isEmpty) {
      showToast("Please enter description.");
      return false;
    }

    widget.vmAccount!.szName = accountName;
    widget.vmAccount!.szMerchant = merchant;
    widget.vmAccount!.szLast4 = last4;
    widget.vmAccount!.fStartingBalance = amount;
    widget.vmAccount!.szDescription = desc;

    return true;
  }

  _requestCreateCard() {
    if (!widget.vmAccount!.refConsumer.isValid()) {
      showToast("Something went wrong.");
      return;
    }

    final FinancialAccountDataModel account = widget.vmAccount!.toDataModel();
    showProgressHUD();

    FinancialAccountManager.sharedInstance.requestCreateAccount(account, widget.vmAccount!.refConsumer, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        onBackPressed();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
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
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                if (_validateFields()) {
                  _requestCreateCard();
                }
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.buttonSave, style: AppStyles.buttonTextStyle),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Container(
            color: AppColors.defaultBackground,
            width: MediaQuery.of(context).size.width,
            child: Container(
              margin: AppDimens.kMarginBig,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(txtAccountName, style: AppStyles.headingText),
                  const SizedBox(height: 15),
                  const Divider(height: 0.5, color: Colors.grey),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        margin: AppDimens.kHorizontalMarginSsmall.copyWith(left: 0),
                        child: const Text(
                          AppStrings.labelMerchant,
                          textAlign: TextAlign.right,
                          style: AppStyles.textGrey,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: edtMerchant,
                          cursorColor: Colors.grey,
                          textAlign: TextAlign.left,
                          onChanged: (value) {
                            _refreshAccountName();
                          },
                          style: AppStyles.textGrey,
                          keyboardType: TextInputType.name,
                          decoration: AppStyles.transactionInputDecoration.copyWith(hintText: AppStrings.hintEnterMerchantName),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 0.5, color: Colors.grey),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        margin: AppDimens.kHorizontalMarginSsmall.copyWith(left: 0),
                        child: const Text(AppStrings.labelCardNumber, textAlign: TextAlign.right, style: AppStyles.textGrey),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: edtCardNumber,
                          cursorColor: Colors.grey,
                          textAlign: TextAlign.left,
                          onChanged: (value) {
                            _refreshAccountName();
                          },
                          style: AppStyles.textGrey,
                          keyboardType: TextInputType.number,
                          decoration: AppStyles.transactionInputDecoration.copyWith(hintText: AppStrings.hintEnterCardNumber),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 0.5, color: Colors.grey),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        margin: AppDimens.kHorizontalMarginSsmall.copyWith(left: 0),
                        child: const Text(AppStrings.labelAmount, textAlign: TextAlign.right, style: AppStyles.textGrey),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: edtAmount,
                          cursorColor: Colors.grey,
                          textAlign: TextAlign.left,
                          style: AppStyles.textGrey,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                          decoration: AppStyles.transactionInputDecoration.copyWith(hintText: AppStrings.hintEnterAmount),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 0.5, color: Colors.grey),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        margin: AppDimens.kHorizontalMarginSsmall.copyWith(left: 0),
                        child: const Text(AppStrings.labelDescription, textAlign: TextAlign.right, style: AppStyles.textGrey),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: edtDescription,
                          cursorColor: Colors.grey,
                          textAlign: TextAlign.left,
                          style: AppStyles.textGrey,
                          keyboardType: TextInputType.name,
                          decoration: AppStyles.transactionInputDecoration.copyWith(hintText: AppStrings.hintEnterDescription),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 0.5, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
