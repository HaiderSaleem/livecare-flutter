import 'package:flutter/material.dart';
import 'package:livecare/listeners/form_details_listener.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/forms/form_list_picker_popup_dialog.dart';
import 'package:livecare/screens/forms/viewModel/form_list_item_view_model.dart';

class FormMultiListPickerItem extends BaseScreen {
  final FormSectionDataModel? modelSection;
  final int indexSection;
  final int position;
  final FormDetailsListener? callback;

  const FormMultiListPickerItem(
      {Key? key,
      required this.modelSection,
      required this.indexSection,
      required this.position,
      required this.callback})
      : super(key: key);

  @override
  _FormMultiListPickerItemState createState() =>
      _FormMultiListPickerItemState();
}

class _FormMultiListPickerItemState
    extends BaseScreenState<FormMultiListPickerItem> {
  List<FormListItemViewModel> arrayItems = [];
  String _txtData = "";
  String _txtTitle = "";
  String _asterisk = "";

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  @override
  void didUpdateWidget(FormMultiListPickerItem oldWidget) {
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

    _txtData;
    arrayItems = [];

    if (field.parsedObject is List<String>) {
      arrayItems = FormListItemViewModel().generateItemsFromDataSources(
          field.arrayDataSource, field.parsedObject as List<String>);
    } else {
      arrayItems = FormListItemViewModel()
          .generateItemsFromDataSources(field.arrayDataSource, []);
    }

    final List<String> selectedItemTitles = arrayItems
        .where((element) => element.isSelected)
        .map((e) => e.szTitle)
        .toList();
    _txtData = selectedItemTitles.join(", ");
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
                  isMultiSelect: true,
                  listener: (List<FormListItemViewModel> selectedItems) {
                    final List<String> selectedItemValues =
                        selectedItems.map((e) => e.szValue).toList();
                    widget.callback?.onUpdateValue(widget.indexSection,
                        widget.position, selectedItemValues);
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
                  Radius.circular(5),),
                border: Border.all(color: AppColors.separatorLineGray),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _txtData,
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
