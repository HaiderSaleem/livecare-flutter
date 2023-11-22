import 'package:flutter/material.dart';
import 'package:livecare/components/listView/form_page_listview.dart';
import 'package:livecare/listeners/route_form_listener.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/models/form/dataModel/form_submission_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/forms/form_details_screen.dart';

class FormPageListScreen extends BaseScreen {
  final FormRefDataModel? modelFormRef;
  final FormSubmissionDataModel? modelSubmission;
  final RouteFormListener? listener;

  const FormPageListScreen(
      {Key? key,
      required this.modelFormRef,
      required this.modelSubmission,
      required this.listener}) : super(key: key);

  @override
  _FormPageListScreenState createState() => _FormPageListScreenState();

}

class _FormPageListScreenState extends BaseScreenState<FormPageListScreen> {
  String _txtBreadcrumb = "Breadcrumb";

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  _refreshFields() {
    final refForm = widget.modelFormRef;
    if (refForm == null) return;
    _txtBreadcrumb = "${refForm.szName} > ";
  }

  _gotoFormDetailsScreen() {
    Navigator.push(
      context,
      createRoute(FormDetailsScreen(listener: widget.listener)),
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
          AppStrings.titlePages,
          style: AppStyles.textCellHeaderStyle,
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Container(
          padding: AppDimens.kMarginNormal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select page", style: AppStyles.rideInformation),
              const SizedBox(
                height: 8,
              ),
              Text(_txtBreadcrumb, style: AppStyles.textCellTitleStyle),
              Expanded(
                child: FormPageListView(
                  arrayFormPage:
                      widget.modelSubmission!.modelFormData.arrayPages,
                  itemClickListener: (formPage, position) {
                    _gotoFormDetailsScreen();
                  },),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
