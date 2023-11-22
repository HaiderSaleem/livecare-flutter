import 'package:flutter/material.dart';
import 'package:livecare/listeners/form_details_listener.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_date.dart';

class FormDatePickerItem extends BaseScreen {
  final FormSectionDataModel? modelSection;
  final int indexSection;
  final int position;
  final FormDetailsListener? callback;

  const FormDatePickerItem(
      {Key? key,
        required this.modelSection,
        required this.indexSection,
        required this.position,
        required this.callback}) : super(key: key);

  @override
  _FormDatePickerItemState createState() => _FormDatePickerItemState();

}

class _FormDatePickerItemState
    extends BaseScreenState<FormDatePickerItem> {

  String _txtData = "";
  String _txtTitle = "";
  String _asterisk = "";

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  @override
  void didUpdateWidget(FormDatePickerItem oldWidget) {
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

    if (field.parsedObject is String) {
      _txtData = field.parsedObject as String;
    }
  }

  _showCalendar(String dateString, int indexSection, int position) {
    showDatePicker(
      context: context,
      initialDate: UtilsDate.getDateTimeFromStringWithFormatToApi(
          dateString, EnumDateTimeFormat.MMMdyyyy.value, false) ??
          DateTime.now(), // Refer step 1
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 50)),
    ).then((value) {
      if (value == null) return;
      widget.callback?.onUpdateValue(
          indexSection,
          position,
          UtilsDate.getStringFromDateTimeWithFormat(
              value, EnumDateTimeFormat.MMMdyyyy.value, false));
    });
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
                        .copyWith(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          GestureDetector(
            onTap: () {
              _showCalendar(_txtData, widget.indexSection, widget.position);
            },
            child: Container(
              height: AppDimens.kEdittextHeight,
              padding: AppDimens.kHorizontalMarginSsmall,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: AppColors.separatorLineGray)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _txtData,
                  style: AppStyles.textCellTitleStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
