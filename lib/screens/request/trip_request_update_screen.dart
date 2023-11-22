import 'package:flutter/material.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_observer.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/transport_request_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class TripRequestUpdateScreen extends BaseScreen {
  final RequestDataModel? modelRequest;

  const TripRequestUpdateScreen({Key? key, required this.modelRequest}) : super(key: key);

  @override
  _TripRequestUpdateScreenState createState() => _TripRequestUpdateScreenState();
}

class _TripRequestUpdateScreenState extends BaseScreenState<TripRequestUpdateScreen> with LocalNotificationObserver {
  String _txtDate = "Select the date";
  bool _readyBy = true;

  var _edtTime = TextEditingController();

  final List<String> _arrayAllTimes = [];
  EnumRequestTiming _enumTiming = EnumRequestTiming.arriveBy;
  DateTime? _dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  _initUI() {
    final request = widget.modelRequest;
    if (request == null) return;

    // Time & Return Time
    // building all time-slots from "00:00 AM" to "11:30 PM"
    _enumTiming = request.enumTiming;
    _dateTime = request.dateTime;

    for (int hh in Iterable.generate(23)) {
      var hour = hh % 12;
      final ampm = hh >= 12 ? "PM" : "AM";
      if (hour == 0) hour = 12;
      final title = UtilsString.padLeadingZerosForTwoDigits(hour) + ":" + UtilsString.padLeadingZerosForTwoDigits(00) + " " + ampm;
      _arrayAllTimes.add(title);
      final title1 = UtilsString.padLeadingZerosForTwoDigits(hour) + ":" + UtilsString.padLeadingZerosForTwoDigits(30) + " " + ampm;
      _arrayAllTimes.add(title1);
    }

    _txtDate = UtilsDate.getStringFromDateTimeWithFormat(_dateTime, EnumDateTimeFormat.MMddyyyy.value, false);
    _edtTime.text = UtilsDate.getStringFromDateTimeWithFormat(_dateTime, EnumDateTimeFormat.hhmma.value, false);

    _refreshTimingPanel();
  }

  _refreshTimingPanel() {
    if (_enumTiming == EnumRequestTiming.readyBy) {
      setState(() {
        _readyBy = true;
      });
    } else if (_enumTiming == EnumRequestTiming.arriveBy) {
      setState(() {
        _readyBy = false;
      });
    }
  }

  bool _validateFields() {
    if (_dateTime == null) {
      showToast("Please select the date");
      return false;
    }

    final String szTime = _edtTime.text;
    if (szTime.isEmpty) {
      showToast("Please select the time.");
      return false;
    }

    // Merge date + time
    var sz = UtilsDate.getStringFromDateTimeWithFormat(_dateTime, EnumDateTimeFormat.MMddyyyy.value, false);
    sz = sz + " " + szTime;
    _dateTime = UtilsDate.getDateTimeFromStringWithFormatToApi(sz, EnumDateTimeFormat.MMddyyyy_hhmma.value, false);

    return true;
  }

  _requestUpdate() {
    final request = widget.modelRequest;
    if (request == null) return;
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    final Map<String, dynamic> params = {};
    params["time"] = UtilsDate.getStringFromDateTimeWithFormat(_dateTime, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);

    TransportRequestManager.sharedInstance.requestUpdateRequest(request, params, EnumRequestType.transport, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        _gotoRootScreen();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _requestCancel() {
    final request = widget.modelRequest;
    if (request == null) return;
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    TransportRequestManager.sharedInstance.requestCancelRequest(request, "", EnumRequestType.transport, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        _gotoRootScreen();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _showCalendar(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Refer step 1
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    ).then((value) {
      if (value == null) return;
      setState(() {
        _dateTime = value;
        _txtDate = UtilsDate.getStringFromDateTimeWithFormat(_dateTime, EnumDateTimeFormat.MMddyyyy.value, false);
      });
    });
  }

  _gotoRootScreen() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Update Request",
          style: AppStyles.textCellHeaderStyle,
        ),
      ),
      backgroundColor: AppColors.defaultBackground,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          bottom: true,
          child: SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: AppDimens.kMarginNormal,
                    child: const Text(AppStrings.labelRideInformation, style: AppStyles.rideInformation),
                  ),
                  Container(
                    margin: AppDimens.kMarginNormal.copyWith(top: 0),
                    padding: AppDimens.kMarginNormal,
                    decoration: BoxDecoration(color: AppColors.textWhite, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Trip information",
                          style: AppStyles.tripInformation,
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
                              padding: AppDimens.kMarginSsmall,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(5)), border: Border.all(width: 1, color: AppColors.separatorLineGray)),
                              child: Text(
                                _txtDate,
                                style: _txtDate == "Select the date" ? AppStyles.hintText : AppStyles.textBlackStyle,
                              )),
                        ),
                        const SizedBox(height: 20),
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
                                return TextFormField(
                                  enabled: true,
                                  textInputAction: TextInputAction.next,
                                  style: AppStyles.inputTextStyle,
                                  cursorColor: Colors.grey,
                                  controller: _edtTime,
                                  focusNode: focusNode,
                                  onFieldSubmitted: (String value) {
                                    onFieldSubmitted();
                                  },
                                  decoration: AppStyles.autoCompleteField.copyWith(hintText: "Select the time"),
                                );
                              },
                              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    color: Colors.white,
                                    elevation: 3.0,
                                    child: Container(
                                      constraints: const BoxConstraints(maxHeight: 130),
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
                            )),
                        const SizedBox(height: 20),
                        const Text(
                          "Timing:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 15),
                        Container(
                          margin: AppDimens.kHorizontalMarginNormal,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  _enumTiming = EnumRequestTiming.readyBy;
                                  _refreshTimingPanel();
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      _readyBy ? 'assets/images/circle_selected_gray.png' : 'assets/images/circle_not_selected_gray.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    Container(
                                      margin: AppDimens.kHorizontalMarginSmall,
                                      child: const Text(
                                        "Ready By",
                                        style: AppStyles.textBlackStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  _enumTiming = EnumRequestTiming.arriveBy;
                                  _refreshTimingPanel();
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      _readyBy ? 'assets/images/circle_not_selected_gray.png' : 'assets/images/circle_selected_gray.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    Container(
                                      margin: AppDimens.kHorizontalMarginSmall,
                                      child: const Text(
                                        "Arrive By",
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
                  ),
                  Container(
                    margin: AppDimens.kMarginNormal,
                    padding: AppDimens.kMarginNormal,
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.shareLightBlue).merge(AppStyles.normalButtonStyle),
                          onPressed: () {
                            if (_validateFields() == true) _requestUpdate();
                          },
                          child: const Text(
                            "Update",
                            textAlign: TextAlign.center,
                            style: AppStyles.buttonTextStyle,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonOrange).merge(AppStyles.normalButtonStyle),
                          onPressed: () {
                            UtilsBaseFunction.showAlertWithMultipleButton(
                                context, "Confirmation", "Are you sure you want to cancel the request?", _requestCancel);
                          },
                          child: const Text(
                            AppStrings.buttonCancel,
                            textAlign: TextAlign.center,
                            style: AppStyles.buttonTextStyle,
                          ),
                        ),
                      ],
                    ),
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
