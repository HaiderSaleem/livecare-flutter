import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import '../../httpurlconnection/http_request_helper.dart';
import '../user/user_manager_test.dart';
import 'package:test/test.dart';

List<ConsumerDataModel> consumerArray = [];
var userManager = UserManagerTest();
var consumer = ConsumerDataModel();

void main() {
  setUp(() async {
    await UserManagerTest.loginUser();
  });

  test('ConsumerManager_getConsumersByOrganizationId', () async {
    var organization =
        UserManager.sharedInstance.currentUser!.getOrganizationByName("OnSeen");
    var orgId = organization!.organizationId;
    var responseDataModel = await HttpRequestHelper.sharedInstance.get(
        null, UrlManager.requestApi.getRequestsForConsumer(orgId, consumer.id));

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
}
