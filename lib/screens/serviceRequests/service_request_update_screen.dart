import 'package:flutter/material.dart';
import 'package:livecare/components/listView/autocomplete_search_listview.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/organization/organization_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/service_request_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/serviceRequests/viewModel/service_request_view_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

import '../../utils/auto_complete_consumer_searchitem.dart';

class ServiceRequestUpdateScreen extends BaseScreen {
  final RequestDataModel? modelRequest;

  const ServiceRequestUpdateScreen({Key? key, required this.modelRequest}) : super(key: key);

  @override
  _ServiceRequestUpdateScreenState createState() => _ServiceRequestUpdateScreenState();
}

class _ServiceRequestUpdateScreenState extends BaseScreenState<ServiceRequestUpdateScreen> {
  String _txtDate = "Select the date";
  final List<AutoCompleteConsumerSearchItem> _arrayOrganizations = [];
  final List<String> _arrayAllTimes = [];
  ServiceRequestViewModel? vmRequest;
  final _edtOrganization = TextEditingController();
  var _edtTime = TextEditingController();
  final _edtHours = TextEditingController();
  final _edtMinutes = TextEditingController();
  final _edtDescription = TextEditingController();

  @override
  void initState() {
    super.initState();
    vmRequest = ServiceRequestViewModel().fromDataModel(widget.modelRequest);
    _initUI();
  }

  _initUI() {
    final vm = vmRequest;
    if (vm == null) return;

    //Organizations
    _edtOrganization.text = vm.refOrganization?.szName ?? "";
    _txtDate = UtilsDate.getStringFromDateTimeWithFormat(vm.date, EnumDateTimeFormat.MMddyyyy.value, false);

    // Time & Return Time
    // building all time-slots from "00:00 AM" to "11:30 PM"

    for (int hh in Iterable.generate(23)) {
      var hour = hh % 12;
      final ampm = hh >= 12 ? "PM" : "AM";
      if (hour == 0) hour = 12;
      final title = UtilsString.padLeadingZerosForTwoDigits(hour) + ":" + UtilsString.padLeadingZerosForTwoDigits(00) + " " + ampm;
      _arrayAllTimes.add(title);
      final title1 = UtilsString.padLeadingZerosForTwoDigits(hour) + ":" + UtilsString.padLeadingZerosForTwoDigits(30) + " " + ampm;
      _arrayAllTimes.add(title1);
    }

    //Time
    _edtTime.text = vm.szTime;

    // Duration
    _edtHours.text = "${vm.nDurationHours}";
    _edtMinutes.text = "${vm.nDurationMins}";

    //Description
    _edtDescription.text = vm.szDescription;
  }

  bool _validateFields() {
    final vm = vmRequest;
    if (vm == null) return false;

    if (vm.refOrganization == null) {
      showToast("Please select the Organization.");
      return false;
    }

    if (vm.date == null) {
      showToast("Please select the date.");
      return false;
    }

    vm.szTime = _edtTime.text;
    if (vm.szTime.isEmpty) {
      showToast("Please select the time.");
      return false;
    }

    vm.nDurationHours = UtilsString.parseInt(_edtHours.text, 0);
    vm.nDurationMins = UtilsString.parseInt(_edtMinutes.text, 0);
    vm.szDescription = _edtDescription.text;

    if (vm.nDurationHours == 0 && vm.nDurationMins == 0) {
      showToast("Please enter duration in HH:MM format.");
      return false;
    }
    if (vm.szDescription.isEmpty || vm.szDescription.length < 5) {
      showToast("Please enter description.");
      return false;
    }
    return true;
  }

