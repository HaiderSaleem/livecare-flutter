import 'package:flutter/material.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class AuditWarningDialog extends BaseScreen {
  const AuditWarningDialog({Key? key}) : super(key: key);

  @override
  _AuditWarningDialogState createState() => _AuditWarningDialogState();
}

class _AuditWarningDialogState extends BaseScreenState<AuditWarningDialog> {
 
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
                        'assets/images/ic_warning.png',
                        height: 85,
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      const Text(
                        AppStrings.amountMismatchWarning,
                        textAlign: TextAlign.center,
                        style: AppStyles.headingText,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Ok",
                          textAlign: TextAlign.center,
                          style: AppStyles.buttonTextStyle,
                        ),
                      ),
                      color: AppColors.primaryColor,
                      height: AppDimens.kButtonHeight,
                    ),
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
