import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/route/dataModel/payload_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/routes/route_confirm_rider_list_screen.dart';

class RouteConfirmRiderListView extends BaseScreen {
  final List<PayloadDataModel> arrayPayloads;
  final List<ConfirmRiderStatus> arrayStatus;
  final RowItemClickListener<PayloadDataModel>? itemClickListener;

  const RouteConfirmRiderListView(
      {Key? key,
      required this.arrayPayloads,
      required this.arrayStatus,
      this.itemClickListener})
      : super(key: key);

  @override
  _RouteConfirmRiderListViewState createState() =>
      _RouteConfirmRiderListViewState();
}

class _RouteConfirmRiderListViewState
    extends BaseScreenState<RouteConfirmRiderListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: AppDimens.kVerticalMarginNormal.copyWith(top: 0),
      itemCount: widget.arrayPayloads.length,
      itemBuilder: (BuildContext context, int index) {
        final payload = widget.arrayPayloads[index];
        final status = widget.arrayStatus[index].enumStatus;
        String _txtName = "";
        var _nameColor = AppColors.textGray;
        String _txtPhone = "";
        var _phoneColor = AppColors.textGray;
        String _txtSpecialNeeds = "";
        var _specialNeedsColor = AppColors.textGray;
        String _txtNotes = "";
        var _notesColor = AppColors.textGray;
        bool _iconSpecialNeeds = false;
        String _iconCall = 'assets/images/ic_call_circle_gray.png';
        String _txtType = "";
        var _typeColor = AppColors.textGray;
        bool _switchStatus = false;

        _txtName = payload.modelTransfer.szName;
        _txtPhone = payload.modelTransfer.getBestContactNumber();
        if (payload.modelTransfer.modelSpecialNeeds.requiresCare()) {
          _txtSpecialNeeds = payload.modelTransfer.modelSpecialNeeds
              .getNeedsArray()
              .join(", ");
          _iconSpecialNeeds = true;
        } else {
          _txtSpecialNeeds = "N/A";
          _iconSpecialNeeds = false;
        }

        _txtNotes = payload.modelTransfer.szNotes;
        if (status == EnumPayloadStatus.noShow ||
            status == EnumPayloadStatus.cancelled) {
          _iconCall = 'assets/images/ic_call_circle_gray.png';
          _nameColor = AppColors.disabledBackground;
          _phoneColor = AppColors.disabledBackground;
          _specialNeedsColor = AppColors.disabledBackground;
          _notesColor = AppColors.disabledBackground;
          _typeColor = AppColors.disabledBackground;

          _switchStatus = false;
          if (payload.enumType == EnumPayloadType.pickup) {
            _txtType = "No Show";
          } else if (payload.enumType == EnumPayloadType.delivery) {
            _txtType = "Not Dropped Off";
          }
        } else {
          _iconCall = 'assets/images/ic_call_circle_blue.png';
          _phoneColor = AppColors.textGrayDark;
          _specialNeedsColor = AppColors.buttonRed;
          _notesColor = AppColors.textGrayDark;

          _switchStatus = true;
          if (payload.enumType == EnumPayloadType.pickup) {
            _nameColor = AppColors.purpleColor;
            _typeColor = AppColors.purpleColor;

            _txtType = "Picked Up";
          } else if (payload.enumType == EnumPayloadType.delivery) {
            _nameColor = AppColors.primaryColor;
            _typeColor = AppColors.primaryColor;

            _txtType = "Dropped Off";
          }
        }

        return Container(
          margin: AppDimens.kMarginNormal.copyWith(bottom: 0),
          decoration: const BoxDecoration(
              color: AppColors.textWhite,
              boxShadow: [
                BoxShadow(
                  color: AppColors.separatorLineGray,
                  blurRadius: 3.0,
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          width: MediaQuery.of(context).size.width,
          padding: AppDimens.kMarginNormal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.textGray,
                            radius: 35,
                            backgroundImage: ExactAssetImage(
                                "assets/images/user_default.png"),
                          ),
                          Visibility(
                            visible: _iconSpecialNeeds,
                            child: Image.asset(
                              'assets/images/ic_warning_red.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Image.asset(
                              _iconCall,
                              width: 20,
                              height: 20,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_txtName,
                          style:
                              AppStyles.textCellTitleBoldStyle.copyWith(color: _nameColor)),
                      const SizedBox(height: 4),
                      Text(_txtPhone,
                          style: AppStyles.textCellTextStyle
                              .copyWith(color: _phoneColor)),
                      const SizedBox(height: 4),
                      Text(
                        _txtSpecialNeeds,
                        style: AppStyles.textCellTitleStyle
                            .copyWith(color: _specialNeedsColor),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Align(
                      child: Switch(
                        onChanged: (val) {
                          widget.itemClickListener?.call(payload, index);
                        },
                        value: _switchStatus,
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.purpleColor,
                        inactiveThumbColor: AppColors.textWhite,
                        inactiveTrackColor: AppColors.textGray,
                      ),
                      alignment: Alignment.topRight,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),
              Text(_txtNotes,
                  style: AppStyles.textCellTextStyle.copyWith(color: _notesColor)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(_txtType,
                    style: AppStyles.textCellTextBoldStyle.copyWith(color: _typeColor)),
              )
            ],
          ),
        );
      },
    );
  }
}
