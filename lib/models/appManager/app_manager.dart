import 'dart:convert';

import 'package:livecare/models/Invite/invite_manager.dart';
import 'package:livecare/models/appManager/dataModel/app_setting_data_model.dart';
import 'package:livecare/models/communication/socket_request_manager.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/form/form_manager.dart';
import 'package:livecare/models/organization/organization_manager.dart';
import 'package:livecare/models/request/base_request_manager.dart';
import 'package:livecare/models/transaction/transaction_manager.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/local_storage_manager.dart';

class AppManager {
  AppSettingDataModel modelSettings = AppSettingDataModel();
  static const localStorageKey = "APP_SETTINGS";
  static AppManager sharedInstance = AppManager();

  initializeManagersAfterLogin() {
    UserManager.sharedInstance.saveToLocalStorage();
    ConsumerManager.sharedInstance.requestGetConsumers(null);
    TransactionManager.sharedInstance.requestGetTransactions(null);
    InviteManager.sharedInstance.requestGetInvites(null);
    OrganizationManager.sharedInstance.requestGetOrganizations("me", null);
    //TransportRouteManager.sharedInstance.requestGetAllRoutes(null);
    FormManager.sharedInstance.requestGetForms(null);
    //BaseRequestManager.sharedInstance.requestGetRequestsForMe(true, null, null);
    SocketRequestManager.sharedInstance.disconnect();
    SocketRequestManager.sharedInstance.connectOnce();
    loadFromLocalStorage();
  }

  initializeManagersAfterLogout() {
    ConsumerManager.sharedInstance.initialize();
    TransactionManager.sharedInstance.initialize();
    // InviteManager.sharedInstance.initialize();
    OrganizationManager.sharedInstance.initialize();
    BaseRequestManager.sharedInstance.initialize();
  }

  initializeManagersAfterInvitationAccepted() {
    ConsumerManager.sharedInstance.requestGetConsumers(null);
    TransactionManager.sharedInstance.requestGetTransactions(null);
  }

  saveToLocalStorage() {
    final params = jsonEncode(modelSettings.serialize());
    LocalStorageManager.saveGlobalObject(params.toString(), localStorageKey);
  }

  loadFromLocalStorage() async {
    final strParams = await LocalStorageManager.loadGlobalObject(localStorageKey);
    if (strParams == null || strParams == "") {
      modelSettings.initialize();
      return;
    }
    final Map<String, dynamic> dictSettingData = jsonDecode(strParams);
    modelSettings.deserialize(dictSettingData);
  }
}
