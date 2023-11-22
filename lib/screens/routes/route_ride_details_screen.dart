import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:livecare/components/listView/route_location_user_listview.dart';
import 'package:livecare/listeners/route_confirm_rider_listener.dart';
import 'package:livecare/models/appManager/app_manager.dart';
import 'package:livecare/models/appManager/dataModel/app_setting_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/route/dataModel/activity_data_model.dart';
import 'package:livecare/models/route/dataModel/payload_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/route/transport_route_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livecare/screens/routes/route_confirm_rider_list_screen.dart';
import 'package:livecare/screens/routes/route_instructions_popup_dialog.dart';
import 'package:livecare/screens/routes/route_rider_details_popup_dialog.dart';
import 'package:livecare/utils/location_manager.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_config.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_map.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class RouteRideDetailsScreen extends BaseScreen {
  RouteDataModel? modelRoute;
  ActivityDataModel? modelActivity;
  int indexActivity = 0;
  bool shouldOpenMapApp = false;

  RouteRideDetailsScreen(
      {Key? key,
      required this.modelRoute,
      required this.modelActivity,
      required this.indexActivity,
      required this.shouldOpenMapApp})
      : super(key: key);

  @override
  _RouteRideDetailsScreenState createState() => _RouteRideDetailsScreenState();
}


