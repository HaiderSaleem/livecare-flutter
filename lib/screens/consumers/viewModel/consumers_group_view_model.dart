import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';

class ConsumersGroupViewModel {
  LocationDataModel? modelLocation;
  List<ConsumerDataModel> arrayConsumers = [];

  String getLocationName() {
    if (modelLocation != null) {
      return modelLocation!.szName;
    }

    return "Unassigned Consumers";
  }

  static List<ConsumersGroupViewModel> buildConsumersGroup(
      List<ConsumerDataModel> consumers) {
    List<ConsumersGroupViewModel> arrayGroups = [];
    List<ConsumerDataModel> arrayNonGroupConsumers = [];

    for (var consumer in consumers) {
      if ((consumer.modelPrimaryLocation != null) &&
          (consumer.modelPrimaryLocation!.isValid())) {
        final location = consumer.modelPrimaryLocation!;
        bool found = false;

        for (var group in arrayGroups) {
          if (group.modelLocation != null &&
              group.modelLocation!.id == location.id) {
            group.arrayConsumers.add(consumer);
            found = true;
            break;
          }
        }

        if (!found) {
          final group = ConsumersGroupViewModel();
          group.modelLocation = location;
          group.arrayConsumers = [consumer];
          arrayGroups.add(group);
        }
      } else {
        arrayNonGroupConsumers.add(consumer);
      }
    }

    if (arrayNonGroupConsumers.isNotEmpty) {
      final group = ConsumersGroupViewModel();
      group.arrayConsumers = arrayNonGroupConsumers;
      arrayGroups.add(group);
    }
    return arrayGroups;
  }
}
