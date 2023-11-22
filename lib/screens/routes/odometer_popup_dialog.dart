import 'package:flutter/material.dart';
import 'package:livecare/listeners/route_odometer_listener.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class OdometerPopupDialog extends BaseScreen {
  final RouteDataModel? modelRoute;
  final RouteOdometerListener? popupListener;

  const OdometerPopupDialog(
      {Key? key, required this.modelRoute, required this.popupListener})
      : super(key: key);

  @override
  _OdometerPopupDialogState createState() => _OdometerPopupDialogState();
}

class _OdometerPopupDialogState extends BaseScreenState<OdometerPopupDialog> {
  final _edtOdometer = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  _initUI() {
    final route = widget.modelRoute;
    if (route == null) return;
    final fOdometerStart = route.fOdometerStart;

    if (fOdometerStart < 0.01) {
      _edtOdometer.text = "";
    } else {
      _edtOdometer.text = fOdometerStart.toStringAsFixed(2);
    }
  }

  _onButtonOkClick() {
    final double odometer = UtilsString.parseDouble(_edtOdometer.text, 0.0);
    if (odometer == 0.0) {
      UtilsBaseFunction.showAlert(context, "Error", "Invalid odometer value.");
      return;
    }
    onBackPressed();
    widget.popupListener?.didOdometerPopupOkClick(odometer);

  }

  _onButtonCancelClick() {
    onBackPressed();
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
                  height: AppDimens.kButtonHeight,
                  color: AppColors.primaryColor,
                  // padding: AppDimens.kMarginNormal,
                  child: Center(
                    child: Text("Odometer (mi)",
                        style: AppStyles.textTitleBoldStyle
                            .copyWith(color: AppColors.textWhite)),
                  ),
                ),
                Container(
                  margin: AppDimens.kMarginNormal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Please enter odometer in miles",
                          style: AppStyles.textGrey),
                      const SizedBox(height: 16),
                      Container(
                        height: AppDimens.kEdittextHeight,
                        margin:
                            AppDimens.kVerticalMarginSsmall.copyWith(top: 0),
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          style: AppStyles.inputTextStyle,
                          cursorColor: AppColors.hintColor,
                          keyboardType: TextInputType.number,
                          controller: _edtOdometer,
                          decoration: AppStyles.autoCompleteField
                              .copyWith(hintText: AppStrings.hintEnterOdometer),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextButton(
                              child: Text(
                                AppStrings.cancel,
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
                              child: const Text(AppStrings.ok,
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
