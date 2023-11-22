import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/utils_date.dart';

class BaseRequestManager {
  static final BaseRequestManager _sharedInstance = BaseRequestManager._internal();

  BaseRequestManager() {
    initialize();
  }

  BaseRequestManager._internal();

  static BaseRequestManager get sharedInstance => _sharedInstance;

  List<RequestDataModel> arrayRequests = [];
  List<RequestDataModel> arrayServiceRequests = [];

  void initialize() {
    arrayRequests = [];
  }

  addRequestIfNeeded(RequestDataModel newRequest) {
    if (newRequest.enumStatus == EnumRequestStatus.cancelled) {
      deleteRequestIfNeeded(newRequest);
      return;
    }

    if (!newRequest.isValid()) return;

    int index = 0;
    for (var request in arrayRequests) {
      if (request.id == newRequest.id) {
        arrayRequests[index] = newRequest;
        request.invalidate();
        return;
      }
      index += 1;
    }
    arrayRequests.add(newRequest);
  }

  addServiceRequestIfNeeded(RequestDataModel newRequest) {
    if (newRequest.enumStatus == EnumRequestStatus.cancelled) {
      deleteRequestIfNeeded(newRequest);
      return;
    }

    if (!newRequest.isValid()) return;

    int index = 0;
    for (var request in arrayServiceRequests) {
      if (request.id == newRequest.id) {
        arrayServiceRequests[index] = newRequest;
        request.invalidate();
        return;
      }
      index += 1;
    }
    arrayServiceRequests.add(newRequest);
  }

  appendRequestsFromArray(List<RequestDataModel>? requests) {
    if (requests == null) return;

    for (var request in requests) {
      addRequestIfNeeded(request);
    }
  }

  deleteRequestIfNeeded(RequestDataModel deleteRequest) {
    var index = 0;
    for (var request in arrayRequests) {
      if (request.id == deleteRequest.id) {
        request.invalidate();
        arrayRequests.removeAt(index);
        return;
      }
      index += 1;
    }

    var index1 = 0;
    for (var request in arrayServiceRequests) {
      if (request.id == deleteRequest.id) {
        request.invalidate();
        arrayServiceRequests.removeAt(index1);
        return;
      }
      index1 += 1;
    }
  }

  RequestDataModel? getRequestById(String requestId) {
    for (var request in arrayRequests) {
      if (request.id == requestId) {
        return request;
      }
    }

    for (var request in arrayServiceRequests) {
      if (request.id == requestId) {
        return request;
      }
    }

    return null;
  }

  List<RequestDataModel> getRequestsByOrganizationId(String organizationId) {
    final List<RequestDataModel> array = [];
    for (var request in arrayRequests) {
      if (request.refOrganization.organizationId == organizationId) {
        array.add(request);
      }
    }
    return array;
  }

  List<RequestDataModel> getRequestsForMe() {
    if (UserManager.sharedInstance.currentUser == null) return [];

    return getRequestsByTransferId(UserManager.sharedInstance.currentUser!.id);
  }

  List<RequestDataModel> getRequestsByConsumerId(String consumerId) {
    return getRequestsByTransferId(consumerId);
  }

  List<RequestDataModel> getRequestsByTransferId(String transferId) {
    final List<RequestDataModel> array = [];
    for (var request in arrayRequests) {
      if (request.checkTransferById(transferId)) {
        array.add(request);
      }
    }
    return array;
  }

