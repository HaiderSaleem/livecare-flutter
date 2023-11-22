import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/financialAccount/financial_account_manager.dart';
import 'package:livecare/models/transaction/dataModel/transaction_data_model.dart';
import 'package:livecare/models/transaction/transaction_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/transaction/viewModel/deposit_view_model.dart';
import 'package:livecare/utils/decimal_text_input_formatter.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

import '../../models/organization/organization_manager.dart';

// ignore: must_be_immutable
class DepositScreen extends BaseScreen {
  DepositViewModel? vmDeposit;

  DepositScreen({Key? key, required this.vmDeposit}) : super(key: key);

  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends BaseScreenState<DepositScreen> {
  String _txtTotalAmount = " \$0.00";
  String _txtDate = "";
  String _selectedConsumer = "";
  String _selectedBillCategory = "";

  int _indexConsumer = -1;

  int _indexBillingCategory = -1;

  String _selectedAccount = "";
  int _indexAccount = -1;
  final _edtAmount = TextEditingController();
  final _edtDescription = TextEditingController();
  DateTime selectedDate = DateTime.now();
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _picker = ImagePicker();
  final List<String> _arrayConsumers = [];
  final List<String> _arrayAccounts = [];
  List<File?> _arrayImages = [];

  List<String> _arrayBillingCategories = [];
  bool showHideBillingCategories = false;

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  _refreshFields() {
    if (widget.vmDeposit == null) {
      widget.vmDeposit = DepositViewModel();
      widget.vmDeposit!.date = DateTime.now();
    }

    _refreshDatePanel();

    // Consumer
    final consumers = ConsumerManager.sharedInstance.arrayConsumers;
    _arrayConsumers.clear();
    _arrayConsumers.addAll(consumers.map((e) => e.szName));
    _arrayBillingCategories = OrganizationManager.sharedInstance.arrayOrganizations[0].arrayBillingCategories;

    if (widget.vmDeposit!.modelConsumer != null) {
      // pre-select the consumer
      var i = 0;
      for (var c in consumers) {
        if (widget.vmDeposit!.modelConsumer!.id == c.id) {
          _indexConsumer = i;
          break;
        }
        i += 1;
      }
    }
    if (_indexConsumer != -1) {
      _selectedConsumer = consumers[_indexConsumer].szName;
    } else {
      _selectedConsumer = AppStrings.selectConsumer;
    }

    if (_indexBillingCategory != -1) {
      _selectedBillCategory = _arrayBillingCategories[_indexBillingCategory];
    } else {
      _selectedBillCategory = AppStrings.selectBillCate;
    }

    if (_arrayBillingCategories.isNotEmpty) {
      showHideBillingCategories = true;
    } else {
      showHideBillingCategories = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAccountList(_indexConsumer);
    });
    _setupImageGripAdapter();

    if (widget.vmDeposit!.isSharedAccount) {
      _selectedConsumer = widget.vmDeposit!.modelAccount!.szName;
      _selectedConsumer = "Shared";
      if (widget.vmDeposit!.modelAccount != null) {
        _selectedAccount = widget.vmDeposit!.modelAccount!.szName;
      }
    }
  }

  _refreshDatePanel() {
    if (widget.vmDeposit == null) return;

    setState(() {
      _txtDate = (UtilsDate.getStringFromDateTimeWithFormat(widget.vmDeposit!.date, EnumDateTimeFormat.EEEEMMMMdyyyy.value, false));
    });
  }

