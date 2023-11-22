import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/model/success_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/utils_general.dart';

class ApiProvider {
  final Dio _dio = Dio();

  Dio get dio => _dio;

  ApiProvider() {
    BaseOptions options = BaseOptions(baseUrl: UtilsGeneral.getApiBaseUrl(), receiveTimeout: 90000, connectTimeout: 90000);
    _dio.options = options;
    _dio.interceptors.add(AwesomeDioInterceptor(logRequestTimeout: false, logRequestHeaders: false, logResponseHeaders: false, logger: debugPrint));
  }

  Options addHeaders() {
    return Options(
      contentType: Headers.jsonContentType,
      headers: {"x-auth": UserManager.sharedInstance.getAuthToken()},
    );
  }

  String _handleError(error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.cancel:
          return "Request to API server was cancelled";
        case DioErrorType.connectTimeout:
          return "Connection timeout with API server";
        case DioErrorType.other:
          return "No internet";
        case DioErrorType.receiveTimeout:
          return "Receive timeout in connection with API server";
        case DioErrorType.response:
          var errorMessage = SuccessModel.fromJson(error.response!.data!).message;
          return errorMessage ?? "Error from server";
        case DioErrorType.sendTimeout:
          return "Send timeout in connection with API server";
      }
    }
    return "Invalid response from server";
  }

  Future<Response?> acceptInvite(String userId, String inviteToken) async {
    try {
      var urlString = UrlManager.inviteApi.acceptInvite(userId, inviteToken);
      return await dio.post(urlString, options: addHeaders());
    } on DioError catch (e) {
      UtilsGeneral.log(_handleError(e));
      return null;
    }
  }

  Future<Response?> declineInvite(String userId, String inviteToken) async {
    try {
      var urlString = UrlManager.inviteApi.declineInvite(userId, inviteToken);
      return await dio.post(urlString, options: addHeaders());
    } on DioError catch (e) {
      UtilsGeneral.log(_handleError(e));
      return null;
    }
  }
}
