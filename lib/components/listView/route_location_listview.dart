import 'package:flutter/material.dart';
import 'package:livecare/components/listView/route_location_pickup_drop_off_listview.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/route/dataModel/activity_data_model.dart';
import 'package:livecare/models/route/dataModel/payload_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_date.dart';

class RouteLocationListView extends BaseScreen {
  final List<ActivityDataModel> arrayLocations;
  final RowItemClickListener<ActivityDataModel>? itemClickListener;

  const RouteLocationListView(
      {Key? key, required this.arrayLocations, this.itemClickListener})
      : super(key: key);

  @override
  _RouteLocationListViewState createState() => _RouteLocationListViewState();
}

class _RouteLocationListViewState
    extends BaseScreenState<RouteLocationListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.arrayLocations.length - 1,
      padding: const EdgeInsets.only(top: 12,bottom: 70),
      itemBuilder: (BuildContext context, int index) {
        var activity = widget.arrayLocations[index + 1];
        String _txtTime = "";
        String _txtWaitTime = "";
        var _addressColor = AppColors.textGrayDark;

        if (activity.dateActualArrival != null) {
          final actualArrival = activity.dateActualArrival;
          _txtTime = UtilsDate.getStringFromDateTimeWithFormat(
              actualArrival, EnumDateTimeFormat.hhmma.value, false);
          _txtWaitTime = "";
        } else if (activity.dateEstimatedArrival != null) {
          final estimatedArrival = activity.dateEstimatedArrival;
          _txtTime = UtilsDate.getStringFromDateTimeWithFormat(
              estimatedArrival, EnumDateTimeFormat.hhmma.value, false);
          if (activity.nWaitTime > 600) {
            final int mins = activity.nWaitTime ~/ 60;
            _txtWaitTime = "WAIT: $mins MINS";
          } else {
            _txtWaitTime = "";
          }
        } else {
          _txtTime = "N/A";
          _txtWaitTime = "";
        }

        String _txtAddress = activity.geoLocation.szAddress;
        String _txtStatus = activity.enumStatus.value;
        String txtDepartTime = "";

        if (activity.dateEstimatedDeparture != null) {
          var estimatedDeparture = activity.dateEstimatedDeparture;
          txtDepartTime = "Depart: "+UtilsDate.getStringFromDateTimeWithFormat(
              estimatedDeparture, EnumDateTimeFormat.hhmma.value, false);
        }

        final List<String> _dataArray = [];
        if (activity.isStartingDepot) {
          _dataArray.add("Starting Location");
          _addressColor = AppColors.purpleColor;
        } else if (activity.isEndingDepot) {
          _dataArray.add("Ending Depot");
          _addressColor = AppColors.primaryColor;
        } else {
          for (var model in activity.arrayPayloads) {
            if (model.enumType == EnumPayloadType.pickup) {
              _dataArray.add("PICK ${model.modelTransfer.szName}");
            } else if (model.enumType == EnumPayloadType.delivery) {
              _dataArray.add("DROP ${model.modelTransfer.szName}");
            }
          }
          if (activity.getPickupCount() > 0) {
            _addressColor = AppColors.purpleColor;
          } else {
            _addressColor = AppColors.primaryColor;
          }
        }

        return GestureDetector(
          onTap: () {
            widget.itemClickListener?.call(activity, index);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: AppDimens.kMarginSmall,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(_txtTime, style: AppStyles.textTitleBoldStyle),
                            const SizedBox(width: 10),
                            Text(_txtWaitTime,
                                style: AppStyles.textCellTextStyle
                                    .copyWith(color: AppColors.textGray)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(_txtStatus,
                                style: AppStyles.textCellTitleStyle
                                    .copyWith(color: AppColors.textGrayDark)),
                            const SizedBox(width: 5),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                child: Icon(Icons.arrow_forward_ios_outlined,
                                    size: 16, color: AppColors.textGray),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Text(txtDepartTime,
                        style: AppStyles.textCellDescriptionStyle),
                    const SizedBox(height: 8),
                    RouteLocationPickupDropOffListView(dataArray: _dataArray),
                    const SizedBox(height: 8),
                    Text(_txtAddress,
                        style: AppStyles.textCellTitleBoldStyle
                            .copyWith(color: _addressColor)),
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
