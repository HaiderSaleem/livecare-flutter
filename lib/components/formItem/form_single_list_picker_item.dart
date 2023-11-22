import 'package:flutter/material.dart';
import 'package:livecare/listeners/form_details_listener.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_field_data_source_data_model.dart';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/forms/form_list_picker_popup_dialog.dart';
import 'package:livecare/screens/forms/viewModel/form_list_item_view_model.dart';

class FormSingleListPickerItem extends BaseScreen {
  final FormSectionDataModel? modelSection;
  final int indexSection;
  final int position;
  final FormDetailsListener? callback;

  const FormSingleListPickerItem(
      {Key? key,
      required this.modelSection,
      required this.indexSection,
      required this.position,
      required this.callback})
      : super(key: key);

  @override
  _FormSingleListPickerItemState createState() =>
      _FormSingleListPickerItemState();
}

class _FormSingleListPickerItemState
    extends BaseScreenState<FormSingleListPickerItem> {

  List<FormListItemViewModel> arrayItems = [];
  String? _txtData;
  String _txtTitle = "";
  String _asterisk = "";

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  @override
  void didUpdateWidget(FormSingleListPickerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initUI();
  }

  _initUI() {
    final FormFieldDataModel field =
        widget.modelSection!.arrayFields[widget.position];
    _txtTitle = field.szFieldName;
    _asterisk = "";
    if (field.isRequired) {
      _asterisk = " *";
    }

    for (int i in Iterable.generate(field.arrayDataSource.length)) {
      final FormFieldDataSourceDataModel dataSource = field.arrayDataSource[i];
      if (_convertObjectToString(field.parsedObject).isNotEmpty &&
          _convertObjectToString(field.parsedObject) == dataSource.szValue) {
        _txtData = dataSource.szName;
      }
    }

    arrayItems = [];
    if (_txtData != null) {
      arrayItems = FormListItemViewModel()
          .generateItemsFromDataSources(field.arrayDataSource, [_txtData!]);
    } else {
      arrayItems = FormListItemViewModel()
          .generateItemsFromDataSources(field.arrayDataSource, []);
    }

  }

  String _convertObjectToString(dynamic anyValue) {
    if (anyValue == null) return "";
    final str = anyValue.toString();
    return (str.isEmpty || str == "null") ? "" : str;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppDimens.kMarginSsmall,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: _txtTitle,
              style: AppStyles.textCellTitleStyle,
              children: <TextSpan>[
                TextSpan(
                  text: _asterisk,
                  style: AppStyles.textCellTitleBoldStyle
                      .copyWith(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => FormListPickerPopupDialog(
                  arrayListItems: arrayItems,
                  isMultiSelect: false,
                  listener: (List<FormListItemViewModel> selectedItems) {
                    widget.callback?.onUpdateValue(
                        widget.indexSection,
                        widget.position,
                        selectedItems.isEmpty
                            ? ""
                            : selectedItems.first.szValue);
                  },
                ),
              );
            },
            child: Container(
              height: AppDimens.kEdittextHeight,
              padding: AppDimens.kHorizontalMarginSsmall,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
                border: Border.all(color: AppColors.separatorLineGray),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _txtData ?? "",
                  style: AppStyles.textCellTitleStyle
                      .copyWith(color: AppColors.textGrayDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
