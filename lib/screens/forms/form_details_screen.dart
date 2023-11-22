import 'dart:io';
import 'package:flutter/material.dart';
import 'package:livecare/components/listView/form_section_listview.dart';
import 'package:livecare/listeners/form_details_listener.dart';
import 'package:livecare/listeners/route_form_listener.dart';
import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_field_rule_result_data_model.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/models/form/dataModel/form_submission_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/forms/form_sub_forms_list_screen.dart';
import 'package:livecare/screens/forms/viewModel/form_view_model.dart';
import 'package:livecare/utils/utils_general.dart';

class FormDetailsScreen extends BaseScreen {
  final FormRefDataModel? refForm;
  final FormSubmissionDataModel? modelSubmission;
  final FormViewModel? vmForm;
  final String? szBreadcrumb;
  final RouteFormListener? listener;

  const FormDetailsScreen(
      {Key? key,
      this.refForm,
      this.modelSubmission,
      this.vmForm,
      this.szBreadcrumb,
      this.listener})
      : super(key: key);

  @override
  _FormDetailsScreenState createState() => _FormDetailsScreenState();
}

class _FormDetailsScreenState extends BaseScreenState<FormDetailsScreen>
    with FormDetailsListener {
  String _txtBreadcrumb = "Breadcrumb";
  List<FormFieldDataModel> arrayFieldsBeforeDelete = [];
  List<FormFieldDataModel> arrayFieldsAfterDelete = [];


  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  _refreshFields() {
    final form = widget.vmForm;
    if (form == null) return;
    _txtBreadcrumb = "${widget.szBreadcrumb}${form.szFormName}";
  }

  _gotoSubformAt(int sectionIndex, int fieldIndex) {
    final form = widget.vmForm;
    if (form == null) return;

    final section = form.arraySections[sectionIndex];
    final field = section.arrayFields[fieldIndex];
    if (!field.allowMultipleInstances) {
      final modelSubmission = widget.modelSubmission;
      final refForm = widget.refForm;
      final modelField = field;
      final szBreadcrumb = "${widget.szBreadcrumb}${form.szFormName}";

      Navigator.push(
        context,
        createRoute(FormSubFormsListScreen(
            refForm: refForm,
            modelSubmission: modelSubmission,
            modelField: modelField,
            szBreadcrumb: szBreadcrumb,
            listener: widget.listener)),
      );
    } else {
      final modelForm = field.getSubFormDataModelAtIndex(0);
      if (modelForm == null) return;

      final vmForm = FormViewModel().instanceFromSubForm(modelForm);
      vmForm.generateRuleResults();
      final modelSubmission = widget.modelSubmission;
      final refForm = widget.refForm;
      final szBreadcrumb = "${form.szFormName} > ";

      Navigator.push(
        context,
        createRoute(FormDetailsScreen(
            refForm: refForm,
            modelSubmission: modelSubmission,
            vmForm: vmForm,
            szBreadcrumb: szBreadcrumb,
            listener: widget.listener)),
      );
    }
  }

  _uploadPhotoAndUpdate(int sectionIndex, int fieldIndex, File image) {
    final refForm = widget.refForm;
    if (refForm == null) return;

    showProgressHUD();
    UtilsGeneral.log("Uploading photo...");
    widget.listener?.requestFormsListScreenUploadPhoto(refForm, image,
        (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess &&
          responseDataModel.parsedObject != null) {
        final medium = responseDataModel.parsedObject;
        setState(() {
          widget.vmForm!.updateValue(medium, sectionIndex, fieldIndex);
        });
      } else if (responseDataModel.errorMessage.isNotEmpty) {
        showToast(responseDataModel.errorMessage);
      } else {
        showToast("Sorry, we've encountered an error");
      }
    });
  }

  _uploadMultiplePhotosAndUpdate(
      int sectionIndex, int fieldIndex,  images) {
    final refForm = widget.refForm;
    if (refForm == null) return;

    showProgressHUD();
    final valueNotifier = ValueNotifier(0);

    List<MediaDataModel> arrayMedia = [];

    int index = 0;

    if(images is List<File>){
      for (var image in images) {
        widget.listener?.requestFormsListScreenUploadPhoto(refForm, image,
                (responseDataModel) {
              if (responseDataModel.isSuccess &&
                  responseDataModel.parsedObject != null) {
                final media = responseDataModel.parsedObject as MediaDataModel;
                media.tag = index;
                arrayMedia.add(media);
              }
              index = index + 1;
              valueNotifier.value++;
            });
      }
      valueNotifier.addListener(() {
        if (valueNotifier.value == images.length) {
          hideProgressHUD();
          // Sort media items by the order the photos were taken in camera view
          arrayMedia.sort((media1, media2) => media1.tag.compareTo(media2.tag));
          setState(() {
            widget.vmForm!.updateValue(arrayMedia, sectionIndex, fieldIndex);
          });
        }
      });
    }

  }

  bool _validateFields() {
    if (widget.vmForm == null) return false;

    for (var section in widget.vmForm!.arraySections) {
      // If section is hidden by field-rule, we don't need to do validation on this.
      if (widget.vmForm!.getRuleResultForFieldKey(section.szKey) != null) {
        final FormFieldRuleResultDataModel? ruleResult =
            widget.vmForm!.getRuleResultForFieldKey(section.szKey);
        if (!ruleResult!.isVisible) continue;
      }
      for (var field in section.arrayFields) {
        if (widget.vmForm!.getRuleResultForFieldKey(field.szFieldKey) != null) {
          final FormFieldRuleResultDataModel? ruleResult =
              widget.vmForm!.getRuleResultForFieldKey(field.szFieldKey);
          if (!ruleResult!.isVisible) continue;
        }
        if (field.isRequired && !field.hasValue()) {
          showToast("Please fill out all required fields before submission.");
          return false;
        }
      }
    }
    return true;
  }

  @override
  onDeleteValue(int sectionIndex, int fieldIndex, int itemIndex) {
    if (widget.vmForm == null) return;
    setState(() {
      widget.vmForm!.deleteValue(sectionIndex, fieldIndex, itemIndex);
      widget.vmForm!.updateRuleResultsForField(sectionIndex, fieldIndex);
    });
  }

  @override
  onItemClick(int sectionIndex, int fieldIndex) {
    if (fieldIndex == -1) {
      setState(() {
        widget.vmForm!.arrayExpanded[sectionIndex] =
            !widget.vmForm!.arrayExpanded[sectionIndex];
      });
      return;
    }
    final FormFieldDataModel field =
        widget.vmForm!.arraySections[sectionIndex].arrayFields[fieldIndex];
    if (field.enumFieldType == EnumFormFieldType.subForm) {
      if (widget.vmForm != null) {
        if (!widget.vmForm!.hasChanges) {
          _gotoSubformAt(sectionIndex, fieldIndex);
        }
      }
    }
  }

  @override
  onUpdateValue(int sectionIndex, int fieldIndex, value) {
    final form = widget.vmForm;
    if (form == null) return;
    final section = form.arraySections[sectionIndex];
    final field = section.arrayFields[fieldIndex];

    if (field.enumFieldType == EnumFormFieldType.multiPhotoPicker) {

      if(value is List<File>){
        final List<File> images = value;
        _uploadMultiplePhotosAndUpdate(sectionIndex, fieldIndex, images);
      }
      else {
        final File image = value as File;
        _uploadPhotoAndUpdate(sectionIndex, fieldIndex, image);
      }

    } else if (field.enumFieldType == EnumFormFieldType.singlePhotoPicker) {
      final File image = value as File;
      _uploadPhotoAndUpdate(sectionIndex, fieldIndex, image);
    } else if (field.enumFieldType == EnumFormFieldType.signature) {
      final File image = value as File;
      _uploadPhotoAndUpdate(sectionIndex, fieldIndex, image);
    } else {
      setState(() {
        if (arrayFieldsBeforeDelete.isEmpty) {
          arrayFieldsBeforeDelete.addAll(
              widget.vmForm!.arraySections[sectionIndex].arrayFields);
        }

        if (sectionIndex == 0 && fieldIndex == 2 && value == "No" || value == null) {

          arrayFieldsBeforeDelete.clear();
          arrayFieldsAfterDelete.clear();
          arrayFieldsBeforeDelete.addAll(widget.vmForm!.arraySections[sectionIndex].arrayFields);

          widget.vmForm!.arraySections[sectionIndex].arrayFields.removeRange(3, 6);
          arrayFieldsAfterDelete.addAll(widget.vmForm!.arraySections[sectionIndex].arrayFields);

        }
        if (sectionIndex == 0 && fieldIndex == 2 && value == "Yes") {

           setState(() {
             widget.vmForm!.arraySections[sectionIndex].arrayFields.clear();
              widget.vmForm!.arraySections[sectionIndex].arrayFields.addAll(arrayFieldsBeforeDelete);
           });
        }
        if (sectionIndex == 0 && fieldIndex == 3 && value is List<String>) {
          if (value.isNotEmpty && value[0]=="other"){
            setState(() {
              print("This is called");
              widget.vmForm!.arraySections[sectionIndex].arrayFields.clear();
              widget.vmForm!.arraySections[sectionIndex].arrayFields.addAll(arrayFieldsBeforeDelete);
            });
          }
          else {
            widget.vmForm!.arraySections[sectionIndex].arrayFields.removeAt(4);
          }
        }
        widget.vmForm!.updateValue(value!, sectionIndex, fieldIndex);
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.titleFormDetails,
          style: AppStyles.textCellHeaderStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                if (_validateFields()) {
                  onBackPressed();
                }
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.buttonSave,
                    style: AppStyles.buttonTextStyle),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Container(
          padding: AppDimens.kVerticalMarginNormal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppDimens.kHorizontalMarginNormal,
                child: const Text("Please fill out the form",
                    style: AppStyles.rideInformation),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                padding: AppDimens.kHorizontalMarginNormal,
                child:
                    Text(_txtBreadcrumb, style: AppStyles.textCellTitleStyle),
              ),
              Expanded(
                child: FormSectionListView(
                  vmForm: widget.vmForm!,
                  callback: this,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
