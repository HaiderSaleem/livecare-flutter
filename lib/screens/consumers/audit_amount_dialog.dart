import 'package:flutter/material.dart';
import 'package:livecare/models/financialAccount/financial_account_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/consumers/audit_photo_dialog.dart';
import 'package:livecare/screens/consumers/viewModel/audit_view_model.dart';
import 'package:livecare/utils/decimal_text_input_formatter.dart';
import 'package:livecare/utils/utils_string.dart';

class AuditAmountDialog extends BaseScreen {
  final AuditViewModel? vmAudit;

  const AuditAmountDialog({Key? key, required this.vmAudit}) : super(key: key);

  @override
  _AuditAmountDialogState createState() => _AuditAmountDialogState();
}

class _AuditAmountDialogState extends BaseScreenState<AuditAmountDialog> {
  final edtAmount = TextEditingController();

  _checkAndGo() {
    if (widget.vmAudit == null) return;

    final amount = UtilsString.parseDouble(edtAmount.text, 0.0);
    if (amount < 0.0) {
      showToast("Please enter valid amount");
      return;
    }

    final preAmount = widget.vmAudit!.fAmount;
    widget.vmAudit!.fAmount = amount;

    if (widget.vmAudit!.nTries == 1 && preAmount == amount) {
      // Already tried with same amount. In this case, we assume caregiver's audit value is correct, and do override
      widget.vmAudit!.isOverride = true;
      _requestAudit();
    } else {
      widget.vmAudit!.nTries = 1;
      widget.vmAudit!.isOverride = false;
      widget.vmAudit!.imagePhoto = null;
      _gotoPhotoDialog();
    }
  }

  _requestAudit() {
    if (widget.vmAudit == null || widget.vmAudit!.modelAccount == null) {
      showToast("Something went wrong.");
      return;
    }
    showProgressHUD();
    widget.vmAudit!.toDataModel((modelAudit, message) {
      if (modelAudit != null) {
        FinancialAccountManager.sharedInstance.requestAuditForAccount(modelAudit, widget.vmAudit!.modelConsumer, widget.vmAudit!.modelAccount!,
            (responseDataModel) {
          hideProgressHUD();
          if (responseDataModel.isSuccess) {
            _closeDialog();
          } else {
            showToast(responseDataModel.beautifiedErrorMessage);
          }
        });
      } else {
        hideProgressHUD();
        showToast(message);
      }
    });
  }

  _gotoPhotoDialog() {
    _closeDialog();
    showDialog(
      context: context,
      builder: (BuildContext context) => AuditPhotoDialog(vmAudit: widget.vmAudit),
    );
  }

  _closeDialog() {
    Navigator.pop(context);
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
            decoration: const BoxDecoration(
              color: AppColors.modalBackground,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            height: AppDimens.kAuditModalHeight,
            width: AppDimens.kAuditModalWidth,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      Image.asset(
                        'assets/images/ic_confirmation.png',
                        height: 85,
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      const Text(
                        AppStrings.pleaseCountTheAmount,
                        textAlign: TextAlign.center,
                        style: AppStyles.headingText,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 40,
                        width: 150,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: edtAmount,
                          onChanged: (value) {},
                          style: const TextStyle(
                            fontStyle: FontStyle.normal,
                            fontFamily: "Lato",
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                          decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 5.0),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              filled: true,
                              hintText: "\$0.00",
                              fillColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _closeDialog();
                          },
                          child: Container(
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(AppStrings.buttonCancel, textAlign: TextAlign.center, style: AppStyles.buttonTextStyle),
                            ),
                            color: AppColors.primaryColor,
                            height: AppDimens.kButtonHeight,
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _checkAndGo();
                          },
                          child: Container(
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(AppStrings.buttonNext, textAlign: TextAlign.center, style: AppStyles.buttonTextStyle),
                            ),
                            color: AppColors.primaryColorDark,
                            height: AppDimens.kButtonHeight,
                          ),
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
    );
  }
}