  Future<void> requestGetRequestsForMe(bool forceReload, EnumRouteType? type, NetworkManagerResponse? callback) async {
    if (!forceReload) {
      final List<RequestDataModel> array = getRequestsForMe();
      final response = NetworkResponseDataModel.forSuccess();
      response.parsedObject = array;
      callback?.call(response);
      return;
    }
    final startDate = DateTime.now().subtract(const Duration(days: 1));

    final Map<String, dynamic> params = {};
    if (type != null) {
      params["\$top"] = "1000";
      params["\$skip"] = "0";
      params["\$orderby"] = "time asc";
      params["\$inlinecount"] = "allpages";
      var filter = "(type eq '${type.value}')";
      filter +=
          " and (status ne 'Cancelled' and status ne 'Completed') and (time ge '${UtilsDate.getStringFromDateTimeWithFormat(startDate, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true)}')";
      params["\$filter"] = filter;
    }
    final String urlString = UrlManager.requestApi.getRequestsForMe();

    NetworkManager.get(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data")) {
        final List<dynamic> data = responseDataModel.payload["data"];
        final List<RequestDataModel> array = [];

        for (int i in Iterable.generate(data.length)) {
          final dict = data[i];
          final request = RequestDataModel();
          request.deserialize(dict);
          if (request.isValid()) {
            array.add(request);
            if (type == EnumRouteType.service) {
              addServiceRequestIfNeeded(request);
            } else {
              addRequestIfNeeded(request);
            }
          }
        }
        final result = NetworkResponseDataModel.forSuccess();
        result.parsedObject = array;
        callback?.call(result);
      } else {
        callback?.call(NetworkResponseDataModel.forFailure());
      }
    });
  }

  Future<void> requestGetRequestForMe(String requestId, bool forceReload, NetworkManagerResponse? callback) async {
    if (!forceReload) {
      final RequestDataModel? request = getRequestById(requestId);
      final response = NetworkResponseDataModel.forSuccess();
      response.parsedObject = request;
      callback?.call(response);
      return;
    }

    final String urlString = UrlManager.serviceRequestApi.getRequestForMeById(requestId);

    final responseDataModel = await NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value);
    if (responseDataModel.isSuccess) {
      final request = RequestDataModel();
      request.deserialize(responseDataModel.payload);

      if (request.isValid()) {
        if (request.enumType == EnumRequestType.transport) {
          addRequestIfNeeded(request);
        } else {
          addServiceRequestIfNeeded(request);
        }
        responseDataModel.parsedObject = request;
      }
      callback?.call(responseDataModel);
    } else {
      callback?.call(NetworkResponseDataModel.forFailure());
    }
  }

  Future<void> requestGetServiceRequestsForConsumer(ConsumerDataModel consumer, bool forceReload, NetworkManagerResponse? callback) async {
    if (!forceReload) {
      final List<RequestDataModel> array = getRequestsByConsumerId(consumer.id);
      if (array.isNotEmpty) {
        final response = NetworkResponseDataModel.forSuccess();
        response.parsedObject = array;
        callback?.call(response);
        return;
      }
    }

    final startDate = DateTime.now().subtract(const Duration(days: 1));

    final Map<String, dynamic> params = {
      "\$top": "1000",
      "\$skip": "0",
      "\$orderby": "time asc",
      "\$inlinecount": "allpages",
      "\$filter":
          "type eq '${EnumRouteType.service.value}' and status ne 'Cancelled' and status ne 'Completed' and status ne 'Error' and time ge '${UtilsDate.getStringFromDateTimeWithFormatToApi(startDate, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true)}'"
    };

    final String urlString = UrlManager.requestApi.getRequestsForConsumer(consumer.organizationId, consumer.id);
    final responseDataModel = await NetworkManager.get(urlString, params, EnumNetworkAuthOptions.authRequired.value);

    if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data")) {
      final List<dynamic> data = responseDataModel.payload["data"];
      final List<RequestDataModel> array = data.map((dict) {
        final request = RequestDataModel()..deserialize(dict);
        addRequestIfNeeded(request);
        return request;
      }).toList();

      final result = NetworkResponseDataModel.forSuccess();
      result.parsedObject = array;
      callback?.call(result);
    } else {
      callback?.call(responseDataModel);
    }
  }

  Future<void> requestGetRequestsForConsumer(ConsumerDataModel consumer, bool forceReload, NetworkManagerResponse? callback) async {
    if (!forceReload) {
      final List<RequestDataModel> array = getRequestsByConsumerId(consumer.id);
      if (array.isNotEmpty) {
        final response = NetworkResponseDataModel.forSuccess();
        response.parsedObject = array;
        callback?.call(response);
        return;
      }
    }

    //final DateTime startDate = UtilsDate.addDaysToDate(DateTime.now(), -1);
    final startDate = DateTime.now().subtract(const Duration(days: 1));

    final Map<String, dynamic> params = {};
    params["\$top"] = "1000";
    params["\$skip"] = "0";
    params["\$orderby"] = "time asc";
    params["\$inlinecount"] = "allpages";
    var filter = "(type eq '${EnumRouteType.transport.value}' or type eq '${EnumRouteType.service.value}')";
    filter += " and (status ne 'Cancelled' and status ne 'Completed' and status ne 'Error') and (time ge "
        "'${UtilsDate.getStringFromDateTimeWithFormatToApi(startDate, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true)}')";
    params["\$filter"] = filter;

    final String urlString = UrlManager.requestApi.getRequestsForConsumer(consumer.organizationId, consumer.id);
    NetworkManager.get(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data")) {
        final List<dynamic> data = responseDataModel.payload["data"];
        final List<RequestDataModel> array = [];

        for (int i in Iterable.generate(data.length)) {
          final dict = data[i];
          final request = RequestDataModel();
          request.deserialize(dict);
          array.add(request);
          addRequestIfNeeded(request);
        }

        final result = NetworkResponseDataModel.forSuccess();
        result.parsedObject = array;
        callback?.call(result);
      } else {
        callback?.call(responseDataModel);
      }
    });
  }

  Future<void> requestUpdateRequest(RequestDataModel request, Map<String, dynamic> newParam, EnumRequestType type, NetworkManagerResponse? callback) async {
    final consumerId = request.getPrimaryConsumerId();
    String urlString = "";
    if (type == EnumRequestType.transport) {
      urlString = UrlManager.requestApi.updateRequest(request.refOrganization.organizationId, request.id, consumerId);
    } else if (type == EnumRequestType.service) {
      urlString = UrlManager.serviceRequestApi.updateRequest(request.refOrganization.organizationId, request.id);
    }
    NetworkManager.put(urlString, newParam, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      callback?.call(responseDataModel);
    });
  }

  Future<void> requestCancelRequest(RequestDataModel request, String reason, EnumRequestType type, NetworkManagerResponse? callback) async {
    String urlString = "";
    if (type == EnumRequestType.transport) {
      urlString = UrlManager.requestApi.cancelRequest(request.refOrganization.organizationId, request.id);
    } else if (type == EnumRequestType.service) {
      urlString = UrlManager.serviceRequestApi.cancelRequest(request.refOrganization.organizationId, request.id);
    }

    final Map<String, dynamic> params = {};
    params["cancelReason"] = reason;

    NetworkManager.post(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        request.enumStatus = EnumRequestStatus.cancelled;
      }

      callback?.call(responseDataModel);
    });
  }

  Future<void> requestGetRequestsForRoute(String organizationId, String routeId, NetworkManagerResponse? callback) async {
    final String urlString = UrlManager.requestApi.getRequestsForRoute(organizationId, routeId);

    NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data")) {
        final List<dynamic> data = responseDataModel.payload["data"];
        final List<RequestDataModel> array = [];
        for (int i in Iterable.generate(data.length)) {
          final dict = data[i];
          final request = RequestDataModel();
          request.deserialize(dict);
          if (request.isValid()) {
            array.add(request);
            addRequestIfNeeded(request);
          }
        }
        final result = NetworkResponseDataModel.forSuccess();
        result.parsedObject = array;
        callback?.call(result);
      } else {
        callback?.call(responseDataModel);
      }
    });
  }

  //Offline Logic
  Future<void> updateRequestOffline(RequestDataModel currentRequest, EnumRequestStatus? enumStatus) async {
    var index = 0;
    for (var request in arrayServiceRequests) {
      if (request.id == currentRequest.id) {
        final date = UtilsDate.getStringFromDateTimeWithFormat(DateTime.now(), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
        currentRequest.dateUpdatedAt = UtilsDate.getDateTimeFromStringWithFormatToApi(date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
        if (enumStatus != null) currentRequest.enumStatus = enumStatus;
        arrayServiceRequests[index] = currentRequest;
        request.invalidate();
        return;
      }
      index += 1;
    }
  }

  Future<NetworkResponseDataModel?> sendRequest(request) async {
    if (request.isEmpty) return null;
    final method = request.method;
    if (method == null) return null;

    Future<NetworkResponseDataModel> response;

    switch (method) {
      case "PUT":
        response = NetworkManager.put(request.endpoint, request.params, request.authOptions);
        break;
      case "GET":
        response = NetworkManager.get(request.endpoint, request.params, request.authOptions);
        break;
      case "POST":
        response = NetworkManager.post(request.endpoint, request.params, request.authOptions);
        break;
      default:
        return null;
    }

    return await response;
  }
}
