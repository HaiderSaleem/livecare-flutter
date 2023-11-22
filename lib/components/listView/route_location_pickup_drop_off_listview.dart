import 'package:flutter/material.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class RouteLocationPickupDropOffListView extends BaseScreen {
  final List<String> dataArray;

  const RouteLocationPickupDropOffListView({Key? key, required this.dataArray}) : super(key: key);

  @override
  _RouteLocationPickupDropOffListViewState createState() => _RouteLocationPickupDropOffListViewState();
}

class _RouteLocationPickupDropOffListViewState extends BaseScreenState<RouteLocationPickupDropOffListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.dataArray.length,
      itemBuilder: (BuildContext context, int index) {
        var data = widget.dataArray[index];
        var _txtAction = "";
        var _txtPassenger = "";
        if (data.contains("DROP")) {
          _txtAction = "D";
          _txtPassenger = data.substring(5, data.length);
        } else if (data.contains("PICK")) {
          _txtAction = "P";
          _txtPassenger = data.substring(5, data.length);
        } else {
          _txtAction = "";
          _txtPassenger = data;
        }

        /*  if(dataArray[position] is PayloadDataModel) {
          var payload = dataArray[position] as PayloadDataModel
          viewHolder.txtAction.visibility = View.VISIBLE

          viewHolder.txtPassenger.text = payload.modelTransfer.szName

          if (payload.enumType == EnumPayloadType.PICKUP) {
            viewHolder.txtAction.text = "P"
          } else if (payload.enumType == EnumPayloadType.DELIVERY) {
            viewHolder.txtAction.text = "D"
          }
        } else if(dataArray[position] is String) {
          var destination = dataArray[position] as String
          viewHolder.txtAction.visibility = View.GONE
          viewHolder.txtPassenger.text = destination
        }*/

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.separatorLineGray,
                  borderRadius: BorderRadius.all(
                    Radius.circular(2.0),
                  ),
                ),
                child: Text(
                  _txtAction,
                  style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.textGrayDark),
                ),
                padding: const EdgeInsets.only(top: 2, bottom: 2, right: 4, left: 4),
                margin: AppDimens.kVerticalMarginSssmall,
              ),
              visible: _txtAction.isNotEmpty,
            ),
            const SizedBox(width: 12),
            Text(_txtPassenger, style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.textGrayDark)),
          ],
        );
      },
    );
  }
}
