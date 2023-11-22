import 'package:flutter/material.dart';
import 'package:livecare/components/listView/sub_form_listview.dart';
import 'package:livecare/listeners/route_form_listener.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/models/form/dataModel/form_submission_data_model.dart';
import 'package:livecare/models/form/dataModel/sub_form_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/forms/form_details_screen.dart';
import 'package:livecare/screens/forms/viewModel/form_view_model.dart';
import 'package:livecare/utils/utils_base_function.dart';


class FormSubFormsListScreen extends BaseScreen {
  final FormRefDataModel? refForm;
  final FormSubmissionDataModel? modelSubmission;
  final FormFieldDataModel? modelField;
  final String? szBreadcrumb;
  final RouteFormListener? listener;

  const FormSubFormsListScreen(
      {Key? key,
      this.refForm,
      this.modelSubmission,
      this.modelField,
      this.szBreadcrumb,
      this.listener})
      : super(key: key);

  @override
  _FormSubFormsListScreenState createState() => _FormSubFormsListScreenState();
}

class _FormSubFormsListScreenState
    extends BaseScreenState<FormSubFormsListScreen> {
  List<SubFormDataModel> arraySubForms = [];
  String _txtBreadcrumb = "Here is breadcrumb";
  bool _showAlert = true;

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  _refreshFields() {
    final field = widget.modelField;
    if (field == null) return;
    final subForms = field.parsedObject;
    setState(() {
      if (subForms is List<SubFormDataModel>) {
        arraySubForms.addAll(subForms);
        if (subForms.isNotEmpty) {
          _showAlert = false;
        } else {
          _showAlert = true;
        }
        _txtBreadcrumb = "${widget.szBreadcrumb}${field.szFieldName}";
      }
    });
  }

  addSubFormWithName(String formName) {
    final field = widget.modelField;
    if (field == null) return;
    widget.modelField!.addNewInstanceForSubForm(formName);
    _refreshFields();
  }

  _gotoSubFormDetailsScreen(int formIndex) {
    final field = widget.modelField;
    if (field == null) return;
    final modelForm = field.getSubFormDataModelAtIndex(formIndex);
    if (modelForm == null) return;

    final vmForm = FormViewModel().instanceFromSubForm(modelForm);
    vmForm.generateRuleResults();

    Navigator.push(
      context,
      createRoute(FormDetailsScreen(
          refForm: widget.refForm,
          modelSubmission: widget.modelSubmission,
          vmForm: vmForm,
          szBreadcrumb: "${widget.szBreadcrumb}${field.szFieldName} > ",
          listener: widget.listener)),
    );
  }

  _promptForDeleteSubForm(int index) {
    UtilsBaseFunction.showAlertWithMultipleButton(
        context,
        "Warning",
        "Are you sure you want to delete this form data?",
        () => {widget.modelField!.deleteSubFormAtIndex(index)});
  }

  _showInputDialogForFormName() {
    final _edtName = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Sub-Form"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please enter name of new sub form."),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              height: AppDimens.kEdittextHeight,
              child: TextFormField(
                controller: _edtName,
                style: const TextStyle(
                  fontStyle: FontStyle.normal,
                  fontFamily: "Lato",
                ),
                keyboardType: TextInputType.text,
                decoration: AppStyles.autoCompleteField,
              ),
            )
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              addSubFormWithName(_edtName.text);
              Navigator.pop(context);
              // onYes();
            },
            child: const Text('Ok'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            AppStrings.titleSubForms,
            style: AppStyles.textCellHeaderStyle,
          ),
          actions: <Widget>[
            Padding(
              padding: AppDimens.kHorizontalMarginBig.copyWith(left: 0),
              child: GestureDetector(
                onTap: () {
                  _showInputDialogForFormName();
                },
                child: const Icon(
                  Icons.add,
                  size: 30.0,
                ),
              ),
            )
          ]),
      body: SafeArea(
        bottom: true,
        child: Container(
          padding: AppDimens.kMarginNormal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Please fill out the form",
                  style: AppStyles.rideInformation),
              const SizedBox(
                height: 8,
              ),
              Text(_txtBreadcrumb, style: AppStyles.textCellTitleStyle),
              Expanded(
                child: _showAlert
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No subform instances",
                              style: AppStyles.textCellTitleBoldStyle),
                          Padding(
                            padding: AppDimens.kMarginNormal,
                            child: Text(
                              "Please click + button at the top right corner to add a new subform.",
                              style: AppStyles.textCellTitleBoldStyle,
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      )
                    : SubFormListView(
                        arraySubForms: arraySubForms,
                        itemClickListener: (subForm, position) {
                          _gotoSubFormDetailsScreen(position);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
