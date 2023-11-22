import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/shared/companion_data_model.dart';
import 'package:livecare/utils/utils_general.dart';

class ConsumerManager {
  static final ConsumerManager _sharedInstance = ConsumerManager._internal();

  factory ConsumerManager() {
    return _sharedInstance;
  }

  ConsumerManager._internal();

  static ConsumerManager get sharedInstance => _sharedInstance;
  List<ConsumerDataModel> arrayConsumers = [];


  initialize() {
    arrayConsumers = [];
  }

  addConsumerIfNeeded(ConsumerDataModel newConsumer) {
    if (!newConsumer.isValid()) return;

    if (!newConsumer.isValidRegion()) return;

    for (var consumer in arrayConsumers) {
      if (consumer.id == newConsumer.id) return;
    }
    arrayConsumers.add(newConsumer);
  }

  List<ConsumerDataModel> getConsumersByOrganizationId(String organizationId) {
    final List<ConsumerDataModel> array = [];

    for (var c in arrayConsumers) {
      if (c.organizationId == organizationId) {
        array.add(c);
      }
    }

    return array;
  }

  ConsumerDataModel? getConsumerById(String consumerId) {
    final array = arrayConsumers.where((element) => element.id == consumerId);
    if (array.isNotEmpty) {
      return array.first;
    }
    return null;
  }

  Future<void> requestGetConsumers(NetworkManagerResponse? callback) async {
    final urlString = UrlManager.consumerApi.getConsumers();

    NetworkManager.get(urlString, null, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess && responseDataModel.payload.containsKey("data")) {
        final List<dynamic> data = responseDataModel.payload["data"];
        final List<ConsumerDataModel> array = [];
        for (var element in data) {
          final consumer = ConsumerDataModel();
          consumer.deserialize(element);
          if (consumer.isValid() && consumer.isValidRegion()) {
            array.add(consumer);
          }
        }

        array.sort((a, b) => a.szName.compareTo(b.szName));
        arrayConsumers.clear();
        arrayConsumers.addAll(array);
      }
      LocalNotificationManager.sharedInstance.notifyLocalNotification(UtilsGeneral.consumersListUpdated);
      callback?.call(responseDataModel);
    });
  }

  Future<void> requestUpdateCompanions(ConsumerDataModel consumer, List<CompanionDataModel> companions, NetworkManagerResponse callback) async {
    final urlString = UrlManager.consumerApi.updateConsumerById(consumer.organizationId, consumer.id);
    List<dynamic> array = [];
    for (var c in companions) {
      if (c.id.isNotEmpty) {
        array.add(c.serializeForUpdate());
      } else {
        array.add(c.serializeForCreate());
      }
    }
    final Map<String, dynamic> params = {};
    params["companions"] = array;

    NetworkManager.put(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        final updatedConsumer = ConsumerDataModel();
        updatedConsumer.deserialize(responseDataModel.payload);
        if (updatedConsumer.isValid()) {
          // Just update companions only.
          // We should not update full consumer details
          consumer.arrayCompanions = updatedConsumer.arrayCompanions;
        }
      }
      callback.call(responseDataModel);
    });
  }
}
