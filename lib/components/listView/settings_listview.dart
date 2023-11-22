import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/appManager/app_manager.dart';
import 'package:livecare/models/appManager/dataModel/app_setting_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class SettingsListView extends BaseScreen {
  final List<EnumSettingMapViewPreference> arrayMapApps;
  final RowItemClickListener<EnumSettingMapViewPreference>? itemClickListener;

  const SettingsListView(
      {Key? key, required this.arrayMapApps, this.itemClickListener})
      : super(key: key);

  @override
  _SettingsListViewState createState() => _SettingsListViewState();
}

class _SettingsListViewState extends BaseScreenState<SettingsListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.arrayMapApps.length,
      itemBuilder: (BuildContext context, int index) {
        var mapPreference = widget.arrayMapApps[index];
        String _txtName = mapPreference.title;
        bool _iconTick = false;
        if (AppManager.sharedInstance.modelSettings
            .enumMapPreference ==
            mapPreference) {
          _iconTick = true;
        } else {
          _iconTick = false;
        }
        return InkWell(
          onTap: () {
            widget.itemClickListener?.call(mapPreference, index);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(_txtName,
                      style: AppStyles.textBlackStyle.copyWith(
                          color: AppColors.textBlack)),
                  _iconTick
                      ? Image.asset(
                    'assets/images/ic_tick.png',
                    width: 20,
                    height: 20,
                  )
                      : const SizedBox(
                    width: 20,
                    height: 20,
                  )
                ],
              ),
              const Divider(
                  height: 40,
                  color: AppColors.separatorLineGray),
            ],
          ),
        );
      },
    );
  }
}