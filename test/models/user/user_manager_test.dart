import 'dart:core';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/user/dataModel/user_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:test/test.dart';

import '../../httpurlconnection/http_request_helper.dart';

var emailCorrect = "kevin.smith@onseen.com";
var emailIncorrect = "kevin.smith1@onseen.com";

var passwordCorrect = "xxxxx1!";
var passwordIncorrect = "yyyyy2!";

class UserManagerTest {
  static buildLoginBody(email, password) {
    return {"email": email, "password": password};
  }

  static Future loginUser() async {
    var body = buildLoginBody(emailCorrect, passwordCorrect);
    var loginResponse = await HttpRequestHelper.sharedInstance.post(body, UrlManager.userApi.login());
    UserManager.sharedInstance.currentUser = UserDataModel();
    UserManager.sharedInstance.currentUser!.deserialize(loginResponse.payload);
  }
}

void main() {
  group('User logged in ', () {
    test('RequestUserLogin_validUser', () async {
      var body = UserManagerTest.buildLoginBody(emailCorrect, passwordCorrect);

      var loginResponse = await HttpRequestHelper.sharedInstance.post(body, UrlManager.userApi.login());

      expect(loginResponse.code, EnumNetworkResponseCode.code200OK.value);
    });

    test('RequestUserLogin_invalidUser', () async {
      var body = UserManagerTest.buildLoginBody(emailIncorrect, passwordCorrect);

      var loginResponse = await HttpRequestHelper.sharedInstance.post(body, UrlManager.userApi.login());

      expect(loginResponse.code, EnumNetworkResponseCode.code401Unauthorized.value);
    });

    test('requestUserLogin_invalidPassword', () async {
      var body = UserManagerTest.buildLoginBody(emailIncorrect, passwordIncorrect);

      var loginResponse = await HttpRequestHelper.sharedInstance.post(body, UrlManager.userApi.login());

      expect(loginResponse.code, EnumNetworkResponseCode.code401Unauthorized.value);
    });

    test('requestGetMyProfile_getMyProfile', () async {
      await UserManagerTest.loginUser();
      var loginResponse = await HttpRequestHelper.sharedInstance.get(null, UrlManager.userApi.getMyProfile());

      expect(loginResponse.code, EnumNetworkResponseCode.code200OK.value);
    });

    test('requestUpdateUserWithDictionary_updateProfile', () async {
      await UserManagerTest.loginUser();
      Map<String, dynamic> params = {
        "phone": "6144325169",
        "notifications": {"message": true, "email": false, "sms": true}
      };

      var profileResponse = await HttpRequestHelper.sharedInstance.put(UrlManager.userApi.getMyProfile(), params, true);

      expect(profileResponse.code, EnumNetworkResponseCode.code200OK.value);
    });

    test('requestUpdateUserWithDictionary_updateProfileBadRequest', () async {
      await UserManagerTest.loginUser();
      Map<String, dynamic> params = {};
      var profileResponse = await HttpRequestHelper.sharedInstance.put(UrlManager.userApi.getMyProfile(), params, true);

      expect(profileResponse.code, EnumNetworkResponseCode.code400BadRequest.value);
    });

    test('requestRefreshToken_refreshToken', () async {
      await UserManagerTest.loginUser();

      var profileResponse = await HttpRequestHelper.sharedInstance.get(null, UrlManager.userApi.refreshToken(UserManager.sharedInstance.getAuthToken()));

      UserManager.sharedInstance.currentUser = UserDataModel();
      UserManager.sharedInstance.currentUser!.deserialize(profileResponse.payload);

      expect(profileResponse.code, EnumNetworkResponseCode.code200OK.value);
    });

    test('requestRefreshToken_refreshTokenInvalidTokenError', () async {
      await UserManagerTest.loginUser();
      var profileResponse = await HttpRequestHelper.sharedInstance.get(null, UrlManager.userApi.refreshToken(UserManager.sharedInstance.getAuthToken() + "a"));

      expect(profileResponse.code, EnumNetworkResponseCode.code401Unauthorized.value);
    });

    test('requestRefreshToken_refreshTokenUserNotFoundError', () async {
      await UserManagerTest.loginUser();

      var profileResponse = await HttpRequestHelper.sharedInstance.get(null, UrlManager.userApi.refreshToken(""));

      expect(profileResponse.code, EnumNetworkResponseCode.code404NotFound.value);
    });
  });
}
