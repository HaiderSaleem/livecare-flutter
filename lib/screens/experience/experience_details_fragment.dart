import 'package:flutter/material.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/experience/dataModel/experience_data_model.dart';
import 'package:livecare/models/experience/experience_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_map.dart';


// ignore: must_be_immutable
class ExperienceDetailsScreen extends BaseScreen {
  ExperienceDataModel? modelExperience;

  ExperienceDetailsScreen({Key? key, required this.modelExperience}) : super(key: key);

  @override
  _ExperienceDetailsScreenState createState() => _ExperienceDetailsScreenState();

}

class _ExperienceDetailsScreenState
    extends BaseScreenState<ExperienceDetailsScreen> {
  String _txtStatus = "";
  String _txtTime = "";
  String _txtName = "";
  String _txtType = "";
  String _txtDescription = "";
  String _txtAddress = "";
  String _txtAction = "Begin";
  bool _btnAction = true;

  GoogleMap? googleMap;
  final Completer<GoogleMapController> _controller = Completer();
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  _refreshFields() {
    final experience = widget.modelExperience;
    if (experience == null) return;

    setState(() {
      _txtStatus = experience.enumStatus.value.toUpperCase();
      final dateString = UtilsDate.getStringFromDateTimeWithFormat(
          experience.getBestDate(), EnumDateTimeFormat.MMMdyyyy.value, false);
      final timeString = UtilsDate.getStringFromDateTimeWithFormat(
          experience.getBestDate(), EnumDateTimeFormat.hhmma.value, false);

      _txtTime = "$dateString @ $timeString";
      _txtName = experience.szName;
      _txtType = experience.enumType.value.toUpperCase();
      _txtDescription = experience.szDescription;

      final location = experience.modelLocation;
      if (location == null) {
        _txtAddress = "";
      } else {
        _txtAddress = location.szAddress;
      }
      if (experience.isActive()) {
        _btnAction = true;
        if (experience.enumStatus == EnumExperienceStatus.inProgress) {
          _txtAction = "End";
        } else {
          _txtAction = "Begin";
        }
      } else {
        _btnAction = true;
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
      markers: markers.toSet(),
      initialCameraPosition: CameraPosition(
          zoom: UtilsMap.cameraZoom,
          tilt: UtilsMap.cameraTilt,
          bearing: UtilsMap.cameraBearing,
          target: widget.modelExperience!.modelLocation!.getCoordinates()),
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
    final GoogleMapController controller = await _controller.future;
    setState(() {
      markers.add(Marker(
          markerId: const MarkerId('sourcePin'),
          position: widget.modelExperience!.modelLocation!.getCoordinates(),
          icon: sourceIcon));

      controller.animateCamera(CameraUpdate.newLatLngBounds(
          UtilsMap.boundsFromLatLngList(
              markers.map((loc) => loc.position).toList()),
          40));
    });
  }

  _reloadExperienceData() {
    final experience = widget.modelExperience;
    if (experience == null) return;

    if (experience.outdated) {
      final newExp =
          ExperienceManager.sharedInstance.getExperienceById(experience.id);
      if (newExp != null) {
        widget.modelExperience = newExp;
        _refreshFields();
      }
    }
  }

  _requestCancelExperience() {
    final experience = widget.modelExperience;
    if (experience == null) return;
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    ExperienceManager.sharedInstance.requestCancelExperience(experience,
        (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        _reloadExperienceData();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _requestBeginExperience() {
    final experience = widget.modelExperience;
    if (experience == null) return;
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    ExperienceManager.sharedInstance.requestBeginExperience(experience,
        (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        _reloadExperienceData();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _requestEndExperience() {
    final experience = widget.modelExperience;
    if (experience == null) return;
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    ExperienceManager.sharedInstance.requestEndExperience(experience,
        (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        _reloadExperienceData();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _onButtonActionClick() {
    final experience = widget.modelExperience;
    if (experience == null) return;
    if (experience.enumStatus == EnumExperienceStatus.inProgress) {
      _requestEndExperience();
    } else {
      _requestBeginExperience();
    }
  }

  _onButtonCancelClick() {
    UtilsBaseFunction.showAlertWithMultipleButton(context, "Confirmation",
        "Are you sure you want to cancel?", _requestCancelExperience);
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
          AppStrings.titleExperience,
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
                padding: AppDimens.kMarginNormal,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Container(
                  margin: AppDimens.kHorizontalMarginNormal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          _txtStatus,
                          style: AppStyles.textCellHeaderStyle
                              .copyWith(color: AppColors.textGray),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(_txtTime,
                          textAlign: TextAlign.center,
                          style: AppStyles.textCellTitleStyle
                              .copyWith(color: AppColors.purpleColor)),
                      const Divider(
                          height: 30, color: AppColors.separatorLineGray),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("NAME:",
                                style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Text(_txtName, style: AppStyles.textCellTitleStyle)
                        ],
                      ),
                      const Divider(
                          height: 30, color: AppColors.separatorLineGray),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("TYPE:",
                                style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(
                              child: Text(_txtType,
                                  style: AppStyles.textCellTitleStyle))
                        ],
                      ),
                      const Divider(
                          height: 30, color: AppColors.separatorLineGray),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("DESCRIPTION:",
                                style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(
                              child: Text(_txtDescription,
                                  style: AppStyles.textCellTitleStyle))
                        ],
                      ),
                      const Divider(
                          height: 30, color: AppColors.separatorLineGray),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: const Text("ADDRESS:",
                                style: AppStyles.textCellTitleBoldStyle),
                          ),
                          Expanded(
                              child: Text(_txtAddress,
                                  style: AppStyles.textCellTitleStyle))
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Visibility(
                        visible: _btnAction,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.textWhite)
                                    .merge(AppStyles.normalButtonStyle),
                                onPressed: () {
                                  _onButtonCancelClick();
                                },
                                child: Text(
                                  "Cancel",
                                  textAlign: TextAlign.center,
                                  style: AppStyles.buttonTextStyle
                                      .copyWith(color: AppColors.primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.purpleColor)
                                    .merge(AppStyles.normalButtonStyle),
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
                          ],
                        ),
                      )
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
