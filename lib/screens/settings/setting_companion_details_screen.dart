import 'package:flutter/material.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/localNotifications/local_notification_observer.dart';
import 'package:livecare/models/shared/companion_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/settings/viewModel/companion_view_model.dart';
import 'package:livecare/utils/utils_base_function.dart';

class SettingCompanionDetailsScreen extends BaseScreen {
  final ConsumerDataModel? modelConsumer;
  final CompanionDataModel? modelCompanion;

  const SettingCompanionDetailsScreen({Key? key, required this.modelConsumer, required this.modelCompanion}) : super(key: key);

  @override
  _SettingCompanionDetailsScreenState createState() => _SettingCompanionDetailsScreenState();
}

class _SettingCompanionDetailsScreenState extends BaseScreenState<SettingCompanionDetailsScreen> with LocalNotificationObserver {
  final _edtCompanionName = TextEditingController();
  CompanionViewModel _vmCompanion = CompanionViewModel();
  bool _isCarSheet = false;
  bool _isWheelChair = false;
  bool _isLift = false;
  bool _isBlind = false;
  bool _isDeaf = false;
  bool _isWalker = false;
  bool _isServiceAnimal = false;

  bool _btnDelete = false;

  @override
  void initState() {
    super.initState();
    _initUI();
    _refreshSpecialNeedsPanel();
  }

  _initUI() {
    if (widget.modelCompanion == null) return;
    if (widget.modelCompanion == null) {
      _btnDelete = false;
    } else {
      _btnDelete = true;
    }
    _vmCompanion = CompanionViewModel().fromDataModel(widget.modelCompanion);
    _edtCompanionName.text = widget.modelCompanion!.szName;
  }

  _refreshSpecialNeedsPanel() {
    setState(() {
      if (_vmCompanion.modelSpecialNeeds.isCarSeat) {
        _isCarSheet = true;
      } else {
        _isCarSheet = false;
      }

      if (_vmCompanion.modelSpecialNeeds.isWheelchair) {
        _isWheelChair = true;
      } else {
        _isWheelChair = false;
      }

      if (_vmCompanion.modelSpecialNeeds.isLift) {
        _isLift = true;
      } else {
        _isLift = false;
      }

      if (_vmCompanion.modelSpecialNeeds.isBlind) {
        _isBlind = true;
      } else {
        _isBlind = false;
      }

      if (_vmCompanion.modelSpecialNeeds.isDeaf) {
        _isDeaf = true;
      } else {
        _isDeaf = false;
      }

      if (_vmCompanion.modelSpecialNeeds.isWalker) {
        _isWalker = true;
      } else {
        _isWalker = false;
      }

      if (_vmCompanion.modelSpecialNeeds.isServiceAnimal) {
        _isServiceAnimal = true;
      } else {
        _isServiceAnimal = false;
      }
    });
  }

  _promptForDeleteCompanion() {
    UtilsBaseFunction.showAlertWithMultipleButton(context, "Warning", "Are you sure you want to delete this companion?", _requestDelete);
  }

  bool _validateFields() {
    _vmCompanion.szName = _edtCompanionName.text.toString();
    if (_vmCompanion.szName.isEmpty) {
      showToast("Please enter name.");
      return false;
    }
    return true;
  }

  _requestAdd() {
    List<CompanionDataModel> originalArray = [];
    final consumer = widget.modelConsumer;
    if (consumer != null) {
      originalArray = consumer.arrayCompanions;
    } else {
      originalArray = UserManager.sharedInstance.currentUser!.arrayCompanions;
    }
    final List<CompanionDataModel> updatedArray = [];
    for (var companion in originalArray) {
      updatedArray.add(companion);
    }
    updatedArray.add(_vmCompanion.toDataModel());
    _requestSave(updatedArray);
  }

  _onUpdate() {
    if (!_validateFields()) {
      return;
    }
    if (_vmCompanion.id.isEmpty) {
      _requestAdd();
    } else {
      _requestUpdate();
    }
  }

  _requestDelete() {
    final List<CompanionDataModel> originalArray = [];
    final consumer = widget.modelConsumer;
    originalArray.addAll(consumer?.arrayCompanions ?? UserManager.sharedInstance.currentUser!.arrayCompanions);

    final List<CompanionDataModel> updatedArray = [];
    for (var companion in originalArray) {
      if (companion.id != _vmCompanion.id) {
        updatedArray.add(companion);
      }
    }
    _requestSave(updatedArray);
  }

