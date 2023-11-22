import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';

import '../../utils/local_storage_manager.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  BaseScreenState createState() => BaseScreenState();
}

class BaseScreenState<T extends BaseScreen> extends State<T> {
  bool _pressedBackButton = false;

  AppBar appBar(String title) => AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/images/ic_menu.png'),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: AppStyles.textCellHeaderStyle,
        ),
      );

  enableBiometric(bool value)  async {
    await LocalStorageManager.addBoolToSF(AppStrings.isBiometric, value);
  }

  Future<bool?> isEnableBiometric()  async{
    return await LocalStorageManager.getBoolFromSF(AppStrings.isBiometric);
  }

  double get appBarHeight => appBar("title").preferredSize.height;

  showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0);
  }


  void showProgressHUD() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(
            child: SizedBox(
              child: CircularProgressIndicator(),
              height: 40.0,
              width: 40.0,
            ),
          ),
        );
      },
    );
  }

  Route createRoute(Widget routeScreen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => routeScreen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route createDialogRoute(Widget routeScreen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => routeScreen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  void hideProgressHUD() {
    Navigator.of(context).pop();
  }

  Future<bool> onBackPressed() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return true;
    }
    if (_pressedBackButton) {
      return true;
    } else {
      setState(() {
        _pressedBackButton = true;
      });
      showToast(AppStrings.pressBackButton);
      Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _pressedBackButton = false;
        });
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector();
  }
}
