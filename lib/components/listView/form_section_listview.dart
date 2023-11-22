import 'package:flutter/material.dart';
import 'package:livecare/components/formItem/form_date_picker_item.dart';
import 'package:livecare/components/formItem/form_label_item.dart';
import 'package:livecare/components/formItem/form_multi_list_picker_item.dart';
import 'package:livecare/components/formItem/form_multi_photo_picker_item.dart';
import 'package:livecare/components/formItem/form_number_field_item.dart';
import 'package:livecare/components/formItem/form_phone_field_item.dart';
import 'package:livecare/components/formItem/form_signature_item.dart';
import 'package:livecare/components/formItem/form_single_list_picker_item.dart';
import 'package:livecare/components/formItem/form_single_photo_picker_item.dart';
import 'package:livecare/components/formItem/form_sub_form_item.dart';
import 'package:livecare/components/formItem/form_text_field_item.dart';
import 'package:livecare/components/formItem/form_text_view_item.dart';
import 'package:livecare/listeners/form_details_listener.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_field_rule_result_data_model.dart';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/forms/viewModel/form_view_model.dart';

class FormSectionListView extends BaseScreen {
  final FormViewModel vmForm;
  final FormDetailsListener? callback;

  const FormSectionListView({Key? key, required this.vmForm, this.callback})
      : super(key: key);

  @override
  _FormDetailsListViewState createState() => _FormDetailsListViewState();
}

class _FormDetailsListViewState extends BaseScreenState<FormSectionListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.vmForm.arraySections.length,
      padding: AppDimens.kMarginSsmall,
      itemBuilder: (BuildContext context, int sectionPosition) {
        FormSectionDataModel? modelSection =
            widget.vmForm.arraySections[sectionPosition];

        final FormFieldRuleResultDataModel? ruleResultForSection =
            widget.vmForm.getRuleResultForFieldKey(modelSection.szKey);

        if (ruleResultForSection != null && !ruleResultForSection.isVisible) {
          return Container();
        }

        bool bExpand = widget.vmForm.arrayExpanded[sectionPosition];
        int indexSection = sectionPosition;

        String _txtTitle = modelSection.szLabel;
        String _iconItem = "assets/images/ic_add.png";
        if (bExpand) {
          _iconItem = "assets/images/ic_minus.png";
        } else {
          _iconItem = "assets/images/ic_add.png";
        }

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                widget.callback?.onItemClick(sectionPosition, -1);
              },
              child: Container(
                margin: AppDimens.kMarginSsmall,
                decoration: const BoxDecoration(
                    color: AppColors.textWhite,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.separatorLineGray,
                        blurRadius: 5.0,
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                padding: AppDimens.kMarginNormal.copyWith(top: 12, bottom: 12),
                child: Row(
                  children: [
                    Image.asset(
                      _iconItem,
                      width: 15,
                      height: 15,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Text(
                        _txtTitle,
                        style: AppStyles.textTitleStyle
                            .copyWith(color: AppColors.buttonTextGray),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: bExpand,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modelSection.arrayFields.length,
                padding: AppDimens.kMarginNormal.copyWith(top: 8, bottom: 8),
                itemBuilder: (BuildContext context, int index) {
                  final FormFieldDataModel field =
                      modelSection.arrayFields[index];

                  switch (field.enumFieldType) {
                    case EnumFormFieldType.subForm:
                      return FormSubFormItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);

                    case EnumFormFieldType.numberField:
                      return FormNumberFieldItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);

                    case EnumFormFieldType.formattedField:
                      return FormPhoneFieldItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);

                    case EnumFormFieldType.datePicker:
                      return FormDatePickerItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);

                    case EnumFormFieldType.singleListPicker:
                      return FormSingleListPickerItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);

                    case EnumFormFieldType.multiListPicker:
                      return FormMultiListPickerItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);

                    case EnumFormFieldType.textView:
                      return FormTextViewItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);

                    case EnumFormFieldType.textLabel:
                      return FormLabelItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);

                    case EnumFormFieldType.singlePhotoPicker:
                      return FormSinglePhotoPickerItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);

                    case EnumFormFieldType.multiPhotoPicker:
                      return FormMultiPhotoPickerItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);

                    case EnumFormFieldType.signature:
                      return FormSignatureItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);

                    default:
                      return FormTextFieldItem(
                          modelSection: modelSection,
                          indexSection: indexSection,
                          position: index,
                          callback: widget.callback);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