  _requestSave(List<CompanionDataModel> companions) {
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    final consumer = widget.modelConsumer;
    if (consumer != null) {
      ConsumerManager.sharedInstance.requestUpdateCompanions(consumer, companions, (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess) {
          Navigator.pop(context);
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {}
  }

  _requestUpdate() {
    List<CompanionDataModel> originalArray = [];
    final consumer = widget.modelConsumer;
    if (consumer != null) {
      originalArray = consumer.arrayCompanions;
    } else {
      originalArray = UserManager.sharedInstance.currentUser!.arrayCompanions;
    }
    final List<CompanionDataModel> updatedArray = [];
    for (var companion in originalArray) {
      if (companion.id == _vmCompanion.id) {
        updatedArray.add(_vmCompanion.toDataModel());
      } else {
        updatedArray.add(companion);
      }
    }
    _requestSave(updatedArray);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.titleCompanionDetails,
          style: AppStyles.textCellHeaderStyle,
        ),
      ),
      backgroundColor: AppColors.defaultBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: AppDimens.kMarginNormal,
            child: Text(AppStrings.titleCompanionDetails.toUpperCase(), style: AppStyles.rideInformation),
          ),
          Expanded(
            child: Container(
              margin: AppDimens.kMarginNormal.copyWith(top: 0),
              padding: AppDimens.kMarginNormal,
              decoration: BoxDecoration(
                color: AppColors.profileFrame,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Name",
                      style: AppStyles.textBlackStyle,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        height: AppDimens.kEdittextHeight,
                        margin: AppDimens.kVerticalMarginSsmall.copyWith(top: 0),
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          style: AppStyles.inputTextStyle,
                          cursorColor: AppColors.hintColor,
                          keyboardType: TextInputType.name,
                          controller: _edtCompanionName,
                          decoration: AppStyles.autoCompleteField.copyWith(
                            hintText: "Companion Name",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Special Needs",
                      style: AppStyles.textBlackStyle,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: AppDimens.kHorizontalMarginSmall,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  _vmCompanion.modelSpecialNeeds.isWheelchair = !_vmCompanion.modelSpecialNeeds.isWheelchair;
                                  _refreshSpecialNeedsPanel();
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      _isWheelChair ? 'assets/images/rect_selected_gray.png' : 'assets/images/rect_not_selected_gray.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    Container(
                                      margin: AppDimens.kHorizontalMarginSmall,
                                      child: const Text(
                                        "WheelChair",
                                        style: AppStyles.textBlackStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: AppDimens.kMarginSmall,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  _vmCompanion.modelSpecialNeeds.isCarSeat = !_vmCompanion.modelSpecialNeeds.isCarSeat;
                                  _refreshSpecialNeedsPanel();
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      _isCarSheet ? 'assets/images/rect_selected_gray.png' : 'assets/images/rect_not_selected_gray.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    Container(
                                      margin: AppDimens.kHorizontalMarginSmall,
                                      child: const Text(
                                        "Car Seat",
                                        style: AppStyles.textBlackStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: AppDimens.kHorizontalMarginSmall,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  _vmCompanion.modelSpecialNeeds.isLift = !_vmCompanion.modelSpecialNeeds.isLift;
                                  _refreshSpecialNeedsPanel();
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      _isLift ? 'assets/images/rect_selected_gray.png' : 'assets/images/rect_not_selected_gray.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    Container(
                                      margin: AppDimens.kHorizontalMarginSmall,
                                      child: const Text(
                                        "Lift",
                                        style: AppStyles.textBlackStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: AppDimens.kMarginSmall,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  _vmCompanion.modelSpecialNeeds.isBlind = !_vmCompanion.modelSpecialNeeds.isBlind;
                                  _refreshSpecialNeedsPanel();
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      _isBlind ? 'assets/images/rect_selected_gray.png' : 'assets/images/rect_not_selected_gray.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    Container(
                                      margin: AppDimens.kHorizontalMarginSmall,
                                      child: const Text(
                                        "Blind",
                                        style: AppStyles.textBlackStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: AppDimens.kHorizontalMarginSmall,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  _vmCompanion.modelSpecialNeeds.isDeaf = !_vmCompanion.modelSpecialNeeds.isDeaf;
                                  _refreshSpecialNeedsPanel();
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      _isDeaf ? 'assets/images/rect_selected_gray.png' : 'assets/images/rect_not_selected_gray.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    Container(
                                      margin: AppDimens.kHorizontalMarginSmall,
                                      child: const Text(
                                        "Deaf",
                                        style: AppStyles.textBlackStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: AppDimens.kMarginSmall,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  _vmCompanion.modelSpecialNeeds.isWalker = !_vmCompanion.modelSpecialNeeds.isWalker;
                                  _refreshSpecialNeedsPanel();
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      _isWalker ? 'assets/images/rect_selected_gray.png' : 'assets/images/rect_not_selected_gray.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    Container(
                                      margin: AppDimens.kHorizontalMarginSmall,
                                      child: const Text(
                                        "Walker",
                                        style: AppStyles.textBlackStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: AppDimens.kHorizontalMarginSmall,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  _vmCompanion.modelSpecialNeeds.isServiceAnimal = !_vmCompanion.modelSpecialNeeds.isServiceAnimal;
                                  _refreshSpecialNeedsPanel();
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      _isServiceAnimal ? 'assets/images/rect_selected_gray.png' : 'assets/images/rect_not_selected_gray.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    Container(
                                      margin: AppDimens.kHorizontalMarginSmall,
                                      child: const Text(
                                        "Service Animal",
                                        style: AppStyles.textBlackStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: AppDimens.kHorizontalMarginNormal,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.shareLightBlue).merge(AppStyles.normalButtonStyle),
              onPressed: () {
                _onUpdate();
              },
              child: const Text(
                AppStrings.buttonSave,
                textAlign: TextAlign.center,
                style: AppStyles.buttonTextStyle,
              ),
            ),
          ),
          Visibility(
            visible: _btnDelete,
            child: Container(
              margin: AppDimens.kMarginNormal.copyWith(top: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonOrange).merge(AppStyles.normalButtonStyle),
                onPressed: () {
                  _promptForDeleteCompanion();
                },
                child: const Text(
                  AppStrings.buttonDelete,
                  textAlign: TextAlign.center,
                  style: AppStyles.buttonTextStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
