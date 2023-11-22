import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livecare/components/listView/settings_listview.dart';
import 'package:livecare/models/appManager/app_manager.dart';
import 'package:livecare/models/appManager/dataModel/app_setting_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class SettingsScreen extends BaseScreen {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends BaseScreenState<SettingsScreen> {
  final String _txtVersion = "";
  final List<EnumSettingMapViewPreference> _arrayMapApps = [];
  var isBiometricEnable = false;

  @override
  void initState()  {
    super.initState();
     _refreshFields();

     getEnableBiometric();
  }

  getEnableBiometric() async {
    if (await isEnableBiometric() == true) {
      setState(() {
        isBiometricEnable = true;
      });
    }
  }


  _refreshFields() async {
    setState(() {
      for (var mapApp in EnumSettingMapViewPreference.values) {
        if (Platform.isAndroid &&
            mapApp != EnumSettingMapViewPreference.appleMaps) {
          _arrayMapApps.add(mapApp);
        }
        if (Platform.isIOS && mapApp != EnumSettingMapViewPreference.hereWeGo) {
          _arrayMapApps.add(mapApp);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      body: Container(
        padding: AppDimens.kMarginNormal,
        color: AppColors.defaultBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: AppDimens.kMarginNormal,
              child: Text(
                AppStrings.defaultNavApp,
                style: AppStyles.tripInformation
                    .copyWith(fontSize: 18, color: AppColors.textGrayDark),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsListView(
                        arrayMapApps: _arrayMapApps,
                        itemClickListener: (mapPreference, index) {
                          setState(() {
                            AppManager.sharedInstance.modelSettings
                                .enumMapPreference = mapPreference;
                            AppManager.sharedInstance.saveToLocalStorage();
                          });
                        }),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  AppStrings.enableBiometric,
                  style: AppStyles.textCellStyle
                      .copyWith(fontSize: 17, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                CupertinoSwitch(
                  value: isBiometricEnable,
                  onChanged: (value) {
                    setState(()  {
                      isBiometricEnable = value;
                       enableBiometric(value);
                    });
                  },
                  thumbColor: CupertinoColors.white,
                  activeColor: isBiometricEnable
                      ? AppColors.primaryColor
                      : AppColors.textGray,
                  trackColor: isBiometricEnable
                      ? AppColors.primaryColor
                      : AppColors.textGray,
                ),
              ],
            ),
            Expanded(
              flex: 0,
              child: Container(
                padding: AppDimens.kMarginNormal,
                child: Row(
                  children: [
                    const Text("App Info:",
                        style: AppStyles.textCellTitleStyle),
                    const SizedBox(width: 10),
                    Text(_txtVersion,
                        style: AppStyles.textCellTitleStyle.copyWith(
                            color: AppColors.textGrayDark,
                            fontWeight: FontWeight.w700))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
