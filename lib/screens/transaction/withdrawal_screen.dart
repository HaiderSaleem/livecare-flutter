import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livecare/components/signature_pad.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/financialAccount/financial_account_manager.dart';
import 'package:livecare/models/organization/organization_manager.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/transaction/dataModel/transaction_data_model.dart';
import 'package:livecare/models/transaction/transaction_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/transaction/viewModel/withdrawal_view_model.dart';
import 'package:livecare/utils/decimal_text_input_formatter.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

// ignore: must_be_immutable
class WithdrawalScreen extends BaseScreen {
  WithdrawalViewModel? vmWithdrawal;

  WithdrawalScreen({Key? key, required this.vmWithdrawal}) : super(key: key);

  @override
  _WithdrawalScreenState createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends BaseScreenState<WithdrawalScreen> {
  String _txtTotalAmount = " \$0.00";
  String _txtDate = "";
  String _selectedConsumer = "";
  String _selectedBillCategory = "";
  int _indexConsumer = -1;
  int _indexBillingCategory = -1;
  final _edtAmount = TextEditingController();
  final _edtDescription = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _picker = ImagePicker();
  final List<String> _arrayConsumers = [];
  List<String> _arrayBillingCategories = [];
  bool showHideBillingCategories = false;

  List<File?> _arrayImages = [];
  final bool _isSwitchSpending = true;
  String _txtSignature = "Electronic Signature of Consumer";

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  _refreshFields() {
    if (widget.vmWithdrawal == null) {
      widget.vmWithdrawal = WithdrawalViewModel();
      widget.vmWithdrawal!.date = DateTime.now();
    }

    _refreshDatePanel();
    _arrayBillingCategories = OrganizationManager.sharedInstance.arrayOrganizations[0].arrayBillingCategories;

    //Consumer
    final consumers = ConsumerManager.sharedInstance.arrayConsumers;
    _arrayConsumers.addAll(consumers.map((e) => e.szName));
    if (widget.vmWithdrawal!.getModelConsumer() != null) {
      // pre-select the consumer
      var i = 0;
      for (var c in consumers) {
        if (widget.vmWithdrawal!.getModelConsumer()!.id == c.id) {
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

    _refreshSignatureButtons();

    _setupImageGripAdapter();

    if (widget.vmWithdrawal!.isSharedAccount) {
      _selectedConsumer = "Shared";
    }
  }

  _refreshSignatureButtons() {
    if (widget.vmWithdrawal == null) return;
    setState(() {
      if (widget.vmWithdrawal != null && widget.vmWithdrawal!.getModelConsumer() != null) {
        _txtSignature = "Electronic Signature of " + widget.vmWithdrawal!.getModelConsumer()!.szName;
      } else {
        _txtSignature = "Electronic Signature of Consumer";
      }
    });
  }

  _refreshDatePanel() {
    if (widget.vmWithdrawal == null) return;

    setState(() {
      _txtDate = (UtilsDate.getStringFromDateTimeWithFormat(widget.vmWithdrawal!.date, EnumDateTimeFormat.EEEEMMMMdyyyy.value, false));
    });
  }

  _setupImageGripAdapter() {
    final List<File?> arrayGrid = [];
    for (var i in widget.vmWithdrawal!.arrayPhotos) {
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
    if (widget.vmWithdrawal == null) return;

    if (index < widget.vmWithdrawal!.arrayPhotos.length) {
      widget.vmWithdrawal!.arrayPhotos.removeAt(index);
    }
    _setupImageGripAdapter();
  }

  _showTakePhotoDialog() {
    UtilsBaseFunction.showImagePicker(context, _takePhotoFromCamera, _choosePhotoFromGallery);
  }

  Future _choosePhotoFromGallery() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    final File file = File(pickedFile!.path);
    widget.vmWithdrawal!.arrayPhotos.add(file);
    setState(() {
      _setupImageGripAdapter();
    });
  }

  Future _takePhotoFromCamera() async {
    PickedFile? pickedFile = await _picker.getImage(source: ImageSource.camera);
    final File file = File(pickedFile!.path);
    widget.vmWithdrawal!.arrayPhotos.add(file);
    _setupImageGripAdapter();
  }

  _showConsumerPicker(BuildContext context) {
    if (widget.vmWithdrawal!.isSharedAccount) return;
    Picker picker = Picker(
      adapter: PickerDataAdapter<String>(pickerData: _arrayConsumers),
      changeToFirst: false,
      textAlign: TextAlign.left,
      looping: false,
      confirmTextStyle: AppStyles.bottomMenuCancelText,
      confirmText: AppStrings.done,
      textStyle: const TextStyle(color: Colors.grey, fontFamily: "Lato"),
      selectedTextStyle: const TextStyle(color: AppColors.textBlack, fontSize: 20),
      columnPadding: const EdgeInsets.all(10.0),
      onConfirm: (Picker picker, List value) {
        final consumer = ConsumerManager.sharedInstance.arrayConsumers[value.first];
        widget.vmWithdrawal!.setModelConsumer(consumer);
        _requestGetAccountsForConsumer(consumer, (success) {});
        setState(
          () {
            _indexConsumer = value.first;
            _selectedConsumer = picker.getSelectedValues().first;
          },
        );
      },
    );
    picker.show(_scaffoldKey.currentState!);
  }

  _showBillCategoryPicker(BuildContext context) {
    //if (widget.vmWithdrawal!.isSharedAccount) return;
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

  bool _validateFields() {
    if (widget.vmWithdrawal == null) return false;

    if (!widget.vmWithdrawal!.isSharedAccount) {
      // Consumer
      if (_selectedConsumer == AppStrings.selectConsumer) {
        showToast("Please select consumer.");
        return false;
      }

      final consumer = ConsumerManager.sharedInstance.arrayConsumers[_indexConsumer];
      //widget.vmWithdrawal!.setModelConsumer(consumer);
    }

    // Amount
    final amount = UtilsString.parseDouble(_edtAmount.text.replaceAll("\$", ""), 0.0);
    if (amount < 0.01) {
      showToast("Please enter valid amount.");
      return false;
    }

    // Description
    final desc = _edtDescription.text;

    // Photos & Signatures ---? Already set

    if (widget.vmWithdrawal!.arrayPhotos.isEmpty) {
      showToast("Please add photos.");
      return false;
    }

    if (_isSwitchSpending) {
      if (widget.vmWithdrawal!.hasConsumerSigned() == false) {
        showToast("Please ask consumer to sign.");
        return false;
      }

      if (widget.vmWithdrawal!.hasCaregiverSigned() == false) {
        showToast("Please sign.");
        return false;
      }
    }

    widget.vmWithdrawal!.fAmount = amount;
    widget.vmWithdrawal!.szDescription = desc;
    if (_selectedBillCategory == AppStrings.selectBillCate) {
      _selectedBillCategory = "";
    }
    widget.vmWithdrawal!.szCategory = _selectedBillCategory;
    widget.vmWithdrawal!.isDiscretionarySpending = _isSwitchSpending;

    return true;
  }

  Future<void> _prepareWithdrawal() async {
    if (!_validateFields()) return;
    showProgressHUD();
    try {
      TransactionDataModel? transaction = await widget.vmWithdrawal!.toDataModel();
      if (transaction == null) {
        throw Exception("Transaction data model is null.");
      }
      await _requestWithdrawal(transaction);
    } catch (error) {
      hideProgressHUD();
      showToast(error.toString());
    }
    Navigator.of(context).pop();
  }

  Future<void> _requestWithdrawal(TransactionDataModel transaction) async {
    showProgressHUD();

    TransactionManager.sharedInstance.requestWithdrawal(widget.vmWithdrawal!.selectedAccountId, transaction).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        bool exceedsMaxSpend = false;
        final newTransaction = responseDataModel.parsedObject as TransactionDataModel?;
        if (newTransaction != null) {
          exceedsMaxSpend = newTransaction.isExceedsMaxSpendForPeriod;
        }
        if (widget.vmWithdrawal!.isSharedAccount) {
          _requestGetAccountsForLocation(widget.vmWithdrawal!.modelAccount!.refLocation!, (success) {
            hideProgressHUD();
            if (success) _gotoBack(exceedsMaxSpend);
          });
        } else {
          _requestGetAccountsForConsumer(transaction.refConsumer!, (success) {
            hideProgressHUD();
            if (success) _gotoBack(exceedsMaxSpend);
          });
        }
      } else {
        hideProgressHUD();
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _requestGetAccountsForConsumer(ConsumerDataModel consumer, Function(bool success) callback) {
    showProgressHUD();
    FinancialAccountManager.sharedInstance.requestGetAccountsForConsumer(consumer, true, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        callback(true);
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
        callback(false);
      }
    });
  }

  _requestGetAccountsForLocation(LocationDataModel location, Function(bool success) callback) {
    showProgressHUD();
    FinancialAccountManager.sharedInstance.requestGetAccountsForLocation(location, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        callback(true);
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
        callback(false);
      }
    });
  }

  _showSignatureScreen(bool forUser) async {
    final data = await Navigator.push(
      context,
      createRoute(
        SignaturePad(
          forUser: forUser,
        ),
      ),
    );
    if (data == null) return;
    final File file = data;
    if (forUser) {
      setState(() {
        widget.vmWithdrawal!.imageConsumerSignature = file;
      });

      _refreshSignatureButtons();
    } else {
      setState(() {
        widget.vmWithdrawal!.imageCaregiverSignature = file;
      });

      _refreshSignatureButtons();
    }
  }

  _gotoBack(bool exceedsMaxSpend) {
    if (exceedsMaxSpend) {
      UtilsBaseFunction.showAlert(context, "Warning", "You exceed max spending limitation", onBackPressed);
    } else {
      // Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pop(context);
      //onBackPressed();
    }
  }

  _showCalendar(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(
        () {
          _selectedDate = picked;
          widget.vmWithdrawal!.date = picked;
        },
      );
    }
    setState(
      () {
        _txtDate = UtilsDate.getStringFromDateTimeWithFormat(_selectedDate, EnumDateTimeFormat.EEEEMMMMdyyyy.value);
      },
    );
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
          AppStrings.buttonWithdrawal,
          style: AppStyles.textCellHeaderStyle,
        ),
        actions: <Widget>[
          //Save Button
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                _prepareWithdrawal();
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
                //Date
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
                        child: Text(_txtDate, style: AppStyles.headingValue)),
                  ),
                ]),
                const Divider(height: 0.5, color: Colors.grey),
                //Consumer
                Row(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        margin: AppDimens.kMarginSsmall.copyWith(left: 0),
                        height: AppDimens.kEdittextHeight,
                        alignment: Alignment.centerRight,
                        child: const Text(AppStrings.labelConsumer, textAlign: TextAlign.right, style: AppStyles.textGrey)),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _showConsumerPicker(context);
                        },
                        child: Text(_selectedConsumer, style: AppStyles.headingValue),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 0.5, color: Colors.grey),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: const Text(AppStrings.labelAmount, textAlign: TextAlign.right, style: AppStyles.textGrey),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _edtAmount,
                        cursorColor: Colors.grey,
                        textAlign: TextAlign.left,
                        onChanged: (value) {
                          final String amountString = value.replaceAll("\$", " ");
                          final double amount = UtilsString.parseDouble(amountString, 0.0);
                          setState(() {
                            _txtTotalAmount = " \$${amount.toStringAsFixed(2)}";
                          });
                        },
                        style: AppStyles.headingValue,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                        decoration: AppStyles.transactionInputDecoration.copyWith(hintText: AppStrings.hintEnterAmount),
                      ),
                    ),
                  ],
                ),
                //Consumer
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
                              child: const Text(AppStrings.labelCategory, textAlign: TextAlign.right, style: AppStyles.textGrey)),
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
                    SizedBox(
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
                  ],
                ),
                const SizedBox(height: 5),
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
                                child: Image.file(aa, fit: BoxFit.fill),
                              ),
                      );
                    }),
                const SizedBox(height: 30),
                _isSwitchSpending
                    ? Column(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () {
                                _showSignatureScreen(true);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width - 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: widget.vmWithdrawal!.imageConsumerSignature != null ? AppColors.signed : AppColors.unsigned),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    _txtSignature,
                                    textAlign: TextAlign.center,
                                    style: AppStyles.headingValue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () {
                                _showSignatureScreen(false);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width - 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: widget.vmWithdrawal!.imageCaregiverSignature != null ? AppColors.signed : AppColors.unsigned),
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    AppStrings.electronicSignatureOfCaregiver,
                                    textAlign: TextAlign.center,
                                    style: AppStyles.headingValue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
