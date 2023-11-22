import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/homeServiceRequest/homeservice_request_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_config.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_map.dart';

import '../../../models/consumer/consumer_manager.dart';
import '../viewModel/home_service_request_view_model.dart';

class HomeServiceSummaryScreen extends BaseScreen {
  final HomeServiceRequestViewModel? vmRequest;

  const HomeServiceSummaryScreen({Key? key, required this.vmRequest}) : super(key: key);

  @override
  _HomeServiceSummaryScreenState createState() => _HomeServiceSummaryScreenState();
}

class _HomeServiceSummaryScreenState extends BaseScreenState<HomeServiceSummaryScreen> {
  GoogleMap? googleMap;
  final Completer<GoogleMapController> _controller = Completer();
  List<Marker> markers = [];
  final Set<Polyline> _polyline = <Polyline>{};

  String _txtRecurring = "N/A";

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  _refreshFields() {
    // if (widget.vmRequest!.enumWayType == EnumRequestWayType.round) {
    //   _txtReturn = widget.vmRequest!.szReturnTime;
    // } else {
    //   _txtReturn = "N/A";
    // }
    if (widget.vmRequest!.isRecurring) {
      _txtRecurring = UtilsDate.getStringFromDateTimeWithFormat(widget.vmRequest!.dateRepeatUntil, EnumDateTimeFormat.MMMMdd.value, false);
    }
  }

  _reloadMap() {
    googleMap = GoogleMap(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
      onTap: (latlang) async {
        UtilsMap.launchMap(context, latlang.latitude, latlang.longitude);
      },
      mapToolbarEnabled: false,
      mapType: MapType.normal,
      tiltGesturesEnabled: false,
      polylines: _polyline,
      markers: markers.toSet(),
      initialCameraPosition: CameraPosition(
          zoom: UtilsMap.cameraZoom,
          tilt: UtilsMap.cameraTilt,
          bearing: UtilsMap.cameraBearing,
          target: widget.vmRequest!.refLocationDataPoint.getCoordinates()),
      onMapCreated: ((GoogleMapController controller) {
        _controller.complete(controller);
        _addStopPins();
      }),
    );
  }

  _addStopPins() async {
    BitmapDescriptor sourceIcon = BitmapDescriptor.fromBytes(await UtilsBaseFunction.getBytesFromAsset("assets/images/ic_map_pin_pink.png", 8));
    BitmapDescriptor destinationIcon = BitmapDescriptor.fromBytes(await UtilsBaseFunction.getBytesFromAsset("assets/images/ic_map_departure.png", 8));

    final GoogleMapController controller = await _controller.future;

    var _origin =
        PointLatLng(widget.vmRequest!.refLocationDataPoint.getCoordinates().latitude, widget.vmRequest!.refLocationDataPoint.getCoordinates().longitude);
    var _destination =
        PointLatLng(widget.vmRequest!.refLocationDataPoint.getCoordinates().latitude, widget.vmRequest!.refLocationDataPoint.getCoordinates().longitude);
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(UtilsConfig.GOOGLE_DIRECTION_API_KEY, _origin, _destination,
        travelMode: TravelMode.driving, avoidHighways: true);

    setState(() {
      markers.add(Marker(markerId: const MarkerId('sourcePin'), position: widget.vmRequest!.refLocationDataPoint.getCoordinates(), icon: sourceIcon));

      markers.add(Marker(markerId: const MarkerId('destPin'), position: widget.vmRequest!.refLocationDataPoint.getCoordinates(), icon: destinationIcon));

      controller.animateCamera(CameraUpdate.newLatLngBounds(UtilsMap.boundsFromLatLngList(markers.map((loc) => loc.position).toList()), 40));

      _polyline.add(Polyline(
        polylineId: const PolylineId("poly"),
        visible: true,
        points: result.points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
        width: 6,
        color: AppColors.shareLightBlue,
      ));
    });
  }

  _submitServiceRequest() {
    var consumerId = ConsumerManager.sharedInstance.arrayConsumers[widget.vmRequest!.indexConsumer].id;
    if (widget.vmRequest == null) return;
    if (widget.vmRequest!.isRecurring) {
      // Create Schedule Request
      _requestCreateScheduleRequest(consumerId);
    } else {
      // Home Service Request
      _requestCreateHomeServiceRequest(consumerId);
    }
  }

  _requestCreateScheduleRequest(String consumerId) {
    if (widget.vmRequest == null) return;
    final schedule = widget.vmRequest!.toDataModel();
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    HomeServiceRequestManager.sharedInstance.homeRequestCreateSchedule(consumerId, schedule, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        _gotoListScreen();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _requestCreateHomeServiceRequest(String consumerId) {
    if (widget.vmRequest == null) return;
    final schedule = widget.vmRequest!.toDataModel();
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    HomeServiceRequestManager.sharedInstance.homeRequestCreateRequest(consumerId, schedule, (responseDataModel) {
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
    _reloadMap();
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(context).pop();
                });
          },
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(AppStrings.newServiceRequest, style: AppStyles.textCellHeaderStyle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                _submitServiceRequest();
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.buttonSubmit, style: AppStyles.buttonTextStyle),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Container(
          color: AppColors.defaultBackground,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: googleMap,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: AppDimens.kMarginNormal,
                  decoration: const BoxDecoration(
                      color: AppColors.textWhite, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                  child: Container(
                    margin: AppDimens.kMarginNormal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Consumer *********************
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(AppStrings.labelConsumer.toUpperCase(), style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(child: Text(widget.vmRequest!.szConsumer, style: AppStyles.textGrey))
                          ],
                        ),
                        const Divider(height: 25, color: AppColors.separatorLineGray),
                        //PICKUP ***********************
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(AppStrings.location.toUpperCase(), style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(child: Text(widget.vmRequest!.refLocationDataPoint.szAddress, style: AppStyles.textGrey, overflow: TextOverflow.ellipsis))
                          ],
                        ),

                        const Divider(height: 30, color: AppColors.separatorLineGray),
                        //DATE ***************************
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(AppStrings.labelDate.toUpperCase(), style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(
                                child: Text(UtilsDate.getStringFromDateTimeWithFormat(widget.vmRequest!.date, EnumDateTimeFormat.MMMdyyyy.value, false),
                                    style: AppStyles.textGrey))
                          ],
                        ),
                        const Divider(height: 30, color: AppColors.separatorLineGray),
                        //TIME ***************************
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(AppStrings.labelTime.toUpperCase(), style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(child: Text(widget.vmRequest!.szTime, style: AppStyles.textGrey))
                          ],
                        ),
                        const Divider(height: 30, color: AppColors.separatorLineGray),

                        // RETURN **************************
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: const Text("DURATION :", style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(
                                child: Text(widget.vmRequest!.nDurationHours.toString() + " hours, " + widget.vmRequest!.nDurationMins.toString() + " minute",
                                    style: AppStyles.textGrey))
                          ],
                        ),
                        const Divider(height: 30, color: AppColors.separatorLineGray),
                        // DESCRIPTION ************************
                        const Row(children: [
                          SizedBox(
                            child: Text("DESCRIPTION OF SERVICES REQUESTED :", style: AppStyles.textCellTitleBoldStyle),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text(widget.vmRequest!.szDescription, style: AppStyles.textGrey)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
