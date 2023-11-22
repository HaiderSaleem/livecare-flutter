import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_field_rule_result_data_model.dart';
import 'package:livecare/models/form/dataModel/form_page_data_model.dart';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/models/form/dataModel/sub_form_data_model.dart';

class FormViewModel {
  String szFormName = "";
  List<FormSectionDataModel> arraySections = [];
  List<bool> arrayExpanded = [];
  List<FormFieldRuleResultDataModel> arrayRuleResults = [];
  bool hasChanges = false;

  FormViewModel() {
    initialize();
  }

  initialize() {
    szFormName = "";
    arraySections = [];
    arrayExpanded = [];
    arrayRuleResults = [];
    hasChanges = false;
  }

  FormViewModel instanceFromFormPage(FormPageDataModel page) {
    final form = FormViewModel();
    form.szFormName = page.szName;
    form.arraySections = page.arraySections;
    for (var _ in form.arraySections) {
      form.arrayExpanded.add(false);
    }
    return form;
  }

  FormViewModel instanceFromSubForm(SubFormDataModel subForm) {
    final form = FormViewModel();
    form.szFormName = subForm.getFormTitle();
    form.arraySections = subForm.arraySections;
    for (var _ in form.arraySections) {
      form.arrayExpanded.add(false);
    }
    return form;
  }

  updateValue(dynamic value, int sectionIndex, int fieldIndex) {
    final modelSection = arraySections[sectionIndex];
    print("Model Section "+arraySections.length.toString());
    print("Field Index "+fieldIndex.toString());
    print("Section Index "+sectionIndex.toString());
    print("Array Field  "+modelSection.arrayFields.length.toString());
    final modelField = modelSection.arrayFields[fieldIndex];
    if (modelField.enumFieldType == EnumFormFieldType.multiPhotoPicker) {
      final mediaToAdd = value;
      final media = modelField.parsedObject;
      if (media is List<MediaDataModel> && mediaToAdd is List<MediaDataModel>) {
        final List<MediaDataModel> resultMedia = [];
        resultMedia.addAll(media);
        resultMedia.addAll(mediaToAdd);
        modelField.parsedObject = resultMedia;
      } else {
        return;
      }
    } else if (modelField.enumFieldType ==
        EnumFormFieldType.singlePhotoPicker) {
      final medium = value;
      if (medium is MediaDataModel) {
        modelField.parsedObject = medium;
      } else {
        return;
      }
    } else {
      modelField.parsedObject = value;
    }
    hasChanges = true;
  }

  deleteValue(int sectionIndex, int fieldIndex, int valueIndex) {
    final modelSection = arraySections[sectionIndex];
    final modelField = modelSection.arrayFields[fieldIndex];

    //delete value
    if (modelField.enumFieldType == EnumFormFieldType.multiPhotoPicker) {
      final media = modelField.parsedObject;
      if (media is List<MediaDataModel>) {
        final List<MediaDataModel> newMedia = [];
        newMedia.addAll(media);
        if (valueIndex < newMedia.length) {
          newMedia.removeAt(valueIndex);
        }
        modelField.parsedObject = newMedia;
      } else {
        return;
      }
    } else if (modelField.enumFieldType ==
            EnumFormFieldType.singlePhotoPicker ||
        modelField.enumFieldType == EnumFormFieldType.signature) {
      modelField.parsedObject = null;
    } else {
      modelField.parsedObject = null;
    }
    hasChanges = true;
  }

  generateRuleResults() {
    arrayRuleResults.clear();
    for (var section in arraySections) {
      for (var field in section.arrayFields) {
        addRuleResultsIfNeeded(field.generateFieldRulesResult()!);
      }
    }
  }

  bool updateRuleResultsForField(int sectionIndex, int fieldIndex) {
    // Return true if rules are updated

    if (sectionIndex >= arraySections.length) {
      return false;
    }
    final modelSection = arraySections[sectionIndex];
    if (fieldIndex >= modelSection.arrayFields.length) {
      return false;
    }
    final modelField = modelSection.arrayFields[fieldIndex];
    final arrayResults = modelField.generateFieldRulesResult();
    if (arrayResults!.isNotEmpty) {
      addRuleResultsIfNeeded(arrayResults);
      return true;
    } else {
      return false;
    }
  }


  addRuleResultsIfNeeded(List<FormFieldRuleResultDataModel> newResults) {
    // Update (if exists) or Add (if not exists)
    for (var newResult in newResults) {
      var found = false;
      for (var result in arrayRuleResults) {
        if (result.szFieldKey == newResult.szFieldKey) {
          result.isVisible = newResult.isVisible;
          found = true;
          break;
        }
      }

      if (found) {
        arrayRuleResults.add(newResult);
      }
    }
  }

  FormFieldRuleResultDataModel? getRuleResultForFieldKey(String key) {
    for (var result in arrayRuleResults) {
      if (key == key) {
        return result;
      }
    }
    return null;
  }
}
