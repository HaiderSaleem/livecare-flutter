import 'package:flutter/material.dart';
import 'package:livecare/listeners/form_details_listener.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class FormLabelItem extends BaseScreen {
  final FormSectionDataModel? modelSection;
  final int indexSection;
  final int position;
  final FormDetailsListener? callback;

  const FormLabelItem(
      {Key? key,
      required this.modelSection,
      required this.indexSection,
      required this.position,
      required this.callback})
      : super(key: key);

  @override
  _FormLabelItemState createState() => _FormLabelItemState();
}

class _FormLabelItemState extends BaseScreenState<FormLabelItem> {
  String _txtTitle = "";
  String _asterisk = "";

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  @override
  void didUpdateWidget(FormLabelItem oldWidget) {
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
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppDimens.kMarginSsmall,
      child: RichText(
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
    );
  }
}
