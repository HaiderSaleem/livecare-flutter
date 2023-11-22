import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livecare/listeners/request_confirm_task_listener.dart';
import 'package:livecare/listeners/request_note_popup_listener.dart';
import 'package:livecare/listeners/route_form_listener.dart';
import 'package:livecare/listeners/vehicle_popup_listener.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/form/dataModel/form_definition_data_model.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/models/form/dataModel/form_submission_data_model.dart';
import 'package:livecare/models/form/form_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/dataModel/task_data_model.dart';
import 'package:livecare/models/request/service_request_manager.dart';
import 'package:livecare/models/route/dataModel/activity_data_model.dart';
import 'package:livecare/models/route/dataModel/payload_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/route/service_route_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/base/main_screen.dart';
import 'package:livecare/screens/consumers/consumer_documents_list_screen.dart';
import 'package:livecare/screens/forms/form_list_screen.dart';
import 'package:livecare/screens/serviceRequests/request_note_popup_dialog.dart';
import 'package:livecare/screens/serviceRequests/service_requests_confirm_tasks_screen.dart';
import 'package:livecare/screens/serviceRoute/service_route_vehicle_popup_dialog.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_map.dart';
import 'package:location/location.dart';

// ignore: must_be_immutable
class ServiceRoutesRequestDetailsScreen extends BaseScreen {
  RouteDataModel? modelRoute;
  int indexActivity = 0;
  bool? isRouteStarted;

  ServiceRoutesRequestDetailsScreen({Key? key, required this.modelRoute, required this.indexActivity, this.isRouteStarted}) : super(key: key);

  @override
  _ServiceRoutesRequestDetailsScreenState createState() => _ServiceRoutesRequestDetailsScreenState();
}

