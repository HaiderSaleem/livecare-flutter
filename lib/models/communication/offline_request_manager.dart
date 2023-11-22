import 'package:livecare/models/communication/offline_request_data_model.dart';

class OfflineRequestManager {
  List<OfflineRequestDataModel> arrayRequestQueue = [];

  static OfflineRequestManager sharedInstance = OfflineRequestManager();

  enqueueRequest(OfflineRequestDataModel httpRequest) {
    for (var request in arrayRequestQueue) {
      if (request.endpoint == httpRequest.endpoint) return;
    }
    arrayRequestQueue.add(httpRequest);
  }

  dequeueRequest(OfflineRequestDataModel httpRequest) {
    int index = 0;
    for (var request in arrayRequestQueue) {
      if (request.endpoint == httpRequest.endpoint) {
        arrayRequestQueue.removeAt(index);
        return;
      }
      index += 1;
    }
  }
}
