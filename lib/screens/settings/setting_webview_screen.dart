import 'package:flutter/material.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SettingWebViewScreen extends BaseScreen {
  final String szTitle;
  final String szUrl;
  final bool tokenRequired;

  const SettingWebViewScreen(
      {Key? key,
      required this.szTitle,
      required this.szUrl,
      required this.tokenRequired}) : super(key: key);

  @override
  _SettingWebViewScreenState createState() => _SettingWebViewScreenState();

}

class _SettingWebViewScreenState extends BaseScreenState<SettingWebViewScreen> {
  @override

  void initState() {
    super.initState();
  }

  _onButtonCancelClick() {
    onBackPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.profileBackground,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: Text(
          widget.szTitle,
          style: AppStyles.textTitleStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: AppDimens.kHorizontalMarginBig.copyWith(left: 0),
            child: GestureDetector(
              onTap: () {
                _onButtonCancelClick();
              },
              child: const Icon(Icons.clear, size: 24, color: AppColors.primaryColor),
            ),
          )
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (webViewController) {
            webViewController.loadUrl(widget.szUrl,
                headers: {"x-auth": UserManager.sharedInstance.getAuthToken()});
          },
        ),
      ),
    );
  }
}
