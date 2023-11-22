import 'package:flutter/material.dart';
import 'package:livecare/listeners/vehicle_popup_listener.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

// ignore: must_be_immutable
class ServiceRoutesVehiclePopupDialog extends BaseScreen {
  double fOdometerStart = 0.0;
  String szLicensePlate = "";
  bool showLicensePlate = false;

  ServiceRoutesVehiclePopupListener? popupListener;

  ServiceRoutesVehiclePopupDialog({Key? key,
    required this.fOdometerStart,
    required this.szLicensePlate,
    required this.showLicensePlate,
    required this.popupListener})
      : super(key: key);

  @override
  _ServiceRoutesVehiclePopupDialogState createState() =>
      _ServiceRoutesVehiclePopupDialogState();
}

class _ServiceRoutesVehiclePopupDialogState
    extends BaseScreenState<ServiceRoutesVehiclePopupDialog> {
  final _edtOdometer = TextEditingController();
  final _edtLicensePlate = TextEditingController();
  final _edtReason = TextEditingController();
  bool consumerNoShow = false;

 
  _onButtonOkClick() {
    final double odometer = UtilsString.parseDouble(_edtOdometer.text, 0.0);
    final String license = _edtLicensePlate.text;
    String reason = _edtReason.text;
    if (odometer == 0.0) {
      UtilsBaseFunction.showAlert(context, "Error", "Invalid odometer value.");
      return;
    }
    if (UtilsString.parseDouble(_edtOdometer.text.toString(), 0.0) < widget.fOdometerStart) {
      UtilsBaseFunction.showAlert(context, "Error",
          "Odometer value may not be less than the initial odometer value.");
      return;
    }

    if (license.isEmpty && widget.showLicensePlate) {
      UtilsBaseFunction.showAlert(context, "Error", "Invalid license plate.");
      return;
    }
    onBackPressed();
    if (reason.isEmpty) {
      reason = "";
      widget.popupListener?.didServiceRoutesVehiclePopupOkClick(
          odometer, license, consumerNoShow, reason);
    }
    else {
      widget.popupListener?.didServiceRoutesVehiclePopupOkClick(
          odometer, license, consumerNoShow, reason);
    }

  }

  _onButtonCancelClick() {
    onBackPressed();
    widget.popupListener?.didServiceRoutesVehiclePopupCancelClick();
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            color: AppColors.textWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: AppColors.primaryColor,
                  height: AppDimens.kButtonHeight,
                  child: Center(
                    child: Text("Vehicle information",
                        style: AppStyles.textTitleBoldStyle
                            .copyWith(color: AppColors.textWhite)),
                  ),
                ),
                Container(
                  margin: AppDimens.kMarginNormal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.showLicensePlate
                          ?
                      "Odometer (mi)"
                          : "Odometer (mi).\nInitial: mi ${UtilsString
                          .parseDouble(widget.fOdometerStart, 0.0)}",
                          style: AppStyles.textGrey),
                      const SizedBox(height: 8),
                      Container(
                        height: AppDimens.kEdittextHeight,
                        margin:
                        AppDimens.kVerticalMarginSsmall.copyWith(top: 0),
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          style: AppStyles.inputTextStyle,
                          keyboardType: TextInputType.number,
                          controller: _edtOdometer,
                          decoration: AppStyles.autoCompleteField
                              .copyWith(hintText: AppStrings.hintEnterOdometer),
                        ),
                      ),
                      Visibility(
                        visible: widget.showLicensePlate,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text("License Plate",
                                style: AppStyles.textGrey),
                            const SizedBox(height: 8),
                            Container(
                              height: AppDimens.kEdittextHeight,
                              margin: AppDimens.kVerticalMarginSsmall
                                  .copyWith(top: 0),
                              child: TextFormField(
                                  textInputAction: TextInputAction.done,
                                  style: AppStyles.inputTextStyle,
                                  keyboardType: TextInputType.text,
                                  controller: _edtLicensePlate,
                                  decoration: AppStyles.autoCompleteField
                                      .copyWith(
                                      hintText: AppStrings.hintEnterLicensePlate
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: !widget.showLicensePlate,
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text("Consumer did not show",
                                  style: AppStyles.textGrey),
                            ),
                            Switch(
                              // This bool value toggles the switch.
                              value: consumerNoShow,
                              activeColor: AppColors.primaryColor,
                              onChanged: (bool value) {
                                // This is called when the user toggles the switch.
                                setState(() {
                                  consumerNoShow = value;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        visible: consumerNoShow,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Reason",
                                style: AppStyles.textGrey),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: AppDimens.kEdittextHeight,
                              child: TextFormField(
                                  controller: _edtReason,
                                  cursorColor: Colors.grey,
                                  textAlign: TextAlign.left,
                                  style: AppStyles.headingValue,
                                  keyboardType: TextInputType.text,
                                  decoration: AppStyles.autoCompleteField
                                      .copyWith(
                                      hintText: AppStrings.hintEnterReason
                                  )
                              ),
                            ),

                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextButton(
                              child: Text(
                                AppStrings.buttonCancel,
                                style: AppStyles.buttonTextStyle
                                    .copyWith(color: AppColors.textGray),
                              ),
                              onPressed: () {
                                _onButtonCancelClick();
                              },
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor)
                                  .merge(AppStyles.normalButtonStyle),
                              child: const Text(AppStrings.buttonKk,
                                  style: AppStyles.buttonTextStyle),
                              onPressed: () {
                                _onButtonOkClick();
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
