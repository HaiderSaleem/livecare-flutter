import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livecare/components/listView/service_routes_listview.dart';
import 'package:livecare/listeners/vehicle_popup_listener.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/service_request_manager.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/route/service_route_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/serviceRoute/service_route_vehicle_popup_dialog.dart';
import 'package:livecare/screens/serviceRoute/service_routes_request_details_screen.dart';
import 'package:livecare/utils/utils_base_function.dart';

import '../../listeners/route_odometer_listener.dart';
import '../../models/route/transport_route_manager.dart';
import '../../resources/app_strings.dart';
import '../../utils/utils_config.dart';
import '../../utils/utils_map.dart';

// ignore: must_be_immutable
class ServiceRoutesListDetailScreen extends BaseScreen {
  RouteDataModel? modelRoute;
  bool isRouteStarted;

  ServiceRoutesListDetailScreen({Key? key, required this.modelRoute, required this.isRouteStarted}) : super(key: key);

  @override
  _ServiceRoutesListDetailScreenState createState() => _ServiceRoutesListDetailScreenState();
}

class _ServiceRoutesListDetailScreenState extends BaseScreenState<ServiceRoutesListDetailScreen> with ServiceRoutesVehiclePopupListener, RouteOdometerListener {
  GoogleMap? _googleMap;
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  final Set<Polyline> _polyline = <Polyline>{};

