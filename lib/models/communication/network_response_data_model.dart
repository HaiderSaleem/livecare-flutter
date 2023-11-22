import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/utils_general.dart';

class NetworkResponseDataModel {
  Map<String, dynamic> payload = {};
  dynamic parsedObject;
  int code = EnumNetworkResponseCode.code200OK.value;
  String errorMessage = "";
  String errorCode = "";

  bool get isSuccess => code.isCodeSuccess;

  bool get isOffline => code.isCodeOffline;

  String get beautifiedErrorMessage {
    if (isSuccess) return "";
    return errorMessage.isNotEmpty ? errorMessage : "Sorry, we've encountered an unknown error.";
  }

  static NetworkResponseDataModel fromDataResponse(http.Response response, bool shouldUpdateToken) {
    final modelResponse = NetworkResponseDataModel()..code = response.statusCode;

    if (response.isSuccessful && shouldUpdateToken) {
      final xAuth = response.headers["x-auth"];
      if (xAuth != null && xAuth.isNotEmpty) {
        UserManager.sharedInstance.updateAuthToken(xAuth);
        UtilsGeneral.log("Updated User Token = $xAuth");
      }
    }

    if (response.body.isNotEmpty) {
      final jsonObject = jsonDecode(response.body) as Map<String, dynamic>;
      modelResponse._processJsonResponse(jsonObject);
    }

    return modelResponse;
  }

  static NetworkResponseDataModel fromBadResponse(http.Response? response) {
    if (response == null) {
      return NetworkResponseDataModel()
        ..code = EnumNetworkResponseCode.code502BadGateway.value
        ..errorMessage = "Sorry, we've encountered an unknown error.";
    }

    final jsonObject = jsonDecode(response.body) as Map<String, dynamic>;
    return NetworkResponseDataModel()
      .._processJsonResponse(jsonObject)
      ..code = response.statusCode;
  }

  static NetworkResponseDataModel forFailure() {
    return NetworkResponseDataModel()..code = EnumNetworkResponseCode.code400BadRequest.value;
  }

  static NetworkResponseDataModel forSuccess() {
    return NetworkResponseDataModel();
  }

  void _processJsonResponse(Map<String, dynamic> jsonObject) {
    payload = jsonObject;
    errorMessage = jsonObject["error"] ?? jsonObject["message"] ?? "";
    errorCode = jsonObject["code"] ?? "";
  }

  static NetworkResponseDataModel instanceFromDataResponse(http.Response response, bool shouldUpdateToken) {
    return fromDataResponse(response, shouldUpdateToken);
  }

  static NetworkResponseDataModel instanceFromBadResponse(http.Response? response) {
    return fromBadResponse(response);
  }

  static NetworkResponseDataModel errorResponse(dynamic error) {
    return NetworkResponseDataModel()
      ..code = EnumNetworkResponseCode.code400BadRequest.value
      ..errorMessage = error.toString();
  }
}

extension ResponseStatus on http.Response {
  bool get isSuccessful => (statusCode ~/ 100) == 2;
}

extension NetworkResponseCodeExtensions on int {
  bool get isCodeSuccess => this == 200 || this == 204 || this == 201;

  bool get isCodeOffline => this == 502 || this == 400;
}

enum EnumNetworkResponseCode {
  code200OK,
  code201Created,
  code204NoContent,
  code400BadRequest,
  code401Unauthorized,
  code403Forbidden,
  code404NotFound,
  code500ServerError,
  code502BadGateway
}

extension UserStatusExtension on EnumNetworkResponseCode {
  int get value {
    switch (this) {
      case EnumNetworkResponseCode.code200OK:
        return 200;
      case EnumNetworkResponseCode.code201Created:
        return 201;
      case EnumNetworkResponseCode.code204NoContent:
        return 204;
      case EnumNetworkResponseCode.code400BadRequest:
        return 400;
      case EnumNetworkResponseCode.code401Unauthorized:
        return 401;
      case EnumNetworkResponseCode.code403Forbidden:
        return 403;
      case EnumNetworkResponseCode.code404NotFound:
        return 404;
      case EnumNetworkResponseCode.code500ServerError:
        return 500;
      case EnumNetworkResponseCode.code502BadGateway:
        return 502;
    }
  }
}
