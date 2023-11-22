import 'package:flutter/material.dart';
import 'package:livecare/components/listView/route_confirm_rider_listview.dart';
import 'package:livecare/listeners/route_confirm_rider_listener.dart';
import 'package:livecare/models/localNotifications/local_notification_observer.dart';
import 'package:livecare/models/route/dataModel/activity_data_model.dart';
import 'package:livecare/models/route/dataModel/payload_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/route/transport_route_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class RouteConfirmRiderListScreen extends BaseScreen {
  final RouteDataModel? modelRoute;
  final ActivityDataModel? modelActivity;
  final bool isManuallyArrived;
  final RouteConfirmRiderListListener? listener;

  const RouteConfirmRiderListScreen({Key? key, required this.modelRoute, required this.modelActivity, required this.isManuallyArrived, required this.listener})
      : super(key: key);

  @override
  _RouteConfirmRiderListScreenState createState() => _RouteConfirmRiderListScreenState();
}

class _RouteConfirmRiderListScreenState extends BaseScreenState<RouteConfirmRiderListScreen> with LocalNotificationObserver {
  final List<PayloadDataModel> _arrayFilteredPayloads = [];
  final List<ConfirmRiderStatus> _arrayStatus = [];

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  _reloadData() {
    setState(() {
      _arrayFilteredPayloads.addAll(widget.modelActivity!.arrayPayloads
          .where((element) => !(element.enumStatus == EnumPayloadStatus.cancelled || element.enumStatus == EnumPayloadStatus.noShow)));

      for (var payload in _arrayFilteredPayloads) {
        final status = ConfirmRiderStatus();
        status.enumStatus = payload.enumStatus;
        _arrayStatus.add(status);
      }
    });
  }

  _onButtonDoneClick() {
    var index = 0;
    for (var payload in _arrayFilteredPayloads) {
      final status = _arrayStatus[index];
      if (status.enumStatus == EnumPayloadStatus.noShow) {
        payload.enumStatus = status.enumStatus;
      } else {
        payload.enumStatus = EnumPayloadStatus.completed;
      }
      index += 1;
    }

    showProgressHUD();
    TransportRouteManager.sharedInstance.requestUpdatePayloads(widget.modelRoute!, widget.modelActivity!, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess || responseDataModel.isOffline) {
        if (responseDataModel.isOffline) {
          TransportRouteManager.sharedInstance.updatePayloadsOffline(widget.modelRoute!, widget.modelActivity!);
        }
        widget.listener?.didRouteConfirmRiderScreenDoneClick();
        onBackPressed();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _onButtonCancelClick() {
    widget.listener?.didRouteConfirmRiderScreenCancelClick();
    onBackPressed();
  }

  _didConfirmPickupPayloadStatusChanged(PayloadDataModel cellPayload) {
    final index = _getIndexForPayloadById(cellPayload.id);
    if (index == null) return;

    setState(() {
      final status = _arrayStatus[index];
      if (status.enumStatus == EnumPayloadStatus.noShow) {
        status.enumStatus = cellPayload.enumStatus;
      } else {
        status.enumStatus = EnumPayloadStatus.noShow;
      }
    });
  }

  int? _getIndexForPayloadById(String id) {
    int index = 0;
    for (var payload in _arrayFilteredPayloads) {
      if (payload.id == id) {
        return index;
      }
      index += 1;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.profileBackground,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text(
          AppStrings.confirmPassengers,
          style: AppStyles.textTitleStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: AppDimens.kHorizontalMarginBig.copyWith(left: 0),
            child: GestureDetector(
              onTap: () {
                _onButtonCancelClick();
              },
              child: const Icon(Icons.clear, size: 24, color: AppColors.primaryColor),
            ),
          )
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 78,
              left: 0,
              right: 0,
              child: RouteConfirmRiderListView(
                arrayPayloads: _arrayFilteredPayloads,
                arrayStatus: _arrayStatus,
                itemClickListener: (payload, index) {
                  _didConfirmPickupPayloadStatusChanged(payload);
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: AppDimens.kMarginNormal,
                child: ElevatedButton(
                  style: AppStyles.roundButtonStyle,
                  onPressed: () {
                    _onButtonDoneClick();
                  },
                  child: const Text(
                    AppStrings.done,
                    textAlign: TextAlign.center,
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmRiderStatus {
  EnumPayloadStatus enumStatus = EnumPayloadStatus.completed;
}
