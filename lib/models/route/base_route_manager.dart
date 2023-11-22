import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/route/dataModel/activity_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_general.dart';

class BaseRouteManager {
  List<RouteDataModel> arrayRoutes = [];
  List<RouteDataModel> arrayServiceRoutes = [];

  var IS_ROUTE_ACTIVE = false;

  isRouteActive() {
    return IS_ROUTE_ACTIVE;
  }

  setRouteActive(bool routeActive) {
    IS_ROUTE_ACTIVE = routeActive;
  }

  addRouteIfNeeded(RouteDataModel newRoute) {
    if (newRoute.enumStatus == EnumRouteStatus.cancelled) {
      deleteRouteIfNeeded(newRoute);
      return;
    }
    if (!newRoute.isValid()) {
      return;
    }
    int index = 0;
    for (var route in arrayRoutes) {
      if (route.id == newRoute.id) {
        arrayRoutes[index] = newRoute;
        route.invalidate();
        return;
      }
      index += 1;
    }
    arrayRoutes.add(newRoute);
  }

  addServiceRouteIfNeeded(RouteDataModel newRoute) {
    if (newRoute.enumStatus == EnumRouteStatus.cancelled) {
      deleteServiceRouteIfNeeded(newRoute);
      return;
    }
    if (!newRoute.isValid()) {
      return;
    }
    int index = 0;
    for (var route in arrayServiceRoutes) {
      if (route.id == newRoute.id) {
        arrayServiceRoutes[index] = newRoute;
        route.invalidate();
        return;
      }
      index += 1;
    }
    arrayServiceRoutes.add(newRoute);
  }

  deleteRouteIfNeeded(RouteDataModel deletedRoute) {
    int index = 0;
    for (var route in arrayRoutes) {
      if (route.id == deletedRoute.id) {
        route.invalidate();
        arrayRoutes.removeAt(index);
        return;
      }
      index += 1;
    }
  }

  deleteServiceRouteIfNeeded(RouteDataModel deletedRoute) {
    int index = 0;
    for (var route in arrayServiceRoutes) {
      if (route.id == deletedRoute.id) {
        route.invalidate();
        arrayServiceRoutes.removeAt(index);
        return;
      }
      index += 1;
    }
  }

  appendRoutesFromArray(List<RouteDataModel>? routes) {
    final mRoutes = routes;
    if (mRoutes == null) return;
    for (var route in mRoutes) {
      addRouteIfNeeded(route);
    }
  }

  appendRoutesFromObjectArray(dynamic payload) {
    final List<dynamic> mPayload = payload;
    for (int i in Iterable.generate(mPayload.length)) {
      Map<String, dynamic> dict = payload[i];
      final route = RouteDataModel();
      route.deserialize(dict);
      addRouteIfNeeded(route);
    }
  }

  appendRouteFromObject(dynamic payload) {
    final Map<String, dynamic> mPayload = payload;
    final route = RouteDataModel();
    route.deserialize(mPayload);
    addRouteIfNeeded(route);
  }

  RouteDataModel? getRouteById(String routeId) {
    for (var route in arrayRoutes) {
      if (route.id == routeId) {
        return route;
      }
    }
    return null;
  }

  RouteDataModel? getServiceRouteById(String routeId) {
    for (var route in arrayServiceRoutes) {
      if (route.id == routeId) {
        return route;
      }
    }
    return null;
  }

  RouteDataModel? getRouteByRequestId(String requestId) {
    for (var route in arrayRoutes) {
      for (var activity in route.arrayActivities) {
        for (var payload in activity.arrayPayloads) {
          if (payload.requestId == requestId) {
            return route;
          }
        }
      }
    }
    return null;
  }

  List<RouteDataModel> getPastRoutes() {
    return arrayRoutes;
    final array = arrayRoutes.where((element) => element.isActiveRoute() == false).toList();
    array.sort((a, b) => a.dateEstimatedStart!.compareTo(b.dateEstimatedStart!));
    return array;
  }

  List<RouteDataModel> getActiveRoutes() {
    final array = arrayRoutes.where((element) => element.isActiveRoute() == true).toList();
    array.sort((a, b) => a.dateEstimatedStart!.compareTo(b.dateEstimatedStart!));
    return array;
  }

  List<RouteDataModel> getRoutesByDate(DateTime? date) {
    final mDate = date;
    if (mDate == null) return [];
    return arrayRoutes.where((element) => element.isValid() && UtilsDate.isSameDate(element.getBestStartDateTimeForRoute(), date)).toList();
  }

