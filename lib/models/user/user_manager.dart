import 'dart:convert';
import 'dart:io';

import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/organization/dataModel/organization_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/organization/organization_manager.dart';
import 'package:livecare/models/user/dataModel/user_data_model.dart';
import 'package:livecare/utils/local_storage_manager.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';

import '../communication/network_response_data_model.dart';

class UserManager {
  static const localStorageKey = "USER";
  UserDataModel? currentUser;
  String authToken = "testAuthToken";

  static UserManager sharedInstance = UserManager();

  initialize() {
    currentUser = null;
  }

  bool isLoggedIn() {
    return (currentUser != null && authToken.isNotEmpty && currentUser!.isValid());
  }

  logout() {
    initialize();
    LocalStorageManager.deleteGlobalObject(localStorageKey);
  }

  String getAuthToken() {
    return authToken;
  }

  updateAuthToken(String? authToken) {
    if (authToken == null) return;
    if (authToken.isNotEmpty) {
      this.authToken = authToken;
    }
  }

  // bool isFuseGuardianUser(){
  //   var userOrg = currentUser?.getPrimaryOrganization();
  //   if(userOrg==null) return true;
  //
  //   if (currentUser?.getRoleByOrganizationId(userOrg.organizationId) == EnumOrganizationUserRole.guardian &&
  //       equalsIgnoreCase(userOrg.szName, "FUSE")
  //   ) {
  //     return false;
  //   }
  //   return true;
  // }

