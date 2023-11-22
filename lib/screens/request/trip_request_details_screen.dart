import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/communication/socket_request_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/transport_request_manager.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/request/trip_request_update_screen.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_config.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_map.dart';

class TripRequestDetailsScreen extends BaseScreen {
  final RequestDataModel? modelRequest;

  const TripRequestDetailsScreen({Key? key, required this.modelRequest}) : super(key: key);

  @override
  _TripRequestDetailsScreenState createState() => _TripRequestDetailsScreenState();
}

class _TripRequestDetailsScreenState extends BaseScreenState<TripRequestDetailsScreen> with SocketDelegate {
  String _txtConsumer = "";
  String _txtDriver = "";
  String _txtVehicle = "";
  String _txtPlateNum = "";
  String _txtTransOrg = "";
  String _txtPickupTitle = "";
  String _txtDropOffTitle = "";
  String _txtRouteStatus = "";

  bool _btnUpdate = true;
  bool _btnCancel = true;

  GoogleMap? googleMap;
  final Completer<GoogleMapController> _controller = Completer();
  List<Marker> markers = [];
  final Set<Polyline> _polyline = <Polyline>{};

  @override
  void initState() {
    super.initState();
    _refreshFields();
    SocketRequestManager.sharedInstance.addListener(this);
  }

  _refreshFields() {
    if (widget.modelRequest == null) return;

    setState(() {
      _txtRouteStatus = widget.modelRequest!.enumStatus.value.toUpperCase();

      if (widget.modelRequest!.enumTiming == EnumRequestTiming.arriveBy) {
        _txtPickupTitle = "Pick-up";
        _txtDropOffTitle =
            "Drop-off\n" + UtilsDate.getStringFromDateTimeWithFormat(widget.modelRequest!.getBestDeliveryTime(), EnumDateTimeFormat.hhmma.value, false);
      } else {
        _txtPickupTitle =
            "Pick-up\n" + UtilsDate.getStringFromDateTimeWithFormat(widget.modelRequest!.getBestPickupTime(), EnumDateTimeFormat.hhmma.value, false);
        _txtDropOffTitle = "Drop-off";
      }

      _txtConsumer = widget.modelRequest!.getBeautifiedTransfersText();

      if (!widget.modelRequest!.isScheduled()) {
        _txtDriver = "N/A";
        _txtVehicle = "N/A";
        _txtPlateNum = "N/A";
        _txtTransOrg = "N/A";
      } else {
        _txtDriver = "N/A";
        _txtVehicle = "N/A";
        _txtPlateNum = "N/A";
        _txtTransOrg = widget.modelRequest!.refTransportOrganization.szName;
      }
      _txtDriver = widget.modelRequest!.refRoute.getDriverName();
      _txtVehicle = widget.modelRequest!.refRoute.getVehicleName();

      if (widget.modelRequest!.canUpdate()) {
        _btnUpdate = true;
        _btnCancel = true;
      } else if (widget.modelRequest!.canCancel()) {
        _btnUpdate = false;
        _btnCancel = true;
      } else {
        _btnUpdate = false;
        _btnCancel = false;
      }
    });
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
          zoom: UtilsMap.cameraZoom, tilt: UtilsMap.cameraTilt, bearing: UtilsMap.cameraBearing, target: widget.modelRequest!.refPickup.getCoordinates()),
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

    var _origin = PointLatLng(widget.modelRequest!.refPickup.getCoordinates().latitude, widget.modelRequest!.refPickup.getCoordinates().longitude);
    var _destination = PointLatLng(widget.modelRequest!.refDelivery.getCoordinates().latitude, widget.modelRequest!.refDelivery.getCoordinates().longitude);
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(UtilsConfig.GOOGLE_DIRECTION_API_KEY, _origin, _destination,
        travelMode: TravelMode.driving, avoidHighways: true);

    setState(() {
      markers.add(Marker(markerId: const MarkerId('sourcePin'), position: widget.modelRequest!.refPickup.getCoordinates(), icon: sourceIcon));

      markers.add(Marker(markerId: const MarkerId('destPin'), position: widget.modelRequest!.refDelivery.getCoordinates(), icon: destinationIcon));

      controller.animateCamera(CameraUpdate.newLatLngBounds(UtilsMap.boundsFromLatLngList(markers.map((loc) => loc.position).toList()), 40));

      _polyline.add(Polyline(
        polylineId: const PolylineId("poly"),
        visible: true,
        points: result.points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
        width: 6,
        color: AppColors.shareLightBlue,
      ));
    });

