import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livecare/components/listView/service_request_details_listview.dart';
import 'package:livecare/listeners/request_confirm_task_listener.dart';
import 'package:livecare/listeners/route_form_listener.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/form/dataModel/form_definition_data_model.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/models/form/dataModel/form_submission_data_model.dart';
import 'package:livecare/models/form/form_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/consumers/consumer_documents_list_screen.dart';
import 'package:livecare/screens/forms/form_list_screen.dart';
import 'package:livecare/screens/serviceRequests/service_request_update_screen.dart';
import 'package:livecare/screens/serviceRequests/service_requests_confirm_tasks_screen.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_map.dart';

class ServiceRequestDetailsScreen extends BaseScreen {
  final RequestDataModel? modelRequest;

  const ServiceRequestDetailsScreen({Key? key, required this.modelRequest}) : super(key: key);

  @override
  _ServiceRequestDetailsScreenState createState() => _ServiceRequestDetailsScreenState();
}

class _ServiceRequestDetailsScreenState extends BaseScreenState<ServiceRequestDetailsScreen> with RouteFormListener, RequestConfirmTaskListener {
  GoogleMap? _googleMap;
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  final List<EnumServiceRequestDetailsItemType> _arrayItems = [];
  String _txtAction = "Start";
  bool _mapView = true;

  @override
  void initState() {
    super.initState();
    _refreshFields();
    _refreshActionButtonPanel();
  }

  _refreshFields() {
    final request = widget.modelRequest;
    if (request == null) return;
    if (request.refLocation.isValid()) {
      _mapView = true;
    } else {
      _mapView = false;
    }
    _buildItems();
  }