  bool equalsIgnoreCase(String? string1, String? string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  bool isGuardianUser() {
    var userOrg = currentUser?.getPrimaryOrganization();
    if (userOrg == null) return false;

    if (currentUser?.getRoleByOrganizationId(userOrg.organizationId) == EnumOrganizationUserRole.guardian) {
      return true;
    }
    return false;
  }

/*

fun isGuardianUser(): Boolean {

val userOrg = currentUser?.getPrimaryOrganization() ?: return false

if (currentUser?.getRoleByOrganizationId(userOrg.organizationId) == EnumOrganizationUserRole.GUARDIAN
) {
return true
}
return false
}*/

  List<EnumAccessControlItem> getAccessControlItems() {
    if (currentUser == null) {
      return [];
    }
    final user = currentUser!;
    final role = user.getPrimaryRole();

    final primaryOrg = user.getPrimaryOrganization()?.organizationId != null
        ? OrganizationManager.sharedInstance.getOrganizationById(user.getPrimaryOrganization()?.organizationId ?? "")
        : null;

    if (primaryOrg != null) {
      return AccessControlItemExtension.getAccessControlItemsByRoleAndOrgType(role, primaryOrg.enumType, primaryOrg.arrayComponents);
    }

    return [];
  }

  bool isAccessControlItem(EnumAccessControlItem item) {
    final aclItems = getAccessControlItems();
    for (var aclItem in aclItems) {
      if (aclItem == item) {
        return true;
      }
    }
    return false;
  }

  saveToLocalStorage() {
    if (!isLoggedIn()) return;
    final Map<String, dynamic> params = {"user_data": jsonEncode(currentUser!.serializeForLocalstorage()).toString(), "auth_token": authToken};
    print(currentUser!.serializeForLocalstorage());

    LocalStorageManager.saveGlobalObject(jsonEncode(params).toString(), localStorageKey);
  }

  loadFromLocalStorage() async {
    final String? strParams = await LocalStorageManager.loadGlobalObject(localStorageKey);
    if (strParams == null || strParams == "") {
      currentUser = null;
      return;
    }

    final Map<String, dynamic> dictUserData = jsonDecode(strParams);
    authToken = UtilsString.parseString(dictUserData["auth_token"]);
    currentUser = UserDataModel();
    currentUser!.deserializeFromLocalstorage(jsonDecode(dictUserData["user_data"]));
  }

  Future<void> requestUserLogin(String email, String password, NetworkManagerResponse callback) async {
    final urlString = UrlManager.userApi.login();
    final Map<String, dynamic> params = {"email": email.toLowerCase(), "password": password};

    try {
      NetworkResponseDataModel responseDataModel = await NetworkManager.post(urlString, params, EnumNetworkAuthOptions.authShouldUpdate.value);

      if (responseDataModel.isSuccess) {
        currentUser = UserDataModel();
        currentUser!.deserialize(responseDataModel.payload);
        currentUser!.szPassword = password;
        UtilsGeneral.log("[User Login] token = " + authToken);
        await OrganizationManager.sharedInstance.requestGetOrganizations(currentUser!.id, callback);
      } else {
        callback.call(responseDataModel);
      }
    } catch (e) {
      print('Error during user login: $e');
      callback.call(NetworkResponseDataModel.forFailure());
    }
  }

  //API calls
  Future<void> requestSsoAuth(String token, NetworkManagerResponse callback) async {
    final urlString = UrlManager.userApi.ssoAuth();
    final Map<String, dynamic> params = {"token": token};

    try {
      NetworkResponseDataModel responseDataModel = await NetworkManager.post(urlString, params, EnumNetworkAuthOptions.authShouldUpdate.value);

      if (responseDataModel.isSuccess) {
        currentUser = UserDataModel();
        currentUser!.deserialize(responseDataModel.payload);
        UtilsGeneral.log("[User Login] token = " + authToken);
        await OrganizationManager.sharedInstance.requestGetOrganizations(currentUser!.id, callback);
      } else {
        callback.call(responseDataModel);
      }
    } catch (e) {
      callback.call(NetworkResponseDataModel.forFailure());
    }
  }

  Future<void> requestUserSignUp(String name, String email, String password, String phone, NetworkManagerResponse callback) async {
    final urlString = UrlManager.userApi.signup();
    final Map<String, dynamic> params = {
      "name": name,
      "username": email.toLowerCase(),
      "email": email.toLowerCase(),
      "phoneNumber": phone,
      "password": password
    };

    try {
      NetworkResponseDataModel responseDataModel = await NetworkManager.post(urlString, params, EnumNetworkAuthOptions.authShouldUpdate.value);

      if (responseDataModel.isSuccess) {
        currentUser = UserDataModel();
        currentUser!.deserialize(responseDataModel.payload);
        UtilsGeneral.log("[User Login] token = " + authToken);
        currentUser!.szPassword = password;
        await OrganizationManager.sharedInstance.requestGetOrganizations(currentUser!.id, callback);
      } else {
        callback.call(responseDataModel);
      }
    } catch (e) {
      callback.call(NetworkResponseDataModel.forFailure());
    }
  }

  Future<void> requestForgotPassword(String email, NetworkManagerResponse callback) async {
    final urlString = UrlManager.userApi.forgotPassword();
    final Map<String, dynamic> params = {"email": email.toLowerCase()};

    try {
      NetworkResponseDataModel responseDataModel = await NetworkManager.post(urlString, params, EnumNetworkAuthOptions.authNone.value);
      callback.call(responseDataModel);
    } catch (e) {
      callback.call(NetworkResponseDataModel.forFailure());
    }
  }

  Future<void> requestUpdateUserPhoto(File image, NetworkManagerResponse callback) async {
    final urlString = UrlManager.userApi.uploadProfilePhoto();

    try {
      NetworkResponseDataModel responseDataModel = await NetworkManager.upload(urlString, "file", true, image, EnumNetworkAuthOptions.authRequired.value);
      if (responseDataModel.isSuccess) {
        var url = UtilsString.parseString(responseDataModel.payload["url"]);
        currentUser!.szPhoto = url;
      }
      callback.call(responseDataModel);
    } catch (e) {
      callback.call(NetworkResponseDataModel.forFailure());
    }
  }

  Future<void> requestUpdateUserWithDictionary(Map<String, dynamic> dictionary, NetworkManagerResponse callback) async {
    final urlString = UrlManager.userApi.updateMyProfile();

    try {
      NetworkResponseDataModel responseDataModel = await NetworkManager.put(urlString, dictionary, EnumNetworkAuthOptions.authRequired.value);
      if (responseDataModel.isSuccess) {
        currentUser!.deserialize(responseDataModel.payload);
        if (dictionary.containsKey("password")) {
          final password = UtilsString.parseString(dictionary["password"]);
          currentUser!.szPassword = password;
        }
      }
      callback.call(responseDataModel);
    } catch (e) {
      callback.call(NetworkResponseDataModel.forFailure());
    }
  }

  Future<void> requestGetMyProfile(NetworkManagerResponse callback) async {
    final urlString = UrlManager.userApi.getMyProfile();

    try {
      NetworkResponseDataModel responseDataModel = await NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value);
      if (responseDataModel.isSuccess) {
        currentUser!.deserialize(responseDataModel.payload);
      }
      callback.call(responseDataModel);
    } catch (e) {
      callback.call(NetworkResponseDataModel.forFailure());
    }
  }
}

enum EnumAccessControlItem {
  consumerLedgers,
  transactionsNew,
  transactionsHistory,
  transactionsAudit,
  transportRequests,
  serviceRequests,
  experiences,
  routes,
  routesHistory,
  calendar,
  availability,
  timeOff,
  settings,
  logOut,
  notifications
}

