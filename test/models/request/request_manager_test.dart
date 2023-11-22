import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:test/test.dart';
import '../../httpurlconnection/http_request_helper.dart';
import '../user/user_manager_test.dart';

List<ConsumerDataModel> consumerArray = [];
var userManager = UserManagerTest();
var consumer = ConsumerDataModel();

void getConsumersByOrganizationId() async {
  var organization =
      UserManager.sharedInstance.currentUser!.getOrganizationByName("OnSeen");
  var orgId = organization!.organizationId;
  var responseDataModel = await HttpRequestHelper.sharedInstance
      .get(null, UrlManager.consumerApi.getOrganizationConsumers(orgId));

  expect(responseDataModel.isSuccess, true);

  var data = responseDataModel.payload["data"];
  for (int i in Iterable.generate(data.length)) {
    var dict = data[i];
    var consumer = ConsumerDataModel();
    consumer.deserialize(dict);
    if (consumer.isValid()) consumerArray.add(consumer);
  }
}

void main() {
  setUp(() async {
    userManager = UserManagerTest();
    await UserManagerTest.loginUser();
    getConsumersByOrganizationId();
    if (consumerArray.isNotEmpty) {
      consumer = consumerArray[0];
    }
  });

  test('RequestManager_requestGetRequestsForConsumer', () async {
    var organization =
        UserManager.sharedInstance.currentUser!.getOrganizationByName("OnSeen");
    var orgId = organization!.organizationId;
    var responseDataModel = await HttpRequestHelper.sharedInstance.get(
        null, UrlManager.requestApi.getRequestsForConsumer(orgId, consumer.id));

    if (responseDataModel.isSuccess) {
      final List<dynamic> data = responseDataModel.payload["data"];
      List<RequestDataModel> array = [];
      for (int i in Iterable.generate(data.length)) {
        var dict = data[i];
        var request = RequestDataModel();
        request.deserialize(dict);
        if (request.isValid()) {
          array.add(request);
        }
      }
    }
  });

  test('RequestManager_getRequestsForMe', () async {
    var responseDataModel = await HttpRequestHelper.sharedInstance
        .get(null, UrlManager.requestApi.getRequestsForMe());

    if (responseDataModel.isSuccess) {
      List<RequestDataModel> array = [];
      final List<dynamic> data = responseDataModel.payload["data"];

      for (int i in Iterable.generate(data.length)) {
        var dict = data[i];
        var request = RequestDataModel();
        request.deserialize(dict);
        if (request.isValid()) {
          array.add(request);
        }
      }
    }
  });

  test('RequestManager_getRequestsForMe_includeId', () async {
    var requestId = "";
    var responseDataModel = await HttpRequestHelper.sharedInstance
        .get(null, UrlManager.requestApi.getRequestsForMe());

    if (responseDataModel.isSuccess) {
      final List<dynamic> data = responseDataModel.payload["data"];

      for (int i in Iterable.generate(data.length)) {
        var dict = data[i];
        var request = RequestDataModel();
        request.deserialize(dict);
        if (request.isValid()) {
          requestId = request.id;
          break;
        }
      }
    }

    responseDataModel = await HttpRequestHelper.sharedInstance
        .get(null, UrlManager.serviceRequestApi.getRequestForMeById(requestId));
    var request = RequestDataModel();
    request.deserialize(responseDataModel.payload);
  });

  ///

// //    This is Routes
test('RequestManager_requestGetRequestsForRoute', () async {
         var driverId = UserManager.sharedInstance.currentUser!.id;
        var organization =
            UserManager.sharedInstance.currentUser!.getOrganizationByName("OnSeen");
        var orgId = organization!.organizationId;
        Map<String, dynamic> params = {};

        var filter = "type eq '${EnumRouteType.transport.value}'";
        filter += " and (status eq 'Scheduled' or status eq 'En Route')";

        params["\$filter"] = filter;

        var responseDataModel = await HttpRequestHelper.sharedInstance
            .get( params, UrlManager.routeApi.getRoutes(orgId, driverId));

         List<RouteDataModel> array = [];
         final List<dynamic> data = responseDataModel.payload["data"];

        for (int i in Iterable.generate(data.length)) {
            var dict = data[i];
            var route = RouteDataModel();
            route.deserialize(dict);

            var responseRequestDataModel = await HttpRequestHelper.sharedInstance
                .get(params, UrlManager.requestApi.getRequestsForRoute(orgId, route.id));

            List<RequestDataModel> arrayRequests = [];
            final List<dynamic> dataRequest = responseRequestDataModel.payload["data"];

            for (int x in Iterable.generate(dataRequest.length)) {
                var dictReq = data[x];
                var request = RequestDataModel();
                request.deserialize(dictReq);
                if (request.isValid()) {
                    arrayRequests.add(request);
                }
            }
        }
      });
}