  _refreshActionButtonPanel() {
    final request = widget.modelRequest;
    if (request == null) return;
    if (request.enumStatus == EnumRequestStatus.completed) {
      _txtAction = "Back";
    } else {
      _txtAction = "Update";
    }
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
          zoom: UtilsMap.cameraZoom, tilt: UtilsMap.cameraTilt, bearing: UtilsMap.cameraBearing, target: widget.modelRequest!.refLocation.getCoordinates()),
      onMapCreated: ((GoogleMapController controller) {
        _controller.complete(controller);
        _addStopPins();
      }),
    );
  }

  _addStopPins() async {
    final request = widget.modelRequest;
    if (request == null) return;
    BitmapDescriptor sourceIcon = BitmapDescriptor.fromBytes(await UtilsBaseFunction.getBytesFromAsset("assets/images/ic_map_pin_pink.png", 8));

    final GoogleMapController controller = await _controller.future;

    setState(() {
      _markers.add(Marker(markerId: const MarkerId('sourcePin'), position: request.refLocation.getCoordinates(), icon: sourceIcon));

      controller.animateCamera(CameraUpdate.newLatLngBounds(UtilsMap.boundsFromLatLngList(_markers.map((loc) => loc.position).toList()), 100));
    });
  }

  _buildItems() {
    final request = widget.modelRequest;
    if (request == null) return;

    setState(() {
      _arrayItems.add(EnumServiceRequestDetailsItemType.serviceType);
      if (request.refConsumer.isValid()) {
        _arrayItems.add(EnumServiceRequestDetailsItemType.consumerName);
        _arrayItems.add(EnumServiceRequestDetailsItemType.consumerNotes);
        _arrayItems.add(EnumServiceRequestDetailsItemType.consumerDocuments);
      }

      _arrayItems.add(EnumServiceRequestDetailsItemType.serviceDateTime);
      _arrayItems.add(EnumServiceRequestDetailsItemType.serviceDuration);
      if (request.enumType != EnumRequestType.outOfOffice) {
        _arrayItems.add(EnumServiceRequestDetailsItemType.serviceAttendees);
      }

      _arrayItems.add(EnumServiceRequestDetailsItemType.serviceDescription);

      if (request.refLocation.isValid()) {
        _arrayItems.add(EnumServiceRequestDetailsItemType.serviceAddress);
      }

      if (request.arrayTasks.isNotEmpty) {
        _arrayItems.add(EnumServiceRequestDetailsItemType.serviceTasks);
      }
      if (request.arrayForms.isNotEmpty) {
        _arrayItems.add(EnumServiceRequestDetailsItemType.serviceForms);
      }
    });
  }

  _showDialogForConfirmTasks() {
    final request = widget.modelRequest;
    if (request == null) return;
    if (request.arrayTasks.isEmpty) return;

    Navigator.push(
      context,
      createRoute(ServiceRequestsConfirmTasksScreen(
        modelRequest: request,
        listener: this,
      )),
    );
  }

  _showDialogForFormsScreen() {
    final request = widget.modelRequest;
    if (request == null) return;
    if (request.arrayForms.isEmpty) return;

    Navigator.push(
      context,
      createRoute(FormListScreen(
        arrayForms: request.arrayForms,
        listener: this,
      )),
    );
  }

  _showDialogForConsumerDocuments() {
    final request = widget.modelRequest;
    if (request == null) return;
    final consumer = ConsumerManager.sharedInstance.getConsumerById(request.refConsumer.consumerId);
    if (consumer == null) return;
    if (consumer.arrayDocuments.isEmpty) return;

    Navigator.push(
      context,
      createRoute(ConsumerDocumentsListScreen(
        modelConsumer: consumer,
      )),
    );
  }

  _gotoUpdateScreen() {
    Navigator.push(
      context,
      createRoute(ServiceRequestUpdateScreen(
        modelRequest: widget.modelRequest,
      )),
    );
  }

  @override
  didRequestConfirmTaskCancelClick() {}

  @override
  didRequestConfirmTaskDoneClick() {
    _buildItems();
  }

  @override
  onPressedCancel() {}

  @override
  onPressedSubmitForm() {
    _buildItems();
  }

  @override
  requestFormsListScreenCreateSubmission(FormRefDataModel formRef, FormSubmissionDataModel submission, NetworkManagerResponse callback) {
    final request = widget.modelRequest;
    if (request == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    FormManager.sharedInstance.requestCreateFormSubmissionForTask(request, formRef.formId, submission, callback);
  }

  @override
  requestFormsListScreenGetSubmission(FormRefDataModel formRef, NetworkManagerResponse callback) {
    final request = widget.modelRequest;
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
    final request = widget.modelRequest;
    if (request == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    FormManager.sharedInstance.requestUpdateFormSubmission(request, formRef.formId, submission, callback);
  }

  @override
  requestFormsListScreenUploadPhoto(FormRefDataModel formRef, File image, NetworkManagerResponse callback) {
    final request = widget.modelRequest;
    if (request == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    FormManager.sharedInstance.requestUploadPhotoForRequest(request, formRef, image, callback);
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
                    Visibility(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: _googleMap,
                      ),
                      visible: _mapView,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          color: AppColors.textWhite,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.separatorLineGray,
                              blurRadius: 3.0,
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      child: ServiceRequestDetailsListView(
                        arrayItems: _arrayItems,
                        request: widget.modelRequest!,
                        itemClickListener: (item, position) {
                          if (item == EnumServiceRequestDetailsItemType.serviceTasks) {
                            _showDialogForConfirmTasks();
                          } else if (item == EnumServiceRequestDetailsItemType.serviceForms) {
                            _showDialogForFormsScreen();
                          } else if (item == EnumServiceRequestDetailsItemType.consumerDocuments) {
                            _showDialogForConsumerDocuments();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: _txtAction == "Update",
              child: Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: AppDimens.kMarginNormal,
                  child: ElevatedButton(
                    style: AppStyles.roundButtonStyle,
                    onPressed: () {
                      _gotoUpdateScreen();
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
}

enum EnumServiceRequestDetailsItemType {
  consumerName,
  consumerNotes,
  consumerDocuments,
  serviceType,
  serviceAddress,
  serviceDateTime,
  serviceDuration,
  serviceDescription,
  serviceAttendees,
  serviceTasks,
  serviceForms
}
