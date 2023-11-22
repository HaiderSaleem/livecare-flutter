import 'package:flutter/material.dart';
import 'package:livecare/listeners/form_details_listener.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class FormSubFormItem extends BaseScreen {
  final FormSectionDataModel? modelSection;
  final int indexSection;
  final int position;
  final FormDetailsListener? callback;

  const FormSubFormItem(
      {Key? key,
      required this.modelSection,
      required this.indexSection,
      required this.position,
      required this.callback})
      : super(key: key);

  @override
  _FormSubFormItemState createState() => _FormSubFormItemState();
}

class _FormSubFormItemState extends BaseScreenState<FormSubFormItem> {

  String _txtTitle = "";
  String _asterisk = "";

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  @override
  void didUpdateWidget(FormSubFormItem oldWidget) {
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
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          widget.callback?.onItemClick(widget.indexSection, widget.position);
        },
        child: Container(
          height: AppDimens.kEdittextHeight,
          padding: AppDimens.kHorizontalMarginSsmall,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: AppColors.separatorLineGray)),
          child: Row(
            children: [
              Image.asset(
                "assets/images/forms_subforms.png",
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
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
              ),
              const SizedBox(
                width: 8,
              ),
              Image.asset(
                "assets/images/ic_right.png",
                width: 15,
                height: 15,
              )
            ],
          ),
        ),
      ),
    );
  }
}
