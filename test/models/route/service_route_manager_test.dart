import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/form/dataModel/form_definition_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import '../../httpurlconnection/http_request_helper.dart';
import '../user/user_manager_test.dart';
import 'package:test/test.dart';

List<RouteDataModel> arrayRoutes = [];
var userManager = UserManagerTest();
var route = RouteDataModel();

void getMySchedule() async {
  var driverId = UserManager.sharedInstance.currentUser!.id;
  var organization =
      UserManager.sharedInstance.currentUser!.getOrganizationByName("OnSeen");
  var orgId = organization!.organizationId;

  Map<String, dynamic> params = {};

  var filter = "type eq '${EnumRouteType.service.value}'";
  filter += " and (status eq 'Scheduled' or status eq 'En Route')";

  params["\$filter"] = filter;

  var responseDataModel = await HttpRequestHelper.sharedInstance
      .get(params, UrlManager.routeApi.getRoutes(orgId, driverId));

  List<dynamic> data = responseDataModel.payload["data"];

  for (int i in Iterable.generate(data.length)) {
    var dict = data[i];
    var route = RouteDataModel();
    route.deserialize(dict);
    if (route.isValid()) {
      arrayRoutes.add(route);
    }
  }
}

void main() {
  setUp(() async {
    await UserManagerTest.loginUser();
    getMySchedule();
    if (arrayRoutes.isNotEmpty) {
      route = arrayRoutes[0];
    }
  });

  test('ServiceRouteManager_requestGetAllRoutes', () async {
    var driverId = UserManager.sharedInstance.currentUser!.id;
    var organization =
        UserManager.sharedInstance.currentUser!.getOrganizationByName("OnSeen");
    var orgId = organization!.organizationId;

    Map<String, dynamic> params = {};

    var filter = "type eq '${EnumRouteType.transport.value}'";
    filter += " and (status eq 'Scheduled' or status eq 'En Route')";

    params["\$filter"] = filter;

    var responseDataModel = await HttpRequestHelper.sharedInstance
        .get(params, UrlManager.routeApi.getRoutes(orgId, driverId));

    List<RouteDataModel> array = [];
    final List<dynamic> data = responseDataModel.payload["data"];

    for (int i in Iterable.generate(data.length)) {
      var dict = data[i];
      var route = RouteDataModel();
      route.deserialize(dict);
      if (route.isValid()) {
        array.add(route);
      }
    }
  });

  test('FormManager_getFormById', () async {

    var driverId = UserManager.sharedInstance.currentUser!.id;
        var organization =
            UserManager.sharedInstance.currentUser!.getOrganizationByName("OnSeen");
        var orgId = organization!.organizationId;
        var formId = route.arrayPreFormRefs[0].formId;

        var responseDataModel = await HttpRequestHelper.sharedInstance
            .get(null, UrlManager.routeFormsApi.getFormById(orgId, formId));
        var formDef = FormDefinitionDataModel();
        formDef.deserialize(responseDataModel.payload);
  });
}
