import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/route/base_route_manager.dart';
import 'package:livecare/models/route/dataModel/activity_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/utils/location_manager.dart';
import 'package:livecare/utils/utils_date.dart';

class ServiceRouteManager extends BaseRouteManager {
  static ServiceRouteManager sharedInstance = ServiceRouteManager();

  requestGetAllRoutes(NetworkManagerResponse callback) {
    final Map<String, dynamic> params = {};
    params["\$top"] = "1000";
    params["\$skip"] = "0";
    params["\$orderby"] = "estimatedStart asc";
    var filter = "(type eq '${EnumRouteType.service.value}')";
    filter += " and (status eq 'Scheduled' or status eq 'En Route')";
    params["\$filter"] = filter;
    // super.requestGetRoutesByParams(
    //     params, EnumRouteType.service, callback = callback);
  }

  requestGetRoutesByDate(DateTime startDate, DateTime endDate, NetworkManagerResponse callback) {
    var filterString = "(type eq '${EnumRouteType.service.value}') and (status ne 'Cancelled') and (estimatedStart ge "
        "'${UtilsDate.getStringFromDateTimeWithFormatToApi(startDate, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true)}'"
        " and estimatedStart le '${UtilsDate.getStringFromDateTimeWithFormatToApi(endDate, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true)}')";

    final Map<String, dynamic> params = {};
    params["\$filter"] = filterString;

    super.requestGetRoutesByParams(params, EnumRouteType.service, callback);
  }

  @override
  Future<void> requestStartRoute(RouteDataModel route, NetworkManagerResponse? callback, {Map<String, dynamic>? params}) async {
    final Map<String, dynamic> params = {};
    final Map<String, dynamic> start = {};
    start["start"] = route.fOdometerStart;
    params["odometer"] = start;
    params["license"] = route.refVehicle?.szLicense;
    params["verification"] = LCLocationManager.sharedInstance.geoPoint.serialize();
    super.requestStartRoute(route, callback, params: params);
  }

  @override
  Future<void> requestUpdateActivityStatus(RouteDataModel route, ActivityDataModel activity, EnumActivityStatus status, NetworkManagerResponse? callback,
      {Map<String, dynamic>? params}) async {
    final Map<String, dynamic> params = {};
    params["odometer"] = activity.fOdometer;
    params["verification"] = LCLocationManager.sharedInstance.geoPoint.serialize();
    super.requestUpdateActivityStatus(
      route,
      activity,
      status,
      callback,
      params: params,
    );
  }

  @override
  Future<void> requestUpdatePayloads(RouteDataModel route, ActivityDataModel activity, NetworkManagerResponse? callback, {Map<String, dynamic>? params}) async {
    final params = activity.serializeForUpdateServicePayloads();
    super.requestUpdatePayloads(
      route,
      activity,
      callback,
      params: params,
    );
  }
}
