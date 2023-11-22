import 'package:livecare/models/form/dataModel/form_configuration_data_model.dart';
import 'package:livecare/models/form/dataModel/form_definition_data_model.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';

class FormSubmissionDataModel {
  String id = "";
  String organizationId = "";
  FormConfigurationDataModel modelFormData = FormConfigurationDataModel();

  FormSubmissionDataModel() {
    initialize();
  }

  initialize() {
    id = "";
    organizationId = "";
    modelFormData = FormConfigurationDataModel();
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;
    try {
      if (dictionary.containsKey("id")) {
        id = UtilsString.parseString(dictionary["id"]);
      }
      if (dictionary.containsKey("organization") && dictionary["organization"] != null) {
        final Map<String, dynamic> dic = dictionary["organization"];
        organizationId = UtilsString.parseString(dic["organizationId"]);
      }
      if (organizationId.isEmpty) {
        if (dictionary.containsKey("organizationId")) {
          organizationId = UtilsString.parseString(dictionary["organizationId"]);
        }
      }
      if (dictionary.containsKey("formData") &&
          dictionary["formData"] != null) {
        modelFormData.deserialize(dictionary["formData"]);
      }
    } catch (error) {
      UtilsGeneral.log("Form Submission deserialize - $error");
    }
  }

  Map<String, dynamic> serialize() {
    final Map<String, dynamic> ser = {};
    try {
      ser["formData"] = modelFormData.serialize();
    } catch (error) {
      UtilsGeneral.log("Form Submission Serialize - $error");
    }
    return ser;
  }
  
  FormSubmissionDataModel? instanceFromFormDefinition(
      FormDefinitionDataModel formDef) {
    final FormSubmissionDataModel submission = FormSubmissionDataModel();
    submission.organizationId = formDef.organizationId;
    submission.modelFormData.deserialize(formDef.modelConfiguration.payload);
    return submission;
  }
}
