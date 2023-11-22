import 'package:flutter/material.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/request/create/ride_summary_screen.dart';
import 'package:livecare/screens/request/viewModel/ride_view_model.dart';
import 'package:livecare/utils/utils_date.dart';

class RideRecurringScreen extends BaseScreen {
  final RideViewModel? vmRide;

  const RideRecurringScreen({Key? key, required this.vmRide}) : super(key: key);

  @override
  _RideRecurringScreenState createState() => _RideRecurringScreenState();
}

class _RideRecurringScreenState extends BaseScreenState<RideRecurringScreen> {
  bool _isRepeat = true;

  bool _isSunday = false;
  bool _isMonday = false;
  bool _isTuesday = false;
  bool _isWednesday = false;
  bool _isThursday = false;
  bool _isFriday = false;
  bool _isSaturday = false;

  String _txtRepeatDate = "Select Date";

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  _refreshFields() {
    if (widget.vmRide == null) return;

    setState(() {
      if (widget.vmRide!.isRecurring) {
        _isRepeat = true;
      } else {
        _isRepeat = false;
      }

      if (widget.vmRide!.flagWeekdays[0]) {
        _isSunday = true;
      } else {
        _isSunday = false;
      }

      if (widget.vmRide!.flagWeekdays[1]) {
        _isMonday = true;
      } else {
        _isMonday = false;
      }

      if (widget.vmRide!.flagWeekdays[2]) {
        _isTuesday = true;
      } else {
        _isTuesday = false;
      }

      if (widget.vmRide!.flagWeekdays[3]) {
        _isWednesday = true;
      } else {
        _isWednesday = false;
      }

      if (widget.vmRide!.flagWeekdays[4]) {
        _isThursday = true;
      } else {
        _isThursday = false;
      }

      if (widget.vmRide!.flagWeekdays[5]) {
        _isFriday = true;
      } else {
        _isFriday = false;
      }

      if (widget.vmRide!.flagWeekdays[6]) {
        _isSaturday = true;
      } else {
        _isSaturday = false;
      }
    });
  }

