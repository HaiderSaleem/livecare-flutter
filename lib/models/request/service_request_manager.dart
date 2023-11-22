import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/request/base_request_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/dataModel/schedule_data_model.dart';

class ServiceRequestManager extends BaseRequestManager {
  ServiceRequestManager() {
    super.initialize();
  }

  static ServiceRequestManager sharedInstance = ServiceRequestManager();

  requestCreateRequest(
      RequestDataModel request, NetworkManagerResponse? callback) {
    final urlString = UrlManager.requestApi
        .createRequest(request.refOrganization.organizationId);
    NetworkManager.post(urlString, request.serializeForCreateService(),
        EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      callback?.call(responseDataModel);
    });
  }

  requestCreateSchedule(
      ScheduleDataModel schedule, NetworkManagerResponse? callback) {
    String urlString = UrlManager.serviceRequestApi
        .createSchedule();
    if (schedule.enumRecurringType == EnumRequestRecurringType.none) {
      urlString = UrlManager.serviceRequestApi
          .createRequest();
    }

    NetworkManager.post(urlString, schedule.serializeForCreateService(),
        EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      callback?.call(responseDataModel);
    });
  }
}
