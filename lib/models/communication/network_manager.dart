import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/offline_request_data_model.dart';
import 'package:livecare/models/communication/offline_request_manager.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/utils_file.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';

class NetworkManager {
  static Future<NetworkResponseDataModel> get(String endpoint, Map<String, dynamic>? params, int authOptions, {bool retryRequest = true}) async {
    Uri uri = Uri.parse(endpoint).replace(queryParameters: params);
    final sessionToken = UtilsString.generateRandomString(16);
    UtilsGeneral.log("[NetworkManager - ($sessionToken)] - GET: ${uri.toString()}");

    Map<String, String> headers = _constructHeaders(authOptions);

    try {
      final value = await http.get(uri, headers: headers);
      return _handleResponse(value, endpoint, authOptions, retryRequest);
    } catch (error, stackTrace) {
      return await _handleError(endpoint, authOptions, method: "GET", error: error, stackTrace: stackTrace);
    }
  }

  static bool _isRefreshTokenNeeded(String endpoint, NetworkResponseDataModel result) {
    if (!endpoint.contains("/users/refresh/") && result.code == EnumNetworkResponseCode.code403Forbidden.value) {
      return true;
    }
    return false;
  }

  static Future<NetworkResponseDataModel> _refreshAndRetry(OfflineRequestDataModel originalHttpRequest, int authOptions) async {
    final endpoint = UrlManager.userApi.refreshToken(UserManager.sharedInstance.getAuthToken());
    final headers = _constructHeaders(authOptions);

    try {
      final value = await http.get(Uri.parse(endpoint), headers: headers);
      if (value.statusCode < 200 || value.statusCode >= 400) {
        return NetworkResponseDataModel.instanceFromBadResponse(value);
      } else {
        NetworkResponseDataModel.instanceFromDataResponse(value, true);

        final method = originalHttpRequest.method;
        if (method == null) {
          return NetworkResponseDataModel.instanceFromBadResponse(null);
        }

        switch (method) {
          case "PUT":
            return await NetworkManager.put(originalHttpRequest.endpoint, originalHttpRequest.params, originalHttpRequest.authOptions, retryRequest: false);
          case "GET":
            return await NetworkManager.get(originalHttpRequest.endpoint, originalHttpRequest.params, originalHttpRequest.authOptions, retryRequest: false);
          case "POST":
            return await NetworkManager.post(originalHttpRequest.endpoint, originalHttpRequest.params, originalHttpRequest.authOptions, retryRequest: false);
          // Add cases for other methods if necessary
          default:
            return NetworkResponseDataModel.instanceFromBadResponse(null);
        }
      }
    } catch (error) {
      UtilsGeneral.log("[NetworkManager] - _refreshAndRetry Error: $error");
      return NetworkResponseDataModel.instanceFromBadResponse(null);
    }
  }

  static Future<NetworkResponseDataModel> post(String endpoint, Map<String, dynamic>? params, int authOptions, {bool retryRequest = true}) async {
    final sessionToken = UtilsString.generateRandomString(16);
    UtilsGeneral.log("[NetworkManager - ($sessionToken)] - POST: $endpoint");

    final headers = _constructHeaders(authOptions);

    try {
      final value = await http.post(Uri.parse(endpoint), headers: headers, body: jsonEncode(params));
      return await _handleResponse(value, endpoint, authOptions, retryRequest);
    } catch (error, stackTrace) {
      return await _handleError(endpoint, authOptions, method: "POST", error: error, stackTrace: stackTrace);
    }
  }

  static Future<NetworkResponseDataModel> put(String endpoint, Map<String, dynamic>? params, int authOptions, {bool retryRequest = true}) async {
    final sessionToken = UtilsString.generateRandomString(16);
    UtilsGeneral.log("[NetworkManager - ($sessionToken)] - PUT: $endpoint");
    UtilsGeneral.log("[NetworkManager - ($sessionToken)] - PUT: ${params!.toString()}");

    final headers = _constructHeaders(authOptions);

    try {
      final value = await http.put(Uri.parse(endpoint), headers: headers, body: jsonEncode(params));
      return await _handleResponse(value, endpoint, authOptions, retryRequest);
    } catch (error, stackTrace) {
      return await _handleError(endpoint, authOptions, method: "PUT", error: error, stackTrace: stackTrace);
    }
  }

