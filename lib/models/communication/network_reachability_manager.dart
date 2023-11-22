import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkReachabilityManager {
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();

  List<ConnectivityReceiverListener> listenerArray = [];

  static NetworkReachabilityManager sharedInstance =
      NetworkReachabilityManager();
  initializeNetworkReachabilityManager() async {
    connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    connectivityResult = result;
    for (var listener in listenerArray) {
      listener.onNetworkConnectionChanged(isConnected());
    }
  }

  addListener(ConnectivityReceiverListener listener) {
    listenerArray.add(listener);
  }

  removeListener(ConnectivityReceiverListener listener) {
    listenerArray.remove(listener);
  }

  bool isConnected() {
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }
}

abstract class ConnectivityReceiverListener {
  onNetworkConnectionChanged(bool isConnected);
}
