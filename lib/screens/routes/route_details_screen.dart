import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livecare/components/listView/route_location_listview.dart';
import 'package:livecare/listeners/outcome_result_listener.dart';
import 'package:livecare/listeners/route_form_listener.dart';
import 'package:livecare/listeners/route_odometer_listener.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/form/dataModel/form_definition_data_model.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/models/form/dataModel/form_submission_data_model.dart';
import 'package:livecare/models/form/form_manager.dart';
import 'package:livecare/models/route/dataModel/activity_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/route/transport_route_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/forms/form_list_screen.dart';
import 'package:livecare/screens/routes/odometer_popup_dialog.dart';
import 'package:livecare/screens/routes/route_outcome_result_list_screen.dart';
import 'package:livecare/screens/routes/route_ride_details_screen.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_config.dart';
import 'package:livecare/utils/utils_map.dart';

// ignore: must_be_immutable
class RouteDetailsScreen extends BaseScreen {
  RouteDataModel? modelRoute;
  bool isRouteStarted;

  RouteDetailsScreen({Key? key, required this.modelRoute, required this.isRouteStarted}) : super(key: key);

  @override
  _RouteDetailsScreenState createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends BaseScreenState<RouteDetailsScreen> with RouteFormListener, OutcomeResultListener, RouteOdometerListener {
  GoogleMap? _googleMap;
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  final Set<Polyline> _polyline = <Polyline>{};
  String _txtAction = "Start";

  @override
  void initState() {
    super.initState();
    _refreshButtons();
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
  }

  _refreshButtons() {
    final route = widget.modelRoute;
    if (route == null) return;

    setState(() {
      if (route.isCompleted()) {
        _txtAction = "Finished Route";
      } else if (route.shouldAskPostForms()) {
        _txtAction = "Submit Post-Forms";
      } else if (route.shouldAskOutcome()) {
        _txtAction = "Submit Outcomes";
      } else if (route.isReadyToComplete()) {
        _txtAction = "Complete Route";
      } else if (!route.isActiveRoute()) {
        _txtAction = "Back";
      } else if (route.enumStatus == EnumRouteStatus.enRoute) {
        _txtAction = "Resume Route";
      } else {
        _txtAction = "Start Route";
      }
    });
  }

  _showDialogForPostFormsScreen() {
    final route = widget.modelRoute;
    if (route == null) return;
    Navigator.push(
      context,
      createRoute(FormListScreen(arrayForms: route.arrayPostFormRefs, listener: this)),
    );
  }

  _showDialogForSubmitOutcomeResult() {
    final route = widget.modelRoute;
    if (route == null) return;
    Navigator.push(
      context,
      createRoute(OutcomeResultListScreen(modelRoute: route, listener: this)),
    );
  }

  _onButtonActionClick() {
    final route = widget.modelRoute;

    if (route == null) return;
    if (!route.isActiveRoute()) {
      onBackPressed();
    } else if (route.shouldAskPostForms()) {
      _showDialogForPostFormsScreen();
    } else if (route.shouldAskOutcome()) {
      _showDialogForSubmitOutcomeResult();
    } else if (route.isReadyToComplete()) {
      _completeRoute();
    } else if (route.enumStatus == EnumRouteStatus.scheduled) {
      _checkFormsBeforeStartRoute();
      /* if (widget.isRouteStarted) {
        UtilsBaseFunction.showAlert(context, "Warning",
            "There's another active route. Please finish that route before starting a new one");
      } else if (route.isFutureRoute()) {
       UtilsBaseFunction.showAlert(context, "Warning",
            "This route cannot be started.  Please try again closer to the route start time.");
      } else {
        _checkFormsBeforeStartRoute();
      }*/
    } else if (route.enumStatus == EnumRouteStatus.enRoute) {
      _resumeRoute();
    }
  }

  _completeRoute() {
    final route = widget.modelRoute;
    if (route == null) return;

    showProgressHUD();
    TransportRouteManager.sharedInstance.requestCompleteRoute(route, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess || responseDataModel.isOffline) {
        if (responseDataModel.isOffline) {
          TransportRouteManager.sharedInstance.completeRouteOffline(route);
        }
        _updateRoute();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _checkFormsBeforeStartRoute() {
    final route = widget.modelRoute;
    if (route == null) return;

    if (route.arrayPreFormRefs.isEmpty) {
      _promptForOdometerBeforeStartRoute();
    } else {
      _showDialogForPreFormsScreen();
    }
  }

  _showDialogForPreFormsScreen() {
    final route = widget.modelRoute;
    if (route == null) return;
    Navigator.push(
      context,
      createRoute(FormListScreen(arrayForms: route.arrayPreFormRefs, listener: this)),
    );
  }

  _promptForOdometerBeforeStartRoute() {
    final route = widget.modelRoute;
    if (route == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) => OdometerPopupDialog(modelRoute: route, popupListener: this),
    );
  }

  _updateRoute() {
    final route = widget.modelRoute;
    if (route == null) return;
    if (route.outdated) {
      final updatedRoute = TransportRouteManager.sharedInstance.getRouteById(route.id);
      if (updatedRoute != null) {
        widget.modelRoute = updatedRoute;
        _refreshButtons();
      }
    }
  }

  _startRoute() {
    final route = widget.modelRoute;
    if (route == null) return;
    if (route.enumStatus == EnumRouteStatus.enRoute) {
      _resumeRoute();
      return;
    }

    showProgressHUD();
    TransportRouteManager.sharedInstance.requestStartRoute(route, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess || responseDataModel.isOffline) {
        if (responseDataModel.isOffline) {
          TransportRouteManager.sharedInstance.startRouteOffline(route);
        }
        _updateRoute();
        _resumeRoute(shouldOpenMapApp: true);
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _resumeRoute({bool shouldOpenMapApp = false}) {
    final route = widget.modelRoute;
    if (route == null) return;

    if (route.getIndexForNextActivityToStartRide() == null) {
      onBackPressed();
      return;
    }
    final int index = route.getIndexForNextActivityToStartRide()!;
    final nextActivity = route.arrayActivities[index];
    if (nextActivity.isAllNoShow() && !nextActivity.isEndingDepot) {
      showProgressHUD();
      TransportRouteManager.sharedInstance.requestUpdateActivityStatus(route, nextActivity, EnumActivityStatus.arrived, (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess || responseDataModel.isOffline) {
          _updateRoute();
          _resumeRoute();
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      _updateRoute();
      _gotoRideDetailsScreen(index, shouldOpenMapApp: shouldOpenMapApp);
    }
  }

  _gotoRideDetailsScreen(int index, {bool shouldOpenMapApp = false}) {
    final route = widget.modelRoute;
    if (route == null) return;
    Navigator.push(
      context,
      createRoute(
          RouteRideDetailsScreen(modelRoute: route, modelActivity: route.arrayActivities[index], indexActivity: index, shouldOpenMapApp: shouldOpenMapApp)),
    ).then((value) {
      final route = widget.modelRoute;
      if (route == null) return;
      if (route.outdated) {
        if (TransportRouteManager.sharedInstance.getRouteById(route.id) == null) {
          onBackPressed();
        } else {
          final updatedRoute = TransportRouteManager.sharedInstance.getRouteById(route.id);
          widget.modelRoute = updatedRoute;
          _refreshButtons();
        }
      }
    });
  }

  @override
  didOdometerPopupOkClick(double odometer) {
    final route = widget.modelRoute;
    if (route == null) return;
    widget.modelRoute!.fOdometerStart = odometer;
    _startRoute();
  }

  @override
  didRouteOutcomeResultScreenCancelClick() {}

  @override
  didRouteOutcomeResultScreenDoneClick() {
    final route = widget.modelRoute;
    if (route == null) return;
    if (route.isReadyToComplete()) {
      _completeRoute();
    } else {
      _refreshButtons();
    }
  }

  @override
  onPressedCancel() {}

  @override
  onPressedSubmitForm() {
    final route = widget.modelRoute;
    if (route == null) return;
    if (route.enumStatus == EnumRouteStatus.scheduled) {
      _promptForOdometerBeforeStartRoute();
    } else {
      if (route.shouldAskOutcome()) {
        _showDialogForSubmitOutcomeResult();
      } else if (route.isReadyToComplete()) {
        _completeRoute();
      } else {
        _refreshButtons();
      }
    }
  }

  @override
  requestFormsListScreenGetSubmission(FormRefDataModel formRef, NetworkManagerResponse callback) {
    final route = widget.modelRoute;
    if (route == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    FormManager.sharedInstance.requestGetRouteFormById(formRef.formId, false, (responseDataModel) {
      if (responseDataModel.isSuccess || responseDataModel.isOffline) {
        final formDef = responseDataModel.parsedObject as FormDefinitionDataModel?;
        if (formRef.submissionId.isNotEmpty && !responseDataModel.isOffline) {
          FormManager.sharedInstance.requestGetRouteFormSubmissionById(route.id, formRef.formId, formRef.submissionId, callback);
        } else {
          final submission = FormSubmissionDataModel().instanceFromFormDefinition(formDef!);
          responseDataModel.parsedObject = submission;
          callback.call(responseDataModel);
        }
      } else {
        callback.call(responseDataModel);
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  @override
  requestFormsListScreenCreateSubmission(FormRefDataModel formRef, FormSubmissionDataModel submission, NetworkManagerResponse callback) {
    final route = widget.modelRoute;
    if (route == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    FormManager.sharedInstance.requestCreateRouteFormSubmission(route, formRef, submission, callback);
  }

  @override
  requestFormsListScreenUpdateSubmission(FormRefDataModel formRef, FormSubmissionDataModel submission, NetworkManagerResponse callback) {
    final route = widget.modelRoute;
    if (route == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    FormManager.sharedInstance.requestUpdateRouteFormSubmission(route, formRef, submission, callback);
  }

  @override
  requestFormsListScreenUploadPhoto(FormRefDataModel formRef, File image, NetworkManagerResponse callback) {
    final route = widget.modelRoute;
    if (route == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    FormManager.sharedInstance.requestUploadPhotoForRoute(route, formRef, image, callback);
  }

  @override
  Widget build(BuildContext context) {
    String _txtType = widget.modelRoute!.enumType.value.toString();
    _reloadMap();
    return Scaffold(
      backgroundColor: AppColors.profileFrame,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.titleTripPlan,
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
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: _googleMap,
                ),
                Expanded(
                  child: RouteLocationListView(
                    arrayLocations: widget.modelRoute!.arrayActivities,
                    itemClickListener: (activity, position) {
                      _gotoRideDetailsScreen(position + 1);
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
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