    if (_polyline.isNotEmpty) {
      _updateMapLocation(result);
    }
  }

  _updateMapLocation(PolylineResult result) async {
    final GoogleMapController controller = await _controller.future;
    setState(() {
      final bounds = UtilsMap.boundsFromLatLngList(result.points.map((loc) => LatLng(loc.latitude, loc.longitude)).toList());
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    });
  }

  _requestCancel() {
    final request = widget.modelRequest;
    if (request == null) return;
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    TransportRequestManager.sharedInstance.requestCancelRequest(request, "", EnumRequestType.transport, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        onBackPressed();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _gotoUpdateScreen() {
    final request = widget.modelRequest;
    if (request == null) return;

    if (!request.canUpdate()) {
      UtilsBaseFunction.showAlert(context, "Error", "You cannot update this request.");
      return;
    }
    Navigator.push(
      context,
      createRoute(TripRequestUpdateScreen(modelRequest: request)),
    );
  }

  @override
  onAnyEventFired() {}

  @override
  onConnected() {}

  @override
  onConnectionStatusChanged() {}

  @override
  onRequestCancelled(RequestDataModel request) {
    _refreshFields();
  }

  @override
  onRequestUpdated(RequestDataModel request) {
    _refreshFields();
  }

  @override
  onRouteDriverLocationUpdated(String routeId, double lat, double lng) {
    if (widget.modelRequest?.routeId == routeId) {
      showToast(AppStrings.driverMoving);
      widget.modelRequest!.refLocation.fLongitude = lng;
      widget.modelRequest!.refLocation.fLatitude = lat;
    }
    _refreshFields();
  }

  @override
  onRouteLocationStatusUpdated(RouteDataModel route) {
    _refreshFields();
  }

  @override
  onRouteUpdated(RouteDataModel route) {
    _refreshFields();
  }

  @override
  Widget build(BuildContext context) {
    _reloadMap();
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
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
        title: const Text(
          "Request Details",
          style: AppStyles.textCellHeaderStyle,
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.3, width: MediaQuery.of(context).size.width, child: googleMap),
              Container(
                padding: AppDimens.kMarginNormal,
                decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                child: Container(
                  margin: AppDimens.kHorizontalMarginNormal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          _txtRouteStatus,
                          style: AppStyles.textCellHeaderStyle.copyWith(color: AppColors.textGray),
                        ),
                      ),
                      // PICK UP and DROP OFF ***************************
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child:
                                Text(_txtPickupTitle, textAlign: TextAlign.center, style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.purpleColor)),
                          ),
                          Image.asset(
                            'assets/images/ic_pickup.png',
                            width: 15,
                            height: 15,
                            color: AppColors.purpleColor,
                          ),
                          Text("--------------------------------", style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.purpleColor)),
                          Image.asset(
                            'assets/images/ic_dropoff.png',
                            width: 15,
                            height: 15,
                            color: AppColors.primaryColor,
                          ),
                          Expanded(
                            child: Text(_txtDropOffTitle,
                                textAlign: TextAlign.center, style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.primaryColor)),
                          ),
                        ],
                      ),

                      const Divider(height: 30, color: AppColors.separatorLineGray),
                      //Consumer *********************
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Text(AppStrings.labelConsumer.toUpperCase(), style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Text(_txtConsumer, style: AppStyles.textCellTitleStyle)
                        ],
                      ),

                      const Divider(height: 30, color: AppColors.separatorLineGray),

                      //DRIVER   *************************
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("DRIVER :", style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(child: Text(_txtDriver, style: AppStyles.textCellTitleStyle))
                        ],
                      ),
                      const Divider(height: 30, color: AppColors.separatorLineGray),

                      //VEHICLE ***********************
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("VEHICLE :", style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(child: Text(_txtVehicle, style: AppStyles.textCellTitleStyle))
                        ],
                      ),
                      const Divider(height: 30, color: AppColors.separatorLineGray),

                      //PLATE NUMBER **********************
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("PLATE NUMB :", style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(child: Text(_txtPlateNum, style: AppStyles.textCellTitleStyle))
                        ],
                      ),
                      const Divider(height: 30, color: AppColors.separatorLineGray),

                      //TRANS ORG ***************************
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("TRANS ORG :", style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(child: Text(_txtTransOrg, style: AppStyles.textCellTitleStyle))
                        ],
                      ),
                      const SizedBox(height: 30),

                      //Button cancel and update ***************************

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: _btnUpdate,
                            child: Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.shareLightBlue).merge(AppStyles.normalButtonStyle),
                                onPressed: () {
                                  _gotoUpdateScreen();
                                },
                                child: const Text(
                                  "Update",
                                  textAlign: TextAlign.center,
                                  style: AppStyles.buttonTextStyle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Visibility(
                            visible: _btnCancel,
                            child: Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonOrange).merge(AppStyles.normalButtonStyle),
                                onPressed: () {
                                  UtilsBaseFunction.showAlertWithMultipleButton(
                                      context, "Confirmation", "Are you sure you want to cancel the request?", _requestCancel);
                                },
                                child: const Text(
                                  AppStrings.buttonCancel,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.buttonTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
