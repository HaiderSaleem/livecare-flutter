import 'package:livecare/models/user/user_manager.dart';

class ProfileViewModel {
  String szName = "";
  String szEmail = "";
  String szPhone = "";
  String szPhoto = "";

  bool isNotifyByEmail = false;
  bool isNotifyByMessage = false;
  bool isNotifyBySMS = false;

  initializeFromProfile() {
    if (UserManager.sharedInstance.currentUser != null) {
      szName = UserManager.sharedInstance.currentUser!.szName;
      szEmail = UserManager.sharedInstance.currentUser!.szEmail;
      szPhone = UserManager.sharedInstance.currentUser!.szPhone;
      szPhoto = UserManager.sharedInstance.currentUser!.szPhoto;

      isNotifyByEmail = UserManager.sharedInstance.currentUser!.isNotifyByEmail;
      isNotifyByMessage = UserManager.sharedInstance.currentUser!.isNotifyByMessage;
      isNotifyBySMS = UserManager.sharedInstance.currentUser!.isNotifyBySMS;
    }
    return;
  }

  Map<String, dynamic> serialize() {
    return {
      "name": szName,
      "email": szEmail,
      "phone": szPhone,
      "photo": szPhoto,
      "notifications": {
        "email": isNotifyByEmail,
        "message": isNotifyByMessage,
        "sms": isNotifyBySMS
      }
    };
  }
}