  String _txtAction = "Start";
  bool _viewAction = true;
  ButtonStyle _buttonStyle = ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor).merge(AppStyles.roundButtonStyle);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUI();
    });
  }

  _initUI() {
    _reloadMap();
    _setupActionButtonPanel();
  }

  refreshUI() {
    _reloadMap();
    _setupActionButtonPanel();
  }

  _reloadMap() {
    _googleMap = GoogleMap(
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
      markers: _markers.toSet(),
      initialCameraPosition: CameraPosition(
          zoom: UtilsMap.cameraZoom,
          tilt: UtilsMap.cameraTilt,
          bearing: UtilsMap.cameraBearing,
          target: widget.modelRoute!.arrayActivities.first.geoLocation.getCoordinates()),
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

    final firstActivity = widget.modelRoute!.arrayActivities.isEmpty ? null : widget.modelRoute!.arrayActivities.first;
    final lastActivity = widget.modelRoute!.arrayActivities.isEmpty ? null : widget.modelRoute!.arrayActivities.last;
    if (firstActivity == null || lastActivity == null) return;
    var _origin = PointLatLng(firstActivity.geoLocation.getCoordinates().latitude, firstActivity.geoLocation.getCoordinates().longitude);
    var _destination = PointLatLng(lastActivity.geoLocation.getCoordinates().latitude, lastActivity.geoLocation.getCoordinates().longitude);
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(UtilsConfig.GOOGLE_DIRECTION_API_KEY, _origin, _destination,
        travelMode: TravelMode.driving,
        avoidHighways: true,
        wayPoints: widget.modelRoute!.arrayActivities
            .map((e) => PolylineWayPoint(location: "${e.geoLocation.getCoordinates().latitude},${e.geoLocation.getCoordinates().longitude}"))
            .toList());

    setState(() {
      for (var activity in widget.modelRoute!.arrayActivities) {
        _markers.add(Marker(
            markerId: MarkerId(activity.id),
            position: activity.geoLocation.getCoordinates(),
            icon: activity.getPickupCount() > 0 ? sourceIcon : destinationIcon));
      }

      controller.animateCamera(CameraUpdate.newLatLngBounds(UtilsMap.boundsFromLatLngList(_markers.map((loc) => loc.position).toList()), 40));

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

  _setupActionButtonPanel() {
    final route = widget.modelRoute;
    if (route == null) {
      setState(() {
        _viewAction = false;
      });
      return;
    }

    setState(() {
      if (!route.isActiveRoute() && !route.isReadyToComplete()) {
        _viewAction = false;
        return;
      } else {
        _viewAction = true;
      }

      if (route.enumStatus == EnumRouteStatus.scheduled) {
        _txtAction = "Start";
        _buttonStyle = ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor).merge(AppStyles.roundButtonStyle);
      } else if (route.enumStatus == EnumRouteStatus.enRoute || route.enumStatus == EnumRouteStatus.inProgress) {
        if (route.isReadyToComplete()) {
          _txtAction = "Complete";
          _buttonStyle = ElevatedButton.styleFrom(backgroundColor: AppColors.buttonRed).merge(AppStyles.roundButtonStyle);
        } else {
          _txtAction = "Resume";
          _buttonStyle = ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor).merge(AppStyles.roundButtonStyle);
        }
      }
    });
  }

  _showDialogForVehicleInformation() {
    showDialog(
        context: context,
        builder: (BuildContext context) => ServiceRoutesVehiclePopupDialog(
            fOdometerStart: widget.modelRoute!.fOdometerStart,
            szLicensePlate: widget.modelRoute!.refVehicle!.szLicense,
            showLicensePlate: true,
            popupListener: this));
  }

  _gotoServiceRouteDetailsScreen(int index) {
    Navigator.push(
      context,
      createRoute(ServiceRoutesRequestDetailsScreen(
        modelRoute: widget.modelRoute,
        indexActivity: index,
      )),
    ).then((val) {
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  _startRoute() {
    final route = widget.modelRoute;
    if (route == null) return;

    if (route.enumStatus == EnumRouteStatus.enRoute || route.enumStatus == EnumRouteStatus.inProgress) return;
    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      showProgressHUD();

      ServiceRouteManager.sharedInstance.requestStartRoute(route, (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess) {
          var id = route.getIdForNextActivityToStartRide();
          _updateRoute(true, route.getIndexForActivityById(id!));
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      //Call API with null callback to queue request
      ServiceRouteManager.sharedInstance.requestStartRoute(route, null);
      ServiceRouteManager.sharedInstance.startRouteOffline(route);
      final activity = route.arrayActivities[0];
      String requestId;
      if (activity.arrayPayloads.isNotEmpty) {
        requestId = activity.arrayPayloads.first.requestId;
        final request = ServiceRequestManager.sharedInstance.getRequestById(requestId);
        if (request == null) return;
        ServiceRequestManager.sharedInstance.updateRequestOffline(request, EnumRequestStatus.inProgress);
      }
      _gotoServiceRouteDetailsScreen(0);
    }
  }

  /*_completeRoute() {
    final route = widget.modelRoute;
    if (route == null) return;
    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      showProgressHUD();
      ServiceRouteManager.sharedInstance.requestCompleteRoute(route,
          (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess) {
          _updateRoute(false);
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      //Call API with null callback to queue request
      ServiceRouteManager.sharedInstance.requestCompleteRoute(route, null);
      ServiceRouteManager.sharedInstance.completeRouteOffline(route);
      _reloadRouteData();
    }
  }*/

  _reloadRouteData() {
    final route = widget.modelRoute;
    if (route == null) return;
    if (route.outdated) {
      final updateRoute = ServiceRouteManager.sharedInstance.getServiceRouteById(route.id);
      if (updateRoute == null) return;
      setState(() {
        widget.modelRoute = updateRoute;
      });
    }
  }

  _onButtonActionClick() {
    final route = widget.modelRoute;
    if (route == null) return;
    if (!route.isActiveRoute() && !route.isReadyToComplete()) return;
    if (route.enumStatus == EnumRouteStatus.scheduled) {
      if (TransportRouteManager.sharedInstance.isRouteActive()) {
        UtilsBaseFunction.showAlert(context, "Warning", "This route cannot be started. Please try again closer to the route start time.");
      }
      if (route.isStartRoute()) {
        _showDialogForVehicleInformation();
      } else {
        UtilsBaseFunction.showAlert(context, "Warning", "This route cannot be started. Please try again closer to the route start time.");
      }

      // if (route.isFutureRoute()) {
      //   UtilsBaseFunction.showAlert(context, "Warning", "This route cannot be started. Please try again closer to the route start time.");
      // } else {
      //   _showDialogForVehicleInformation();
      // }
    } else if (route.enumStatus == EnumRouteStatus.enRoute || route.enumStatus == EnumRouteStatus.inProgress) {
      // final int index = route.getIndexForNextActivityToStartRide()!;
      // print("Index-->> "+index.toString());
      _gotoServiceRouteDetailsScreen(0);

      /*  if (route.isReadyToComplete()) {
        _completeRoute();
      } else {
        if (route.getIndexForNextActivityToStartRide() == null) {
          _completeRoute();
        } else {
          final int index = route.getIndexForNextActivityToStartRide()!;
          _gotoServiceRouteDetailsScreen(index);
        }
      }*/
    }
  }

  _updateRoute(bool goToDetails, int? index) {
    final route = widget.modelRoute;
    if (route == null) return;

    ServiceRouteManager.sharedInstance.requestGetRouteById(route.id, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess || responseDataModel.isOffline) {
        if (ServiceRouteManager.sharedInstance.getServiceRouteById(route.id) == null) {
          showToast("Route is not found.");
        } else {
          final updatedRoute = ServiceRouteManager.sharedInstance.getServiceRouteById(route.id);
          widget.modelRoute = updatedRoute;
          refreshUI();
          if (goToDetails) _gotoServiceRouteDetailsScreen(index!);
        }
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _updateMapLocation(PolylineResult result) async {
    final GoogleMapController controller = await _controller.future;
    setState(() {
      final bounds = UtilsMap.boundsFromLatLngList(result.points.map((loc) => LatLng(loc.latitude, loc.longitude)).toList());
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    });
  }

  @override
  didServiceRoutesVehiclePopupCancelClick() {}

  @override
  didServiceRoutesVehiclePopupOkClick(double odometer, String licensePlate, bool consumerNoShow, String cancelReason) {
    if (widget.modelRoute == null) return;
    setState(() {
      widget.modelRoute!.fOdometerStart = odometer;
      widget.modelRoute!.refVehicle?.szLicense = licensePlate;
    });
    _startRoute();
  }

  @override
  Widget build(BuildContext context) {
    _reloadMap();
    return Scaffold(
      backgroundColor: AppColors.profileFrame,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.titleAppointment,
          style: AppStyles.textCellHeaderStyle,
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: _googleMap,
                ),
                Expanded(
                  child: ServiceRoutesListView(
                    arrayActivities: widget.modelRoute!.arrayActivities,
                    itemClickListener: (route, position) {
                      _gotoServiceRouteDetailsScreen(position);
                    },
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Visibility(
                visible: _viewAction,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: AppDimens.kMarginNormal,
                  child: ElevatedButton(
                    style: _buttonStyle,
                    onPressed: () {
                      _onButtonActionClick();
                    },
                    child: Text(
                      _txtAction,
                      textAlign: TextAlign.center,
                      style: AppStyles.buttonTextStyle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  didOdometerPopupOkClick(double odometer) {
    final route = widget.modelRoute;
    if (route == null) return;
    widget.modelRoute!.fOdometerStart = odometer;
    _startRoute();
  }
}
