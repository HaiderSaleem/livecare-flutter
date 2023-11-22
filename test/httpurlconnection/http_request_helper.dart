import 'dart:convert';
import 'dart:io';
import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';
import 'package:http/http.dart' as http;

class HttpRequestHelper {
  static final HttpRequestHelper sharedInstance = HttpRequestHelper();

  Future<NetworkResponseDataModel> post(
      Map<String, dynamic>? params, String urlString) async {
    final sessionToken = UtilsString.generateRandomString(16);
    UtilsGeneral.log("[NetworkManager - ($sessionToken)] - POST: $urlString");
    Map<String, String> headers = {};
    headers[HttpHeaders.contentTypeHeader] = "application/json";
    headers[HttpHeaders.acceptHeader] = "application/json";

    headers["x-auth"] = UserManager.sharedInstance.getAuthToken();

    var response = await http.post(Uri.parse(urlString),
        headers: headers, body: jsonEncode(params));

    final xAuth = response.headers["x-auth"];
    if (xAuth != "") {
      UserManager.sharedInstance.updateAuthToken(xAuth);
    }

    if (response.statusCode < 200 || response.statusCode >= 400) {
      final result = NetworkResponseDataModel.instanceFromBadResponse(response);
      return result;
    } else {
      final result = NetworkResponseDataModel.instanceFromDataResponse(
          response,
          ((EnumNetworkAuthOptions.authRequired.value &
                  EnumNetworkAuthOptions.authShouldUpdate.value) >
              0));
      return result;
    }
  }

  Future<NetworkResponseDataModel> get(
      Map<String, dynamic>? params, String endpoint) async {
    var urlString = endpoint;
    if (params != null) {
      urlString = "$urlString?";
      final keys = params.keys;
      for (var element in keys) {
        final String key = element;
        final dynamic value = params[key];
        urlString = "$urlString$key=$value&";
      }
    }
    if (urlString.endsWith('&')) {
      urlString = urlString.substring(0, urlString.length - 1);
    }
    final sessionToken = UtilsString.generateRandomString(16);
    UtilsGeneral.log("[NetworkManager - ($sessionToken)] - GET: $urlString");
    Map<String, String> headers = {};

    headers["x-auth"] = UserManager.sharedInstance.getAuthToken();

    final response = await http.get(Uri.parse(urlString), headers: headers);

    if (response.statusCode < 200 || response.statusCode >= 400) {
      final result = NetworkResponseDataModel.instanceFromBadResponse(response);
      return result;
    } else {
      final result = NetworkResponseDataModel.instanceFromDataResponse(
          response,
          ((EnumNetworkAuthOptions.authRequired.value &
                  EnumNetworkAuthOptions.authShouldUpdate.value) >
              0));
      return result;
    }
  }

  Future<NetworkResponseDataModel> put(
      String urlString, Map<String, dynamic>? params, bool refreshToken) async {
    final sessionToken = UtilsString.generateRandomString(16);
    UtilsGeneral.log("[NetworkManager - ($sessionToken)] - PUT: $urlString");
    UtilsGeneral.log(
        "[NetworkManager - ($sessionToken)] - PUT: ${params!.toString()}");
    Map<String, String> headers = {};
    headers[HttpHeaders.contentTypeHeader] = "application/json";
    headers[HttpHeaders.acceptHeader] = "application/json";

    headers["x-auth"] = UserManager.sharedInstance.getAuthToken();

    final response = await http.put(Uri.parse(urlString),
        headers: headers, body: jsonEncode(params));
    if (refreshToken) {
      final xAuth = response.headers["x-auth"];
      if (xAuth != "") {
        UserManager.sharedInstance.updateAuthToken(xAuth);
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 400) {
      final result = NetworkResponseDataModel.instanceFromBadResponse(response);
      return result;
    } else {
      final result = NetworkResponseDataModel.instanceFromDataResponse(
          response,
          ((EnumNetworkAuthOptions.authRequired.value &
                  EnumNetworkAuthOptions.authShouldUpdate.value) >
              0));
      return result;
    }
  }
}
