import 'package:flutter/material.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/login/login.dart';
import 'package:livecare/utils/string_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationScreen extends BaseScreen {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends BaseScreenState<RegistrationScreen> {
  //Registration fields
  final edtName = TextEditingController();
  final edtEmail = TextEditingController();
  final edtPassword = TextEditingController();
  final edtConfirmPassword = TextEditingController();

  _requestSignup() {
    final fullName = edtName.text;
    final email = edtEmail.text;
    final password = edtPassword.text;
    final confirmPassword = edtConfirmPassword.text;

    if (fullName.isEmpty) {
      showToast(AppStrings.fullName);
      return;
    }

    if (!email.isValidEmail()) {
      showToast(AppStrings.validEmailAddress);
      return;
    }

    if (password.isEmpty) {
      showToast(AppStrings.enterPassword);
      return;
    }

    if (confirmPassword != password) {
      showToast(AppStrings.confirmPassNotMatch);
      return;
    }

    if (!NetworkReachabilityManager.sharedInstance.isConnected()) {
      showToast(AppStrings.noInternetConnAvail);
      return;
    }

    showProgressHUD();
    UserManager.sharedInstance.requestUserSignUp(fullName, email, password, "", (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        _gotoLoginScreen();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _gotoLoginScreen() {
    Navigator.pushReplacement(
      context,
      createRoute(const LoginScreen()),
    );
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
                Center(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: AppDimens.kHorizontalMarginHuge,
                      height: MediaQuery.of(context).size.height - 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: AppDimens.kVerticalMarginHuge,
                            child: Text(
                              AppStrings.registerAccount,
                              textAlign: TextAlign.center,
                              style: AppStyles.textStyle.copyWith(fontSize: AppDimens.kFontTitle),
                            ),
                          ),
                          Container(
                            height: AppDimens.kEdittextHeight,
                            margin: AppDimens.kVerticalMarginSmall.copyWith(top: 0),
                            child: TextFormField(
                              style: AppStyles.inputTextStyle,
                              keyboardType: TextInputType.text,
                              controller: edtName,
                              decoration: AppStyles.textInputDecoration.copyWith(hintText: AppStrings.fullName),
                            ),
                          ),
                          Container(
                            height: AppDimens.kEdittextHeight,
                            margin: AppDimens.kVerticalMarginSmall.copyWith(top: 0),
                            child: TextFormField(
                              style: AppStyles.inputTextStyle,
                              keyboardType: TextInputType.emailAddress,
                              controller: edtEmail,
                              decoration: AppStyles.textInputDecoration.copyWith(hintText: AppStrings.emailAddress),
                            ),
                          ),
                          Container(
                            height: AppDimens.kEdittextHeight,
                            margin: AppDimens.kVerticalMarginSmall.copyWith(top: 0),
                            child: TextFormField(
                              style: AppStyles.inputTextStyle,
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              controller: edtPassword,
                              decoration: AppStyles.textInputDecoration.copyWith(hintText: AppStrings.password),
                            ),
                          ),
                          Container(
                            height: AppDimens.kEdittextHeight,
                            margin: AppDimens.kVerticalMarginSmall.copyWith(top: 0),
                            child: TextFormField(
                              style: AppStyles.inputTextStyle,
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              controller: edtConfirmPassword,
                              decoration: AppStyles.textInputDecoration.copyWith(hintText: AppStrings.confirmPassword),
                            ),
                          ),
                          ElevatedButton(
                            style: AppStyles.defaultButtonStyle,
                            onPressed: () {
                              _requestSignup();
                            },
                            child: const Text(
                              AppStrings.register,
                              textAlign: TextAlign.center,
                              style: AppStyles.buttonTextStyle,
                            ),
                          ),
                          Padding(
                            padding: AppDimens.kVerticalMarginBig.copyWith(bottom: 0),
                            child: const Text(
                              AppStrings.ifHouHaveAlreadyAccount,
                              textAlign: TextAlign.center,
                              style: AppStyles.textStyle,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              AppStrings.login,
                              textAlign: TextAlign.center,
                              style: AppStyles.buttonTextStyle,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: TextButton(
                              onPressed: () async {
                                if (await canLaunchUrl(Uri.parse("https://www.onseen.com/privacy-policy"))) {
                                  launchUrl(Uri.parse("https://www.onseen.com/privacy-policy"));
                                }
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
