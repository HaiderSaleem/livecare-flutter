import 'package:livecare/models/consumer/dataModel/consumer_ref_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class OrganizationUserDataModel {
  String organizationId = "";
  String szName = "";
  String szPhoto = "";
  String szPhone = "";
  int nMaxTimeOnVehicle = 0;
  int nMaxLimitBuffer = 0;
  int nMaxMileage = 0;
  EnumOrganizationStatus enumStatus = EnumOrganizationStatus.active;
  EnumOrganizationUserRole enumRole = EnumOrganizationUserRole.caregiver;
  List<String> arrayRegions = [];
  List<ConsumerRefDataModel> arrayLinkedConsumers = [];

  initialize() {
    organizationId = "";
    szName = "";
    enumStatus = EnumOrganizationStatus.active;
    enumRole = EnumOrganizationUserRole.caregiver;
    arrayRegions = [];
    arrayLinkedConsumers = [];
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "organizationId")) {
      organizationId = UtilsString.parseString(dictionary["organizationId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "photo")) {
      szPhoto = UtilsString.parseString(dictionary["photo"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "phone")) {
      szPhone = UtilsString.parseString(dictionary["phone"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "maxTimeOnVehicle")) {
      nMaxTimeOnVehicle =
          UtilsString.parseInt(dictionary["maxTimeOnVehicle"], 0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "maxLimitBuffer")) {
      nMaxLimitBuffer = UtilsString.parseInt(dictionary["maxLimitBuffer"], 0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "maxMileage")) {
      nMaxMileage = UtilsString.parseInt(dictionary["maxMileage"], 0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = OrganizationStatusExtension.fromString(
          UtilsString.parseString(dictionary["status"]));
    }
    if (UtilsBaseFunction.containsKey(dictionary, "role")) {
      enumRole = OrganizationUserRoleExtension.fromString(
          UtilsString.parseString(dictionary["role"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "regions")) {
      final List<dynamic> array = dictionary["regions"];
      for (int i in Iterable.generate(array.length)) {
        final str = array[i];
        arrayRegions.add(str);
      }
    }


    if (UtilsBaseFunction.containsKey(dictionary, "consumers")) {
      final List<dynamic> consumers = dictionary["consumers"];
      for (int i in Iterable.generate(consumers.length)) {
        final consumer = ConsumerRefDataModel();
        consumer.deserialize(consumers[i]);
        arrayLinkedConsumers.add(consumer);
      }
    }
  }

  bool isValid() {
    return enumStatus == EnumOrganizationStatus.active;
  }
}
