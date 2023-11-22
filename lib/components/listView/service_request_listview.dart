import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_date.dart';

class ServiceRequestListView extends BaseScreen {
  final List<RequestDataModel> arrayRequests;
  final RowItemClickListener<RequestDataModel>? itemClickListener;

  const ServiceRequestListView(
      {Key? key, required this.arrayRequests, this.itemClickListener})
      : super(key: key);

  @override
  _ServiceRequestListViewState createState() => _ServiceRequestListViewState();
}

class _ServiceRequestListViewState
    extends BaseScreenState<ServiceRequestListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.arrayRequests.length,
      padding: AppDimens.kVerticalMarginNormal.copyWith(top: 0),
      itemBuilder: (context, index) {
        var request = widget.arrayRequests[index];

        String _txtAddress = "";
        String _txtConsumer = "";
        bool _viewAddress = true;

        String _txtDate = UtilsDate.getStringFromDateTimeWithFormat(
            request.dateTime, EnumDateTimeFormat.MMdd.value, false);
        String _txtTime = UtilsDate.getStringFromDateTimeWithFormat(
            request.dateTime, EnumDateTimeFormat.hhmma.value, false);
        String _txtStatus = request.enumStatus.value.toUpperCase();

        if (request.enumType == EnumRequestType.serviceOther) {
          _viewAddress = true;
          _txtAddress = request.refLocation.szAddress;
        } else {
          _viewAddress = false;
          _txtAddress = "";
        }
        if (request.enumType == EnumRequestType.outOfOffice) {
          _txtConsumer = "OUT OF OFFICE";
        } else {
          if (request.arrayTransfers.isNotEmpty) {
            _txtConsumer =
                "${request.refConsumer.szName} + ${request.arrayTransfers.length} attendees";
          } else {
            _txtConsumer = request.refConsumer.szName;
          }
        }

        return InkWell(
          onTap: () {
            widget.itemClickListener?.call(request, index);
          },
          child: Container(
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
                        const SizedBox(width: 10),
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
                            size: 16, color: Colors.grey),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(_txtStatus, style: AppStyles.textCellTextStyle),
                Visibility(
                  visible: _viewAddress,
                  child: const SizedBox(height: 12),
                ),
                Visibility(
                  visible: _viewAddress,
                  child: Row(
                    children: [
                      Image.asset("assets/images/icon_pin.png",
                          height: 16, width: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_txtAddress,
                            style: AppStyles.textCellTextStyle
                                .copyWith(color: AppColors.primaryColor)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(_txtConsumer,
                    style: AppStyles.textCellTitleBoldStyle
                        .copyWith(color: AppColors.textGrayDark)),
              ],
            ),
          ),
        );
      },
    );
  }
}
