import 'package:flutter/material.dart';
import 'package:livecare/listeners/form_details_listener.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class FormTextFieldItem extends BaseScreen {
  final FormSectionDataModel? modelSection;
  final int indexSection;
  final int position;
  final FormDetailsListener? callback;

  const FormTextFieldItem(
      {Key? key,
        required this.modelSection,
        required this.indexSection,
        required this.position,
        required this.callback})
      : super(key: key);

  @override
  _FormTextFieldItemState createState() => _FormTextFieldItemState();
}

class _FormTextFieldItemState extends BaseScreenState<FormTextFieldItem> {
  String _txtData = "";
  String _txtTitle = "";
  String _asterisk = "";

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  @override
  void didUpdateWidget(FormTextFieldItem oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppDimens.kMarginSsmall,
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
          SizedBox(
            height: AppDimens.kEdittextHeight,
            child: TextFormField(
              initialValue: _txtData,
              cursorColor: Colors.grey,
              textAlign: TextAlign.left,
              onChanged: (value) {
                widget.callback?.onUpdateValue(widget.indexSection, widget.position, value);
              },
              style: AppStyles.headingValue,
              keyboardType: TextInputType.text,
              decoration: AppStyles.autoCompleteField,
            ),
          ),
        ],
      ),
    );
  }
}