  bool _validateFields() {
    if (widget.vmRide!.isRecurring == false) {
      return true;
    }

    var anyFlagChecked = false;
    for (var flag in widget.vmRide!.flagWeekdays) {
      anyFlagChecked = anyFlagChecked || flag;
    }
    if (!anyFlagChecked) {
      showToast("Please select the days of week to repeat.");
      return false;
    }

    if (widget.vmRide!.dateRepeatUntil == null) {
      showToast("Please select the date to repeat.");
      return false;
    }

    return true;
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
          widget.vmRide!.dateRepeatUntil = value;
          _txtRepeatDate = UtilsDate.getStringFromDateTimeWithFormat(
              value, EnumDateTimeFormat.MMddyyyy.value, false);
        });

    });
  }

  _gotoRideSummaryScreen() {
    if (!_validateFields()) return;
    Navigator.push(
      context,
      createRoute(RideSummaryScreen(
        vmRide: widget.vmRide,
      )),
    );
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
          AppStrings.labelRecurringTrip,
          style: AppStyles.textCellHeaderStyle,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                _gotoRideSummaryScreen();
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.buttonNext,
                    style: AppStyles.buttonTextStyle),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: AppDimens.kMarginNormal,
                child: const Text(AppStrings.labelRecurringTripCaps,
                    style: AppStyles.rideInformation),
              ),
              Expanded(
                child: Container(
                  margin: AppDimens.kMarginNormal.copyWith(top: 0),
                  padding: AppDimens.kMarginNormal,
                  decoration: BoxDecoration(
                      color: AppColors.textWhite,
                      borderRadius: BorderRadius.circular(10)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: AppDimens.kVerticalMarginNormal,
                          child: const Text(
                            "Is this a recurring trip?",
                            style: AppStyles.textBlackStyle,
                          ),
                        ),
                        const Divider(height: 0.5, color: AppColors.separatorLineGray),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 24),
                            InkWell(
                              onTap: () {
                                widget.vmRide!.isRecurring = true;
                                _refreshFields();
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    _isRepeat
                                        ? 'assets/images/circle_selected_gray.png'
                                        : 'assets/images/circle_not_selected_gray.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                  Container(
                                    margin: AppDimens.kHorizontalMarginSmall,
                                    child: const Text(
                                      "YES",
                                      style: AppStyles.textBlackStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 48),
                            InkWell(
                              onTap: () {
                                widget.vmRide!.isRecurring = false;
                                _refreshFields();
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    _isRepeat
                                        ? 'assets/images/circle_not_selected_gray.png'
                                        : 'assets/images/circle_selected_gray.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                  Container(
                                    margin: AppDimens.kHorizontalMarginSmall,
                                    child: const Text(
                                      "NO",
                                      style: AppStyles.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 0.5, color: AppColors.separatorLineGray),
                        const SizedBox(height: 15),
                        Visibility(
                          visible: _isRepeat,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("REPEAT ON:",
                                    style: AppStyles.textCellStyle),
                              const SizedBox(height: 10),
                              Container(
                                margin: AppDimens.kHorizontalMarginHuge,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: AppDimens.kMarginSmall,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              widget.vmRide!.flagWeekdays[0] =
                                                  !widget
                                                      .vmRide!.flagWeekdays[0];
                                              _refreshFields();
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  _isSunday
                                                      ? 'assets/images/rect_selected_gray.png'
                                                      : 'assets/images/rect_not_selected_gray.png',
                                                  width: 25,
                                                  height: 25,
                                                ),
                                                Container(
                                                  margin: AppDimens
                                                      .kHorizontalMarginSmall,
                                                  child: const Text(
                                                    "Sunday",
                                                    style: AppStyles
                                                        .textBlackStyle,
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
                                margin: AppDimens.kHorizontalMarginHuge,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: AppDimens.kHorizontalMarginSmall,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              widget.vmRide!.flagWeekdays[1] =
                                                  !widget
                                                      .vmRide!.flagWeekdays[1];
                                              _refreshFields();
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  _isMonday
                                                      ? 'assets/images/rect_selected_gray.png'
                                                      : 'assets/images/rect_not_selected_gray.png',
                                                  width: 25,
                                                  height: 25,
                                                ),
                                                Container(
                                                  margin: AppDimens
                                                      .kHorizontalMarginSmall,
                                                  child: const Text(
                                                    "Monday",
                                                    style: AppStyles
                                                        .textBlackStyle,
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
                                margin: AppDimens.kHorizontalMarginHuge,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: AppDimens.kMarginSmall,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              widget.vmRide!.flagWeekdays[2] =
                                                  !widget
                                                      .vmRide!.flagWeekdays[2];
                                              _refreshFields();
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  _isTuesday
                                                      ? 'assets/images/rect_selected_gray.png'
                                                      : 'assets/images/rect_not_selected_gray.png',
                                                  width: 25,
                                                  height: 25,
                                                ),
                                                Container(
                                                  margin: AppDimens
                                                      .kHorizontalMarginSmall,
                                                  child: const Text(
                                                    "Tuesday",
                                                    style: AppStyles
                                                        .textBlackStyle,
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
                                margin: AppDimens.kHorizontalMarginHuge,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: AppDimens.kHorizontalMarginSmall,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              widget.vmRide!.flagWeekdays[3] =
                                                  !widget
                                                      .vmRide!.flagWeekdays[3];
                                              _refreshFields();
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  _isWednesday
                                                      ? 'assets/images/rect_selected_gray.png'
                                                      : 'assets/images/rect_not_selected_gray.png',
                                                  width: 25,
                                                  height: 25,
                                                ),
                                                Container(
                                                  margin: AppDimens
                                                      .kHorizontalMarginSmall,
                                                  child: const Text(
                                                    "Wednesday",
                                                    style: AppStyles
                                                        .textBlackStyle,
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
                                margin: AppDimens.kHorizontalMarginHuge,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: AppDimens.kMarginSmall,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              widget.vmRide!.flagWeekdays[4] =
                                                  !widget
                                                      .vmRide!.flagWeekdays[4];
                                              _refreshFields();
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  _isThursday
                                                      ? 'assets/images/rect_selected_gray.png'
                                                      : 'assets/images/rect_not_selected_gray.png',
                                                  width: 25,
                                                  height: 25,
                                                ),
                                                Container(
                                                  margin: AppDimens
                                                      .kHorizontalMarginSmall,
                                                  child: const Text(
                                                    "Thursday",
                                                    style: AppStyles
                                                        .textBlackStyle,
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
                                margin: AppDimens.kHorizontalMarginHuge,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: AppDimens.kHorizontalMarginSmall,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              widget.vmRide!.flagWeekdays[5] =
                                                  !widget
                                                      .vmRide!.flagWeekdays[5];
                                              _refreshFields();
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  _isFriday
                                                      ? 'assets/images/rect_selected_gray.png'
                                                      : 'assets/images/rect_not_selected_gray.png',
                                                  width: 25,
                                                  height: 25,
                                                ),
                                                Container(
                                                  margin: AppDimens
                                                      .kHorizontalMarginSmall,
                                                  child: const Text(
                                                    "Friday",
                                                    style: AppStyles
                                                        .textBlackStyle,
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
                                margin: AppDimens.kHorizontalMarginHuge,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: AppDimens.kMarginSmall,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              widget.vmRide!.flagWeekdays[6] =
                                                  !widget
                                                      .vmRide!.flagWeekdays[6];
                                              _refreshFields();
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  _isSaturday
                                                      ? 'assets/images/rect_selected_gray.png'
                                                      : 'assets/images/rect_not_selected_gray.png',
                                                  width: 25,
                                                  height: 25,
                                                ),
                                                Container(
                                                  margin: AppDimens
                                                      .kHorizontalMarginSmall,
                                                  child: const Text(
                                                    "Saturday",
                                                    style: AppStyles
                                                        .textBlackStyle,
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
                              const SizedBox(height: 10),
                              const Divider(
                                  height: 0.5,
                                  color: AppColors.separatorLineGray),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  const Text("REPEAT UNTIL:",
                                      style: AppStyles.textCellStyle),
                                  const SizedBox(width: 24),
                                  InkWell(
                                    onTap: () {
                                      _showCalendar(context);
                                    },
                                    child: Text(_txtRepeatDate,
                                        style: _txtRepeatDate == "Select Date"
                                            ? AppStyles.hintText
                                            : AppStyles.textCellStyle),
                                  )
                                ],
                              ),
                              const SizedBox(height: 15),
                              const Divider(height: 0.5, color: AppColors.separatorLineGray),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
