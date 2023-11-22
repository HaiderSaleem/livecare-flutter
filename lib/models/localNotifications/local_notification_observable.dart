import 'package:livecare/models/localNotifications/local_notification_observer.dart';

abstract class LocalNotificationObservable {
  bool addObserver(LocalNotificationObserver? o);

  bool removeObserver(LocalNotificationObserver? o);

  removeAllObservers();

  notifyLocalNotification(String notification);
}
