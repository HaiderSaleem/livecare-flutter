// ignore_for_file: library_prefixes

import 'package:livecare/models/request/base_request_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/route/transport_route_manager.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/location_manager.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

abstract class SocketDelegate {
  onConnected();

  onConnectionStatusChanged();

  onAnyEventFired();

  onRequestUpdated(RequestDataModel request);

  onRequestCancelled(RequestDataModel request);

  onRouteDriverLocationUpdated(String routeId, double lat, double lng);

  onRouteLocationStatusUpdated(RouteDataModel route);

  onRouteUpdated(RouteDataModel route);
}

enum EnumSocketConnectionStatus {
  notConnected,
  connecting,
  connected,
  disconnected
}

extension SocketConnectionStatusExtension on EnumSocketConnectionStatus {
  String get value {
    switch (this) {
      case EnumSocketConnectionStatus.notConnected:
        return "Not Connected";
      case EnumSocketConnectionStatus.connecting:
        return "Connecting";
      case EnumSocketConnectionStatus.connected:
        return "Connected";
      case EnumSocketConnectionStatus.disconnected:
        return "Disconnected";
    }
  }
}

class SocketRequestManager {
  List<SocketDelegate> listenerArray = [];

  DateTime? dateLastHandshake;
  IO.Socket? mSocket;

  static SocketRequestManager sharedInstance = SocketRequestManager();

  addListener(SocketDelegate listener) {
    listenerArray.add(listener);
  }

  removeListener(SocketDelegate listener) {
    listenerArray.remove(listener);
  }

  connectOnce() {
    if (mSocket != null) {
      return;
    }
    _connect();
  }

  EnumSocketConnectionStatus _getConnectionStatus() {
    if (mSocket == null) return EnumSocketConnectionStatus.notConnected;
    if (mSocket!.connected) {
      return EnumSocketConnectionStatus.connected;
    }
    return EnumSocketConnectionStatus.notConnected;
  }

  _connect() async {
    final String token = UserManager.sharedInstance.getAuthToken();

    mSocket = IO.io(
        UtilsGeneral.getApiBaseUrl(),
        IO.OptionBuilder()
            .setQuery({"token": token})
            .setTransports(['websocket'])
            .setExtraHeaders({'token':token, 'Connection': 'upgrade', 'Upgrade': 'websocket'})
            .enableReconnection()
            .disableAutoConnect()
            .setReconnectionDelay(1)
            .enableForceNew()
            .build());

    mSocket?.on("connect", (data) {
      UtilsGeneral.log("[Socket - Connected]");
      _onConnected();
      _emitSubscribeForOrg();
    });

    mSocket?.on("disconnect", (data) {
      UtilsGeneral.log("[Socket - Disconnected]");
      _onDisconnected();
    });

    mSocket?.on("connect_error", (data) {
      UtilsGeneral.log("[Socket - Connect Error]$data");
      _onConnectionStatusChanged();
    });

    // Trip-Request connecting, connected, disconnected
    mSocket?.on(EnumSocketEvent.requestUpdated.value, (data) {
      UtilsGeneral.log("[Socket - requestUpdated]: $data");
      if (data is List<dynamic>) {
        final array = data;
        final dict = array.isEmpty ? null : array.first;
        final request = RequestDataModel();
        request.deserialize(dict as Map<String, dynamic>?);
        _onRequestUpdated(request);
      }
    });

    // Route
    mSocket?.on(EnumSocketEvent.routeUpdated.value, (data) {
      UtilsGeneral.log("[Socket - routeUpdated]: $data");
      if (data is List<dynamic>) {
        final array = data;
        final dict = array.isEmpty ? null : array.first;

        final route = RouteDataModel();
        route.deserialize(dict as Map<String, dynamic>?);
        _onRouteUpdated(route);
      }
    });

    mSocket?.on(EnumSocketEvent.routeLocationStatusUpdated.value, (data) {
      UtilsGeneral.log("[Socket - routeLocationStatusUpdated]: $data");
      if (data is List<dynamic>) {
        final array = data;
        final dict = array.isEmpty ? null : array.first;

        final route = RouteDataModel();
        route.deserialize(dict as Map<String, dynamic>?);
        _onRouteLocationStatusUpdated(route);
      }
    });

    mSocket?.on(EnumSocketEvent.driverLocationUpdate.value, (data) {
      UtilsGeneral.log("[Socket - driverLocationUpdate]: $data");
      if (data is List<dynamic>) {
        final array = data;
        final dict = array.isEmpty ? null : array.first;

        final String routeId = UtilsString.parseString(dict?["routeId"]);
        final double lat = UtilsString.parseDouble(dict?["lat"], 0.0);
        final double lng = UtilsString.parseDouble(dict?["lng"], 0.0);
        if (routeId.isNotEmpty) {
          _onRouteDriverLocationUpdated(routeId, lat, lng);
        }
      }
    });

    mSocket?.connect();
  }

  disconnect() {
    if (mSocket != null) {
      UtilsGeneral.log("[Socket - Disconnected]");
      mSocket?.disconnect();
      mSocket?.off("connect");
      mSocket?.off("onRouteDriverLocationUpdated");
      mSocket?.off("onRouteLocationUpdated");
      mSocket?.off("onRouteUpdated");
      mSocket?.off("onRouteCancelled");
      mSocket?.off("onRouteStatusUpdated");
      mSocket?.off("onRouteLocationStatusUpdated");
      mSocket = null;
    }
  }

