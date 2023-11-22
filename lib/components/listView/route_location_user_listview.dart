import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/route/dataModel/payload_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class RouteLocationUserListView extends BaseScreen {
  final List<PayloadDataModel> arrayPayloads;
  final RowItemClickListener<PayloadDataModel>? itemClickListener;

  const RouteLocationUserListView(
      {Key? key, required this.arrayPayloads, this.itemClickListener})
      : super(key: key);

  @override
  _RouteLocationUserListViewState createState() =>
      _RouteLocationUserListViewState();
}

class _RouteLocationUserListViewState
    extends BaseScreenState<RouteLocationUserListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.arrayPayloads.length,
      itemBuilder: (BuildContext context, int index) {
        var payload = widget.arrayPayloads[index];
        String _txtName = "";
        var _nameColor = AppColors.textGray;
        String _txtPhone = "";
        String _txtType = "";
        var _typeColor = AppColors.textGray;
        var _iconArrowColor = AppColors.textGray;
        bool _iconWarning = false;

        _txtName = payload.modelTransfer.szName;
        _txtPhone = payload.modelTransfer.getBestContactNumber();

        if (payload.modelTransfer.modelSpecialNeeds.requiresCare()) {
          _iconWarning = true;
        } else {
          _iconWarning = false;
        }

        if (payload.enumType == EnumPayloadType.pickup) {
          _txtType = "Pick Up";
          _typeColor = AppColors.purpleColor;
          _nameColor = AppColors.purpleColor;
          _iconArrowColor = AppColors.purpleColor;
        } else if (payload.enumType == EnumPayloadType.delivery) {
          _txtType = "Drop Off";
          _typeColor = AppColors.primaryColor;
          _nameColor = AppColors.primaryColor;
          _iconArrowColor = AppColors.primaryColor;
        }

        if (payload.enumStatus == EnumPayloadStatus.noShow) {
          _txtType = "No Show";
          _typeColor = AppColors.disabledBackground;
          _nameColor = AppColors.disabledBackground;
          _iconArrowColor = AppColors.disabledBackground;
        } else if (payload.enumStatus == EnumPayloadStatus.cancelled) {
          _txtType = "Cancelled";
          _typeColor = AppColors.disabledBackground;
          _nameColor = AppColors.disabledBackground;
          _iconArrowColor = AppColors.disabledBackground;
        }

        return GestureDetector(
          onTap: () {
            widget.itemClickListener?.call(payload, index);
          },
          child: Column(
            children: [
              const Divider(height: 1, thickness: 1),
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                padding: AppDimens.kMarginSmall,
                child: Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.textGray,
                          radius: 35,
                          backgroundImage:
                              ExactAssetImage("assets/images/user_default.png"),
                        ),
                        Visibility(
                          visible: _iconWarning,
                          child: Image.asset(
                            'assets/images/ic_warning_red.png',
                            width: 20,
                            height: 20,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_txtName,
                            style:
                                AppStyles.textCellTitleBoldStyle.copyWith(color: _nameColor)),
                        const SizedBox(height: 5),
                        Text(_txtPhone,
                            style: AppStyles.textCellTextStyle
                                .copyWith(color: AppColors.textGray)),
                      ],
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(_txtType,
                            style:
                                AppStyles.textCellTitleBoldStyle.copyWith(color: _typeColor)),
                        const SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios_outlined,
                            size: 16, color: _iconArrowColor),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
            ],
          ),
        );
      },
    );
  }
}
