import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_date.dart';

class RouteListView extends BaseScreen {
  final List<RouteDataModel> arrayRoutes;
  final RowItemClickListener<RouteDataModel>? itemClickListener;

  const RouteListView({Key? key, required this.arrayRoutes, this.itemClickListener}) : super(key: key);

  @override
  _RouteListViewState createState() => _RouteListViewState();
}

class _RouteListViewState extends BaseScreenState<RouteListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: AppDimens.kVerticalMarginNormal,
      itemCount: widget.arrayRoutes.length,
      itemBuilder: (BuildContext context, int index) {
        var route = widget.arrayRoutes[index];
        final DateTime? time = route.getBestCompletedTimeForRoute();
        final DateTime? date = route.getBestStartDateTimeForRoute();

        String _txtDate = UtilsDate.getStringFromDateTimeWithFormat(date!.toLocal(), EnumDateTimeFormat.MMdd.value, false) + " - ";
        String _txtTime =
        UtilsDate.getStringFromDateTimeWithFormat(time, EnumDateTimeFormat.hhmma.value, false);
        String _txtRouteName = route.szName;
        String _txtVehicle = route.getVehicleName();
        String _txtType = route.enumType.value.toString();
        String _txtPickupAddress = "";
        String _txtDropOffAddress = "";
        String _txtPickupTime = "";
        String _txtDropOffTime = "";
        String _txtDescription = "";
        String _tag = route.enumType.value.substring(0, 1);

        final firstActivity = route.getFirstActivity();

        if (firstActivity != null) {
          //_txtDescription =firstActivity.arrayPayloads[0].szDescription;
          _txtDescription = firstActivity.arrayPayloads[0].modelTransfer.szName;

          _txtPickupAddress = firstActivity.geoLocation.szAddress;

          if(_txtType == EnumRouteType.transport.value){
            _txtPickupTime = UtilsDate.getStringFromDateTimeWithFormat
              (route.dateEstimatedStart, EnumDateTimeFormat.hhmma.value, false);
          }
          else {
            _txtPickupTime = UtilsDate.getStringFromDateTimeWithFormat
              (route.dateEstimatedCompleted, EnumDateTimeFormat.hhmma.value, false);
          }

        } else {
          _txtPickupAddress = "N/A";
          _txtDropOffAddress = "N/A";
        }

        final lastActivity = route.arrayActivities.isEmpty ? null : route.arrayActivities.last;
        if (lastActivity != null) {
          _txtDropOffAddress = lastActivity.geoLocation.szAddress;
          _txtDropOffTime = UtilsDate.getStringFromDateTimeWithFormat(route.dateEstimatedCompleted, EnumDateTimeFormat.hhmma.value, false);
        }

        String _txtRidersCount = route.getRidersCount().toString();
        String _txtStatus = route.enumStatus.value.toString();

        return GestureDetector(
          onTap: () {
            widget.itemClickListener?.call(route, index);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: AppDimens.kHorizontalMarginSmall,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(_txtDate, style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.primaryColor)),
                                Text(_txtTime, style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.primaryColor)),
                              ],
                            ),
                          ),
                          Text(_txtType, textDirection: TextDirection.rtl, style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.primaryColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: AppDimens.kMarginSmall,
                decoration: const BoxDecoration(
                    color: AppColors.textWhite,
                    boxShadow: [
                      BoxShadow(color: AppColors.separatorLineGray, blurRadius: 3.0),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                width: MediaQuery.of(context).size.width,
                padding: AppDimens.kMarginNormal,
                child: _txtType == EnumRouteType.transport.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_txtRouteName, style: AppStyles.textStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.textGrayDark)),
                              const Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  child: Icon(Icons.arrow_forward_ios_outlined, size: 16, color: Colors.grey),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(_txtVehicle, style: AppStyles.dropDownText),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Image.asset("assets/images/icon_car.png", height: 16, width: 16),
                              Expanded(
                                child: Container(
                                  margin: AppDimens.kHorizontalMarginSmall,
                                  child: Text(
                                    _txtPickupAddress,
                                    style: AppStyles.textCellTextStyle.copyWith(
                                      color: AppColors.purpleColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            width: 16,
                            child: Text(":", textAlign: TextAlign.center),
                          ),
                          Row(
                            children: [
                              Image.asset("assets/images/icon_pin.png", height: 16, width: 16),
                              Expanded(
                                child: Container(
                                  margin: AppDimens.kHorizontalMarginSmall,
                                  child: Text(
                                    _txtDropOffAddress,
                                    style: AppStyles.textCellTextStyle.copyWith(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 30),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text("Riders:", style: AppStyles.textCellTextStyle.copyWith(fontWeight: FontWeight.w700)),
                                      const SizedBox(width: 10),
                                      Text(_txtRidersCount, style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.textGrayDark)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Pick-up:", style: AppStyles.textCellTextStyle.copyWith(fontWeight: FontWeight.w700)),
                                      const SizedBox(width: 10),
                                      Text(_txtPickupTime, style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.textGrayDark)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text("Status:", style: AppStyles.textCellTextStyle.copyWith(fontWeight: FontWeight.w700)),
                                      const SizedBox(width: 10),
                                      Text(_txtStatus, style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.textGrayDark)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Drop-Off:", style: AppStyles.textCellTextStyle.copyWith(fontWeight: FontWeight.w700)),
                                      const SizedBox(width: 10),
                                      Text(_txtDropOffTime, style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.textGrayDark)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Route Name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_txtRouteName, style: AppStyles.textStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.textGrayDark)),
                              const Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  child: Icon(Icons.arrow_forward_ios_outlined, size: 16, color: Colors.grey),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          // Route Name
                          Text(_txtVehicle, style: AppStyles.dropDownText),
                          const SizedBox(height: 5),
                          Text(_txtStatus, style: AppStyles.textCellTextStyle),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: AppColors.separatorLineGray,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(2.0),
                                        ),
                                      ),
                                      child: Text(
                                        _tag,
                                        style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.textGrayDark),
                                      ),
                                      padding: const EdgeInsets.only(top: 2, bottom: 2, right: 4, left: 4),
                                      margin: AppDimens.kVerticalMarginSssmall,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(_txtDescription, style: AppStyles.textStyle.copyWith(fontWeight: FontWeight.w700, color: AppColors.textGrayDark)),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(_txtPickupTime, style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.textGrayDark)),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
