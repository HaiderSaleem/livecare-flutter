import 'dart:io';

import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/models/form/dataModel/form_submission_data_model.dart';

abstract class RouteFormListener {
  onPressedSubmitForm();

  onPressedCancel();

  requestFormsListScreenGetSubmission(
      FormRefDataModel formRef, NetworkManagerResponse callback);

  requestFormsListScreenCreateSubmission(FormRefDataModel formRef,
      FormSubmissionDataModel submission, NetworkManagerResponse callback);

  requestFormsListScreenUpdateSubmission(FormRefDataModel formRef,
      FormSubmissionDataModel submission, NetworkManagerResponse callback);

  requestFormsListScreenUploadPhoto(FormRefDataModel formRef, File image, NetworkManagerResponse callback);
}
