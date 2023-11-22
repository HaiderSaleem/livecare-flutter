import 'package:flutter/material.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/transport_request_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:livecare/screens/request/viewModel/ride_view_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_config.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RideSummaryScreen extends BaseScreen {
  final RideViewModel? vmRide;

  const RideSummaryScreen({Key? key, required this.vmRide}) : super(key: key);

  @override
  _RideSummaryScreenState createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends BaseScreenState<RideSummaryScreen> {
  GoogleMap? googleMap;
  final Completer<GoogleMapController> _controller = Completer();
  List<Marker> markers = [];
  final Set<Polyline> _polyline = <Polyline>{};

  String _txtReturn = "N/A";
  String _txtRecurring = "N/A";

  @override
  void initState() {
    super.initState();
    _refreshFields();

  }

  _refreshFields() {
    if (widget.vmRide!.enumWayType == EnumRequestWayType.round) {
      _txtReturn = widget.vmRide!.szReturnTime;
    } else {
      _txtReturn = "N/A";
    }

    if (widget.vmRide!.isRecurring) {
      _txtRecurring = UtilsDate.getStringFromDateTimeWithFormat(
          widget.vmRide!.dateRepeatUntil,
          EnumDateTimeFormat.MMMMdd.value,
          false);
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
          target: widget.vmRide!.pickup.getCoordinates()),
      onMapCreated: ((GoogleMapController controller) {
        _controller.complete(controller);
        _addStopPins();
      }),
    );
  }

  _addStopPins() async {
    BitmapDescriptor sourceIcon = BitmapDescriptor.fromBytes(
        await UtilsBaseFunction.getBytesFromAsset(
            "assets/images/ic_map_pin_pink.png", 8));
    BitmapDescriptor destinationIcon = BitmapDescriptor.fromBytes(
        await UtilsBaseFunction.getBytesFromAsset(
            "assets/images/ic_map_departure.png", 8));

    final GoogleMapController controller = await _controller.future;

    var _origin = PointLatLng(widget.vmRide!.pickup.getCoordinates().latitude,
        widget.vmRide!.pickup.getCoordinates().longitude);
    var _destination = PointLatLng(
        widget.vmRide!.delivery.getCoordinates().latitude,
        widget.vmRide!.delivery.getCoordinates().longitude);
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        UtilsConfig.GOOGLE_DIRECTION_API_KEY, _origin, _destination,
        travelMode: TravelMode.driving, avoidHighways: true);

    setState(() {
      markers.add(Marker(
          markerId: const MarkerId('sourcePin'),
          position: widget.vmRide!.pickup.getCoordinates(),
          icon: sourceIcon));

      markers.add(Marker(
          markerId: const MarkerId('destPin'),
          position: widget.vmRide!.delivery.getCoordinates(),
          icon: destinationIcon));

      controller.animateCamera(CameraUpdate.newLatLngBounds(
          UtilsMap.boundsFromLatLngList(
              markers.map((loc) => loc.position).toList()),
          40));

      _polyline.add(Polyline(
        polylineId: const PolylineId("poly"),
        visible: true,
        points:
            result.points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
        width: 6,
        color: AppColors.shareLightBlue,
      ));
    });
  }

  _requestCreateTripRequest() {
    if (widget.vmRide == null) return;
    final schedule = widget.vmRide!.toDataModel();
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    TransportRequestManager.sharedInstance.requestCreateSchedule(schedule,
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
    _reloadMap();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.titleRideSummary,
          style: AppStyles.textCellHeaderStyle,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                _requestCreateTripRequest();
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.buttonSubmit,
                    style: AppStyles.buttonTextStyle),
              ),
            ),
          ),

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
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: googleMap,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: AppDimens.kMarginNormal,
                  decoration: const BoxDecoration(
                      color: AppColors.textWhite,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
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
                              child: Text(
                                  AppStrings.labelConsumer.toUpperCase(),
                                  style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(
                                child: Text(
                                    widget.vmRide!.getBeautifiedConsumersText(),
                                    style: AppStyles.textGrey))
                          ],
                        ),
                        const Divider(
                            height: 25, color: AppColors.separatorLineGray),

                        //TYPE *************************
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: const Text("TYPE :",
                                  style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(
                                child: Text(widget.vmRide!.enumWayType.value,
                                    style: AppStyles.textGrey))
                          ],
                        ),
                        const Divider(
                            height: 30, color: AppColors.separatorLineGray),

                        //PICKUP ***********************
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(AppStrings.pickup.toUpperCase(),
                                  style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(
                                child: Text(widget.vmRide!.pickup.szAddress,
                                    style: AppStyles.textGrey))
                          ],
                        ),

                        const Divider(
                            height: 30, color: AppColors.separatorLineGray),
                        //DROP OFF **********************
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(AppStrings.dropOff.toUpperCase(),
                                  style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(
                                child: Text(widget.vmRide!.delivery.szAddress,
                                    style: AppStyles.textGrey))
                          ],
                        ),

                        const Divider(
                            height: 30, color: AppColors.separatorLineGray),

                        //DATE ***************************

                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(AppStrings.labelDate.toUpperCase(),
                                  style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(
                                child: Text(
                                    UtilsDate.getStringFromDateTimeWithFormat(
                                        widget.vmRide!.date,
                                        EnumDateTimeFormat.MMddyyyy1.value,
                                        false),
                                    style: AppStyles.textGrey))
                          ],
                        ),

                        const Divider(
                            height: 30, color: AppColors.separatorLineGray),

                        // READ BY ************************
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(
                                  widget.vmRide!.enumTiming.value
                                          .toUpperCase() +
                                      " :",
                                  style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(
                                child: Text(widget.vmRide!.szTime,
                                    style: AppStyles.textGrey))
                          ],
                        ),

                        const Divider(
                            height: 30, color: AppColors.separatorLineGray),

                        // RETURN **************************

                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: const Text("RETURN :",
                                  style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(
                                child:
                                    Text(_txtReturn, style: AppStyles.textGrey))
                          ],
                        ),

                        const Divider(
                            height: 30, color: AppColors.separatorLineGray),

                        // RECURRING ************************
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: const Text("RECURRING :",
                                  style: AppStyles.textCellTitleBoldStyle),
                            ),
                            Expanded(
                                child: Text(_txtRecurring,
                                    style: AppStyles.textGrey))
                          ],
                        ),
                        const Divider(
                            height: 30, color: AppColors.separatorLineGray),
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
