import 'package:livecare/models/localNotifications/local_notification_observable.dart';
import 'package:livecare/models/localNotifications/local_notification_observer.dart';
import 'package:livecare/utils/utils_general.dart';

class LocalNotificationManager extends LocalNotificationObservable {
  final List<LocalNotificationObserver?> _observers = [];

  static LocalNotificationManager sharedInstance = LocalNotificationManager();

  @override
  bool addObserver(LocalNotificationObserver? o) {
    if (o != null && !_observers.contains(o)) {
      _observers.add(o);
      return true;
    }
    return false;
  }

  @override
  notifyLocalNotification(String notification) {
    for(var observer in _observers) {
      if(observer!= null) {
        if (notification == UtilsGeneral.consumersListUpdated) {
          observer.consumerListUpdated();
        }
        if (notification == UtilsGeneral.transactionsListUpdated) {
          observer.transactionListUpdated();
        }
        if (notification == UtilsGeneral.inviteListUpdated) {
          observer.inviteListUpdated();
        }
        if (notification == UtilsGeneral.routesListUpdated) {
          observer.routeListUpdated();
        }
        if (notification == UtilsGeneral.organizationListUpdated) {
          observer.organizationListUpdated();
        }
        if (notification == UtilsGeneral.experienceListUpdated) {
          observer.experiencesListUpdated();
        }
      }
    }
  }

  @override
  removeAllObservers() {
    _observers.clear();
  }

  @override
  bool removeObserver(LocalNotificationObserver? o) {
    if (o != null) {
      _observers.remove(o);
      return true;
    }
    return false;
  }
}
