import 'package:flutter/material.dart';
import 'package:livecare/components/listView/route_listview.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_observer.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/route/transport_route_manager.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/routes/route_details_screen.dart';
import '../../utils/utils_date.dart';

class RoutesHistoryScreen extends BaseScreen {
  const RoutesHistoryScreen({Key? key}) : super(key: key);

  @override
  _RoutesHistoryScreenState createState() => _RoutesHistoryScreenState();
}

class _RoutesHistoryScreenState extends BaseScreenState<RoutesHistoryScreen>
    with LocalNotificationObserver {
  final List<RouteDataModel> _arrayRoutes = [];
  DateTime _dateSelected = DateTime.now();
  String _txtDate = "";

  @override
  void initState() {
    super.initState();
    var splitDate = "${_dateSelected.toString().split(" ")[0]}T00:00:00.000";

    _dateSelected = DateTime.parse(splitDate);
    _reloadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUI();
    });

    LocalNotificationManager.sharedInstance.addObserver(this);

  }

  _initUI() {
    _txtDate = UtilsDate.getStringFromDateTimeWithFormat(
        _dateSelected, EnumDateTimeFormat.MMMdyyyy.value, false);

    getRoutes();
  }

  getRoutes(){

    DateTime begin = _dateSelected.toLocal();
    DateTime end = _dateSelected.add(const Duration(days: 1)).toLocal();

    _requestGetRoutes(begin,end);
  }

  _reloadData() {
    setState(() {
      _txtDate = UtilsDate.getStringFromDateTimeWithFormat(_dateSelected, EnumDateTimeFormat.MMMdyyyy.value, false);

    /*  final results = TransportRouteManager.sharedInstance.getPastRoutes();
      print("Routes-->"+results.length.toString());

      _arrayRoutes.clear();
      _arrayRoutes.addAll(results);*/
    });
  }

  void addRoutesToList(List<RouteDataModel> routes) {
    _arrayRoutes.clear();
    _arrayRoutes.addAll(routes);

  }


  _showCalendar(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _dateSelected, // Refer step 1
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 60)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 60)),
    ).then((value) {
      if (value == null) return;
      setState(() {
        _txtDate = UtilsDate.getStringFromDateTimeWithFormat(
            value, EnumDateTimeFormat.MMMdyyyy.value, false);
        _dateSelected = value;
      });
      getRoutes();
    });
  }


  _gotoServiceRouteDetailsScreen(RouteDataModel route) {
    Navigator.push(
      context,
      createRoute(RouteDetailsScreen(modelRoute: route, isRouteStarted: false,)),
    );
  }

  _requestGetRoutes(DateTime begin,DateTime end) {
    if (!UserManager.sharedInstance.isLoggedIn()) return;
    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      showProgressHUD();
      TransportRouteManager.sharedInstance.requestGetCompletedRoutesByDate(begin,end,(responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess) {
          addRoutesToList(responseDataModel.parsedObject as List<RouteDataModel>);
          _reloadData();
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      _reloadData();
    }
  }


  @override
  void dispose() {
    super.dispose();
    LocalNotificationManager.sharedInstance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      var value = DateTime(_dateSelected.year,
                          _dateSelected.month, _dateSelected.day - 1);
                      setState(() {
                        _txtDate = UtilsDate.getStringFromDateTimeWithFormat(
                            value, EnumDateTimeFormat.MMMdyyyy.value, false);
                        _dateSelected = value;
                      });
                      getRoutes();

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
                      var value = DateTime(_dateSelected.year,
                          _dateSelected.month, _dateSelected.day + 1);
                      setState(() {
                        _txtDate = UtilsDate.getStringFromDateTimeWithFormat(
                            value, EnumDateTimeFormat.MMMdyyyy.value, false);
                        _dateSelected = value;
                      });
                      getRoutes();
                    },
                    padding: const EdgeInsets.all(15),
                    icon: const Icon(Icons.arrow_forward_ios)),
              ],
            ),
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
                    getRoutes();
                    return Future.delayed(const Duration(milliseconds: 1000));
                  },
                  child: RouteListView(
                    arrayRoutes: _arrayRoutes,
                    itemClickListener: (route, position) {
                      _gotoServiceRouteDetailsScreen(route);
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

