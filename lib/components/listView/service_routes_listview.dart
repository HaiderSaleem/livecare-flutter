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

class ServiceRoutesListView extends BaseScreen {
  final List<ActivityDataModel> arrayActivities;
  final RowItemClickListener<ActivityDataModel>? itemClickListener;

  const ServiceRoutesListView({Key? key, required this.arrayActivities, this.itemClickListener}) : super(key: key);

  @override
  _ServiceRoutesListViewState createState() => _ServiceRoutesListViewState();
}

class _ServiceRoutesListViewState extends BaseScreenState<ServiceRoutesListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.arrayActivities.length,
      padding: AppDimens.kVerticalMarginSmall,
      itemBuilder: (BuildContext context, int index) {
        var activity = widget.arrayActivities[index];

        String _txtTime = "";
        String _txtWaitTime = "";
        var _addressColor = AppColors.textGrayDark;

        String _txtStatus = "";
        // String _txtConsumer = "";
        // String _txtVehicle = "";
        // String _txtDescription = "";
        String _txtAddress = activity.geoLocation.szAddress;

        _txtStatus = activity.enumStatus.value.toUpperCase();

        String txtDepartTime = "";

        if (activity.dateEstimatedDeparture != null) {
          var estimatedDeparture = activity.dateEstimatedDeparture;
          txtDepartTime = "Appointment: " + UtilsDate.getStringFromDateTimeWithFormat(estimatedDeparture, EnumDateTimeFormat.hhmma.value, false);
        }

        if (activity.dateActualArrival != null) {
          final actualArrival = activity.dateActualArrival;
          _txtTime = UtilsDate.getStringFromDateTimeWithFormat(actualArrival, EnumDateTimeFormat.hhmma.value, false);
          _txtWaitTime = "";
        } else if (activity.dateEstimatedArrival != null) {
          final estimatedArrival = activity.dateEstimatedArrival;
          _txtTime = UtilsDate.getStringFromDateTimeWithFormat(estimatedArrival, EnumDateTimeFormat.hhmma.value, false);
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

        final DateTime? dateTime = activity.getBestArrivalDateTime();
        _txtTime = UtilsDate.getStringFromDateTimeWithFormat(dateTime, EnumDateTimeFormat.hhmma.value, false);
        if (activity.arrayPayloads.isNotEmpty) {
          final payload = activity.arrayPayloads.first;
          // _txtConsumer = payload.modelTransfer.szName;
          _txtStatus = payload.enumStatus.value.toUpperCase();
          // if (payload.szDescription.isEmpty) {
          //   _txtDescription = "N/A";
          // } else {
          //   _txtDescription = payload.szDescription;
          // }
        } else {
          _txtStatus = "N/A";
          // _txtConsumer = "N/A";
          // _txtDescription = "N/A";
        }
        _txtAddress = activity.geoLocation.szAddress;

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
            } else {
              var name = model.modelTransfer.szName;
              if (name.trim().isEmpty) name = model.szDescription;
              _dataArray.add(name);
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
                            Text(_txtWaitTime, style: AppStyles.textCellTextStyle.copyWith(color: AppColors.textGray)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(_txtStatus, style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.textGrayDark)),
                            const SizedBox(width: 5),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                child: Icon(Icons.arrow_forward_ios_outlined, size: 16, color: AppColors.textGray),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Text(txtDepartTime, style: AppStyles.textCellDescriptionStyle),
                    const SizedBox(height: 12),
                    RouteLocationPickupDropOffListView(dataArray: _dataArray),
                    const SizedBox(height: 12),
                    Text(_txtAddress, style: AppStyles.textCellTitleBoldStyle.copyWith(color: _addressColor)),
                  ],
                ),
              ),
            ],
          ),
        );

        /*
        return GestureDetector(
          onTap: () {
            widget.itemClickListener?.call(activity, index);
          },
          child: Container(
            margin: AppDimens.kMarginSmall.copyWith(top: 0, bottom: 20),
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
                    Text(_txtTime,
                        style: AppStyles.textCellTitleBoldStyle
                            .copyWith(color: AppColors.primaryColor)),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        child: Icon(Icons.arrow_forward_ios_outlined,
                            size: 16, color: Colors.grey),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                Text(_txtStatus, style: AppStyles.textCellTextStyle),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Image.asset("assets/images/ic_person.png",
                        height: 16, width: 16),
                    Expanded(
                      child: Container(
                        margin: AppDimens.kHorizontalMarginSmall,
                        child: Text(
                          _txtConsumer,
                          style: AppStyles.textCellTextStyle.copyWith(
                            color: AppColors.textGrayDark,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Image.asset("assets/images/icon_car.png",
                        height: 16, width: 16),
                    Expanded(
                      child: Container(
                        margin: AppDimens.kHorizontalMarginSmall,
                        child: Text(
                          _txtVehicle,
                          style: AppStyles.textCellTextStyle.copyWith(
                            color: AppColors.textGrayDark,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Image.asset("assets/images/icon_pin.png",
                        height: 16, width: 16),
                    Expanded(
                      child: Container(
                        margin: AppDimens.kHorizontalMarginSmall,
                        child: Text(
                          _txtAddress,
                          style: AppStyles.textCellTextStyle.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Image.asset("assets/images/ic_notes.png",
                        height: 16, width: 16),
                    Expanded(
                      child: Container(
                        margin: AppDimens.kHorizontalMarginSmall,
                        child: Text(
                          _txtDescription,
                          style: AppStyles.textCellTextStyle.copyWith(
                            color: AppColors.textGrayDark,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
*/
      },
    );
  }
}
