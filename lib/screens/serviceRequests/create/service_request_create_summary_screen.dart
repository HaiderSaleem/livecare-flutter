import 'package:flutter/material.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/request/service_request_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/serviceRequests/viewModel/service_request_view_model.dart';
import 'package:livecare/utils/utils_date.dart';

class ServiceRequestCreateSummaryScreen extends BaseScreen {
  final ServiceRequestViewModel? vmRequest;

  const ServiceRequestCreateSummaryScreen({Key? key, required this.vmRequest})
      : super(key: key);

  @override
  _ServiceRequestCreateSummaryScreenState createState() => _ServiceRequestCreateSummaryScreenState();
}

class _ServiceRequestCreateSummaryScreenState
    extends BaseScreenState<ServiceRequestCreateSummaryScreen> {
  String _txtOrganization = "";
  String _txtDateTime = "";
  String _txtDuration = "";
  String _txtDescription = "N/A";
  String _txtRepeatUntil = "N/A";

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  _refreshFields() {
    final request = widget.vmRequest;
    if (request == null) return;

    _txtOrganization = request.refOrganization?.szName ?? "";
    _txtDateTime = UtilsDate.getStringFromDateTimeWithFormat(
        UtilsDate.mergeDateTime(request.date!, request.szTime),
        EnumDateTimeFormat.MMddyyyy_hhmma.value,
        false);
    _txtDuration =
        "${request.nDurationHours * 60 + request.nDurationMins} mins";
    _txtDescription = request.szDescription;

    if (request.isRecurring) {
      _txtRepeatUntil = UtilsDate.getStringFromDateTimeWithFormat(
          request.dateRepeatUntil, EnumDateTimeFormat.MMddyyyy.value, false);
    }
  }

  _requestCreateRequest() {
    final request = widget.vmRequest;
    if (request == null) return;
    final schedule = request.toDataModel();
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    ServiceRequestManager.sharedInstance.requestCreateSchedule(schedule,
        (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        _gotoListScreen();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _gotoListScreen() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.titleRequestSummary,
          style: AppStyles.textCellHeaderStyle,
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: AppColors.profileBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: AppDimens.kMarginNormal,
                  margin: AppDimens.kMarginNormal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("ORG",
                                style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(
                            child: Text(_txtOrganization,
                                style: AppStyles.textCellTitleStyle),
                          )
                        ],
                      ),
                      const Divider(
                          height: 25, color: AppColors.separatorLineGray),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("DATE TIME :",
                                style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(
                            child: Text(_txtDateTime,
                                style: AppStyles.textCellTitleStyle),
                          )
                        ],
                      ),
                      const Divider(
                          height: 30, color: AppColors.separatorLineGray),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("DURATION:",
                                style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(
                            child: Text(_txtDuration,
                                style: AppStyles.textCellTitleStyle),
                          )
                        ],
                      ),
                      const Divider(
                          height: 30, color: AppColors.separatorLineGray),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("DESCRIPTION :",
                                style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(
                              child: Text(_txtDescription,
                                  style: AppStyles.textCellTitleStyle))
                        ],
                      ),
                      const Divider(
                          height: 30, color: AppColors.separatorLineGray),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("RECURRING :",
                                style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(
                            child: Text(_txtRepeatUntil,
                                style: AppStyles.textCellTitleStyle),
                          )
                        ],
                      ),
                      const Divider(
                          height: 30, color: AppColors.separatorLineGray),
                    ],
                  ),
                ),
              ),
              Container(
                padding: AppDimens.kMarginNormal,
                child: ElevatedButton(
                  style: AppStyles.roundButtonStyle,
                  onPressed: () {
                    _requestCreateRequest();
                  },
                  child: const Text(
                    AppStrings.buttonSubmit,
                    textAlign: TextAlign.center,
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
