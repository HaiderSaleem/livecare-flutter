import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

import 'consumer_data_model.dart';

class ConsumerRefDataModel extends ConsumerDataModel {
  @override
  initialize() {
    super.initialize();
    consumerId = "";
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    super.deserialize(dictionary);
    if (dictionary == null) return;
    if (UtilsBaseFunction.containsKey(dictionary, "consumerId")) {
      consumerId = UtilsString.parseString(dictionary["consumerId"]);
    }
  }

  ConsumerRefDataModel() {
    initialize();
  }

  ConsumerRefDataModel.fromConsumerDataModel(ConsumerDataModel? model) {
    if (model == null) return;
    id = model.id;
    consumerId = model.id;
    organizationId = model.organizationId;
    szName = model.szName;
    szNickname = model.szNickname;
    szRegion = model.szRegion;
    szNotes = model.szNotes;
  }

  @override
  bool isValid() {
    return consumerId.isNotEmpty;
  }
}