class _RouteRideDetailsScreenState
    extends BaseScreenState<RouteRideDetailsScreen>
    with RouteConfirmRiderListListener {
  List<PayloadDataModel> _arrayFilteredPayloads = [];
  bool _isManuallyArrived = false;
  bool _isArrivalDetected = false;
  GoogleMap? _googleMap;
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  final Set<Polyline> _polyline = <Polyline>{};

  String _txtAddress = "";
  String _txtTime = "";
  String _txtActualTime = "";
  String _txtWaitTime = "";
  String _txtPickup = "";
  String _txtDropOff = "";
  String _txtAction = "Start Ride";
  Location locationManager = Location();

  @override
  void initState() {
    super.initState();
    _onLocationChanged();
    _reloadData();
    _refreshFields();

    if (widget.shouldOpenMapApp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _promptForOpenNavigationApps(widget.modelActivity!.geoLocation);
      });
      widget.shouldOpenMapApp = false;
    }
  }

  _reloadData() {
    final route = widget.modelActivity;
    if (route == null) return;
    _arrayFilteredPayloads = [];
    setState(() {
      _arrayFilteredPayloads.addAll(route.arrayPayloads.where(
          (element) => element.enumStatus != EnumPayloadStatus.cancelled));
    });
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
          target: widget.modelActivity!.geoLocation.getCoordinates()),
      onMapCreated: ((GoogleMapController controller) {
        _controller.complete(controller);
        _addStopPins();
      }),
    );
  }

  _addStopPins() async {
    _googleMap?.markers.clear();
    _googleMap?.polylines.clear();
    BitmapDescriptor sourceIcon = BitmapDescriptor.fromBytes(
        await UtilsBaseFunction.getBytesFromAsset(
            "assets/images/ic_map_pin_pink.png", 8));
    BitmapDescriptor destinationIcon = BitmapDescriptor.fromBytes(
        await UtilsBaseFunction.getBytesFromAsset(
            "assets/images/ic_map_departure.png", 8));

    final GoogleMapController controller = await _controller.future;

    var _origin = PointLatLng(
        widget.modelRoute!.arrayActivities[widget.indexActivity - 1].geoLocation
            .getCoordinates()
            .latitude,
        widget.modelRoute!.arrayActivities[widget.indexActivity - 1].geoLocation
            .getCoordinates()
            .longitude);
    var _destination = PointLatLng(
        widget.modelActivity!.geoLocation.getCoordinates().latitude,
        widget.modelActivity!.geoLocation.getCoordinates().longitude);
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        UtilsConfig.GOOGLE_DIRECTION_API_KEY, _origin, _destination,
        travelMode: TravelMode.driving,
        avoidHighways: true,
        wayPoints: widget.modelActivity!.arrayWaypoints
            .map((e) =>
                PolylineWayPoint(location: "${e.latitude},${e.longitude}"))
            .toList());

    setState(() {
      _markers.add(Marker(
          markerId: const MarkerId('sourcePin'),
          position: widget
              .modelRoute!.arrayActivities[widget.indexActivity - 1].geoLocation
              .getCoordinates(),
          icon: sourceIcon));

      _markers.add(Marker(
          markerId: const MarkerId('destPin'),
          position: widget.modelActivity!.geoLocation.getCoordinates(),
          icon: destinationIcon));

      controller.animateCamera(CameraUpdate.newLatLngBounds(
          UtilsMap.boundsFromLatLngList(
              _markers.map((loc) => loc.position).toList()),
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

  _refreshFields() {
    final activity = widget.modelActivity;
    if (activity == null) return;
    setState(() {
      _txtAddress = activity.geoLocation.szAddress;
      final estimatedArrival = activity.dateEstimatedArrival;
      if (estimatedArrival == null) {
        _txtTime = "N/A";
      } else {
        _txtTime = UtilsDate.getStringFromDateTimeWithFormat(
            DateTime(
                estimatedArrival.year,
                estimatedArrival.month,
                estimatedArrival.day,
                estimatedArrival.hour,
                estimatedArrival.minute,
                activity.nWaitTime),
            EnumDateTimeFormat.hhmma.value,
            false);
      }

      final actualArrival = activity.dateActualArrival;
      if (actualArrival == null) {
        _txtActualTime = "N/A";
      } else {
        _txtActualTime = UtilsDate.getStringFromDateTimeWithFormat(
            actualArrival, EnumDateTimeFormat.hhmma.value, false);
      }

      // show waitTime if it's greater than 10 mins
      if (activity.nWaitTime >= 600) {
        _txtWaitTime = "WAIT: ${activity.nWaitTime / 60} MINS";
      } else {
        _txtWaitTime = "";
      }

      _txtPickup = "";
      _txtDropOff = "";

      if (activity.isStartingDepot) {
        _txtPickup = "Starting Location";
      } else if (activity.isEndingDepot) {
        _txtDropOff = "Ending Depot";
      } else {
        if (activity.getPickupCount() > 0) {
          _txtPickup = "Pick -up";
        }
        if (activity.getDropOffCount() > 0) {
          _txtDropOff = "Drop-off";
        }
      }
    });
    _refreshButtons();
  }

  _refreshButtons() {
    setState(() {
      if (widget.modelActivity?.enumStatus == EnumActivityStatus.arrived) {
        _txtAction = "Arrived";
      } else if (widget.modelActivity?.enumStatus ==
          EnumActivityStatus.cancelled) {
        _txtAction = "Cancelled";
      } else if (widget.modelActivity?.enumStatus ==
          EnumActivityStatus.enRoute) {
        _txtAction = "Mark As Arrived";
      } else if (!_isValidToStartRide()) {
        if (_shouldSkipForNextRide()) {
          _txtAction = "Skip Ride";
        } else {
          _txtAction = "Back";
        }
      } else if (widget.modelActivity?.enumStatus ==
          EnumActivityStatus.scheduled) {
        _txtAction = "Start Ride";
      }
    });
  }

  _startRide() {
    final index = widget.modelRoute?.getIndexForNextActivityToStartRide();
    if (index == null) {
      onBackPressed();
      return;
    }
    final nextActivity = widget.modelRoute!.arrayActivities[index];
    if (nextActivity.isAllNoShow() && !nextActivity.isEndingDepot) {
      showProgressHUD();
      TransportRouteManager.sharedInstance.requestUpdateActivityStatus(
          widget.modelRoute!, nextActivity, EnumActivityStatus.arrived,
          (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess || responseDataModel.isOffline) {
          if (responseDataModel.isOffline) {
            TransportRouteManager.sharedInstance.startRideOffline(
                widget.modelRoute!, nextActivity, EnumActivityStatus.arrived);
          }
          _reloadRouteData();
          _moveToNextRide();
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      showProgressHUD();
      TransportRouteManager.sharedInstance.requestUpdateActivityStatus(
          widget.modelRoute!, nextActivity, EnumActivityStatus.enRoute,
          (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess || responseDataModel.isOffline) {
          if (responseDataModel.isOffline) {
            TransportRouteManager.sharedInstance.startRideOffline(
                widget.modelRoute!, nextActivity, EnumActivityStatus.enRoute);
          }
          _reloadRouteData();
          _refreshButtons();
          if (!_checkIfArrived()) {
            if (widget.modelActivity!.arrayInstructions.isNotEmpty) {
              _showDialogForInstructions();
            } else {
              _promptForOpenNavigationApps(widget.modelActivity!.geoLocation);
            }
          }
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    }
  }

  _moveToNextRide() {
    _isArrivalDetected = false;
    _isManuallyArrived = false;

    final index = widget.modelRoute?.getIndexForNextActivityToStartRide();
    if (index == null) {
      onBackPressed();
      return;
    }
    widget.indexActivity = index;

    if (widget.indexActivity < widget.modelRoute!.arrayActivities.length) {
      widget.modelActivity =
          widget.modelRoute!.arrayActivities[widget.indexActivity];
      _addStopPins();
      _reloadData();
      _refreshFields();
      showToast("Your next ride is ready");
    } else {
      onBackPressed();
    }
  }

  markActivityAsArrived(bool isManual) {
    _isManuallyArrived = isManual;
    showProgressHUD();
    TransportRouteManager.sharedInstance.requestUpdateActivityStatus(
        widget.modelRoute!, widget.modelActivity!, EnumActivityStatus.arrived,
        (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess || responseDataModel.isOffline) {
        if (responseDataModel.isOffline) {
          TransportRouteManager.sharedInstance
              .markAsArrivedOffline(widget.modelRoute!, widget.modelActivity!);
        }
        _reloadRouteData();
        _refreshButtons();
        if (widget.modelActivity!.isAllNoShow()) {
          _moveToNextRide();
        } else {
          _showDialogForConfirmPayloads();
        }
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  bool _isValidToStartRide() {
    // Check if we can start current location or not...
    final index = widget.modelRoute?.getIndexForNextActivityToStartRide();
    if (index == null) return false;
    return (index == widget.indexActivity);
  }

  bool _shouldSkipForNextRide() {
    // Check if we need to skip current location and look for next location...
    final index = widget.modelRoute?.getIndexForNextActivityToStartRide();
    if (index == null) return false;
    return (index > widget.indexActivity);
  }

  bool _checkIfArrived() {
    return LCLocationManager.sharedInstance.checkArrivalProbability(
        widget.modelActivity!.geoLocation.getCoordinates());
  }

  _reloadRouteData() {
    if (widget.modelRoute!.outdated) {
      final route = TransportRouteManager.sharedInstance
          .getRouteById(widget.modelRoute!.id);
      if (route == null) return;
      final index = route.getIndexForActivityById(widget.modelActivity!.id);
      if (index == null) return;
      widget.modelRoute = route;
      widget.indexActivity = index;
      widget.modelActivity = route.arrayActivities[index];
    }
  }

  _showDialogForConfirmPayloads() {
    final route = widget.modelRoute;
    if (route == null) return;
    final activity = widget.modelActivity;
    if (activity == null) return;
    Navigator.push(
      context,
      createRoute(RouteConfirmRiderListScreen(
          modelRoute: route,
          modelActivity: activity,
          isManuallyArrived: _isManuallyArrived,
          listener: this)),
    );
  }

  _promptForOpenNavigationApps(LocationDataModel location) {
    final preference =
        AppManager.sharedInstance.modelSettings.enumMapPreference;
    if (preference == EnumSettingMapViewPreference.waze) {
      _openWaze(location);
    } else if (preference == EnumSettingMapViewPreference.googleMaps) {
      UtilsMap.launchMap(context, location.fLatitude, location.fLongitude);
      //_openGoogleMaps(location);
    } else if (preference == EnumSettingMapViewPreference.hereWeGo) {
      _openHereWeGo(location);
    } else if (preference == EnumSettingMapViewPreference.appleMaps) {
      _openAppleMaps(location);
    } else {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            margin: AppDimens.kMarginSmall,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: AppDimens.kVerticalMarginNormal,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.navigation,
                        textAlign: TextAlign.center,
                        style: AppStyles.boldText
                            .copyWith(color: AppColors.hintColor),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        AppStrings.pleaseSelectNavApp,
                        textAlign: TextAlign.center,
                        style: AppStyles.hintText,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0.5, color: Colors.transparent),
                Container(
                  color: Colors.white,
                  child: ListTile(
                    title: const Text(
                      AppStrings.wazeApp,
                      textAlign: TextAlign.center,
                      style: AppStyles.bottomMenuText,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      AppManager
                              .sharedInstance.modelSettings.enumMapPreference =
                          EnumSettingMapViewPreference.waze;
                      AppManager.sharedInstance.saveToLocalStorage();
                      _openWaze(location);
                    },
                  ),
                ),
                const Divider(height: 0.5, color: Colors.transparent),
                Container(
                  color: Colors.white,
                  child: ListTile(
                    title: const Text(
                      AppStrings.googleMapsApp,
                      textAlign: TextAlign.center,
                      style: AppStyles.bottomMenuText,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      AppManager
                              .sharedInstance.modelSettings.enumMapPreference =
                          EnumSettingMapViewPreference.googleMaps;
                      AppManager.sharedInstance.saveToLocalStorage();
                      //_openGoogleMaps(location);
                      UtilsMap.launchMap(context, location.fLatitude, location.fLongitude);
                    },
                  ),
                ),
                const Divider(height: 0.5, color: Colors.transparent),
                Visibility(
                  visible: Platform.isIOS,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                      ),
                    ),
                    child: ListTile(
                      title: const Text(
                        AppStrings.appleMapsApp,
                        textAlign: TextAlign.center,
                        style: AppStyles.bottomMenuText,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        AppManager.sharedInstance.modelSettings
                                .enumMapPreference =
                            EnumSettingMapViewPreference.appleMaps;
                        AppManager.sharedInstance.saveToLocalStorage();
                        _openAppleMaps(location);
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: Platform.isAndroid,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                      ),
                    ),
                    child: ListTile(
                      title: const Text(
                        AppStrings.hereWeGoApp,
                        textAlign: TextAlign.center,
                        style: AppStyles.bottomMenuText,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        AppManager.sharedInstance.modelSettings
                                .enumMapPreference =
                            EnumSettingMapViewPreference.hereWeGo;
                        AppManager.sharedInstance.saveToLocalStorage();
                        _openHereWeGo(location);
                      },
                    ),
                  ),
                ),
                const Divider(height: 8, color: Colors.transparent),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    ),
                  ),
                  child: ListTile(
                    title: const Text(
                      AppStrings.buttonCancel,
                      textAlign: TextAlign.center,
                      style: AppStyles.bottomMenuCancelText,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  _openWaze(LocationDataModel location) async {
    String wazeUrl =
        "waze://?ll=${location.fLatitude}latitude,${location.fLongitude}&navigate=yes";
    var uri = Uri.encodeFull(wazeUrl);
    if (await canLaunchUrl(Uri.parse(uri))) {
      await launchUrl(Uri.parse(uri));
    } else {
      showToast("Waze App not found.");
    }
  }

  _openGoogleMaps(LocationDataModel location) async {
    final arrayWayPoints = widget.modelActivity!.arrayWaypoints;
    final originPoint = widget
        .modelRoute!.arrayActivities[widget.indexActivity - 1].geoLocation;
    String googleUrl;
    if (Platform.isAndroid) {
      googleUrl = "google.navigation:q=${originPoint.fLatitude},${originPoint.fLongitude}"
          "&destination=${location.fLatitude},"
          " ${location.fLongitude}&waypoints=${arrayWayPoints.map((e) =>
      "${e.latitude}, ${e.longitude}").join("|")}&travelmode=driving";
    } else {
      googleUrl = "comgooglemaps://?saddr=&daddr=${originPoint.fLatitude}, ${originPoint.fLongitude}"
          "&destination=${originPoint.fLatitude}, ${originPoint.fLongitude}&travelmode=driving";

      //url = 'https://maps.apple.com/?q=$lat,$lng';
    }

   /* String googleUrl =
        "comgooglemaps://?saddr=&daddr=${originPoint.fLatitude}, "
        "${originPoint.fLongitude}&destination=${location.fLatitude},"
        " ${location.fLongitude}&waypoints=${arrayWayPoints.map((e) =>
    "${e.latitude}, ${e.longitude}").join("|")}&travelmode=driving";
*/
    //String googleUrl = 'https://www.google.com/maps/search/?api=1&query=${originPoint.fLatitude},${originPoint.fLongitude}';
    //String googleUrl = "comgooglemaps://?saddr=&daddr=${originPoint.fLatitude},${originPoint.fLongitude}&directionsmode=driving";

    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(
        Uri.parse(googleUrl),
      );
    } else {
      showToast("Google Maps App not found.");
    }

   /* print("Google maps link--> "+googleUrl);
    var uri = Uri.encodeFull(googleUrl);
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      showToast("Google Maps App not found.");
    }*/
  }

  _openHereWeGo(LocationDataModel location) async {
    String hereWoGoUrl =
        "here.directions://v1.0/mylocation/${location.fLatitude},${location.fLongitude}?m=w";
    var uri = Uri.encodeFull(hereWoGoUrl);
    if (await canLaunchUrl(Uri.parse(uri))) {
      await launchUrl(Uri.parse(uri));
    } else {
      showToast("HERE WeGo App not found.");
    }
  }

  _openAppleMaps(LocationDataModel location) async {
    String appleUrl =
        "https://maps.apple.com/?q=${location.fLatitude},${location.fLongitude}";
    var uri = Uri.encodeFull(appleUrl);
    if (await canLaunchUrl(Uri.parse(uri))) {
      await launchUrl(Uri.parse(uri));
    } else {
      showToast("Apple Maps App not found.");
    }
  }

  _showDialogForPayloadDetails(int index, PayloadDataModel payload) {
    if (index >= _arrayFilteredPayloads.length) return;
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          RouteRiderDetailsPopupDialog(modelPayload: payload),
    );
  }

  _showDialogForInstructions() {
    final activity = widget.modelActivity;
    if (activity == null) return;
    final route = widget.modelRoute;
    if (route == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) => RouteInstructionsPopupDialog(
          modalLocationFrom:
              route.arrayActivities[widget.indexActivity - 1].geoLocation,
          modalLocationTo: activity.geoLocation,
          arrayInstructions: activity.arrayInstructions),
    );
  }

  _onButtonActionClick() {
    final activity = widget.modelActivity;
    if (activity == null) return;
    if (!activity.isActive() || !_isValidToStartRide()) {
      onBackPressed();
    } else if (activity.enumStatus == EnumActivityStatus.scheduled) {
      _startRide();
    } else if (activity.enumStatus == EnumActivityStatus.enRoute) {
      UtilsBaseFunction.showAlertWithMultipleButton(
          context,
          "Confirmation",
          "Are you sure you arrived at stop?",
          () => markActivityAsArrived(true));
    } else if (activity.enumStatus == EnumActivityStatus.arrived) {
      _showDialogForConfirmPayloads();
    }
  }

  @override
  didRouteConfirmRiderScreenCancelClick() {}

  @override
  didRouteConfirmRiderScreenDoneClick() {
    _reloadRouteData();
    _moveToNextRide();
  }

  _onLocationChanged() {
    // Request permission to use location
    locationManager.requestPermission().then((permissionStatus) {
      if (permissionStatus == PermissionStatus.granted) {
        // If granted listen to the onLocationChanged stream and emit over our controller
        locationManager.onLocationChanged.listen((locationData) {
          final activity = widget.modelActivity;
          if (activity == null) return;
          if (activity.enumStatus == EnumActivityStatus.enRoute &&
              !_isArrivalDetected) {
            if (_checkIfArrived()) {
              _isArrivalDetected = true;
              markActivityAsArrived(false);
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _reloadMap();
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            AppStrings.titleRideDetails,
            style: AppStyles.textCellHeaderStyle,
          ),
          actions: <Widget>[
            Padding(
              padding: AppDimens.kHorizontalMarginBig.copyWith(left: 0),
              child: Row(
                children: [
                  Visibility(
                    visible: widget.modelActivity!.arrayInstructions.isNotEmpty,
                    child: GestureDetector(
                      onTap: () {
                        _showDialogForInstructions();
                      },
                      child: Image.asset(
                          "assets/images/baseline_multiple_stop_white.png",
                          width: 24,
                          height: 24),
                    ),
                  ),
                  Visibility(
                    visible: widget.modelActivity!.arrayInstructions.isEmpty,
                    child: GestureDetector(
                      onTap: () {
                        _promptForOpenNavigationApps(widget.modelActivity!.geoLocation);
                      },
                      child: Image.asset("assets/images/ic_navigation.png",
                          width: 24, height: 24),
                    ),
                  )
                ],
              ),
            )
          ]),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 78,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: _googleMap,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          color: AppColors.profileBackground,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.separatorLineGray,
                              blurRadius: 3.0,
                            ),
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: Column(
                        children: [
                          Container(
                            padding: AppDimens.kMarginNormal,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      child: Text("Type",
                                          style: AppStyles.textCellTextStyle
                                              .copyWith(
                                                  color: AppColors.textGray)),
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                    Text("Location",
                                        style: AppStyles.textCellTextStyle
                                            .copyWith(
                                                color: AppColors.textGray)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Visibility(
                                      child: SizedBox(
                                        child: Text("Pickup",
                                            style: AppStyles.boldText.copyWith(
                                                color: AppColors.purpleColor)),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                      ),
                                      visible: _txtPickup.isNotEmpty,
                                    ),
                                    Visibility(
                                      child: SizedBox(
                                        child: Text("Drop-off",
                                            style: AppStyles.boldText.copyWith(
                                                color: AppColors.primaryColor)),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                      ),
                                      visible: _txtDropOff.isNotEmpty,
                                    ),
                                    Expanded(
                                      child: Text(_txtAddress,
                                          softWrap: true,
                                          style: AppStyles
                                              .textCellTitleBoldStyle
                                              .copyWith(
                                                  color:
                                                      AppColors.textGrayDark)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    SizedBox(
                                      child: Text("Schedule Time",
                                          style: AppStyles.textCellTextStyle
                                              .copyWith(
                                                  color: AppColors.textGray)),
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                    Expanded(
                                      child: Visibility(
                                        visible: _txtWaitTime.isNotEmpty,
                                        child: Text(
                                          "Wait Time",
                                          style: AppStyles.textCellTextStyle
                                              .copyWith(
                                                  color: AppColors.textGray),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    SizedBox(
                                      child: Text(_txtTime,
                                          style: AppStyles
                                              .textCellTitleBoldStyle
                                              .copyWith(
                                                  color:
                                                      AppColors.textGrayDark)),
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                    Expanded(
                                      child: Visibility(
                                        visible: _txtWaitTime.isNotEmpty,
                                        child: Text(_txtWaitTime,
                                            softWrap: true,
                                            style: AppStyles
                                                .textCellTitleBoldStyle
                                                .copyWith(
                                                    color: AppColors
                                                        .textGrayDark)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Actual Time",
                                            style: AppStyles.textCellTextStyle
                                                .copyWith(
                                                    color: AppColors.textGray)),
                                        const SizedBox(height: 8),
                                        Text(_txtActualTime,
                                            softWrap: true,
                                            style: AppStyles
                                                .textCellTitleBoldStyle
                                                .copyWith(
                                                    color: AppColors
                                                        .textGrayDark)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Riders",
                                      textAlign: TextAlign.left,
                                      style: AppStyles.textCellTextStyle
                                          .copyWith(color: AppColors.textGray)),
                                ),
                              ],
                            ),
                          ),
                          RouteLocationUserListView(
                            arrayPayloads: _arrayFilteredPayloads,
                            itemClickListener: (payload, position) {
                              _showDialogForPayloadDetails(position, payload);
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
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
          ],
        ),
      ),
    );
  }
}
