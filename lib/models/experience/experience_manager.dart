import 'package:flutter/cupertino.dart';
import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/experience/dataModel/experience_data_model.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/organization/dataModel/organization_data_model.dart';
import 'package:livecare/models/organization/organization_manager.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_general.dart';

class ExperienceManager {
  static final ExperienceManager _sharedInstance = ExperienceManager._internal();

  factory ExperienceManager() {
    return _sharedInstance;
  }

  ExperienceManager._internal();

  static ExperienceManager get sharedInstance => _sharedInstance;

  List<ExperienceDataModel> arrayExperiences = [];

  initialize() {
    arrayExperiences = [];
  }

  addExperienceIfNeeded(ExperienceDataModel newExp) {
    if (newExp.isValid() == false) return;

    int index = 0;
    for (var exp in arrayExperiences) {
      if (exp.id == newExp.id) {
        arrayExperiences.insert(index, newExp);
        exp.invalidate();
        return;
      }
      index = index + 1;
    }
    arrayExperiences.add(newExp);
  }

  ExperienceDataModel? getExperienceById(String experienceId) {
    for (var exp in arrayExperiences) {
      if (exp.id == experienceId) return exp;
    }

    return null;
  }

  Future<void> requestGetExperiencesByOrganizationId(String organizationId, NetworkManagerResponse callback) async {
    final String urlString = UrlManager.experienceApi.getExperiencesByOrganizationId(organizationId);

    NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess && UtilsBaseFunction.containsKey(responseDataModel.payload, "data")) {
        final List<dynamic> data = responseDataModel.payload["data"];
        for (int i in Iterable.generate(data.length)) {
          final Map<String, dynamic> dict = data[i];
          try {
            final exp = ExperienceDataModel();
            exp.deserialize(dict);
            addExperienceIfNeeded(exp);
          } catch (e) {
            print("Manager Exception--" + e.toString());
          }
        }
      }
      callback.call(responseDataModel);
    });
  }

  Future<void> requestGetExperienceById(String experienceId, NetworkManagerResponse callback) async {
    final urlString = UrlManager.experienceApi.getExperienceById(experienceId);

    NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        final exp = ExperienceDataModel();
        exp.deserialize(responseDataModel.payload);
        addExperienceIfNeeded(exp);
      }

      LocalNotificationManager.sharedInstance.notifyLocalNotification(UtilsGeneral.experienceListUpdated);
      callback.call(responseDataModel);
    });
  }

  requestGetExperiences(NetworkManagerResponse callback) {
    final valueNotifier = ValueNotifier(0);
    final List<OrganizationDataModel> arrayOrgs = OrganizationManager.sharedInstance.arrayOrganizations;

    arrayExperiences = [];

    var index = 0;
    for (var _ in arrayOrgs) {
      final OrganizationDataModel org = arrayOrgs[index];
      requestGetExperiencesByOrganizationId(org.id, (responseDataModel) {
        valueNotifier.value++;
      });
      index = index + 1;
    }

    valueNotifier.addListener(() {
      if (valueNotifier.value == arrayOrgs.length) {
        LocalNotificationManager.sharedInstance.notifyLocalNotification(UtilsGeneral.organizationListUpdated);
        callback.call(NetworkResponseDataModel.forSuccess());
      }
    });
  }

  Future<void> requestBeginExperience(ExperienceDataModel experience, NetworkManagerResponse callback) async {
    final location = experience.modelLocation;
    if (location == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    final urlString = UrlManager.experienceApi.beginExperience(experience.refOrganization.organizationId, location.id, experience.id);

    NetworkManager.put(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        // Reload Route from Server
        requestGetExperienceById(experience.id, callback);
      } else {
        callback.call(responseDataModel);
      }
    });
  }

  requestEndExperience(ExperienceDataModel experience, NetworkManagerResponse callback) {
    final location = experience.modelLocation;
    if (location == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    final urlString = UrlManager.experienceApi.endExperience(experience.refOrganization.organizationId, location.id, experience.id);

    NetworkManager.put(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        // Reload Route from Server
        requestGetExperienceById(experience.id, callback);
      } else {
        callback.call(responseDataModel);
      }
    });
  }

  requestCancelExperience(ExperienceDataModel experience, NetworkManagerResponse callback) {
    final location = experience.modelLocation;
    if (location == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    final urlString = UrlManager.experienceApi.cancelExperience(experience.refOrganization.organizationId, location.id, experience.id);

    NetworkManager.put(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        // Reload Route from Server
        requestGetExperienceById(experience.id, callback);
      } else {
        callback.call(responseDataModel);
      }
    });
  }
}