extension AccessControlItemExtension on EnumAccessControlItem {
  static List<EnumAccessControlItem> getAccessControlItemsByRoleAndOrgType(
      EnumOrganizationUserRole userRole, EnumOrganizationType orgType, List<EnumOrganizationComponent> orgComponents) {
    List<EnumAccessControlItem> items = [];
    if (orgType == EnumOrganizationType.service || orgType == EnumOrganizationType.transport) {
      if (userRole == EnumOrganizationUserRole.guardian) {
        if (orgComponents.contains(EnumOrganizationComponent.transport)) {
          items.addAll([EnumAccessControlItem.transportRequests]);
        }
      } else if (userRole == EnumOrganizationUserRole.driver) {
        if (orgComponents.contains(EnumOrganizationComponent.transport)) {
          items.addAll([
            EnumAccessControlItem.routes,
            EnumAccessControlItem.serviceRequests,
            EnumAccessControlItem.routesHistory,
            EnumAccessControlItem.calendar,
            EnumAccessControlItem.availability,
            EnumAccessControlItem.timeOff,
          ]);
        }
      }
      if (userRole == EnumOrganizationUserRole.administrator) {
        if (orgComponents.contains(EnumOrganizationComponent.ledger)) {
          items.addAll([
            EnumAccessControlItem.consumerLedgers,
            EnumAccessControlItem.transactionsNew,
            EnumAccessControlItem.transactionsHistory,
            EnumAccessControlItem.transactionsAudit,
          ]);
        }
        if (orgComponents.contains(EnumOrganizationComponent.transport)) {
          items.addAll([
            EnumAccessControlItem.transportRequests,
            EnumAccessControlItem.routes,
            EnumAccessControlItem.routesHistory,
            EnumAccessControlItem.calendar,
            EnumAccessControlItem.availability,
            EnumAccessControlItem.timeOff,
          ]);
        }
        if (orgComponents.contains(EnumOrganizationComponent.service)) {
          items.addAll([
            EnumAccessControlItem.serviceRequests,
          ]);
        }
        if (orgComponents.contains(EnumOrganizationComponent.experience)) {
          items.addAll([
            EnumAccessControlItem.experiences,
          ]);
        }
      } else if (userRole == EnumOrganizationUserRole.caregiver || userRole == EnumOrganizationUserRole.pm || userRole == EnumOrganizationUserRole.leadDSP) {
        if (orgComponents.contains(EnumOrganizationComponent.ledger)) {
          items.addAll([
            EnumAccessControlItem.consumerLedgers,
            EnumAccessControlItem.transactionsNew,
            EnumAccessControlItem.transactionsHistory,
            EnumAccessControlItem.transactionsHistory,
          ]);
        }
        if (orgComponents.contains(EnumOrganizationComponent.transport)) {
          items.addAll([
            EnumAccessControlItem.transportRequests,
            EnumAccessControlItem.routes,
            EnumAccessControlItem.routesHistory,
            EnumAccessControlItem.calendar,
            EnumAccessControlItem.availability,
            EnumAccessControlItem.timeOff,
          ]);
        }
        if (orgComponents.contains(EnumOrganizationComponent.service)) {
          items.addAll([
            EnumAccessControlItem.serviceRequests,
          ]);
        }
        if (orgComponents.contains(EnumOrganizationComponent.experience)) {
          items.addAll([
            EnumAccessControlItem.experiences,
          ]);
        }
      }
    }
    if (orgType == EnumOrganizationType.network) {
      if (orgComponents.contains(EnumOrganizationComponent.transport)) {
        items.addAll([
          EnumAccessControlItem.routes,
          EnumAccessControlItem.routesHistory,
          EnumAccessControlItem.calendar,
          EnumAccessControlItem.availability,
          EnumAccessControlItem.timeOff
        ]);
      }
    }

    items.addAll([EnumAccessControlItem.settings, EnumAccessControlItem.logOut]);
    return items;
  }

  int get value {
    switch (this) {
      case EnumAccessControlItem.consumerLedgers:
        return 0;
      case EnumAccessControlItem.transactionsNew:
        return 1;
      case EnumAccessControlItem.transactionsHistory:
        return 2;
      case EnumAccessControlItem.transactionsAudit:
        return 3;
      case EnumAccessControlItem.transportRequests:
        return 4;
      case EnumAccessControlItem.serviceRequests:
        return 5;
      case EnumAccessControlItem.experiences:
        return 6;
      case EnumAccessControlItem.routes:
        return 7;
      case EnumAccessControlItem.routesHistory:
        return 8;
      case EnumAccessControlItem.calendar:
        return 9;
      case EnumAccessControlItem.availability:
        return 10;
      case EnumAccessControlItem.timeOff:
        return 11;
      case EnumAccessControlItem.settings:
        return 12;
      case EnumAccessControlItem.logOut:
        return 13;
      case EnumAccessControlItem.notifications:
        return 14;
    }
  }
}
