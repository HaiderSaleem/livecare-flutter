import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/organization/dataModel/organization_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/network/api_provider.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_general.dart';

class OrganizationManager {
  List<OrganizationDataModel> arrayOrganizations = [];
  static final ApiProvider apiProvider = ApiProvider();

  static OrganizationManager sharedInstance = OrganizationManager();

  initialize() {
    arrayOrganizations = [];
  }

  addOrganizationIfNeeded(OrganizationDataModel newOrg) {
    if (!newOrg.isValid()) return;

    for (var org in arrayOrganizations) {
      if (org.id == newOrg.id) return;
    }
    arrayOrganizations.add(newOrg);
  }

  OrganizationDataModel? getOrganizationById(String organizationId) {
    for (var org in arrayOrganizations) {
      if (org.id == organizationId) return org;
    }
    return null;
  }

  allowConsumerRequests(String organizationId) {
    OrganizationDataModel? org = getOrganizationById(organizationId);
    if (org != null) {
      return org.allowConsumerRequests;
    }
    return true;
  }


  Future requestGetOrganizations2(String userId,NetworkManagerResponse? callback) async {
    final String urlString = UrlManager.organizationApi.getOrganizations(userId);

    NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess && UtilsBaseFunction.containsKey(responseDataModel.payload, "data")) {
        final List<dynamic> data = responseDataModel.payload["data"];
        final List<OrganizationDataModel> array = [];
        for (int i in Iterable.generate(data.length)) {
          final dict = data[i];
          final org = OrganizationDataModel();
          org.deserialize(dict);
          if (org.isValid()) array.add(org);
        }

        arrayOrganizations.clear();
        arrayOrganizations.addAll(array);

        callback?.call(responseDataModel);
        return;
      }
      LocalNotificationManager.sharedInstance.notifyLocalNotification(UtilsGeneral.organizationListUpdated);
      callback?.call(responseDataModel);

    });
  }



  requestGetOrganizations(String userId,NetworkManagerResponse? callback) {
    final String urlString = UrlManager.organizationApi.getOrganizations(userId);

    NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess && UtilsBaseFunction.containsKey(responseDataModel.payload, "data")) {
        final List<dynamic> data = responseDataModel.payload["data"];
        final List<OrganizationDataModel> array = [];
        for (int i in Iterable.generate(data.length)) {
          final dict = data[i];
          final org = OrganizationDataModel();
          org.deserialize(dict);
          if (org.isValid()) array.add(org);
        }

        arrayOrganizations.clear();
        arrayOrganizations.addAll(array);

      }
      LocalNotificationManager.sharedInstance.notifyLocalNotification(UtilsGeneral.organizationListUpdated);
      callback?.call(responseDataModel);
    });
  }

  requestGetLocationsByOrganizationId(String organizationId, bool forceReload, NetworkManagerResponse? callback) {
    final organization = getOrganizationById(organizationId);
    if (organization == null) {
      final response = NetworkResponseDataModel.forFailure();
      callback?.call(response);
      return;
    }

    if (!forceReload) {
      if (organization.arrayLocations.isNotEmpty) {
        final response = NetworkResponseDataModel.forSuccess();
        response.parsedObject = organization.arrayLocations;
        callback?.call(response);
        return;
      }
    }

    final urlString = UrlManager.locationApi.getLocationsByOrganizationId(organizationId);

    NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess && UtilsBaseFunction.containsKey(responseDataModel.payload, "data")) {
        final List<dynamic> data = responseDataModel.payload["data"];
        final List<LocationDataModel> array = [];

        for (int i in Iterable.generate(data.length)) {
          final dict = data[i];
          final offer = LocationDataModel();
          offer.deserialize(dict);
          array.add(offer);
        }

        organization.arrayLocations.clear();
        organization.arrayLocations.addAll(array);
        responseDataModel.parsedObject = organization.arrayLocations;
        callback?.call(responseDataModel);
      }
    });
  }
}
