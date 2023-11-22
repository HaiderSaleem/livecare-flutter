import 'package:flutter/material.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/string_extensions.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_general.dart';

class ForgotPasswordScreen extends BaseScreen {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends BaseScreenState<ForgotPasswordScreen> {
  //Forgot password field
  final edtEmail = TextEditingController();

  _requestResetPassword() {
    final email = edtEmail.text;

    if (!email.isValidEmail()) {
      showToast(AppStrings.validEmailAddress);
      return;
    }

    if (!NetworkReachabilityManager.sharedInstance.isConnected()) {
      showToast(AppStrings.noInternetConnAvail);
      return;
    }

    showProgressHUD();
    UserManager.sharedInstance.requestForgotPassword(email, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        UtilsBaseFunction.showAlert(context, "Confirmation", "You should receive an email to reset password soon.");
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          child: Container(
            color: AppColors.primaryColor,
            child: Stack(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/background01.png',
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logo_livecare.png',
                                  width: 250,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    margin: AppDimens.kHorizontalMarginHuge.copyWith(top: 230),
                    height: MediaQuery.of(context).size.height - 240,
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: AppDimens.kVerticalMarginHuge,
                                child: Text(
                                  AppStrings.resetPassword,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.textStyle.copyWith(fontSize: AppDimens.kFontTitle),
                                ),
                              ),
                              const Text(
                                AppStrings.resetPasswordDescription,
                                textAlign: TextAlign.center,
                                style: AppStyles.textStyle,
                              ),
                              Container(
                                height: AppDimens.kEdittextHeight,
                                margin: AppDimens.kVerticalMarginBig.copyWith(bottom: 10),
                                child: TextFormField(
                                  style: AppStyles.inputTextStyle,
                                  keyboardType: TextInputType.emailAddress,
                                  controller: edtEmail,
                                  decoration: AppStyles.textInputDecoration.copyWith(hintText: AppStrings.usernameOrEmail),
                                ),
                              ),
                              ElevatedButton(
                                style: AppStyles.defaultButtonStyle,
                                onPressed: () {
                                  _requestResetPassword();
                                },
                                child: const Text(
                                  AppStrings.resetPassword,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.buttonTextStyle,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  AppStrings.goBackToLogin,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.buttonTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: TextButton(
                            onPressed: () {
                              UtilsGeneral.log("Privacy policy");
                            },
                            child: const Text(
                              AppStrings.privacy,
                              textAlign: TextAlign.center,
                              style: AppStyles.buttonTextStyle,
                            ),
                          ),
                        )
                      ],
                    ),
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
