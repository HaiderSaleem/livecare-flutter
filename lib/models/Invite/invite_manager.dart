import 'package:livecare/models/Invite/dataModel/invite_data_model.dart';
import 'package:livecare/models/appManager/app_manager.dart';
import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/network/api_provider.dart';
import 'package:livecare/utils/utils_general.dart';

class InviteManager {
  static InviteManager sharedInstance = InviteManager();
  List<InviteDataModel> arrayInvites = [];
  static final ApiProvider apiProvider = ApiProvider();

  initialize() {
    arrayInvites = [];
  }

  addInviteIfNeeded(InviteDataModel newInvite) {
    if (!newInvite.isValid()) return;
    if (!arrayInvites.any((invite) => invite.id == newInvite.id)) {
      arrayInvites.add(newInvite);
    }
  }

  List<InviteDataModel> getPendingInvites() {
    return arrayInvites.where((invite) => invite.enumStatus == EnumInvitationStatus.pending).toList();
  }

  Future<void> requestGetInvites(NetworkManagerResponse? callback) async {
    var currentUser = UserManager.sharedInstance.currentUser;
    if (currentUser == null) {
      callback?.call(NetworkResponseDataModel.forFailure());
      return;
    }

    var urlString = UrlManager.inviteApi.getInvites(currentUser.id);
    NetworkResponseDataModel responseDataModel = await NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value);

    if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data") && responseDataModel.payload["data"] != null) {
      final List<dynamic> data = responseDataModel.payload["data"];
      for (var dict in data) {
        var invite = InviteDataModel();
        invite.deserialize(dict);
        if (invite.isValid()) addInviteIfNeeded(invite);
      }
      LocalNotificationManager.sharedInstance.notifyLocalNotification(UtilsGeneral.inviteListUpdated);
    }
    callback?.call(responseDataModel);
  }

  Future<void> requestAcceptInvite(InviteDataModel invite, NetworkManagerResponse callback) async {
    var userId = UserManager.sharedInstance.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    var response = await NetworkManager.post(UrlManager.inviteApi.acceptInvite(userId, invite.token), null, EnumNetworkAuthOptions.authRequired.value);
    if (response.isSuccess) {
      invite.enumStatus = EnumInvitationStatus.accepted;
      UserManager.sharedInstance.requestGetMyProfile(callback);
      AppManager.sharedInstance.initializeManagersAfterInvitationAccepted();
    } else {
      callback.call(NetworkResponseDataModel.forFailure());
    }
  }

  Future<bool> requestDeclineInvite(InviteDataModel invite) async {
    var userId = UserManager.sharedInstance.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      return false;
    }

    var response = await NetworkManager.post(UrlManager.inviteApi.declineInvite(userId, invite.token), null, EnumNetworkAuthOptions.authRequired.value);
    if (response.isSuccess) {
      invite.enumStatus = EnumInvitationStatus.declined;
      return true;
    } else {
      return false;
    }
  }
}

