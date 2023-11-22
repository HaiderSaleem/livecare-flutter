import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class LocationRefDataModel extends LocationDataModel {


  @override
  initialize() {
    super.initialize();
    locationId = "";
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    super.deserialize(dictionary);

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "id")) {
      locationId = UtilsString.parseString(dictionary["id"]);
    } else {
      if (UtilsBaseFunction.containsKey(dictionary, "locationId")) {
        locationId = UtilsString.parseString(dictionary["locationId"]);
      }
    }
  }

  LocationRefDataModel() {
    initialize();
  }

  LocationRefDataModel.fromLocationDataModel(LocationDataModel? model) {
    if (model == null) return;
    id = model.id;
    locationId = model.id;
    organizationId = model.organizationId;
    accountId = model.accountId;
    szName = model.szName;
    szRegion = model.szRegion;
  }

  @override
  bool isValid() {
    return id.isNotEmpty;
  }
}
