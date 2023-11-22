import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:livecare/models/appManager/app_manager.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/base/main_screen.dart';
import 'package:livecare/screens/login/forgot_password.dart';
import 'package:livecare/screens/login/registration.dart';
import 'package:livecare/utils/string_extensions.dart';
import 'package:local_auth/local_auth.dart' as localAuth;
import 'package:url_launcher/url_launcher.dart';

import '../../utils/local_storage_manager.dart';

class LoginScreen extends BaseScreen {
  final Auth0? auth0;

  const LoginScreen({this.auth0, Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseScreenState<LoginScreen> {
  //Login fields
  final _edtEmail = TextEditingController();
  final _edtPassword = TextEditingController();
  late Auth0 auth0;

  final auth = localAuth.LocalAuthentication();
  String authorized = " not authorized";
  bool _canCheckBiometric = false;
  late List<localAuth.BiometricType> _availableBiometric;

  @override
  void initState() {
    _checkBiometric();
    _getAvailableBiometric();
    super.initState();
    auth0 = widget.auth0 ?? Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);

  }

  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
          localizedReason: "Scan your finger to authenticate", options: localAuth.AuthenticationOptions(useErrorDialogs: true, stickyAuth: true));
    } on PlatformException catch (e) {
      print(e);
    }

    if (authenticated) {
      var email = await LocalStorageManager.getStringFromSF(AppStrings.email);
      var password = await LocalStorageManager.getStringFromSF(AppStrings.password);

      showProgressHUD();
      UserManager.sharedInstance.requestUserLogin(email!, password!, (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess) {
          if (UserManager.sharedInstance.currentUser != null && UserManager.sharedInstance.currentUser!.isValid()) {
            _gotoMainScreen();
          } else {
            showToast(AppStrings.userNotActive);
          }
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      setState(() {
        authorized = "Failed to authenticate";
      });
    }
  }

  Future<void> _checkBiometric() async {
    bool canCheckBiometric = false;

    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    bool? isBiometricEnabled = await isEnableBiometric();

    setState(() {
      _canCheckBiometric = canCheckBiometric;
    });

    if (isBiometricEnabled! && canCheckBiometric) {
      await _authenticate();
    }
  }

  Future _getAvailableBiometric() async {
    List<localAuth.BiometricType> availableBiometric = [];

    try {
      availableBiometric = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    setState(() {
      _availableBiometric = availableBiometric;
    });
  }

  _requestLogin() {
    final email = _edtEmail.text;
    final password = _edtPassword.text;

    if (email.isEmpty) {
      showToast(AppStrings.enterEmailAddress);
      return;
    }
    if (!email.isValidEmail()) {
      showToast(AppStrings.validEmailAddress);
      return;
    }
    if (password.isEmpty) {
      showToast(AppStrings.inputPassword);
      return;
    }

    if (!NetworkReachabilityManager.sharedInstance.isConnected()) {
      showToast(AppStrings.noInternetConnAvail);
      return;
    }

    showProgressHUD();
    UserManager.sharedInstance.requestUserLogin(email, password, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        if (UserManager.sharedInstance.currentUser != null && UserManager.sharedInstance.currentUser!.isValid()) {
          LocalStorageManager.addStringToSF(AppStrings.email, email);
          LocalStorageManager.addStringToSF(AppStrings.password, password);
          _gotoMainScreen();
        } else {
          showToast(AppStrings.userNotActive);
        }
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _ssoAuth(token) {
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) {
      showToast(AppStrings.noInternetConnAvail);
      return;
    }
    showProgressHUD();
    UserManager.sharedInstance.requestSsoAuth(token, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        if (UserManager.sharedInstance.currentUser != null && UserManager.sharedInstance.currentUser!.isValid()) {
          _gotoMainScreen();
        } else {
          showToast(AppStrings.userNotActive);
        }
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _gotoMainScreen() {
    Navigator.pushReplacement(context, createRoute(MainScreen()));
    AppManager.sharedInstance.initializeManagersAfterLogin();
  }

  _gotoRegisterScreen() {
    Navigator.push(
      context,
      createRoute(const RegistrationScreen()),
    );
  }

  Future<void> _ssoLogin() async {
    var credentials = await auth0.webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME']).login();

    setState(() {
      _ssoAuth(credentials.accessToken);
    });
  }

  _gotoForgotPasswordScreen() {
    Navigator.push(
      context,
      createRoute(const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
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
                  child: Wrap(
                    children: [
                      Container(
                        margin: AppDimens.kHorizontalMarginHuge.copyWith(top: 150),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: AppDimens.kEdittextHeight,
                                  margin: AppDimens.kVerticalMarginSmall.copyWith(top: 0),
                                  child: TextFormField(
                                    textInputAction: TextInputAction.next,
                                    style: AppStyles.inputTextStyle,
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _edtEmail,
                                    decoration: AppStyles.textInputDecoration.copyWith(hintText: AppStrings.usernameOrEmail),
                                  ),
                                ),
                                Container(
                                  height: AppDimens.kEdittextHeight,
                                  margin: AppDimens.kVerticalMarginSsmall.copyWith(top: 0),
                                  child: TextFormField(
                                    textInputAction: TextInputAction.done,
                                    style: AppStyles.inputTextStyle,
                                    obscureText: true,
                                    keyboardType: TextInputType.visiblePassword,
                                    controller: _edtPassword,
                                    decoration: AppStyles.textInputDecoration.copyWith(hintText: AppStrings.password),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: TextButton(
                                    onPressed: () {
                                      _gotoForgotPasswordScreen();
                                    },
                                    child: const Text(
                                      AppStrings.forgotPassword,
                                      style: AppStyles.buttonTextStyle,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: AppStyles.defaultButtonStyle.copyWith(),
                                  onPressed: () {
                                    _requestLogin();
                                  },
                                  child: const Text(
                                    AppStrings.login,
                                    textAlign: TextAlign.center,
                                    style: AppStyles.buttonTextStyle,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _ssoLogin();
                                  },
                                  child: const Text(
                                    AppStrings.ssoLogin,
                                    textAlign: TextAlign.center,
                                    style: AppStyles.buttonTextStyle,
                                  ),
                                ),
                                Padding(
                                  padding: AppDimens.kVerticalMarginSssmall.copyWith(bottom: 0),
                                  child: const Text(
                                    AppStrings.ifYouHaveNoAccount,
                                    textAlign: TextAlign.center,
                                    style: AppStyles.textStyle,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _gotoRegisterScreen();
                                  },
                                  child: const Text(
                                    AppStrings.registerAccount,
                                    textAlign: TextAlign.center,
                                    style: AppStyles.buttonTextStyle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () async {
                      if (await canLaunchUrl(Uri.parse("https://www.onseen.com/privacy-policy"))) {
                        await launchUrl(Uri.parse("https://www.onseen.com/privacy-policy"));
                      } else {
                        throw 'Could not launch';
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
    );
  }
}