class _ServiceRoutesRequestDetailsScreenState extends BaseScreenState<ServiceRoutesRequestDetailsScreen>
    with ServiceRoutesVehiclePopupListener, RouteFormListener, RequestNotePopupListener, RequestConfirmTaskListener {
  GoogleMap? _googleMap;
  ActivityDataModel? _modelActivity;
  RequestDataModel? _modelRequest;
  bool _isTaskListUpdated = false;
  bool _isFormsUpdated = false;
  bool _isOutcomeUpdated = false;
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  bool _mapView = true;
  String _txtConsumer = "";
  String _txtTime = "";
  String _txtStatus = "";
  String _txtDuration = "";
  String _txtVehicle = "";
  String _txtAddress = "";
  String _txtRequestDescription = "";
  String _txtConsumerNotes = "";
  bool _viewTasks = false;
  String _txtTasks = "";
  bool _viewForms = false;
  String _txtForms = "";
  bool _viewDocuments = false;
  String _txtDocuments = "";
  bool _viewOutcomeNotes = false;
  bool _viewAction = false;
  String _txtAction = "Start";
  Location locationManager = Location();
  ButtonStyle _buttonStyle = ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor).merge(AppStyles.roundButtonStyle);

  @override
  void initState() {
    super.initState();
    _refreshFields();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestGetRequestDetails();
    });
  }

  _initializeActivity() {
    _modelActivity = null;
    _modelRequest = null;
    _isTaskListUpdated = false;
    _isFormsUpdated = false;
    _isOutcomeUpdated = false;
  }

  _requestGetRequestDetails() {
    _initializeActivity();
    final route = widget.modelRoute;
    if (route == null) return;
    _modelActivity = route.arrayActivities[widget.indexActivity];

    final String requestId;
    if (_modelActivity!.arrayPayloads.isNotEmpty) {
      requestId = _modelActivity!.arrayPayloads.first.requestId;
    } else {
      return;
    }

    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      showProgressHUD();
      ServiceRequestManager.sharedInstance.requestGetRequestForMe(requestId, true, (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess && responseDataModel.parsedObject != null) {
          final request = responseDataModel.parsedObject as RequestDataModel;
          _modelRequest = request;
          _refreshFields();
          _refreshActionButtonPanel();
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      //Call API with null callback to queue request
      ServiceRequestManager.sharedInstance.requestGetRequestForMe(requestId, true, null);
      _modelRequest = ServiceRequestManager.sharedInstance.getRequestById(requestId);
      if (_modelRequest == null) {
        showToast("Unable to get request. Please check your internet connection.");
      }
    }
  }

  _refreshFields() {
    final request = _modelRequest;
    if (request == null) return;
    if (_modelActivity == null) return;
    if (_modelActivity!.arrayPayloads.isEmpty) return;

    final payload = _modelActivity!.arrayPayloads.first;

    setState(() {
      if (request.refLocation.isValid()) {
        _mapView = true;
      } else {
        _mapView = false;
      }

      _txtConsumer = request.refConsumer.szName;
      _txtTime =
          "${UtilsDate.getStringFromDateTimeWithFormat(request.dateTime, EnumDateTimeFormat.MMMdyyyy.value, false)}, ${UtilsDate.getStringFromDateTimeWithFormat(request.dateTime, EnumDateTimeFormat.hhmma.value, false)}";

      _txtStatus = payload.enumStatus.value.toUpperCase();
      _txtDuration = request.getBeautifiedDuration();
      _txtVehicle = "N/A";
      final vehicleName = widget.modelRoute?.refVehicle?.szName;
      if (vehicleName != null && vehicleName.isNotEmpty) {
        _txtVehicle = vehicleName;
      }

      _txtAddress = "N/A";
      if (request.refLocation.isValid() && request.refLocation.szAddress.isNotEmpty) {
        _txtAddress = request.refLocation.szAddress;
      }

      if (request.enumType == EnumRequestType.serviceOther) {
        if (request.szAssignmentType.isEmpty) {
          _txtRequestDescription = "N/A";
        } else {
          _txtRequestDescription = request.szAssignmentType;
        }

        if (request.szDescription.isEmpty) {
          _txtConsumerNotes = "N/A";
        } else {
          _txtConsumerNotes = request.szDescription;
        }
      } else {
        if (request.szDescription.isEmpty) {
          _txtRequestDescription = "N/A";
        } else {
          _txtRequestDescription = request.szDescription;
        }

        if (request.refConsumer.szNotes.isEmpty) {
          _txtConsumerNotes = "N/A";
        } else {
          _txtConsumerNotes = request.refConsumer.szNotes;
        }
      }
    });
    _refreshStackView();
    _refreshActionButtonPanel();
    _addStopPins();
  }

  _refreshStackView() {
    final request = _modelRequest;
    if (request == null) return;

    setState(() {
      if (request.arrayTasks.isEmpty) {
        _viewTasks = false;
      } else {
        _viewTasks = true;
        final int nCompleted = request.arrayTasks.where((element) => element.enumStatus == EnumTaskStatus.completed).length;
        final int nAll = request.arrayTasks.length;
        _txtTasks = "Task Checklist ($nCompleted/$nAll)";
      }

      if (request.arrayForms.isEmpty) {
        _viewForms = false;
      } else {
        _viewForms = true;
        final nCompleted = request.arrayForms.where((element) => element.submissionId.isNotEmpty).length;
        final int nAll = request.arrayForms.length;
        _txtForms = "Forms ($nCompleted/$nAll)";
      }

      if (request.isRequiresOutcome) {
        _viewOutcomeNotes = true;
      } else {
        _viewOutcomeNotes = false;
      }

      final consumer = ConsumerManager.sharedInstance.getConsumerById(request.refConsumer.consumerId);
      if (consumer == null) return;
      if (consumer.arrayDocuments.isNotEmpty) {
        _viewDocuments = true;
        _txtDocuments = "Documents (${consumer.arrayDocuments.length})";
      } else {
        _viewDocuments = false;
      }
    });
  }

  _refreshActionButtonPanel() {
    final request = _modelRequest;
    if (request == null) return;

    setState(() {
      if (widget.modelRoute?.enumStatus != EnumRouteStatus.enRoute && widget.modelRoute?.enumStatus != EnumRouteStatus.inProgress) {
        _viewAction = false;
        return;
      }
      if (request.enumStatus == EnumRequestStatus.completed && !_isValidToStartActivity()) {
        _viewAction = false;
      } else {
        _viewAction = true;
        if (request.enumStatus == EnumRequestStatus.inProgress) {
          _txtAction = "Complete";
          _buttonStyle = ElevatedButton.styleFrom(backgroundColor: AppColors.buttonRed).merge(AppStyles.roundButtonStyle);
        } else {
          _txtAction = "Start";
          _buttonStyle = ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor).merge(AppStyles.roundButtonStyle);
        }
      }
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
      markers: _markers.toSet(),
      initialCameraPosition: CameraPosition(
          zoom: UtilsMap.cameraZoom,
          tilt: UtilsMap.cameraTilt,
          bearing: UtilsMap.cameraBearing,
          target: widget.modelRoute!.arrayActivities[widget.indexActivity].geoLocation.getCoordinates()),
      onMapCreated: ((GoogleMapController controller) {
        _controller.complete(controller);
        _addStopPins();
      }),
    );
  }

  _addStopPins() async {
    final request = _modelRequest;
    if (request == null) return;
    BitmapDescriptor sourceIcon = BitmapDescriptor.fromBytes(await UtilsBaseFunction.getBytesFromAsset("assets/images/ic_map_pin_pink.png", 8));

    final GoogleMapController controller = await _controller.future;

    setState(() {
      _markers.add(Marker(markerId: const MarkerId('sourcePin'), position: request.refLocation.getCoordinates(), icon: sourceIcon));

      controller.animateCamera(CameraUpdate.newLatLngBounds(UtilsMap.boundsFromLatLngList(_markers.map((loc) => loc.position).toList()), 100));
    });
  }

  bool _validateForComplete() {
    final request = _modelRequest;
    if (request == null) return false;

    if (request.arrayTasks.isNotEmpty && !_isTaskListUpdated) {
      if (request.arrayTasks.where((element) => element.enumStatus == EnumTaskStatus.newTask).isNotEmpty) {
        showToast("Please update tasks list.");
        return false;
      }
    }
    if (request.arrayForms.isNotEmpty && !_isFormsUpdated) {
      if (request.arrayForms.where((element) => element.submissionId.isEmpty).isNotEmpty) {
        showToast("Please submit forms.");
        return false;
      }
    }
    if (request.isRequiresOutcome && !_isOutcomeUpdated) {
      showToast("Please update outcome note.");
      return false;
    }
    return true;
  }

  _showDialogForConfirmTasks() {
    final request = _modelRequest;
    if (request == null) return;
    if (request.arrayTasks.isEmpty) return;
    if (request.enumStatus == EnumRequestStatus.completed) return;
    Navigator.push(
      context,
      createRoute(ServiceRequestsConfirmTasksScreen(modelRequest: request, listener: this)),
    );
  }

  _showDialogForFormsScreen() {
    final request = _modelRequest;
    if (request == null) return;
    if (request.arrayForms.isEmpty) return;
    if (request.enumStatus == EnumRequestStatus.completed) return;
    Navigator.push(
      context,
      createRoute(FormListScreen(arrayForms: request.arrayForms, listener: this)),
    );
  }

  _showDialogForNotes() {
    final request = _modelRequest;
    if (request == null) return;
    if (request.enumStatus == EnumRequestStatus.completed) return;
    showDialog(
      context: context,
      builder: (BuildContext context) => RequestNotePopupDialog(szNotes: _modelActivity!.szOutcome, popupListener: this),
    );
  }

  _showDialogForConsumerDocuments() {
    final request = _modelRequest;
    if (request == null) return;
    final consumer = ConsumerManager.sharedInstance.getConsumerById(request.refConsumer.consumerId);
    if (consumer == null) return;
    if (consumer.arrayDocuments.isEmpty) return;
    Navigator.push(
      context,
      createRoute(ConsumerDocumentsListScreen(modelConsumer: consumer)),
    );
  }

  _showDialogForVehicleInformation() {
    var millage = 0.0;
    if (widget.indexActivity == 0) {
      millage = widget.modelRoute!.fOdometerStart;
    } else {
      millage = widget.modelRoute!.arrayActivities[widget.indexActivity - 1].fOdometer;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) => ServiceRoutesVehiclePopupDialog(
        fOdometerStart: millage,
        szLicensePlate: "",
        showLicensePlate: false,
        popupListener: this,
      ),
    );
  }

  _onButtonActionClick() {
    final request = _modelRequest;
    if (request == null) return;

    if (widget.modelRoute!.enumStatus != EnumRouteStatus.enRoute && widget.modelRoute!.enumStatus != EnumRouteStatus.inProgress) {
      return;
    }
    if (request.enumStatus == EnumRequestStatus.scheduled || request.enumStatus == EnumRequestStatus.enRoute) {
      _startActivity();
    } else if (request.enumStatus == EnumRequestStatus.inProgress) {
      if (_validateForComplete()) {
        _showDialogForVehicleInformation();
      }
    }
    _refreshFields();
  }

  _onButtonTasksClick() {
    _showDialogForConfirmTasks();
  }

  _onButtonFormsClick() {
    _showDialogForFormsScreen();
  }

  _onButtonDocumentsClick() {
    _showDialogForConsumerDocuments();
  }

  _onButtonOutcomeClick() {
    _showDialogForNotes();
  }

  _startActivity() {
    final route = widget.modelRoute;
    if (route == null) return;
    final activity = _modelActivity;
    if (activity == null) return;

    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      showProgressHUD();
      ServiceRouteManager.sharedInstance.requestUpdateActivityStatus(route, activity, EnumActivityStatus.arrived, (responseDataModel) {
        if (responseDataModel.isSuccess) {
          //_reloadRouteData();
          final String requestId;
          if (_modelActivity!.arrayPayloads.isNotEmpty) {
            requestId = _modelActivity!.arrayPayloads.first.requestId;
          } else {
            return;
          }

          if (NetworkReachabilityManager.sharedInstance.isConnected()) {
            ServiceRequestManager.sharedInstance.requestGetRequestForMe(requestId, true, (responseDataModel) {
              if (responseDataModel.isSuccess && responseDataModel.parsedObject != null) {
                final request = responseDataModel.parsedObject as RequestDataModel;
                _modelRequest = request;
                _refreshActionButtonPanel();
              } else {
                showToast(responseDataModel.beautifiedErrorMessage);
              }
            });
          }
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      //Call API with null callback to queue request
      ServiceRouteManager.sharedInstance.requestUpdateActivityStatus(route, activity, EnumActivityStatus.arrived, null);
      ServiceRouteManager.sharedInstance.startRideOffline(route, activity, EnumActivityStatus.arrived);
      _modelRequest?.enumStatus = EnumRequestStatus.inProgress;
      //_reloadRouteData();
    }
  }

  _completeActivity(bool consumerNoShow, String cancelReason) {
    final route = widget.modelRoute;
    if (route == null) return;
    final activity = _modelActivity;
    if (activity == null) return;

    for (var payload in activity.arrayPayloads) {
      if (consumerNoShow) {
        payload.enumStatus = EnumPayloadStatus.noShow;
        payload.cancelReason = cancelReason;
      } else {
        payload.enumStatus = EnumPayloadStatus.completed;
      }
    }

    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      ServiceRouteManager.sharedInstance.requestUpdatePayloads(route, activity, (responseDataModel) {
        if (responseDataModel.isSuccess) {
          //_updateRoute();
          _completeRoute();
          // _gotoMyScheduleListScreen();
          //_moveToNextActivity();
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      //Call API with null callback to queue request
      ServiceRouteManager.sharedInstance.requestUpdatePayloads(route, activity, null);
      ServiceRouteManager.sharedInstance.updatePayloadsOffline(route, activity);
      setState(() {
        _modelRequest?.enumStatus = EnumRequestStatus.completed;
      });
      _completeRoute();
    }
  }

  _updateRoute() {
    final route = widget.modelRoute;
    if (route == null) return;
    ServiceRouteManager.sharedInstance.requestGetRouteById(route.id, (responseDataModel) {
      if (responseDataModel.isSuccess) {
        hideProgressHUD();
        final updatedRoute = ServiceRouteManager.sharedInstance.getServiceRouteById(route.id);
        widget.modelRoute = updatedRoute;
        _gotoMyScheduleListScreen();
        /* if (ServiceRouteManager.sharedInstance.getServiceRouteById(route.id) == null) {
          showToast("Route is not found.");
        } else {
          print("Line 562");
          final updatedRoute = ServiceRouteManager.sharedInstance.getServiceRouteById(route.id);
          widget.modelRoute = updatedRoute;
          _gotoMyScheduleListScreen();
        }*/
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _gotoMyScheduleListScreen() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainScreen(fromServiceRoute: true)), (Route<dynamic> route) => false);
  }

/*
  _reloadRouteData() {
    final activity = _modelActivity;
    if (activity == null) return;

    if (widget.modelRoute!.outdated) {
      final route = ServiceRouteManager.sharedInstance
          .getServiceRouteById(widget.modelRoute!.id);
      if (route == null) {
        //onBackPressed();
        return;
      }
      final index = route.getIndexForActivityById(activity.id);
      if (index == null) {
       // onBackPressed();
        return;
      }
      widget.modelRoute = route;
      widget.indexActivity = index;
      //_requestGetRequestDetails();
    }
  }
*/

/*
  _moveToNextActivity() {
    if (widget.modelRoute!.outdated) {
      final route = ServiceRouteManager.sharedInstance.getServiceRouteById(widget.modelRoute!.id);
      if (route == null) {
        onBackPressed();
        //_gotoMyScheduleListScreen();

        return;
      } else {
        setState(() {
          widget.modelRoute = route;
        });
      }
    }

    final index = widget.modelRoute!.getIndexForNextActivityToStartRide();
    if (index == null) {
      onBackPressed();
      //_gotoMyScheduleListScreen();

      return;
    } else {
      if (index < widget.modelRoute!.arrayActivities.length) {
        widget.indexActivity = index;
        _requestGetRequestDetails();
      } else {
        onBackPressed();
        //_gotoMyScheduleListScreen();

      }
    }

  }
*/

  _completeRoute() {
    showProgressHUD();
    final route = widget.modelRoute;
    if (route == null) return;
    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      ServiceRouteManager.sharedInstance.requestCompleteRoute(route, (responseDataModel) {
        if (responseDataModel.isSuccess) {
          //_gotoMyScheduleListScreen();
          _updateRoute();
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      //Call API with null callback to queue request
      ServiceRouteManager.sharedInstance.requestCompleteRoute(route, null);
      ServiceRouteManager.sharedInstance.completeRouteOffline(route);
      // _reloadRouteData();
    }
  }

  bool _isValidToStartActivity() {
    // Check if we can start current activity or not...
    final index = widget.modelRoute?.getIndexForNextActivityToStartRide();
    if (index == null) return false;
    return (index == widget.indexActivity);
  }

  @override
  didRequestNotePopupCancelClick() {}

  @override
  didRequestNotePopupOkClick(String notes) {
    setState(() {
      _isOutcomeUpdated = true;
      _modelActivity!.szOutcome = notes;
    });
  }

  @override
  onPressedCancel() {}

  @override
  onPressedSubmitForm() {
    _isFormsUpdated = true;
    _refreshStackView();
  }

  @override
  requestFormsListScreenCreateSubmission(FormRefDataModel formRef, FormSubmissionDataModel submission, NetworkManagerResponse callback) {
    final request = _modelRequest;
    if (request == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    FormManager.sharedInstance.requestCreateFormSubmissionForTask(request, formRef.formId, submission, callback);
  }

  @override
  requestFormsListScreenGetSubmission(FormRefDataModel formRef, NetworkManagerResponse callback) {
    final request = _modelRequest;
    if (request == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    FormManager.sharedInstance.requestGetRequestFormById(formRef.formId, false, (responseDataModel) {
      if (responseDataModel.isSuccess || responseDataModel.isOffline) {
        final formDef = responseDataModel.parsedObject as FormDefinitionDataModel?;
        if (formRef.submissionId.isNotEmpty && !responseDataModel.isOffline) {
          FormManager.sharedInstance.requestGetRequestFormSubmissionById(request.id, formRef.formId, formRef.submissionId, callback);
        } else {
          final submission = FormSubmissionDataModel().instanceFromFormDefinition(formDef!);
          responseDataModel.parsedObject = submission;
          callback.call(responseDataModel);
        }
      } else {
        callback.call(responseDataModel);
      }
    });
  }

  @override
  requestFormsListScreenUpdateSubmission(FormRefDataModel formRef, FormSubmissionDataModel submission, NetworkManagerResponse callback) {
    final request = _modelRequest;
    if (request == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    FormManager.sharedInstance.requestUpdateFormSubmission(request, formRef.formId, submission, callback);
  }

  @override
  requestFormsListScreenUploadPhoto(FormRefDataModel formRef, File image, NetworkManagerResponse callback) {
    final request = _modelRequest;
    if (request == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    FormManager.sharedInstance.requestUploadPhotoForRequest(request, formRef, image, callback);
  }

  @override
  didServiceRoutesVehiclePopupCancelClick() {}

  @override
  didServiceRoutesVehiclePopupOkClick(double odometer, String licensePlate, bool consumerNoShow, String cancelReason) {
    setState(() {
      _modelActivity?.fOdometer = odometer;
    });
    _completeActivity(consumerNoShow, cancelReason);
  }

  @override
  didRequestConfirmTaskCancelClick() {}

  @override
  didRequestConfirmTaskDoneClick() {
    _isTaskListUpdated = true;
    _refreshStackView();
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
          AppStrings.serviceAppointment,
          style: AppStyles.textCellHeaderStyle,
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Visibility(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: _googleMap,
                      ),
                      visible: _mapView,
                    ),
                    Container(
                      padding: AppDimens.kMarginNormal,
                      decoration: const BoxDecoration(
                          color: AppColors.profileBackground,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.separatorLineGray,
                              blurRadius: 3.0,
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset("assets/images/ic_person.png", height: 16, width: 16),
                              Expanded(
                                child: Container(
                                  margin: AppDimens.kHorizontalMarginSmall,
                                  child: Text(
                                    _txtConsumer,
                                    style: AppStyles.textCellTitleBoldStyle,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            _txtTime,
                            style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.primaryColor),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(_txtStatus, style: AppStyles.textCellTextStyle),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              Image.asset("assets/images/ic_clock.png", height: 16, width: 16),
                              Expanded(
                                child: Container(
                                  margin: AppDimens.kHorizontalMarginSmall,
                                  child: Text(
                                    _txtDuration,
                                    style: AppStyles.textCellTextBoldStyle.copyWith(color: AppColors.textGray),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              Image.asset("assets/images/icon_car.png", height: 16, width: 16),
                              Expanded(
                                child: Container(
                                  margin: AppDimens.kHorizontalMarginSmall,
                                  child: Text(
                                    _txtVehicle,
                                    style: AppStyles.textCellTextBoldStyle.copyWith(color: AppColors.textGray),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              Image.asset("assets/images/icon_pin.png", height: 16, width: 16),
                              Expanded(
                                child: Container(
                                  margin: AppDimens.kHorizontalMarginSmall,
                                  child: Text(
                                    _txtAddress,
                                    style: AppStyles.textCellTextBoldStyle.copyWith(color: AppColors.primaryColor),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Image.asset("assets/images/ic_notes.png", height: 16, width: 16),
                              Expanded(
                                child: Container(
                                  margin: AppDimens.kHorizontalMarginSmall,
                                  child: Text(
                                    _txtConsumerNotes,
                                    style: AppStyles.textCellTextBoldStyle.copyWith(color: AppColors.textGray),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            _txtRequestDescription,
                            style: AppStyles.textCellTextBoldStyle.copyWith(color: AppColors.textGrayDark),
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          //Task check list view
                          Visibility(
                            visible: _viewTasks,
                            child: GestureDetector(
                              onTap: () {
                                _onButtonTasksClick();
                              },
                              child: Container(
                                padding: AppDimens.kVerticalMarginSmall,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_txtTasks, style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.primaryColor)),
                                    const Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        child: Icon(Icons.arrow_forward_ios_outlined, size: 16, color: Colors.grey),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          //Forms view
                          Visibility(
                            visible: _viewForms,
                            child: GestureDetector(
                              onTap: () {
                                _onButtonFormsClick();
                              },
                              child: Container(
                                padding: AppDimens.kVerticalMarginSmall,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_txtForms, style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.primaryColor)),
                                    const Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        child: Icon(Icons.arrow_forward_ios_outlined, size: 16, color: Colors.grey),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          //Documents view
                          Visibility(
                            visible: _viewDocuments,
                            child: GestureDetector(
                              onTap: () {
                                _onButtonDocumentsClick();
                              },
                              child: Container(
                                padding: AppDimens.kVerticalMarginSmall,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_txtDocuments, style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.primaryColor)),
                                    const Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        child: Icon(Icons.arrow_forward_ios_outlined, size: 16, color: Colors.grey),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          //Outcome note view
                          Visibility(
                            visible: _viewOutcomeNotes,
                            child: GestureDetector(
                              onTap: () {
                                _onButtonOutcomeClick();
                              },
                              child: Container(
                                padding: AppDimens.kVerticalMarginSmall,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Outcome Note", style: AppStyles.textCellTitleStyle.copyWith(color: AppColors.primaryColor)),
                                    const Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        child: Icon(Icons.arrow_forward_ios_outlined, size: 16, color: Colors.grey),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: _viewAction,
              child: Container(
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
            )
          ],
        ),
      ),
    );
  }
}
