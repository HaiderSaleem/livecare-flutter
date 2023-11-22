import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/organization/dataModel/booking_windows.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class OrganizationDataModel extends BaseDataModel {

  EnumOrganizationStatus enumStatus = EnumOrganizationStatus.active;
  String parentId = "";
  String szName = "";
  EnumOrganizationType enumType = EnumOrganizationType.none;
  List<EnumOrganizationComponent> arrayComponents = [];
  String szType = "";
  String szPhone = "";
  String szEmail = "";
  String szHeroUri = "";
  String szPhoto = "";
  List<String> arrayRegions = [];
  List<String> arrayBillingCategories = [];
  BookingWindows? bookingWindows;

  bool allowConsumerRequests = true;

  //Utility Properties
  List<LocationDataModel> arrayLocations = [];

  @override
  initialize() {
    super.initialize();
    enumStatus = EnumOrganizationStatus.active;
    parentId = "";
    szName = "";
    enumType = EnumOrganizationType.none;
    arrayComponents = [];
    szType = "";
    szPhone = "";
    szEmail = "";
    szHeroUri = "";
    szPhoto = "";

    arrayRegions = [];
    arrayBillingCategories = [];
    bookingWindows = null;
    arrayLocations = [];
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "parentId")) {
      parentId = UtilsString.parseString(dictionary["parentId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "type")) {
      enumType = OrganizationTypeExtension.fromString(
          UtilsString.parseString(dictionary["type"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "allowConsumerRequests")) {
      allowConsumerRequests =
          UtilsString.parseBool(dictionary["allowConsumerRequests"], true);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "bookingWindows")) {
      bookingWindows = BookingWindows();
      bookingWindows!.deserialize(dictionary["bookingWindows"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "components")) {
      final List<dynamic> components = dictionary["components"];
      for (int i in Iterable.generate(components.length)) {
        final String component = components[i];
        arrayComponents
            .add(OrganizationComponentExtension.fromString(component));
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "type")) {
      szType = UtilsString.parseString(dictionary["type"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "phone")) {
      szPhone = UtilsString.parseString(dictionary["phone"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "email")) {
      szEmail = UtilsString.parseString(dictionary["email"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "heroUri")) {
      szHeroUri = UtilsString.parseString(dictionary["heroUri"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "photo")) {
      szPhoto = UtilsString.parseString(dictionary["photo"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = OrganizationStatusExtension.fromString(
          UtilsString.parseString(dictionary["status"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "regions")) {
      final List<dynamic> regions = dictionary["regions"];
      for (int i in Iterable.generate(regions.length)) {
        final String region = regions[i];
        arrayRegions.add(region);
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "billingCategories")) {
      final List<dynamic> array = dictionary["billingCategories"];
      for (int i in Iterable.generate(array.length)) {
        final str = array[i];
        arrayBillingCategories.add(str);
      }
    }
  }

  @override
  bool isValid() {
    return (id.isNotEmpty && (enumStatus == EnumOrganizationStatus.active));
  }

  OrganizationRefDataModel toRef() {
    final ref = OrganizationRefDataModel();
    ref.organizationId = id;
    ref.szName = szName;
    ref.szPhoto = szPhoto;
    ref.szPhone = szPhone;
    ref.enumStatus = enumStatus;
    ref.arrayRegions.addAll(arrayRegions);
    return ref;
  }
}

enum EnumOrganizationStatus { active, deleted }

extension OrganizationStatusExtension on EnumOrganizationStatus {
  static EnumOrganizationStatus fromString(String? status) {
    if (status == null || status == "") return EnumOrganizationStatus.active;
    if (status.toLowerCase() ==
        EnumOrganizationStatus.active.value.toLowerCase()) {
      return EnumOrganizationStatus.active;
    }
    if (status.toLowerCase() ==
        EnumOrganizationStatus.deleted.value.toLowerCase()) {
      return EnumOrganizationStatus.deleted;
    }
    return EnumOrganizationStatus.active;
  }

  String get value {
    switch (this) {
      case EnumOrganizationStatus.active:
        return "Active";
      case EnumOrganizationStatus.deleted:
        return "Deleted";
    }
  }
}

enum EnumOrganizationType { none, service, transport, network }

extension OrganizationTypeExtension on EnumOrganizationType {
  static EnumOrganizationType fromString(String? status) {
    if (status == null || status == "") return EnumOrganizationType.none;
    for (EnumOrganizationType t in EnumOrganizationType.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumOrganizationType.none;
  }

  String get value {
    switch (this) {
      case EnumOrganizationType.none:
        return "";
      case EnumOrganizationType.service:
        return "Service";
      case EnumOrganizationType.transport:
        return "Transport";
      case EnumOrganizationType.network:
        return "Network";
      default:
        return "";
    }
  }
}

enum EnumOrganizationComponent { none, service, transport, ledger, experience }

extension OrganizationComponentExtension on EnumOrganizationComponent {
  static EnumOrganizationComponent fromString(String? status) {
    if (status == null || status == "") return EnumOrganizationComponent.none;
    for (EnumOrganizationComponent t in EnumOrganizationComponent.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumOrganizationComponent.none;
  }

  String get value {
    switch (this) {
      case EnumOrganizationComponent.none:
        return "";
      case EnumOrganizationComponent.service:
        return "Service";
      case EnumOrganizationComponent.transport:
        return "Transport";
      case EnumOrganizationComponent.ledger:
        return "Ledger";
      case EnumOrganizationComponent.experience:
        return "Experience";
      default:
        return "";
    }
  }

}
