import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/request/base_request_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/dataModel/schedule_data_model.dart';

import '../user/user_manager.dart';

class HomeServiceRequestManager extends BaseRequestManager {
  static final HomeServiceRequestManager _sharedInstance = HomeServiceRequestManager._internal();

  factory HomeServiceRequestManager() {
    return _sharedInstance;
  }

  HomeServiceRequestManager._internal();

  static HomeServiceRequestManager get sharedInstance => _sharedInstance;

  homeRequestCreateRequest(String consumerId, RequestDataModel request, NetworkManagerResponse? callback) {
    var organization = UserManager.sharedInstance.currentUser!.getOrganizationByName("OnSeen");
    var orgId = organization!.organizationId;
    final urlString = UrlManager.homeRequestApi.createHomeServiceRequest(orgId, consumerId);

    NetworkManager.post(urlString, request.serializeForCreateTransport(), EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      callback?.call(responseDataModel);
    });
  }

  homeRequestCreateSchedule(String consumerId, ScheduleDataModel schedule, NetworkManagerResponse? callback) {
    var organization = UserManager.sharedInstance.currentUser!.getOrganizationByName("OnSeen");
    var orgId = organization!.organizationId;
    String urlString = UrlManager.homeRequestApi.createHomeServiceSchedule(orgId, consumerId);

    if (schedule.enumRecurringType == EnumRequestRecurringType.none && !schedule.isRoundTrip) {
      urlString = UrlManager.requestApi.createRequest(schedule.refOrganization.organizationId);
    }

    NetworkManager.post(urlString, schedule.serializeForCreateTransport(), EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      callback?.call(responseDataModel);
    });
  }
}
