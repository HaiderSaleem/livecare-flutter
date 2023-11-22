import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/request/base_request_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/dataModel/schedule_data_model.dart';

class TransportRequestManager extends BaseRequestManager {
  TransportRequestManager() {
    initialize();
  }

  static final TransportRequestManager sharedInstance = TransportRequestManager();

  requestCreateRequest(RequestDataModel request, NetworkManagerResponse? callback) {
    final urlString = UrlManager.requestApi.createRequest(request.refOrganization.organizationId);
    NetworkManager.post(urlString, request.serializeForCreateTransport(), EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      callback?.call(responseDataModel);
    });
  }

  requestCreateSchedule(ScheduleDataModel schedule, NetworkManagerResponse? callback) {
    String urlString = UrlManager.requestApi.createSchedule(schedule.refOrganization.organizationId);
    if (schedule.enumRecurringType == EnumRequestRecurringType.none && !schedule.isRoundTrip) {
      urlString = UrlManager.requestApi.createRequest(schedule.refOrganization.organizationId);
    }

    NetworkManager.post(urlString, schedule.serializeForCreateTransport(), EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      callback?.call(responseDataModel);
    });
  }
}
