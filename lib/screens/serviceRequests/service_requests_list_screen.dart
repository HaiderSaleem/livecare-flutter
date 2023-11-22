import 'package:flutter/material.dart';
import 'package:livecare/components/listView/service_request_listview.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/communication/socket_request_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_observer.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/service_request_manager.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/serviceRequests/create/service_request_create_screen.dart';
import 'package:livecare/screens/serviceRequests/service_request_details_screen.dart';
import 'package:livecare/screens/serviceRequests/viewModel/service_request_view_model.dart';

class ServiceRequestsListScreen extends BaseScreen {
  const ServiceRequestsListScreen({Key? key}) : super(key: key);

  @override
  _ServiceRequestsListScreenState createState() => _ServiceRequestsListScreenState();
}

class _ServiceRequestsListScreenState extends BaseScreenState<ServiceRequestsListScreen> with LocalNotificationObserver, SocketDelegate {
  final List<RequestDataModel> _arrayRequests = [];

  @override
  void initState() {
    super.initState();
    LocalNotificationManager.sharedInstance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestGetRequests();
    });
    SocketRequestManager.sharedInstance.addListener(this);
  }

  _requestGetRequests() {
    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      showProgressHUD();
      ServiceRequestManager.sharedInstance.requestGetRequestsForMe(true, EnumRouteType.transport, (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess && responseDataModel.parsedObject != null) {
          final requests = responseDataModel.parsedObject as List<RequestDataModel>;

          setState(() {
            _arrayRequests.clear();
            _arrayRequests.addAll(requests.where((element) => element.isActiveRequest() && element.enumType == EnumRequestType.outOfOffice));
          });
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      final requests = ServiceRequestManager.sharedInstance.arrayServiceRequests;
      setState(() {
        _arrayRequests.clear();
        _arrayRequests.addAll(requests.where((element) => element.isActiveRequest() && element.enumType == EnumRequestType.outOfOffice));
      });
    }
  }

  _gotoRequestDetailsScreen(RequestDataModel request) {
    Navigator.push(
      context,
      createRoute(ServiceRequestDetailsScreen(modelRequest: request)),
    );
  }

  _gotoRequestCreateScreen() {
    final request = ServiceRequestViewModel();
    Navigator.push(
      context,
      createRoute(ServiceRequestCreateScreen(vmRequest: request)),
    );
  }

  @override
  routeListUpdated() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    LocalNotificationManager.sharedInstance.removeObserver(this);
  }

  @override
  onAnyEventFired() {}

  @override
  onConnected() {}

  @override
  onConnectionStatusChanged() {}

  @override
  onRequestCancelled(RequestDataModel request) {
    setState(() {});
  }

  @override
  onRequestUpdated(RequestDataModel request) {
    setState(() {});
  }

  @override
  onRouteDriverLocationUpdated(String routeId, double lat, double lng) {}

  @override
  onRouteLocationStatusUpdated(RouteDataModel route) {
    setState(() {});
  }

  @override
  onRouteUpdated(RouteDataModel route) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (NetworkReachabilityManager.sharedInstance.isConnected()) {
            _gotoRequestCreateScreen();
          }
        },
        child: const Icon(Icons.add, size: 30),
        backgroundColor: AppColors.buttonBackground,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          bottom: true,
          child: _arrayRequests.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.noRequest,
                    style: AppStyles.tripInformation.copyWith(color: AppColors.textBlack),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () {
                    _requestGetRequests();
                    return Future.delayed(const Duration(milliseconds: 1000));
                  },
                  child: ServiceRequestListView(
                    arrayRequests: _arrayRequests,
                    itemClickListener: (RequestDataModel request, int index) {
                      _gotoRequestDetailsScreen(request);
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
