import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/dataModel/task_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/serviceRequests/service_request_details_screen.dart';
import 'package:livecare/utils/utils_date.dart';

class ServiceRequestDetailsListView extends BaseScreen {
  final List<EnumServiceRequestDetailsItemType> arrayItems;
  final RequestDataModel request;
  final RowItemClickListener<EnumServiceRequestDetailsItemType>?
      itemClickListener;

  const ServiceRequestDetailsListView(
      {Key? key,
      required this.arrayItems,
      required this.request,
      this.itemClickListener})
      : super(key: key);

  @override
  _ServiceRequestDetailsListViewState createState() =>
      _ServiceRequestDetailsListViewState();
}

class _ServiceRequestDetailsListViewState
    extends BaseScreenState<ServiceRequestDetailsListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.arrayItems.length,
      itemBuilder: (BuildContext context, int index) {
        final item = widget.arrayItems[index];
        final request = widget.request;
        String _txtTitle = "";
        String _txtValue = "";
        bool _clickable = false;

        if (item == EnumServiceRequestDetailsItemType.consumerName) {
          _txtTitle = "CONSUMER:";
          _txtValue = request.refConsumer.szName;
        } else if (item == EnumServiceRequestDetailsItemType.consumerNotes) {
          _txtTitle = "NOTES:";
          _txtValue = request.refConsumer.szNotes.isEmpty
              ? "N/A"
              : request.refConsumer.szNotes;
        } else if (item ==
            EnumServiceRequestDetailsItemType.consumerDocuments) {
          _txtTitle = "DOCUMENTS:";
          _txtValue = "N/A";
          final consumer = ConsumerManager.sharedInstance
              .getConsumerById(request.refConsumer.consumerId);
          if (consumer != null) {
            if (consumer.arrayDocuments.isNotEmpty) {
              _txtValue = "${consumer.arrayDocuments.length} Attachments";
            }
          }
        } else if (item == EnumServiceRequestDetailsItemType.serviceType) {
          _txtTitle = "TYPE:";
          _txtValue = request.enumType.value;
        } else if (item == EnumServiceRequestDetailsItemType.serviceDateTime) {
          _txtTitle = "DATETIME:";
          _txtValue = UtilsDate.getStringFromDateTimeWithFormat(
              request.dateTime, EnumDateTimeFormat.MMddyyyy_hhmma.value, false);
        } else if (item == EnumServiceRequestDetailsItemType.serviceDuration) {
          _txtTitle = "DURATION:";
          _txtValue = "${request.intDuration} mins";
        } else if (item == EnumServiceRequestDetailsItemType.serviceAttendees) {
          _txtTitle = "ATTENDEES:";
          _txtValue = "N/A";
          if (request.arrayTransfers.isNotEmpty) {
            final List<String> names = [];
            names.addAll(request.arrayTransfers.map((e) => e.szName));
            _txtValue = names.join("\n");
          }
        } else if (item ==
            EnumServiceRequestDetailsItemType.serviceDescription) {
          _txtTitle = "DESCRIPTION:";
          _txtValue = request.szDescription;
        } else if (item == EnumServiceRequestDetailsItemType.serviceAddress) {
          _txtTitle = "ADDRESS:";
          _txtValue = "N/A";
          if (request.refLocation.isValid()) {
            _txtValue = request.refLocation.szAddress;
          }
        } else if (item == EnumServiceRequestDetailsItemType.serviceTasks) {
          _txtTitle = "TASKS:";
          _txtValue = "N/A";
          if (request.arrayTasks.isNotEmpty) {
            final int nCompleted = request.arrayTasks
                .where(
                    (element) => element.enumStatus == EnumTaskStatus.completed)
                .length;
            final int nAll = request.arrayTasks.length;
            _txtValue = "$nCompleted of $nAll Completed";
            _clickable = true;
          }
        } else if (item == EnumServiceRequestDetailsItemType.serviceForms) {
          _txtTitle = "FORMS:";
          _txtValue = "N/A";
          if (request.arrayForms.isNotEmpty) {
            final int nCompleted = request.arrayForms
                .where((element) => element.submissionId.isNotEmpty)
                .length;
            final int nAll = request.arrayForms.length;
            _txtValue = "$nCompleted of $nAll Submitted";
            _clickable = true;
          }
        }
        return InkWell(
          onTap: () {
            widget.itemClickListener?.call(item, index);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: index != 0,
                child: const Divider(
                  height: 1,
                ),
              ),
              Container(
                padding: AppDimens.kMarginSmall,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text(_txtTitle,
                          style: AppStyles.textCellTitleBoldStyle),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        _txtValue,
                        style: AppStyles.textCellTitleStyle.copyWith(
                            color: _clickable
                                ? AppColors.primaryColor
                                : AppColors.textGray),
                      ),
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
