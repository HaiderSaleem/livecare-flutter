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

class TripRequestDetailsScreenModify extends BaseScreen {
  final RequestDataModel? modelRequest;

  const TripRequestDetailsScreenModify({Key? key, required this.modelRequest}) : super(key: key);

  @override
  _TripRequestDetailsScreenStateModify createState() => _TripRequestDetailsScreenStateModify();
}

class _TripRequestDetailsScreenStateModify extends BaseScreenState<TripRequestDetailsScreenModify> with SocketDelegate {
  String _txtConsumer = "";
  String _txtDriver = "";
  String _txtVehicle = "";
  String _txtPlateNum = "";
  String _txtTransOrg = "";
  String _txtPickupTitle = "";
  String _txtDropOffTitle = "";
  String _txtRouteStatus = "";
  String _txtRequestType = "";
  String _txtLocation = "";

  bool _btnUpdate = true;
  bool _btnCancel = true;
  bool _showAcceptDecline = false;

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

      if (_txtRouteStatus == EnumRequestStatus.pending) {
        _showAcceptDecline = true;
      }

      if (widget.modelRequest!.enumType == EnumRequestType.transport) {
        _txtRequestType = widget.modelRequest!.enumType.value.toUpperCase() + " REQUEST";
      } else {
        _txtRequestType = widget.modelRequest!.enumType.value.toUpperCase() + " REQUEST";
      }

