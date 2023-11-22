import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_date.dart';

class RequestListView extends BaseScreen {
  final List<RequestDataModel> arrayRequests;
  final RowItemClickListener<RequestDataModel>? itemClickListener;

  const RequestListView(
      {Key? key, required this.arrayRequests, this.itemClickListener})
      : super(key: key);

  @override
  _RequestListViewState createState() => _RequestListViewState();
}

class _RequestListViewState extends BaseScreenState<RequestListView> {
   String _txtRouteStatus = "";

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: AppDimens.kHorizontalMarginSsmall,
      itemCount: widget.arrayRequests.length,
      itemBuilder: (context, index) {
        var request = widget.arrayRequests[index];

        final DateTime? dateTime;
        if(request.enumStatus == EnumRequestStatus.scheduled){
          dateTime = request.getBestPickupTime();
        } else {
          if(request.enumTiming == EnumRequestTiming.arriveBy){
            dateTime = request.getBestDeliveryTime();
          }
          else {
            dateTime = request.getBestPickupTime();
          }
        }

        String _txtDate = UtilsDate.getStringFromDateTimeWithFormat(
            dateTime, EnumDateTimeFormat.MMdd.value, false);

      /*  txtTime.text = UtilsDate.getStringFromDateTimeWithFormat(
            dateTime,
            EnumDateTimeFormat.hhmma.value,
            null
        )
        */
        String _txtTime = UtilsDate.getStringFromDateTimeWithFormat(
            dateTime, EnumDateTimeFormat.hhmma.value, false);


         _txtRouteStatus = request.enumStatus.value.toUpperCase();
        String _txtPickupAddress = request.refPickup.szAddress;
        String _txtDropoffAddress = request.refDelivery.szAddress;
        String _txtType = request.enumType.value;

        if(_txtType == EnumRouteType.service.value){
           _txtDropoffAddress = request.refLocation.szAddress;
            _txtPickupAddress = request.refLocation.szAddress;
        }

        String _txtConsumer = request.getBeautifiedTransfersText();
        return InkWell(
          onTap: () {
            widget.itemClickListener?.call(request, index);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: AppDimens.kHorizontalMarginSmall,
                decoration: const BoxDecoration(
                    color: AppColors.textWhite,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.separatorLineGray,
                        blurRadius: 3.0,
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                padding: AppDimens.kMarginNormal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(_txtDate,
                                style: AppStyles.textCellTitleBoldStyle
                                    .copyWith(color: AppColors.primaryColor)),
                            const SizedBox(width: 20),
                            Text(
                              _txtTime,
                              style: AppStyles.textCellTitleBoldStyle
                                  .copyWith(color: AppColors.primaryColor),
                            ),
                          ],
                        ),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            child: Icon(Icons.arrow_forward_ios_outlined,
                                size: 16, color: Colors.black),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _txtType,
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: AppDimens.kFontCellText,
                        fontFamily: "Lato",
                      ),
                    ),
                    const SizedBox(height: 10),
                    //ACCEPTED
                    Container(
                      width: 120,
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: getCorrectColor(),
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(_txtRouteStatus,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: changeRouteStatusColor(),
                            fontSize: AppDimens.kFontCellText,
                            fontFamily: "Lato",
                          )),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Image.asset("assets/images/icon_car.png",
                            height: 16, width: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_txtPickupAddress,
                              style: AppStyles.textCellTextStyle
                                  .copyWith(color: AppColors.purpleColor)),
                        )
                      ],
                    ),
                    Container(
                      margin: AppDimens.kHorizontalMarginSssmall,
                      child: const Text(" :", textAlign: TextAlign.center),
                    ),
                    Row(
                      children: [
                        Image.asset("assets/images/icon_pin.png",
                            height: 16, width: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_txtDropoffAddress,
                              style: AppStyles.textCellTextStyle
                                  .copyWith(color: AppColors.primaryColor)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_txtConsumer,
                        style: AppStyles.textCellTitleBoldStyle
                            .copyWith(color: AppColors.textGrayDark)),
                  ],
                ),
              ),
              const SizedBox(height: 16)
            ],
          ),
        );
      },
    );
  }


  Color getCorrectColor() {
    if (_txtRouteStatus == EnumRequestStatus.accepted.value.toUpperCase()) {
      //GREEN COLOR
      return AppColors.status_accepted;
    } else if (_txtRouteStatus ==
        EnumRequestStatus.cancelled.value.toUpperCase()) {
      // YELLOW Color
      return AppColors.status_cancelled;
    } else if (_txtRouteStatus ==
        EnumRequestStatus.pending.value.toUpperCase()) {
      // YELLOW Color
      return AppColors.unsigned;
    }
    else if (_txtRouteStatus ==
        EnumRequestStatus.scheduled.value.toUpperCase()) {
      // YELLOW Color
      return AppColors.status_scheduled;
    }
    else {
      // SUBMITTED /BLUE
      return AppColors.status_submitted;
    }
  }

  Color changeRouteStatusColor() {
    if (_txtRouteStatus == EnumRequestStatus.accepted.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.noShow.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.requested.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.assigned.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.scheduled.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.enRoute.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.error.value.toUpperCase()) {
      return AppColors.white;
    } else {
      return AppColors.textBlack;
    }
  }

}
