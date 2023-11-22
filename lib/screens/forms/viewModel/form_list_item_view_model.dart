import 'package:livecare/models/form/dataModel/form_field_data_source_data_model.dart';

class FormListItemViewModel {
  String szTitle = "";
  String szValue = "";
  bool isSelected = false;

  initialize(String title, String value, bool selected) {
    szTitle = title;
    szValue = value;
    isSelected = selected;
  }

  List<FormListItemViewModel> generateItemsFromDataSources(
      List<FormFieldDataSourceDataModel> array,
      List<String> selectedValues) {
    List<FormListItemViewModel> items = [];
    for (var ds in array) {
      bool selected = false;
      for (var v in selectedValues) {
        if (ds.szValue == v) {
          selected = true;
          break;
        }
      }
      final FormListItemViewModel form = FormListItemViewModel();
      form.initialize(ds.szName, ds.szValue, selected);
      items.add(form);
    }
    return items;
  }
}
