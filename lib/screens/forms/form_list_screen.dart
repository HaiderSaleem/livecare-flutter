import 'package:flutter/material.dart';
import 'package:livecare/components/listView/form_listview.dart';
import 'package:livecare/listeners/route_form_listener.dart';
import 'package:livecare/models/form/dataModel/form_field_rule_result_data_model.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/models/form/dataModel/form_submission_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/forms/form_details_screen.dart';
import 'package:livecare/screens/forms/form_page_list_screen.dart';
import 'package:livecare/screens/forms/viewModel/form_view_model.dart';
import 'package:livecare/utils/utils_string.dart';

class FormListScreen extends BaseScreen {
  final List<FormRefDataModel> arrayForms;
  final RouteFormListener? listener;

  const FormListScreen({Key? key, required this.arrayForms, required this.listener}) : super(key: key);

  @override
  _FormListScreenState createState() => _FormListScreenState();
}

class _FormListScreenState extends BaseScreenState<FormListScreen> {
  List<FormSubmissionDataModel?> arraySubmissions = [];
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  _refreshFields() {
    arraySubmissions = List.filled(widget.arrayForms.length, null);
  }

  _requestGetSubmissionForFormRef(FormRefDataModel formRef, RequestSubmissionResponse callback) {
    showProgressHUD();
    widget.listener?.requestFormsListScreenGetSubmission(formRef, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess || responseDataModel.isOffline) {
        final submission = responseDataModel.parsedObject as FormSubmissionDataModel?;
        callback.call(submission);
      } else {
        callback.call(null);
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _saveSubmissionWithCallback(FormRefDataModel formRef, FormSubmissionDataModel submission, SaveSubmissionResponse callback) {
    if (submission.id.isEmpty) {
      widget.listener?.requestFormsListScreenCreateSubmission(formRef, submission, (responseDataModel) {
        if (responseDataModel.isSuccess || responseDataModel.isOffline) {
          final newSubmission = responseDataModel.parsedObject as FormSubmissionDataModel?;
          if (newSubmission == null) {
            callback.call(false);
            showToast("Sorry, we've encountered an error while creating new form submission");
          } else if (!responseDataModel.isOffline) {
            submission.id = newSubmission.id;
            formRef.submissionId = submission.id;
            callback.call(true);
          } else {
            submission.id = UtilsString.generateRandomString(24);
            formRef.submissionId = submission.id;
            callback.call(true);
          }
        } else {
          callback.call(false);
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      widget.listener?.requestFormsListScreenUpdateSubmission(formRef, submission, (responseDataModel) {
        if (responseDataModel.isSuccess || responseDataModel.isOffline) {
          callback.call(true);
        } else {
          callback.call(false);
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    }
  }

  _onFormClick(FormRefDataModel form, int position) {
    final formRef = widget.arrayForms[position];
    final submission = arraySubmissions[position];
    if (submission != null) {
      _gotoPagesListScreen(formRef, submission);
    } else {
      _requestGetSubmissionForFormRef(formRef, (submission) {
        if (submission != null) {
          arraySubmissions[position] = submission;
          _gotoPagesListScreen(formRef, submission);
        }
      });
    }
  }

  _gotoPagesListScreen(FormRefDataModel formRef, FormSubmissionDataModel submission) {
    if (submission.modelFormData.arrayPages.length == 1) {
      // Go directly to the page-details

      final page = submission.modelFormData.arrayPages[0];
      final vmForm = FormViewModel().instanceFromFormPage(page);
      vmForm.generateRuleResults();
      Navigator.push(
        context,
        createRoute(FormDetailsScreen(refForm: formRef, modelSubmission: submission, vmForm: vmForm, szBreadcrumb: "", listener: widget.listener)),
      );
    } else {
      //   Go to pages - list
      Navigator.push(
        context,
        createRoute(FormPageListScreen(modelFormRef: formRef, modelSubmission: submission, listener: widget.listener)),
      );
    }
  }

  _onButtonSubmitClick() {
    /// validate
    for (var submission in arraySubmissions) {
      if (submission == null) {
        showToast("Please fill out all forms.");
        return;
      }
    }

    int index1 = 0;
    for (var _ in widget.arrayForms) {
      final submission = arraySubmissions[index1];
      if (submission != null) {
        for (var page in submission.modelFormData.arrayPages) {
          final vmForm = FormViewModel().instanceFromFormPage(page);
          if (!_validateFields(vmForm)) {
            return;
          }
        }
      }
      index1 += 1;
    }

    int index = 0;
    showProgressHUD();
    for (var formRef in widget.arrayForms) {
      final submission = arraySubmissions[index];
      if (submission != null) {
        _saveSubmissionWithCallback(formRef, submission, (completed) {
          if (completed) {}
        });
      }
      index += 1;
    }
    hideProgressHUD();
    onBackPressed();
    widget.listener?.onPressedSubmitForm();
  }

  _onButtonCancelClick() {
    widget.listener?.onPressedCancel();
    onBackPressed();
  }

  bool _validateFields(FormViewModel? vmForm) {
    if (vmForm == null) return false;

    for (var section in vmForm.arraySections) {
      // If section is hidden by field-rule, we don't need to do validation on this.
      if (vmForm.getRuleResultForFieldKey(section.szKey) != null) {
        final FormFieldRuleResultDataModel? ruleResult = vmForm.getRuleResultForFieldKey(section.szKey);
        if (!ruleResult!.isVisible) continue;
      }
      for (var field in section.arrayFields) {
        if (vmForm.getRuleResultForFieldKey(field.szFieldKey) != null) {
          final FormFieldRuleResultDataModel? ruleResult = vmForm.getRuleResultForFieldKey(field.szFieldKey);
          if (!ruleResult!.isVisible) continue;
        }
        if (field.isRequired && !field.hasValue()) {
          showToast("Please fill out all forms.");
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.titleForms,
          style: AppStyles.textCellHeaderStyle,
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 132,
              left: 0,
              right: 0,
              child: Container(
                padding: AppDimens.kMarginNormal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(AppStrings.pleaseFilloutTheForms, style: AppStyles.filloutForms),
                    Expanded(
                      child: FormListView(
                        arrayForms: widget.arrayForms,
                        itemClickListener: (form, position) {
                          _onFormClick(form, position);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: AppDimens.kMarginNormal,
                child: Column(
                  children: [
                    ElevatedButton(
                      style: AppStyles.roundButtonStyle,
                      onPressed: () {
                        _onButtonSubmitClick();
                      },
                      child: const Text(
                        "Submit Forms",
                        textAlign: TextAlign.center,
                        style: AppStyles.buttonTextStyle,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: AppStyles.whiteRoundButtonStyle,
                      onPressed: () {
                        _onButtonCancelClick();
                      },
                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.center,
                        style: AppStyles.buttonTextStyle.copyWith(color: AppColors.primaryColor),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef RequestSubmissionResponse = Function(FormSubmissionDataModel? submission);

typedef SaveSubmissionResponse = Function(bool completed);
