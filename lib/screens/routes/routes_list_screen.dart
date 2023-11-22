import 'package:flutter/material.dart';
import 'package:livecare/components/listView/route_listview.dart';
import 'package:livecare/models/communication/socket_request_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_observer.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/route/service_route_manager.dart';
import 'package:livecare/models/route/transport_route_manager.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/routes/route_details_screen.dart';
import 'package:livecare/screens/serviceRoute/service_routes_list_detail_screen.dart';

import '../../utils/utils_date.dart';

class RoutesListScreen extends BaseScreen {
  const RoutesListScreen({Key? key}) : super(key: key);

  @override
  _RoutesListScreenState createState() => _RoutesListScreenState();
}

class _RoutesListScreenState extends BaseScreenState<RoutesListScreen> with LocalNotificationObserver, SocketDelegate {
  final List<RouteDataModel> _arrayRoutes = [];
  DateTime _dateSelected = DateTime.now();
  String _txtDate = "";

  @override
  void initState() {
    super.initState();
    LocalNotificationManager.sharedInstance.addObserver(this);
    SocketRequestManager.sharedInstance.addListener(this);
    var splitDate = "${_dateSelected.toString().split(" ")[0]}T00:00:00.000";
    _dateSelected = DateTime.parse(splitDate);

    _txtDate = UtilsDate.getStringFromDateTimeWithFormat(_dateSelected, EnumDateTimeFormat.MMMdyyyy.value, false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestGetRoutes();
    });
  }

  _reloadData() {
    setState(() {
      _txtDate = UtilsDate.getStringFromDateTimeWithFormat(_dateSelected, EnumDateTimeFormat.MMMdyyyy.value, false);

      final results = TransportRouteManager.sharedInstance.getActiveRoutes();
      _arrayRoutes.clear();
      _arrayRoutes.addAll(results);
    });
  }

  _showCalendar(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _dateSelected, // Refer step 1
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    ).then((value) {
      if (value == null) return;
      setState(() {
        _txtDate = UtilsDate.getStringFromDateTimeWithFormat(value, EnumDateTimeFormat.MMMdyyyy.value, false);
        _dateSelected = value;
      });
      _requestGetRoutes();
    });
  }

  _gotoRouteDetailsScreen(RouteDataModel route) {
    /// Reload route data from server to get odometer and other data

    showProgressHUD();
    if (route.enumType == EnumRouteType.transport) {
      TransportRouteManager.sharedInstance.requestGetRouteById(route.id, (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess || responseDataModel.isOffline) {
          if (TransportRouteManager.sharedInstance.getRouteById(route.id) == null) {
            showToast("Route is not found.");
          } else {
            final updatedRoute = TransportRouteManager.sharedInstance.getRouteById(route.id);
            var startedRoute = false;
            for (var r in _arrayRoutes) {
              if (r.enumStatus == EnumRouteStatus.enRoute) {
                startedRoute = true;
                break;
              }
            }

            Navigator.push(
              context,
              createRoute(RouteDetailsScreen(
                modelRoute: updatedRoute,
                isRouteStarted: startedRoute,
              )),
            ).then((value) => _requestGetRoutes());
          }
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      ServiceRouteManager.sharedInstance.requestGetRouteById(route.id, (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess || responseDataModel.isOffline) {
          if (TransportRouteManager.sharedInstance.getRouteById(route.id) == null) {
            showToast("Route is not found.");
          } else {
            final updatedRoute = TransportRouteManager.sharedInstance.getRouteById(route.id);
            var startedRoute = false;
            for (var r in _arrayRoutes) {
              if (r.enumStatus == EnumRouteStatus.inProgress) {
                startedRoute = true;
                break;
              }
            }

            Navigator.push(
              context,
              createRoute(ServiceRoutesListDetailScreen(
                modelRoute: updatedRoute!,
                isRouteStarted: startedRoute,
              )),
            ).then((value) {
              _requestGetRoutes();
            });
          }
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    }
  }

  _requestGetRoutes() {
    if (!UserManager.sharedInstance.isLoggedIn()) return;
    showProgressHUD();

    DateTime begin = _dateSelected.toLocal();
    DateTime end = begin.add(const Duration(days: 1));

    TransportRouteManager.sharedInstance.requestGetRoutesByDate(begin, end, (responseDataModel) {
      hideProgressHUD();

      if (responseDataModel.isSuccess || responseDataModel.isOffline) {
        _reloadData();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
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
  onRequestCancelled(RequestDataModel request) {}

  @override
  onRequestUpdated(RequestDataModel request) {
    _requestGetRoutes();
  }

  @override
  onRouteDriverLocationUpdated(String routeId, double lat, double lng) {}

  @override
  onRouteLocationStatusUpdated(RouteDataModel route) {}

  @override
  onRouteUpdated(RouteDataModel route) {
    _requestGetRoutes();
    _reloadData();
    showToast(AppStrings.routesUpdatedSuccessfully);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Left Arrow Buttons and Date
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      var currentDate = DateTime.now();
                      // if (_dateSelected.isAfter(currentDate)) {
                      // Previous Date
                      _dateSelected = _dateSelected.subtract(const Duration(days: 1));
                      setState(() {
                        _txtDate = UtilsDate.getStringFromDateTimeWithFormat(_dateSelected, EnumDateTimeFormat.MMMdyyyy.value, false);
                      });
                      _requestGetRoutes();
                      // } else {
                      //   showToast(AppStrings.cannotseeprevride);
                      // }
                    },
                    padding: const EdgeInsets.all(15),
                    icon: const Icon(Icons.arrow_back_ios)),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showCalendar(context);
                    },
                    child: Container(
                      padding: AppDimens.kMarginNormal,
                      child: Text(
                        _txtDate,
                        textAlign: TextAlign.center,
                        style: AppStyles.textTitleBoldStyle.copyWith(color: AppColors.textGray),
                      ),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _dateSelected = _dateSelected.add(const Duration(days: 1)).add(const Duration(hours: 1));
                      // Next Date
                      //  var value = DateTime(_dateSelected.year, _dateSelected.month, _dateSelected.day + 1);
                      setState(() {
                        _txtDate = UtilsDate.getStringFromDateTimeWithFormat(_dateSelected, EnumDateTimeFormat.MMMdyyyy.value, false);
                      });
                      _requestGetRoutes();
                    },
                    padding: const EdgeInsets.all(15),
                    icon: const Icon(Icons.arrow_forward_ios)),
              ],
            ),

            // Date Time
            Expanded(
              child: Container(
                color: AppColors.defaultBackground,
                padding: AppDimens.kMarginSsmall,
                child: _arrayRoutes.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.noScheduledRoutes,
                          style: AppStyles.tripInformation.copyWith(color: AppColors.textBlack),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () {
                          _requestGetRoutes();
                          return Future.delayed(const Duration(milliseconds: 1000));
                        },
                        child: RouteListView(
                          arrayRoutes: _arrayRoutes,
                          itemClickListener: (route, position) {
                            _gotoRouteDetailsScreen(route);
                          },
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
