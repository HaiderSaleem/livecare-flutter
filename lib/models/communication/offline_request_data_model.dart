import 'package:livecare/models/communication/network_manager_response.dart';

class OfflineRequestDataModel {
  String endpoint = "";
  Map<String, dynamic>? params;
  int authOptions = 0;
  NetworkManagerResponse? callback;
  String? method;

  OfflineRequestDataModel() {
    initialize();
  }

  initialize() {
    endpoint = "";
    params = null;
    authOptions = 0;
    callback = null;
    method = null;
  }
}