  _requestUpdate() {
    final request = widget.modelRequest;
    if (request == null) return;
    final schedule = vmRequest?.toDataModel();
    if (schedule == null) return;
    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      showProgressHUD();
      final Map<String, dynamic> params = schedule.serializeForUpdateService();
      ServiceRequestManager.sharedInstance.requestUpdateRequest(request, params, EnumRequestType.service, (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess) {
          _gotoRootScreen();
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      //Call API with null callback to queue request
      final Map<String, dynamic> params = schedule.serializeForUpdateService();
      ServiceRequestManager.sharedInstance.requestUpdateRequest(request, params, EnumRequestType.service, null);
      _gotoRootScreen();
    }
  }

  _requestCancel() {
    final request = widget.modelRequest;
    if (request == null) return;
    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      showProgressHUD();
      ServiceRequestManager.sharedInstance.requestCancelRequest(request, "", EnumRequestType.service, (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess) {
          _gotoRootScreen();
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      //Call API with null callback to queue request
      ServiceRequestManager.sharedInstance.requestCancelRequest(request, "", EnumRequestType.service, null);
      _gotoRootScreen();
    }
  }

  _showCalendar(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)), // Refer step 1
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2025),
    ).then((value) {
      if (value == null) return;

      final today = DateTime.now();
      if (UtilsDate.isSameDate(today, value)) {
        showToast("You cannot book a ride for the past date.");
      } else {
        setState(() {
          vmRequest!.date = value;
          _txtDate = UtilsDate.getStringFromDateTimeWithFormat(value, EnumDateTimeFormat.MMddyyyy.value, false);
        });
      }
    });
  }

  _gotoRootScreen() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.titleUpdateRequest,
          style: AppStyles.textCellHeaderStyle,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: AppDimens.kMarginNormal,
                child: const Text("REQUEST INFORMATION", style: AppStyles.rideInformation),
              ),
              Expanded(
                child: Container(
                  margin: AppDimens.kMarginNormal.copyWith(top: 0),
                  padding: AppDimens.kMarginNormal,
                  decoration: BoxDecoration(color: AppColors.textWhite, borderRadius: BorderRadius.circular(10)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: AppDimens.kVerticalMarginNormal,
                          child: const Text(
                            "Out of office Request",
                            style: AppStyles.tripInformation,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Organization:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: AppDimens.kEdittextHeight,
                          child: Autocomplete<AutoCompleteConsumerSearchItem>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              return _arrayOrganizations.where((AutoCompleteConsumerSearchItem option) {
                                return option.szName.toLowerCase().contains(textEditingValue.text.toLowerCase());
                              });
                            },
                            displayStringForOption: (AutoCompleteConsumerSearchItem option) => option.szName,
                            fieldViewBuilder:
                                (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                              if (textEditingController.text.isEmpty) {
                                // _edtOrganization = textEditingController;
                              }
                              return TextFormField(
                                enabled: false,
                                textInputAction: TextInputAction.next,
                                style: AppStyles.inputTextStyle,
                                cursorColor: Colors.grey,
                                controller: _edtOrganization,
                                focusNode: focusNode,
                                onFieldSubmitted: (String value) {
                                  onFieldSubmitted();
                                },
                                decoration: AppStyles.autoCompleteField.copyWith(hintText: AppStrings.selectOrganization),
                              );
                            },
                            onSelected: (selection) {
                              final org = OrganizationManager.sharedInstance.arrayOrganizations[selection.index];
                              widget.modelRequest!.refOrganization = org.toRef();
                            },
                            optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<AutoCompleteConsumerSearchItem> onSelected,
                                Iterable<AutoCompleteConsumerSearchItem> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  color: Colors.white,
                                  elevation: 3.0,
                                  child: Container(
                                    constraints: const BoxConstraints(maxHeight: 200),
                                    width: MediaQuery.of(context).size.width - AppDimens.kMarginNormal.top * 4,
                                    child: AutocompleteSearchListView(
                                      options: options,
                                      onSelected: (option) {
                                        onSelected(option);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Date:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            _showCalendar(context);
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: AppDimens.kEdittextHeight,
                              padding: AppDimens.kMarginSsmall,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(5)), border: Border.all(width: 1, color: AppColors.separatorLineGray)),
                              child: Text(
                                _txtDate,
                                style: _txtDate == "Select the date" ? AppStyles.inputTextStyle.copyWith(color: AppColors.hintColor) : AppStyles.inputTextStyle,
                              )),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Time:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: AppDimens.kEdittextHeight,
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              return _arrayAllTimes.where((String option) {
                                return option.contains(textEditingValue.text.toLowerCase());
                              });
                            },
                            fieldViewBuilder:
                                (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                              _edtTime = textEditingController;
                              if (textEditingController.text.isEmpty) {
                                _edtTime.text = vmRequest?.szTime ?? "";
                              }
                              return TextFormField(
                                textInputAction: TextInputAction.next,
                                style: AppStyles.inputTextStyle,
                                cursorColor: Colors.grey,
                                controller: _edtTime,
                                focusNode: focusNode,
                                onFieldSubmitted: (String value) {
                                  onFieldSubmitted();
                                },
                                decoration: AppStyles.autoCompleteField.copyWith(hintText: "Select the Time"),
                              );
                            },
                            onSelected: (selection) {},
                            optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  color: Colors.white,
                                  elevation: 3.0,
                                  child: Container(
                                    constraints: const BoxConstraints(maxHeight: 200),
                                    width: MediaQuery.of(context).size.width - AppDimens.kMarginNormal.top * 4,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.all(8.0),
                                      itemCount: options.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final String option = options.elementAt(index);
                                        return GestureDetector(
                                          onTap: () {
                                            onSelected(option);
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding: AppDimens.kVerticalMarginSsmall,
                                                child: Text(
                                                  option,
                                                  style: AppStyles.dropDownText,
                                                ),
                                              ),
                                              const Divider(
                                                height: 0.5,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Duration:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: AppDimens.kEdittextHeight,
                              width: 100,
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                style: AppStyles.inputTextStyle,
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.grey,
                                controller: _edtHours,
                                onFieldSubmitted: (String value) {},
                                decoration: AppStyles.autoCompleteField.copyWith(hintText: "Hours"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              ":",
                              style: AppStyles.textBlackStyle,
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: AppDimens.kEdittextHeight,
                              width: 100,
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                style: AppStyles.inputTextStyle,
                                cursorColor: Colors.grey,
                                keyboardType: TextInputType.number,
                                controller: _edtMinutes,
                                onFieldSubmitted: (String value) {},
                                decoration: AppStyles.autoCompleteField.copyWith(hintText: "Mins"),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Description:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                            textInputAction: TextInputAction.next,
                            style: AppStyles.inputTextStyle,
                            maxLines: 7,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.grey,
                            controller: _edtDescription,
                            onFieldSubmitted: (String value) {},
                            decoration: AppStyles.autoCompleteField),
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
                    if (_validateFields()) _requestUpdate();
                  },
                  child: const Text(
                    "Update Request",
                    textAlign: TextAlign.center,
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
              ),
              Container(
                margin: AppDimens.kMarginNormal.copyWith(top: 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonOrange).merge(AppStyles.normalButtonStyle),
                  onPressed: () {
                    UtilsBaseFunction.showAlertWithMultipleButton(context, "Confirmation", "Are you sure you want to cancel the request?", _requestCancel);
                  },
                  child: const Text(
                    "Cancel Request",
                    textAlign: TextAlign.center,
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