  Future<void> requestGetRoutesByParams(Map<String, dynamic> params, EnumRouteType type, NetworkManagerResponse? callback) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      callback?.call(NetworkResponseDataModel.forFailure());
      return;
    }

    final String urlString = UrlManager.routeApi.getRoutes(transOrg.organizationId, currentUser.id);

    try {
      NetworkResponseDataModel responseDataModel = await NetworkManager.get(urlString, params, EnumNetworkAuthOptions.authRequired.value);
      processResponseDataModel(responseDataModel, type);
      LocalNotificationManager.sharedInstance.notifyLocalNotification(UtilsGeneral.routesListUpdated);
      callback?.call(responseDataModel);
    } catch (e) {
      callback?.call(NetworkResponseDataModel.forFailure());
    }
  }

  void processResponseDataModel(NetworkResponseDataModel responseDataModel, EnumRouteType type) {
    if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data") && responseDataModel.payload["data"] != null) {
      final List<RouteDataModel> array = [];
      final List<dynamic> data = responseDataModel.payload["data"];
      setRouteActive(false);

      for (int i in Iterable.generate(data.length)) {
        final Map<String, dynamic> dict = data[i];

        final route = RouteDataModel();
        route.deserialize(dict);
        if (route.isValid()) {
          if (route.enumStatus == EnumRouteStatus.enRoute) {
            setRouteActive(true);
          }
          array.add(route);
          if (type == EnumRouteType.service) {
            addServiceRouteIfNeeded(route);
          } else {
            addRouteIfNeeded(route);
          }
        }
      }
      array.sort((a, b) => a.dateEstimatedStart!.compareTo(b.dateEstimatedStart!));

      if (type == EnumRouteType.service) {
        arrayServiceRoutes.clear();
        arrayServiceRoutes.addAll(array);
      } else {
        arrayRoutes.clear();
        arrayRoutes.addAll(array);
      }

      responseDataModel.parsedObject = array;
    }
  }

  Future<void> requestGetCompletedRoutesByParams(Map<String, dynamic> params, EnumRouteType type, NetworkManagerResponse? callback) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();

    if (currentUser == null || transOrg == null) {
      callback?.call(NetworkResponseDataModel.forFailure());
      return;
    }
    final String urlString = UrlManager.routeApi.getRoutes(transOrg.organizationId, currentUser.id);

    try {
      NetworkResponseDataModel responseDataModel = await NetworkManager.get(urlString, params, EnumNetworkAuthOptions.authRequired.value);
      if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data") && responseDataModel.payload["data"] != null) {
        final List<RouteDataModel> array = [];
        final List<dynamic> data = responseDataModel.payload["data"];
        setRouteActive(false);
        for (int i in Iterable.generate(data.length)) {
          final Map<String, dynamic> dict = data[i];
          final route = RouteDataModel();
          route.deserialize(dict);
          array.add(route);
        }
        array.sort((a, b) => a.dateEstimatedStart!.compareTo(b.dateEstimatedStart!));
        responseDataModel.parsedObject = array;
      }
      LocalNotificationManager.sharedInstance.notifyLocalNotification(UtilsGeneral.routesListUpdated);
      callback?.call(responseDataModel);
    } catch (e) {
      callback?.call(NetworkResponseDataModel.forFailure());
    }
  }

  Future<void> requestGetRouteById(String routeId, NetworkManagerResponse? callback) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      callback?.call(NetworkResponseDataModel.forFailure());
      return;
    }

    final String urlString = UrlManager.routeApi.getRouteById(transOrg.organizationId, routeId);

    try {
      NetworkResponseDataModel responseDataModel = await NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value);
      if (responseDataModel.isSuccess) {
        final Map<String, dynamic> dict = responseDataModel.payload;
        final route = RouteDataModel();
        route.deserialize(dict);
        if (route.enumType == EnumRouteType.service) {
          addServiceRouteIfNeeded(route);
        } else {
          addRouteIfNeeded(route);
        }
      }
      callback?.call(responseDataModel);
      LocalNotificationManager.sharedInstance.notifyLocalNotification(UtilsGeneral.routesListUpdated);
    } catch (e) {
      callback?.call(NetworkResponseDataModel.forFailure());
    }
  }

  Future<void> requestStartRoute(RouteDataModel route, NetworkManagerResponse? callback, {Map<String, dynamic>? params}) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      callback?.call(NetworkResponseDataModel.forFailure());
      return;
    }
    final String urlString = UrlManager.routeApi.startRoute(transOrg.organizationId, route.id);
    NetworkManager.put(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        requestGetRouteById(route.id, callback);
        setRouteActive(true);
      } else {
        callback?.call(NetworkResponseDataModel.forFailure());
      }
    });
  }

  Future<void> requestUpdateActivityStatus(RouteDataModel route, ActivityDataModel activity, EnumActivityStatus status, NetworkManagerResponse? callback,
      {Map<String, dynamic>? params}) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      callback?.call(NetworkResponseDataModel.forFailure());
      return;
    }
    final String urlString = UrlManager.routeApi.updateActivityStatus(transOrg.organizationId, route.id, activity.id, status.value);
    NetworkManager.put(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        requestGetRouteById(route.id, callback);
      } else {
        callback?.call(NetworkResponseDataModel.forFailure());
      }
    });
  }

  Future<void> requestUpdatePayloads(RouteDataModel route, ActivityDataModel activity, NetworkManagerResponse? callback, {Map<String, dynamic>? params}) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      callback?.call(NetworkResponseDataModel.forFailure());
      return;
    }
    /* val urlString: String = UrlManager.RouteApi.updatePayloads(
        organizationId = transOrg.organizationId,
        routeId = route.id,
        activityId = activity.id
    )
    */
    final String urlString = UrlManager.routeApi.updatePayloads(transOrg.organizationId, route.id, activity.id);
    NetworkManager.put(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        requestGetRouteById(route.id, callback);
      } else {
        callback?.call(NetworkResponseDataModel.forFailure());
      }
    });
  }

  requestCompleteRoute(RouteDataModel route, NetworkManagerResponse? callback) {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      callback?.call(NetworkResponseDataModel.forFailure());
      return;
    }
    final String urlString = UrlManager.routeApi.completeRoute(transOrg.organizationId, route.id);
    NetworkManager.put(urlString, {}, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        requestGetRouteById(route.id, callback);
        setRouteActive(false);
      } else {
        callback?.call(NetworkResponseDataModel.forFailure());
      }
    });
  }

  //Offline Logic
  startRouteOffline(RouteDataModel currentRoute) {
    var index = 0;
    for (var route in arrayRoutes) {
      if (route.id == currentRoute.id) {
        currentRoute.onStartRoute();
        arrayRoutes[index] = currentRoute;
        route.invalidate();
        return;
      }
      index += 1;
    }

    var index1 = 0;
    for (var route in arrayServiceRoutes) {
      if (route.id == currentRoute.id) {
        currentRoute.onStartServiceRoute();
        arrayServiceRoutes[index1] = currentRoute;
        route.invalidate();
        return;
      }
      index1 += 1;
    }
  }

  markAsArrivedOffline(RouteDataModel currentRoute, ActivityDataModel currentActivity) {
    var index = 0;
    for (var route in arrayRoutes) {
      if (route.id == currentRoute.id) {
        currentRoute.onMarkAsArrived(currentActivity);
        final date = UtilsDate.getStringFromDateTimeWithFormat(DateTime.now(), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
        currentRoute.dateUpdatedAt = UtilsDate.getDateTimeFromStringWithFormatToApi(date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
        arrayRoutes[index] = currentRoute;
        route.invalidate();
        return;
      }
      index += 1;
    }
  }

  updatePayloadsOffline(RouteDataModel currentRoute, ActivityDataModel currentActivity) {
    final dateString = UtilsDate.getStringFromDateTimeWithFormat(DateTime.now(), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    final date = UtilsDate.getDateTimeFromStringWithFormatToApi(dateString, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    var index = 0;
    for (var route in arrayRoutes) {
      if (route.id == currentRoute.id) {
        currentRoute.onUpdatePayloads(currentActivity);
        currentRoute.dateUpdatedAt = date;
        arrayRoutes[index] = currentRoute;
        route.invalidate();
        return;
      }
      index += 1;
    }

    var index1 = 0;
    for (var route in arrayServiceRoutes) {
      if (route.id == currentRoute.id) {
        currentRoute.onUpdateServicePayloads(currentActivity);
        currentRoute.dateUpdatedAt = date;
        arrayServiceRoutes[index1] = currentRoute;
        route.invalidate();
        return;
      }
      index1 += 1;
    }
  }

  startRideOffline(RouteDataModel currentRoute, ActivityDataModel currentActivity, EnumActivityStatus enumStatus) {
    final dateString = UtilsDate.getStringFromDateTimeWithFormat(DateTime.now(), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    final date = UtilsDate.getDateTimeFromStringWithFormatToApi(dateString, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    var index = 0;
    for (var route in arrayRoutes) {
      if (route.id == currentRoute.id) {
        currentRoute.onStartRide(currentActivity, enumStatus);
        currentRoute.dateUpdatedAt = date;
        arrayRoutes[index] = currentRoute;
        route.invalidate();
        return;
      }
      index += 1;
    }

    var index1 = 0;
    for (var route in arrayServiceRoutes) {
      if (route.id == currentRoute.id) {
        currentRoute.onStartServiceRide(currentActivity, enumStatus);
        currentRoute.dateUpdatedAt = date;
        arrayServiceRoutes[index1] = currentRoute;
        route.invalidate();
        return;
      }
      index1 += 1;
    }
  }

  completeRouteOffline(RouteDataModel currentRoute) {
    var index = 0;
    for (var route in arrayRoutes) {
      if (route.id == currentRoute.id) {
        currentRoute.onCompleteRoute();
        arrayRoutes[index] = currentRoute;
        route.invalidate();
        return;
      }
      index += 1;
    }

    var index1 = 0;
    for (var route in arrayServiceRoutes) {
      if (route.id == currentRoute.id) {
        currentRoute.onCompleteRoute();
        arrayServiceRoutes[index1] = currentRoute;
        route.invalidate();
        return;
      }
      index1 += 1;
    }
  }
}