      if (widget.modelRequest!.isScheduled()) {
        _txtPickupTitle =
            "Start\n" + UtilsDate.getStringFromDateTimeWithFormat(widget.modelRequest!.getBestPickupTime(), EnumDateTimeFormat.hhmma.value, false);

        _txtDropOffTitle =
            "End\n" + UtilsDate.getStringFromDateTimeWithFormat(widget.modelRequest!.getBestDeliveryTime(), EnumDateTimeFormat.hhmma.value, false);
      } else {
        if (widget.modelRequest!.enumTiming == EnumRequestTiming.arriveBy) {
          _txtPickupTitle = "Start";
          _txtDropOffTitle =
              "End\n" + UtilsDate.getStringFromDateTimeWithFormat(widget.modelRequest!.getBestDeliveryTime(), EnumDateTimeFormat.hhmma.value, false);
        } else {
          _txtPickupTitle =
              "Start\n" + UtilsDate.getStringFromDateTimeWithFormat(widget.modelRequest!.getBestPickupTime(), EnumDateTimeFormat.hhmma.value, false);
          _txtDropOffTitle = "End";
        }
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

      _txtLocation = widget.modelRequest!.refDelivery.szAddress;

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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width,
                child: googleMap,
              ),
              Container(
                padding: AppDimens.kMarginSmall,
                decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                child: Container(
                  margin: AppDimens.kHorizontalMarginNormal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          _txtRequestType,
                          style: AppStyles.textCellHeaderStyle.copyWith(color: AppColors.textGray),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
                            width: 20,
                            height: 20,
                            color: AppColors.purpleColor,
                          ),
                          Text("----------------------", style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.purpleColor)),
                          Image.asset(
                            'assets/images/ic_dropoff.png',
                            width: 20,
                            height: 20,
                            color: AppColors.primaryColor,
                          ),
                          Expanded(
                            child: Text(_txtDropOffTitle,
                                textAlign: TextAlign.center, style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.primaryColor)),
                          ),
                          const Divider(height: 30, color: AppColors.separatorLineGray),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //ACCEPTED // PENDING // SUBMITTED
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: getCorrectColor(),
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Text(_txtRouteStatus,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: changeRouteStatusColor(),
                                fontSize: AppDimens.kFontCellText,
                                fontFamily: "Lato",
                              )),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      const Divider(height: 30, color: AppColors.separatorLineGray),

                      // PROVIDER VEHICLE
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "PROVIDER",
                                      style: AppStyles.textCellHeaderStyle.copyWith(color: AppColors.textGray),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(1.5),
                                    decoration: const BoxDecoration(color: AppColors.border_color, shape: BoxShape.circle),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                                      child: FadeInImage(
                                        height: 90,
                                        width: 90,
                                        fadeInDuration: const Duration(milliseconds: 500),
                                        fadeInCurve: Curves.easeInExpo,
                                        fadeOutCurve: Curves.easeOutExpo,
                                        placeholder: const AssetImage("assets/images/ic_driver.png"),
                                        image: NetworkImage(widget.modelRequest!.refRoute.getDriverPhoto()),
                                        imageErrorBuilder: (context, error, stackTrace) {
                                          return SizedBox(width: 90, height: 90, child: Image.asset("assets/images/ic_driver.png"));
                                        },
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _txtDriver,
                                      style: AppStyles.textCellStyle.copyWith(color: AppColors.textGray),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const VerticalDivider(color: AppColors.separatorLineGray, thickness: 0.5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "VEHICLE",
                                      style: AppStyles.textCellHeaderStyle.copyWith(color: AppColors.textGray),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(1.5),
                                    decoration: const BoxDecoration(color: AppColors.border_color, shape: BoxShape.circle),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                                      child: FadeInImage(
                                        height: 90,
                                        width: 90,
                                        fadeInDuration: const Duration(milliseconds: 500),
                                        fadeInCurve: Curves.easeInExpo,
                                        fadeOutCurve: Curves.easeOutExpo,
                                        placeholder: const AssetImage("assets/images/ic_vehicle.png"),
                                        image: NetworkImage(widget.modelRequest!.refRoute.getVehiclePhoto()),
                                        imageErrorBuilder: (context, error, stackTrace) {
                                          return SizedBox(width: 90, height: 90, child: Image.asset("assets/images/ic_vehicle.png"));
                                        },
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _txtVehicle,
                                      style: AppStyles.textCellStyle.copyWith(color: AppColors.textGray),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 30, color: AppColors.separatorLineGray),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("LOCATION:", textAlign: TextAlign.center, style: AppStyles.textCellHeaderStyle.copyWith(color: AppColors.textGray)),
                          Expanded(
                            child: Text(
                              _txtLocation,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: AppStyles.textCellStyle.copyWith(color: AppColors.textGray),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      _showAcceptDecline
                          //DECLINE ACCEPT BUTTON
                          ? Row(
                              children: <Widget>[
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15.0), backgroundColor: AppColors.buttonOrange),
                                    onPressed: () {
                                      UtilsBaseFunction.showAlertWithMultipleButton(
                                          context, "Confirmation", "Are you sure you want to decline the request?", _requestCancel);
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      child: const Text(
                                        AppStrings.buttonDecline,
                                        textAlign: TextAlign.center,
                                        style: AppStyles.buttonTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15.0), backgroundColor: AppColors.primaryColor),
                                    onPressed: () {
                                      UtilsBaseFunction.showAlertWithMultipleButton(
                                          context, "Confirmation", "Are you sure you want to accept the request?", _requestCancel);
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      child: const Text(
                                        AppStrings.buttonAccept,
                                        textAlign: TextAlign.center,
                                        style: AppStyles.buttonTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )

                          //CANCEL BUTTON
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15.0), backgroundColor: AppColors.buttonOrange)
                                  .merge(AppStyles.normalButtonStyle),
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

  Color getCorrectColor() {
    if (_txtRouteStatus == EnumRequestStatus.accepted.value.toUpperCase()) {
      //GREEN COLOR
      return AppColors.status_accepted;
    } else if (_txtRouteStatus == EnumRequestStatus.cancelled.value.toUpperCase()) {
      // YELLOW Color
      return AppColors.status_cancelled;
    } else if (_txtRouteStatus == EnumRequestStatus.pending.value.toUpperCase()) {
      // YELLOW Color
      return AppColors.unsigned;
    } else {
      // SUBMITTED /BLUE
      return AppColors.status_submitted;
    }
  }

  Color changeRouteStatusColor() {
    if (_txtRouteStatus == EnumRequestStatus.accepted.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.noShow.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.requested.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.assigned.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.scheduled.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.enRoute.value.toUpperCase() ||
        _txtRouteStatus == EnumRequestStatus.error.value.toUpperCase()) {
      return AppColors.white;
    } else {
      return AppColors.textBlack;
    }
  }
}
