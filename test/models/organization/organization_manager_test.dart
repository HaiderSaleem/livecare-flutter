import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/organization/dataModel/organization_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import '../../httpurlconnection/http_request_helper.dart';
import '../user/user_manager_test.dart';
import 'package:test/test.dart';

List<OrganizationDataModel> organizationArray = [];
var userManager = UserManagerTest();

void main() {
  setUp(() async {
    await UserManagerTest.loginUser();
    organizationArray = [];
    await requestGetOrganizations_getOrganizations();
  });

  test(
      'requestGetOrganizations_organizationArraySizeEqualsUserOrganizationArraySize',
      () {
    var userOrganizationsArray =
        UserManager.sharedInstance.currentUser!.arrayOrganizations;
    expect(organizationArray.length, userOrganizationsArray.length);
  });

  test(
      'requestGetOrganizations_organizationArrayIdsEqualsUserOrganizationArrayIds',
      () {
    var userOrganizationsArray =
        UserManager.sharedInstance.currentUser?.arrayOrganizations;

    for (var org in organizationArray) {
      var orgMatch = false;
      for (var userOrg in userOrganizationsArray!) {
        if (userOrg.organizationId == org.id) {
          orgMatch = true;
        }
      }
      expect(orgMatch, orgMatch = true);
    }
  });

  test('OrganizationManager_requestGetLocationsByOrganizationId', () async {
    var organization =
        UserManager.sharedInstance.currentUser!.getOrganizationByName("OnSeen");

    var orgId = organization!.organizationId;

    var responseDataModel = await HttpRequestHelper.sharedInstance
        .get(null, UrlManager.locationApi.getLocationsByOrganizationId(orgId));

    List<LocationDataModel> array = [];

    final List<dynamic> data = responseDataModel.payload["data"];

    for (int i in Iterable.generate(data.length)) {
      var dict = data[i];
      var location = LocationDataModel();
      location.deserialize(dict);
      if (location.isValid()) {
        array.add(location);
      }
    }
  });
}

Future requestGetOrganizations_getOrganizations() async {
  var userId = UserManager.sharedInstance.currentUser?.id;

  var organizationsResponse = await HttpRequestHelper.sharedInstance
      .get(null, UrlManager.organizationApi.getOrganizations(userId!));

  expect(organizationsResponse.code, EnumNetworkResponseCode.code200OK.value);

  List<dynamic> data = organizationsResponse.payload["data"];

  for (int i in Iterable.generate(data.length)) {
    var dict = data[i];
    var org = OrganizationDataModel();
    org.deserialize(dict);
    if (org.isValid()) organizationArray.add(org);
  }
}