  _onConnected() {
    for (var listener in listenerArray) {
      listener.onAnyEventFired();
      listener.onConnected();
    }
  }

  _onDisconnected() {}

  _onAnyEventFired(String event) {
    final now = DateTime.now();
    dateLastHandshake = now;
    UtilsGeneral.log(
        "[Socket - Any Event Fired]: Event Name = [$event], Timestamp = $now");
  }

  _onConnectionStatusChanged() {
    _onAnyEventFired("onConnectionStatusChanged");
    for (var listener in listenerArray) {
      listener.onConnectionStatusChanged();
    }
  }

  _onRequestUpdated(RequestDataModel request) {
    _onAnyEventFired("onRequestUpdated");
    BaseRequestManager.sharedInstance.addRequestIfNeeded((request));
    for (var listener in listenerArray) {
      listener.onRequestUpdated(request);
    }
  }

  _onRequestCancelled(RequestDataModel request) {
    _onAnyEventFired("onRequestCancelled");
    BaseRequestManager.sharedInstance.deleteRequestIfNeeded((request));
    for (var listener in listenerArray) {
      listener.onRequestCancelled(request);
    }
  }

  _onRouteDriverLocationUpdated(String routeId, double lat, double lng) {
    _onAnyEventFired("onRouteDriverLocationUpdated");
    for (var listener in listenerArray) {
      listener.onRouteDriverLocationUpdated(routeId, lat, lng);
    }
  }

  _onRouteUpdated(RouteDataModel route) {
    _onAnyEventFired("onRouteUpdated");
    if (UserManager.sharedInstance.currentUser?.id == route.refDriver?.userId) {
      TransportRouteManager.sharedInstance.addRouteIfNeeded(route);
      BaseRequestManager.sharedInstance.requestGetRequestsForRoute("", route.id,
          (responseDataModel) {
        for (var listener in listenerArray) {
          listener.onRouteUpdated(route);
        }
      });
    }
  }

  _onRouteLocationStatusUpdated(RouteDataModel route) {
    _onAnyEventFired("onRouteLocationStatusUpdated");
    final user = UserManager.sharedInstance.currentUser;
    if (user?.getPrimaryOrganization() == null) {
      return;
    }
    if (user?.id == route.refDriver?.userId) {
      BaseRequestManager.sharedInstance.requestGetRequestsForRoute(
          user!.getPrimaryOrganization()!.organizationId, route.id,
          (responseDataModel) {
        for (var listener in listenerArray) {
          listener.onRouteLocationStatusUpdated(route);
        }
      });
    }
  }

  _emitEvent(EnumSocketEvent event, dynamic payload) {
    if (mSocket != null &&
        _getConnectionStatus() == EnumSocketConnectionStatus.connected) {
      mSocket!.emit(event.value, payload);
      UtilsGeneral.log("[Socket Emitting - ${event.value}]: $payload");
    }
  }

  _emitDriverLocationUpdateForRoute(String routeId) {
    final Map<String, dynamic> params = {};
    params["driverId"] = UserManager.sharedInstance.currentUser?.id;
    params["routeId"] = routeId;
    params["lat"] = LCLocationManager.sharedInstance.geoPoint.fLatitude;
    params["lng"] = LCLocationManager.sharedInstance.geoPoint.fLongitude;
    _emitEvent(EnumSocketEvent.driverLocationUpdate, params);
  }

  _emitSubscribeForOrg() {
    final user = UserManager.sharedInstance.currentUser;
    final primaryOrg = user?.getPrimaryOrganization();
    if (user == null || primaryOrg == null) {
      return;
    }
    final Map<String, dynamic> params = {};
    params["organizationId"] = primaryOrg.organizationId;
    _emitEvent(EnumSocketEvent.subscribeToOrganization, params);
  }

  _emitSubscribeForRoute(String routeId) {
    final Map<String, dynamic> params = {};
    params["routeId"] = routeId;
    _emitEvent(EnumSocketEvent.subscribeToRoute, params);
  }

  _emitUnsubscribeForRoute(String routeId) {
    final Map<String, dynamic> params = {};
    params["routeId"] = routeId;
    _emitEvent(EnumSocketEvent.unsubscribeToRoute, params);
  }
}

enum EnumSocketEvent {
  subscribeToOrganization,
  unsubscribeToOrganization,
  subscribeToRoute,
  unsubscribeToRoute,
  routeUpdated,
  routeLocationStatusUpdated,
  requestUpdated,
  driverLocationUpdate
}

extension SocketEventExtension on EnumSocketEvent {
  String get value {
    switch (this) {
      case EnumSocketEvent.subscribeToOrganization:
        return "subscribeToOrg";
      case EnumSocketEvent.unsubscribeToOrganization:
        return "unSubscribeToOrg";
      case EnumSocketEvent.subscribeToRoute:
        return "subscribeToRoute";
      case EnumSocketEvent.unsubscribeToRoute:
        return "unSubscribeToRoute";
      case EnumSocketEvent.routeUpdated:
        return "routeUpdated";
      case EnumSocketEvent.routeLocationStatusUpdated:
        return "routeLocationStatusUpdated";
      case EnumSocketEvent.requestUpdated:
        return "requestUpdated";
      case EnumSocketEvent.driverLocationUpdate:
        return "driverLocationUpdate";
    }
  }
}