  _refreshAccountList(int indexConsumer) {
    if (indexConsumer == -1) {
      _selectedAccount = AppStrings.selectAccount;
      return;
    }

    final consumer = ConsumerManager.sharedInstance.arrayConsumers[indexConsumer];

    showProgressHUD();
    FinancialAccountManager.sharedInstance.requestGetAccountsForConsumer(consumer, false, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        if (consumer.arrayAccounts != null) {
          _arrayAccounts.clear();
          _arrayAccounts.addAll(consumer.arrayAccounts!.map((e) => e.szName));

          // pre-select the account in callback (to run after accounts-list is retrieved from server)
          // var indexAccount = -1;
          if (widget.vmDeposit!.modelConsumer != null && widget.vmDeposit!.modelAccount != null && widget.vmDeposit!.modelConsumer!.arrayAccounts != null) {
            var i = 0;
            for (var a in widget.vmDeposit!.modelConsumer!.arrayAccounts!) {
              if (widget.vmDeposit!.modelAccount!.id == a.id) {
                _indexAccount = i;
                break;
              }
              i += 1;
            }
          }
          setState(() {
            if (_indexAccount != -1) {
              _selectedAccount = _arrayAccounts[_indexAccount];
            } else {
              _selectedAccount = AppStrings.selectAccount;
            }
          });
        }
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
        _selectedAccount = AppStrings.selectAccount;
      }
    });
  }

  _setupImageGripAdapter() {
    final List<File?> arrayGrid = [];
    for (var i in widget.vmDeposit!.arrayPhotos) {
      arrayGrid.add(i);
    }
    arrayGrid.add(null);
    setState(() {
      _arrayImages = arrayGrid;
    });
  }

  _showDeleteDialog(int index) {
    UtilsBaseFunction.removeItemBottomSheet(context, () => _removePhotoAtIndex(index));
  }

  _removePhotoAtIndex(int index) {
    if (widget.vmDeposit == null) return;

    if (index < widget.vmDeposit!.arrayPhotos.length) {
      widget.vmDeposit!.arrayPhotos.removeAt(index);
    }
    _setupImageGripAdapter();
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
            _selectedBillCategory = picker.getSelectedValues().first;
          },
        );
      },
    );
    picker.show(_scaffoldKey.currentState!);
  }

  _showTakePhotoDialog() {
    UtilsBaseFunction.showImagePicker(context, _takePhotoFromCamera, _choosePhotoFromGallery);
  }

  Future _choosePhotoFromGallery() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    final File file = File(pickedFile!.path);
    widget.vmDeposit!.arrayPhotos.add(file);
    setState(() {
      _setupImageGripAdapter();
    });
  }

  Future _takePhotoFromCamera() async {
    PickedFile? pickedFile = await _picker.getImage(source: ImageSource.camera);
    final File file = File(pickedFile!.path);
    widget.vmDeposit!.arrayPhotos.add(file);
    setState(() {
      _setupImageGripAdapter();
    });
  }

  _showConsumerPicker(BuildContext context) {
    if (widget.vmDeposit!.isSharedAccount) return;
    Picker picker = Picker(
      adapter: PickerDataAdapter<String>(pickerData: _arrayConsumers),
      changeToFirst: false,
      textAlign: TextAlign.left,
      looping: false,
      confirmTextStyle: const TextStyle(color: AppColors.primaryColor, fontFamily: "Lato", fontSize: 18, fontWeight: FontWeight.w700),
      confirmText: AppStrings.done,
      textStyle: const TextStyle(color: Colors.grey, fontFamily: "Lato"),
      selectedTextStyle: const TextStyle(color: AppColors.textBlack, fontSize: 20),
      columnPadding: const EdgeInsets.all(10.0),
      onConfirm: (Picker picker, List value) {
        _refreshAccountList(value.first);
        setState(() {
          _selectedConsumer = picker.getSelectedValues().first;
          _indexConsumer = value.first;
        });
      },
    );
    picker.show(_scaffoldKey.currentState!);
  }

  _showAccountPicker(BuildContext context) {
    Picker picker = Picker(
      adapter: PickerDataAdapter<String>(pickerData: _arrayAccounts),
      changeToFirst: false,
      textAlign: TextAlign.left,
      looping: false,
      confirmTextStyle: const TextStyle(color: AppColors.primaryColor, fontFamily: "Lato", fontSize: 18, fontWeight: FontWeight.w700),
      confirmText: AppStrings.done,
      textStyle: const TextStyle(color: Colors.grey, fontFamily: "Lato"),
      selectedTextStyle: const TextStyle(color: AppColors.textBlack, fontSize: 20),
      columnPadding: const EdgeInsets.all(10.0),
      onConfirm: (Picker picker, List value) {
        setState(() {
          _selectedAccount = picker.getSelectedValues().first;
          _indexAccount = value.first;
        });
      },
    );
    picker.show(_scaffoldKey.currentState!);
  }

  bool _validateFields() {
    if (widget.vmDeposit == null) return false;

    if (!widget.vmDeposit!.isSharedAccount) {
      // Consumer
      if (_selectedConsumer == AppStrings.selectConsumer) {
        showToast("Please select consumer.");
        return false;
      }

      final consumer = ConsumerManager.sharedInstance.arrayConsumers[_indexConsumer];

      // Account
      if (_selectedAccount == AppStrings.selectAccount) {
        showToast("Please select account.");
        return false;
      }
      final account = consumer.arrayAccounts![_indexAccount];

      widget.vmDeposit!.modelConsumer = consumer;
      widget.vmDeposit!.modelAccount = account;
    }

    // Amount
    final amount = UtilsString.parseDouble(_edtAmount.text, 0.0);
    if (amount < 0.01) {
      showToast("Please enter valid amount.");
      return false;
    }
    // Description
    final desc = _edtDescription.text;

    // Photos & Signatures ---? Already set
    if (widget.vmDeposit!.arrayPhotos.isEmpty) {
      showToast("Please add photos.");
      return false;
    }

    widget.vmDeposit!.fAmount = amount;
    widget.vmDeposit!.szDescription = desc;

    return true;
  }

  Future<void> _prepareDeposit() async {
    if (!_validateFields()) return;
    showProgressHUD();
    try {
      TransactionDataModel? transaction = await widget.vmDeposit!.toDataModel();
      if (transaction == null) {
        throw Exception("Transaction data model is null.");
      }
      await _requestDeposit(transaction);
    } catch (error) {
      hideProgressHUD();
      showToast(error.toString());
    }
    Navigator.of(context).pop();
  }

  Future<void> _requestDeposit(TransactionDataModel transaction) async {
    showProgressHUD();

    await TransactionManager.sharedInstance.requestDeposit(transaction, (responseDataModel) async {
      hideProgressHUD();

      if (responseDataModel.isSuccess) {
        await requestFinancialAccount(transaction.refConsumer);
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  requestFinancialAccount(ConsumerDataModel consumer) {
    showProgressHUD();

    FinancialAccountManager.sharedInstance.requestGetAccountsForConsumer(consumer, true, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        _gotoBack();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _gotoBack() {
    Navigator.pop(context);
  }

  _showCalendar(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.vmDeposit!.date = picked;
      });
    }
    setState(() {
      _txtDate = UtilsDate.getStringFromDateTimeWithFormat(selectedDate, EnumDateTimeFormat.EEEEMMMMdyyyy.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.buttonDeposit,
          style: AppStyles.textCellHeaderStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                _prepareDeposit();
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
            margin: AppDimens.kMarginBig,
            child: Column(
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
                    child: InkWell(
                        onTap: () {
                          _showCalendar(context);
                        },
                        child: Text(
                          _txtDate,
                          style: AppStyles.headingText,
                        )),
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
                      child: const Text(AppStrings.labelConsumer, textAlign: TextAlign.right, style: AppStyles.textGrey),
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        _showConsumerPicker(context);
                      },
                      child: Text(_selectedConsumer, style: AppStyles.headingValue),
                    )),
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
                        if (_arrayAccounts.length > 1) {
                          _showAccountPicker(context);
                        }
                      },
                      child: Text(_selectedAccount, style: AppStyles.headingValue),
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
                        controller: _edtAmount,
                        cursorColor: Colors.grey,
                        textAlign: TextAlign.left,
                        onChanged: (value) {
                          final double amount = UtilsString.parseDouble(value, 0.0);
                          setState(() {
                            _txtTotalAmount = " \$${amount.toStringAsFixed(2)}";
                          });
                        },
                        style: AppStyles.headingValue,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                        decoration: AppStyles.transactionInputDecoration.copyWith(
                          hintText: AppStrings.hintEnterAmount,
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: showHideBillingCategories,
                  child: Column(
                    children: [
                      const Divider(height: 0.5, color: Colors.grey),
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.30,
                            margin: AppDimens.kMarginSsmall.copyWith(left: 0),
                            height: AppDimens.kEdittextHeight,
                            alignment: Alignment.centerRight,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _showBillCategoryPicker(context);
                              },
                              child: Text(_selectedBillCategory, style: AppStyles.headingValue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0.5, color: Colors.grey),
                Row(
                  children: [
                    Container(
                      height: AppDimens.kEdittextHeight,
                      alignment: Alignment.centerRight,
                      margin: AppDimens.kVerticalMarginSsmall,
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: const Text(AppStrings.labelDescription, textAlign: TextAlign.right, style: AppStyles.textGrey),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _edtDescription,
                        cursorColor: Colors.grey,
                        textAlign: TextAlign.left,
                        onChanged: (value) {},
                        style: AppStyles.headingValue,
                        keyboardType: TextInputType.name,
                        decoration: AppStyles.transactionInputDecoration.copyWith(hintText: AppStrings.hintEnterDescription),
                      ),
                    ),
                    /* Expanded(child: TextFormField(
                      controller: _edtAmount,
                      cursorColor: Colors.green,
                      textAlign: TextAlign.left,
                      onChanged: (value){},
                      style: AppStyles.textCellStyle,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]')),],
                      decoration: AppStyles.transactionInputDecoration
                      .copyWith(hintText: AppStrings.hintEnterAccountName),
                    )),*/
                  ],
                ),
                const Divider(height: 0.5, color: Colors.grey),
                const SizedBox(height: 15),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    maxCrossAxisExtent: 100,
                  ),
                  itemCount: _arrayImages.length,
                  itemBuilder: (BuildContext ctx, index) {
                    final aa = _arrayImages[index];
                    return InkWell(
                      onTap: () {
                        _showDeleteDialog(index);
                      },
                      child: aa == null
                          ? InkWell(
                              onTap: () {
                                _showTakePhotoDialog();
                              },
                              child: Container(
                                decoration: const BoxDecoration(color: AppColors.textWhite, borderRadius: BorderRadius.all(Radius.circular(1))),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 35.0,
                                    ),
                                    Text(AppStrings.addImage)
                                  ],
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                aa,
                                fit: BoxFit.fill,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
