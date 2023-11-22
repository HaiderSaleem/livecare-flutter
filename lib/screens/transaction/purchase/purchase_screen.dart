import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_picker/picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livecare/components/listView/purchase_receipt_listview.dart';
import 'package:livecare/listeners/purchase_receipts_listener.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/models/organization/organization_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/transaction/purchase/purchase_summary.dart';
import 'package:livecare/screens/transaction/purchase/receipt_details.dart';
import 'package:livecare/screens/transaction/viewModel/purchase_view_model.dart';
import 'package:livecare/screens/transaction/viewModel/transaction_details_view_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_file.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class PurchaseScreen extends BaseScreen {
  PurchaseViewModel? vmPurchase;

  PurchaseScreen({Key? key, required this.vmPurchase}) : super(key: key);

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends BaseScreenState<PurchaseScreen> with PurchaseReceiptsListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _switchSpending = true;
  String _txtTotalAmount = " \$0.00";
  String _txtDate = "";
  DateTime selectedDate = DateTime.now();
  final edtMerchant = TextEditingController();
  final edtDescription = TextEditingController();
  final _picker = ImagePicker();
  int selectedIndex = 0;
  List<String> pickerMerchantData = [];
  List<File?> _arrayPhotos = [];
  final edtAmount = TextEditingController();

  String _selectedBillCategory = "";
  int _indexBillingCategory = -1;

  List<String> _arrayBillingCategories = [];
  bool showHideBillingCategories = false;

  @override
  void initState() {
    super.initState();
    _refreshFields();
    _refreshReceiptImages();
  }

  _refreshReceiptImages() async {
    if (await Permission.storage.request().isGranted) {
      if (widget.vmPurchase!.arrayReceipt.isNotEmpty && await _shouldDownloadImages()) {
        showProgressHUD();
        widget.vmPurchase!.getReceiptsImages((transactionA, message) {
          hideProgressHUD();
          _populateWithReceiptImages();
        });
      } else {
        _populateWithReceiptImages();
      }
    }
  }

  Future<bool> _shouldDownloadImages() async {
    for (var receipt in widget.vmPurchase!.arrayReceipt) {
      Directory dir = await UtilsFile.getFileDirectory();
      String path = dir.path;
      final imgFile = File('$path/${receipt.modelMedia!.mediaId}.png');
      if (!await imgFile.exists()) {
        return true;
      }
    }
    return false;
  }

  _populateWithReceiptImages() async {
    for (var receipt in widget.vmPurchase!.arrayReceipt) {
      Directory dir = await UtilsFile.getFileDirectory();
      String path = dir.path;
      final imgFile = File('$path/${receipt.modelMedia!.mediaId}.png');
      if (await imgFile.exists()) {
        setState(() {
          _arrayPhotos.insert(0, imgFile);
        });
      }
    }
  }

  _refreshFields() {
    if (widget.vmPurchase == null) {
      widget.vmPurchase = PurchaseViewModel();
      widget.vmPurchase!.date = DateTime.now();
    } else {
      edtMerchant.text = (widget.vmPurchase!.szMerchant);
      edtDescription.text = (widget.vmPurchase!.szDescription);
    }
    _arrayBillingCategories = OrganizationManager.sharedInstance.arrayOrganizations[0].arrayBillingCategories;

    if (_arrayBillingCategories.isNotEmpty) {
      showHideBillingCategories = true;
      if (widget.vmPurchase!.szCategory.isNotEmpty) {
        _selectedBillCategory = widget.vmPurchase!.szCategory;
      } else {
        _selectedBillCategory = AppStrings.selectBillCate;
      }
    } else {
      showHideBillingCategories = false;
    }

    _refreshDatePanel();

    _setupImageGripAdapter();

    _refreshTotalAmount();
  }

  _refreshDatePanel() {
    if (widget.vmPurchase == null) return;

    setState(() {
      _txtDate = (UtilsDate.getStringFromDateTimeWithFormat(widget.vmPurchase!.date, EnumDateTimeFormat.MMMdyyyy.value, false));
    });
  }

  _setupImageGripAdapter() {
    final List<File?> arrayGrid = [];
    for (var i in _arrayPhotos) {
      arrayGrid.add(i);
    }
    arrayGrid.add(null);
    setState(() {
      _arrayPhotos = arrayGrid;
    });
  }

  _showDeleteDialog(int index) {
    UtilsBaseFunction.removeItemBottomSheet(context, () => _removePhotoAtIndex(index));
  }

  _removePhotoAtIndex(int index) {
    _arrayPhotos.removeAt(index);
    setState(() {
      _arrayPhotos = _arrayPhotos;
    });
  }

  _showTakePhotoDialog() {
    UtilsBaseFunction.showImagePicker(context, _takePhotoFromCamera, _choosePhotoFromGallery);
  }

  Future _choosePhotoFromGallery() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      _arrayPhotos.insert(0, file);
      setState(() {
        _arrayPhotos = _arrayPhotos;
      });
    }
  }

  Future _takePhotoFromCamera() async {
    PickedFile? pickedFile = await _picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      _arrayPhotos.insert(0, file);
      setState(() {
        _arrayPhotos = _arrayPhotos;
      });
    }
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

  _refreshReceiptsPanel(bool value) {
    if (widget.vmPurchase != null) {
      widget.vmPurchase!.hasReceiptPhotos = value;
    }
    setState(() {
      _switchSpending = value;
    });
  }

  _refreshTotalAmount() {
    if (widget.vmPurchase == null) return;

    double total = 0.0;
    for (var transaction in widget.vmPurchase!.arrayTransactionDetails) {
      total = total + transaction.fAmount;
    }
    setState(() {
      _txtTotalAmount = "\$${total.toStringAsFixed(2)}";
    });
  }

  bool _validateFields() {
    if (widget.vmPurchase == null) return false;

    final merchant = edtMerchant.text;
    final desc = edtDescription.text;
    final hasReceiptPhotos = _switchSpending;

    if (merchant.isEmpty) {
      showToast("Please enter merchant name.");
      return false;
    }

    if (desc.isEmpty) {
      showToast("Please enter description.");
      return false;
    }

    if (hasReceiptPhotos) {
      if (_arrayPhotos.length <= 1) {
        showToast("Please add receipt photos.");
        return false;
      }
    }

    widget.vmPurchase!.szMerchant = merchant;
    widget.vmPurchase!.szDescription = desc;
    widget.vmPurchase!.hasReceiptPhotos = hasReceiptPhotos;
    widget.vmPurchase!.arrayReceiptPhotos.clear();
    if (_selectedBillCategory == AppStrings.selectBillCate) {
      _selectedBillCategory = "";
    }
    widget.vmPurchase!.szCategory = _selectedBillCategory;
    for (var element in _arrayPhotos) {
      if (element == null) continue;
      widget.vmPurchase!.arrayReceiptPhotos.add(element);
    }
    if (widget.vmPurchase!.arrayTransactionDetails.isEmpty) {
      showToast("Please add at least one transaction.");
      return false;
    }

    for (var transaction in widget.vmPurchase!.arrayTransactionDetails) {
      if (!transaction.isSharedAccount) {
        if (transaction.modelConsumer == null) {
          showToast("Please select consumers.");
          return false;
        }
        if (transaction.getModelAccount() == null) {
          showToast("Please select accounts.");
          return false;
        }
      }
      if (!transaction.hasValidAmount()) {
        showToast("Please enter amounts.");
        return false;
      }
    }

    return true;
  }

  _requestReloadTransactions() {
    // Reload Transactions
    final vmPurchase = widget.vmPurchase;
    checkAvailableAmount();
  }

  checkAvailableAmount() {
    final vmPurchase = widget.vmPurchase;
    if (vmPurchase == null) return;
    for (var transaction in vmPurchase.arrayTransactionDetails) {
      final account = transaction.getModelAccount();
      if (account == null) continue;
      if (account.enumType == EnumFinancialAccountType.cash) {
      } else {
        // For Food Stamp or Gift Cards, we check balance
        final amountBalance = account.fBalance;
        if (transaction.fAmount > amountBalance) {
          showToast("No sufficient amount is available for " + account.szName + ".");
          return;
        }
      }
    }

    if (vmPurchase.hasReceiptPhotos) {
      _gotoSummaryScreen();
    } else {
      // If no receipt photos added, we ask caregiver to manually input receipts
      _gotoReceiptDetailsScreen();
    }
  }

  _gotoSummaryScreen() {
    Navigator.push(
      context,
      createRoute(PurchaseSummaryScreen(
        vmPurchase: widget.vmPurchase,
        isSharedFinancialAccount: widget.vmPurchase!.isSharedAccount,
        billingCategory: _selectedBillCategory,
      )),
    );
  }

  _gotoReceiptDetailsScreen() {
    Navigator.push(
      context,
      createRoute(ReceiptDetailsScreen(
        vmPurchase: widget.vmPurchase,
        selectedBillCategory: _selectedBillCategory,
      )),
    );
  }

  _refreshListView() {
    if (widget.vmPurchase != null) {
      setState(() {
        widget.vmPurchase!.arrayTransactionDetails.add(TransactionDetailsViewModel());
      });
    }
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
        widget.vmPurchase!.date = picked;
      });
    }
    setState(() {
      _txtDate = UtilsDate.getStringFromDateTimeWithFormat(selectedDate, EnumDateTimeFormat.MMMdyyyy.value);
    });
  }

  @override
  didTransactionDetailsAccountSelected(int indexAccount, int indexRow) {
    if (widget.vmPurchase == null) return;

    final transaction = widget.vmPurchase!.arrayTransactionDetails[indexRow];
    if (transaction.modelConsumer != null && transaction.modelConsumer!.arrayAccounts != null) {
      transaction.setModelAccount(transaction.modelConsumer!.arrayAccounts![indexAccount]);
    }
  }

  @override
  didTransactionDetailsAmountChanged(double amount, int indexRow) {
    if (widget.vmPurchase == null) return;

    final transaction = widget.vmPurchase!.arrayTransactionDetails[indexRow];
    transaction.fAmount = amount;
    _refreshTotalAmount();
  }

  @override
  didTransactionDetailsConsumerSelected(int indexConsumer, int indexRow) {
    if (widget.vmPurchase == null) return;

    final consumer = ConsumerManager.sharedInstance.arrayConsumers[indexConsumer];
    final transaction = widget.vmPurchase!.arrayTransactionDetails[indexRow];

    transaction.modelConsumer = consumer;
  }

  @override
  didTransactionDetailsDeleteClick(int indexRow) {
    if (widget.vmPurchase == null) return;

    setState(() {
      widget.vmPurchase!.arrayTransactionDetails.removeAt(indexRow);
    });
    _refreshTotalAmount();
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
          AppStrings.buttonPurchase,
          style: AppStyles.textCellHeaderStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                if (!_validateFields()) return;
                _requestReloadTransactions();
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.buttonNext, style: AppStyles.buttonTextStyle),
              ),
            ),
          )
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
                  Text(AppStrings.totalTransactionAmount + _txtTotalAmount, style: AppStyles.totalTransactionText),
                  const SizedBox(height: 15),
                  const Divider(height: 0.5, color: Colors.grey),
                  //Date
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 0.5, color: Colors.grey),
                  //Merchant
                  Row(
                    children: [
                      Container(
                        height: AppDimens.kEdittextHeight,
                        alignment: Alignment.centerRight,
                        margin: AppDimens.kVerticalMarginSsmall,
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: const Text(AppStrings.labelMerchant, textAlign: TextAlign.right, style: AppStyles.textGrey),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: edtMerchant,
                          cursorColor: Colors.grey,
                          textAlign: TextAlign.left,
                          onChanged: (value) {},
                          style: AppStyles.textGrey,
                          keyboardType: TextInputType.name,
                          decoration: AppStyles.transactionInputDecoration.copyWith(hintText: AppStrings.hintEnterMerchantName),
                        ),
                      ),
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
                              child: InkWell(
                                onTap: () {
                                  _showBillCategoryPicker(context);
                                },
                                child: Text(_selectedBillCategory, style: AppStyles.headingValue),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 0.5, color: Colors.grey),
                      ],
                    ),
                  ),
                  //Description
                  Row(
                    children: [
                      Container(
                        height: AppDimens.kEdittextHeight,
                        alignment: Alignment.centerRight,
                        margin: AppDimens.kVerticalMarginSsmall,
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: const Text(AppStrings.labelDescription, textAlign: TextAlign.right, style: AppStyles.headingValue),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: edtDescription,
                          cursorColor: Colors.grey,
                          textAlign: TextAlign.left,
                          onChanged: (value) {},
                          style: AppStyles.textGrey,
                          keyboardType: TextInputType.name,
                          decoration: AppStyles.transactionInputDecoration.copyWith(hintText: AppStrings.hintEnterTransactionDescription),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 0.5, color: Colors.grey),
                  //Switch Receipt
                  Row(
                    children: [
                      Container(
                        height: AppDimens.kEdittextHeight,
                        alignment: Alignment.centerRight,
                        margin: AppDimens.kVerticalMarginSsmall,
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: const Text(AppStrings.labelReceipt, textAlign: TextAlign.right, style: AppStyles.textGrey),
                      ),
                      Switch(
                        onChanged: _refreshReceiptsPanel,
                        value: _switchSpending,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                      ),
                    ],
                  ),
                  const Divider(height: 0.5, color: Colors.grey),
                  const SizedBox(height: 15),
                  //Add Image
                  Visibility(
                    maintainAnimation: true,
                    maintainState: true,
                    visible: _switchSpending,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                        maxCrossAxisExtent: 100,
                      ),
                      itemCount: _arrayPhotos.length,
                      itemBuilder: (BuildContext ctx, index) {
                        final aa = _arrayPhotos[index];
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
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: AppDimens.kVerticalMarginHuge.copyWith(bottom: 0),
                        child: const Text(AppStrings.transactionDetails, textAlign: TextAlign.right, style: AppStyles.totalTransactionText),
                      ),
                      const SizedBox(height: 25),
                      const Divider(height: 0.5, color: Colors.grey),
                      const SizedBox(height: 15),
                      PurchaseReceiptListView(
                          arrayTransactions: widget.vmPurchase!.arrayTransactionDetails, scaffoldKey: _scaffoldKey, itemClickListener: this),
                      widget.vmPurchase!.isSharedAccount
                          ? Container()
                          : Container(
                              margin: AppDimens.kMarginNormal,
                              child: ElevatedButton(
                                style: AppStyles.defaultButtonStyle,
                                onPressed: () {
                                  _refreshListView();
                                },
                                child: const Text(
                                  AppStrings.buttonAddConsumer,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.buttonTextStyle,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