  static Future<NetworkResponseDataModel> download(String endpoint, String mimeType, String mediaId, int authOptions) async {
    final sessionToken = UtilsString.generateRandomString(16);
    UtilsGeneral.log("[NetworkManager - ($sessionToken)] - DOWNLOAD FILE: $endpoint");

    final headers = _constructHeaders(authOptions);

    try {
      var response = await http.get(Uri.parse(endpoint), headers: headers);

      if (response.statusCode < 200 || response.statusCode >= 400) {
        return await _handleResponse(response, endpoint, authOptions, false);
      } else {
        File file = await UtilsFile.createPNGFile(mediaId);
        await file.writeAsBytes(response.bodyBytes);
        return NetworkResponseDataModel.instanceFromDataResponse(response, ((authOptions & EnumNetworkAuthOptions.authShouldUpdate.value) > 0));
      }
    } catch (error, stackTrace) {
      UtilsGeneral.log("[NetworkManager - ($sessionToken)] - DOWNLOAD ERROR: $error");
      return await _handleError(endpoint, authOptions, method: "GET", error: error, stackTrace: stackTrace);
    }
  }

  static Future<NetworkResponseDataModel> upload(String endPoint, String fileName, bool overrideImageCheck, File file, int authOptions) async {
    final sessionToken = UtilsString.generateRandomString(16);
    UtilsGeneral.log("[NetworkManager - ($sessionToken)] - UPLOAD FILE: $endPoint");
    Map<String, String> headers = _constructHeaders(authOptions);
    headers[HttpHeaders.contentTypeHeader] = "multipart/form-data";

    var request = http.MultipartRequest("POST", Uri.parse(endPoint));
    request.headers.addAll(headers);

    try {
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath("file", file.path);
      request.fields["override"] = overrideImageCheck.toString();
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode < 200 || response.statusCode >= 400) {
        return NetworkResponseDataModel.instanceFromBadResponse(response);
      } else {
        return NetworkResponseDataModel.instanceFromDataResponse(response, ((authOptions & EnumNetworkAuthOptions.authShouldUpdate.value) > 0));
      }
    } catch (e) {
      return NetworkResponseDataModel.instanceFromBadResponse(null);
    }
  }

  static Map<String, String> _constructHeaders(int authOptions) {
    Map<String, String> headers = {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.acceptHeader: "application/json"};
    if ((authOptions & EnumNetworkAuthOptions.authRequired.value) > 0 && UserManager.sharedInstance.isLoggedIn()) {
      headers["x-auth"] = UserManager.sharedInstance.getAuthToken();
    }
    return headers;
  }

  static Future<NetworkResponseDataModel> _handleResponse(http.Response value, String endpoint, int authOptions, bool retryRequest) async {
    if (value.statusCode < 200 || value.statusCode >= 400) {
      final result = NetworkResponseDataModel.instanceFromBadResponse(value);
      if (_isRefreshTokenNeeded(endpoint, result) && retryRequest) {
        final httpRequest = _createOfflineRequestModel(endpoint, null, authOptions, "GET");
        return await _refreshAndRetry(httpRequest, authOptions);
      } else {
        return result;
      }
    } else {
      return NetworkResponseDataModel.instanceFromDataResponse(value, ((authOptions & EnumNetworkAuthOptions.authShouldUpdate.value) > 0));
    }
  }

  static Future<NetworkResponseDataModel> _handleError(String endpoint, int authOptions, {String method = "GET", dynamic error, StackTrace? stackTrace}) {
    UtilsGeneral.log("Error occurred: $error");
    if (stackTrace != null) {
      UtilsGeneral.log("StackTrace: $stackTrace");
    }

    final httpRequest = _createOfflineRequestModel(endpoint, null, authOptions, method);
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) {
      OfflineRequestManager.sharedInstance.enqueueRequest(httpRequest);
    }
    return Future.value(NetworkResponseDataModel.instanceFromBadResponse(null));
  }

  static OfflineRequestDataModel _createOfflineRequestModel(String endpoint, Map<String, dynamic>? params, int authOptions, String method) {
    final httpRequest = OfflineRequestDataModel();
    httpRequest.params = params;
    httpRequest.authOptions = authOptions;
    httpRequest.endpoint = endpoint;
    httpRequest.method = method;
    return httpRequest;
  }
}

enum EnumNetworkAuthOptions { authNone, authRequired, authShouldUpdate }

extension NetworkAuthOptionsExtension on EnumNetworkAuthOptions {
  int get value {
    switch (this) {
      case EnumNetworkAuthOptions.authNone:
        return 00000000;
      case EnumNetworkAuthOptions.authRequired:
        return 00000001;
      case EnumNetworkAuthOptions.authShouldUpdate:
        return 00000010;
    }
  }
}
