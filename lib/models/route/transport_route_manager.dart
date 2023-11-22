import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/route/base_route_manager.dart';
import 'package:livecare/models/route/dataModel/activity_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/location_manager.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_general.dart';

class TransportRouteManager extends BaseRouteManager {
  static TransportRouteManager sharedInstance = TransportRouteManager();

  requestGetAllRoutes(NetworkManagerResponse? callback) {
    final Map<String, dynamic> params = {};

    params["\$top"] = "1000";
    params["\$skip"] = "0";
    params["\$orderby"] = "estimatedStart asc";
    var filter = "(type eq '${EnumRouteType.transport.value}')";
    filter += " and (status eq 'Scheduled' or status eq 'En Route')";

    params["\$filter"] = filter;
    super.requestGetRoutesByParams(params, EnumRouteType.transport, callback);
  }

  requestGetRoutesByDate(DateTime begin, DateTime end, NetworkManagerResponse callback) {
    final Map<String, dynamic> params = {};
    params["\$top"] = "1000";
    params["\$skip"] = "0";
    params["\$orderby"] = "estimatedStart asc";
    /* var filterString = "status ne 'Cancelled' and estimatedStart ge "
        "'${UtilsDate.getStringFromDateTimeWithFormat(begin, EnumDateTimeFormat.yyyyMMdd.value,
        false)}T18:30:00.000Z'"
        " and estimatedStart le '${UtilsDate.getStringFromDateTimeWithFormat(end,
        EnumDateTimeFormat.yyyyMMdd.value, false)}T18:30:00.000Z'";*/

    final Map<String, dynamic> params2 = {};
    params2["\$top"] = "500";
    params2["\$skip"] = "0";
    params2["\$orderby"] = "estimatedStart asc";

    var filterString =
        "(status ne 'Cancelled') and (estimatedStart ge '${UtilsDate.getStringFromDateTimeWithFormatToApi(begin, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true)}' and estimatedStart le '${UtilsDate.getStringFromDateTimeWithFormatToApi(end, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true)}')";

    params["\$filter"] = filterString;

    super.requestGetRoutesByParams(params, EnumRouteType.none, callback);
  }

  requestGetCompletedRoutesByDate(DateTime begin, DateTime end, NetworkManagerResponse? callback) {
    final Map<String, dynamic> params = {};

    params["\$top"] = "1000";
    params["\$skip"] = "0";
    params["\$orderby"] = "estimatedStart asc";

    var filter =
        "(status eq 'Completed') and (actualCompleted ge '${UtilsDate.getStringFromDateTimeWithFormatToApi(begin, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true)}' and actualCompleted le '${UtilsDate.getStringFromDateTimeWithFormatToApi(end, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true)}')";

    params["\$filter"] = filter;
    super.requestGetCompletedRoutesByParams(params, EnumRouteType.transport, callback);
  }

  requestGetRoutesForHistory(NetworkManagerResponse callback) {
    final Map<String, dynamic> params = {};
    params["\$top"] = "1000";
    params["\$skip"] = "0";
    params["\$orderby"] = "estimatedStart desc";
    var filter = "(type eq '${EnumRouteType.transport.value}')";
    filter += " and (status eq 'Completed')";
    params["\$filter"] = filter;
    super.requestGetRoutesByParams(params, EnumRouteType.transport, callback);
  }

  @override
  Future<void> requestStartRoute(RouteDataModel route, NetworkManagerResponse? callback, {Map<String, dynamic>? params}) async {
    final Map<String, dynamic> params = {};
    final Map<String, dynamic> start = {};
    start["start"] = route.fOdometerStart;
    params["odometer"] = start;
    params["verification"] = LCLocationManager.sharedInstance.geoPoint.serialize();
    super.requestStartRoute(route, callback, params: params);
  }

  @override
  Future<void> requestUpdateActivityStatus(RouteDataModel route, ActivityDataModel activity, EnumActivityStatus status, NetworkManagerResponse? callback,
      {Map<String, dynamic>? params}) async {
    super.requestUpdateActivityStatus(route, activity, status, callback, params: {});
  }

  @override
  Future<void> requestUpdatePayloads(RouteDataModel route, ActivityDataModel activity, NetworkManagerResponse? callback, {Map<String, dynamic>? params}) async {
    final params = activity.serializeForUpdateTransportPayloads();
    super.requestUpdatePayloads(
      route,
      activity,
      callback,
      params: params,
    );
  }

  Future<void> requestSubmitOutcomeResults(RouteDataModel route, NetworkManagerResponse? callback) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      callback?.call(NetworkResponseDataModel.forFailure());
      return;
    }

    final String urlString = UrlManager.routeApi.submitOutcomeResults(transOrg.organizationId, route.id);
    final Map<String, dynamic> params = route.serializeForOutcomeResults();

    try {
      NetworkResponseDataModel responseDataModel = await NetworkManager.put(urlString, params, EnumNetworkAuthOptions.authRequired.value);
      if (responseDataModel.isSuccess) {
        requestGetRouteById(route.id, callback);
      } else {
        callback?.call(NetworkResponseDataModel.forFailure());
      }
    } catch (e) {
      callback?.call(NetworkResponseDataModel.forFailure());
    }
  }

  // Driver's Geo-Location
  requestUpdateDriverLocationForAllRoutes() {
    // Update location for all En-Route routes of Today
    final today = DateTime.now();
    final yesterday = UtilsDate.addDaysToDate(today, -1);
    final tomorrow = UtilsDate.addDaysToDate(today, 1);
    UtilsGeneral.log("[Route Manager - requestUpdateDriverLocationForAllRoutes] - Starting...");
    int count = 0;
    for (var route in arrayRoutes) {
      if (route.enumStatus == EnumRouteStatus.enRoute) {
        if (route.isRouteForBetweenDates(yesterday, tomorrow)) {
          //TODO ADD SocketRequestManager
          //SocketRequestManager.sharedInstance.emitDriverLocationUpdateForRoute(routeId = route.id)
          /*
                    // If driver is still not arrived at first stop, we manually post location to server.
                    if let firstLocation = route.arrayLocations.first, firstLocation.enumStatus == EnumRouteLocationStatus.EN_ROUTE {
//                        self.requestUpdateDriverLocationForRouteById(route.id, Callback: nil)
                    }
 */
          count += 1;
        }
      }
    }
    UtilsGeneral.log("[Route Manager - requestUpdateDriverLocationForAllRoutes] - Uploaded Routes = $count");
  }
}
