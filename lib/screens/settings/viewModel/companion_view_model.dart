import 'package:livecare/models/shared/companion_data_model.dart';
import 'package:livecare/models/shared/special_needs_data_model.dart';

class CompanionViewModel {
  String id = "";
  String szName = "";
  SpecialNeedsDataModel modelSpecialNeeds = SpecialNeedsDataModel();

  initialize() {
    id = "";
    szName = "";
    modelSpecialNeeds = SpecialNeedsDataModel();
  }

  CompanionViewModel fromDataModel(CompanionDataModel? companion) {
    final vm = CompanionViewModel();
    final modelCompanion = companion;
    if (modelCompanion == null) return vm;
    vm.id = modelCompanion.id;
    vm.szName = modelCompanion.szName;
    vm.modelSpecialNeeds.clone(modelCompanion.modelSpecialNeeds);
    return vm;
  }

  CompanionDataModel toDataModel() {
    final companion = CompanionDataModel();
    companion.id = id;
    companion.szName = szName;
    companion.modelSpecialNeeds.clone(modelSpecialNeeds);
    return companion;
  }
}
