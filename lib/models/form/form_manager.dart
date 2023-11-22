import 'dart:io';

import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/communication/network_manager.dart';
import 'package:livecare/models/communication/network_manager_response.dart';
import 'package:livecare/models/communication/network_response_data_model.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/form/dataModel/form_definition_data_model.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/models/form/dataModel/form_submission_data_model.dart';
import 'package:livecare/models/form/dataModel/form_submission_ref_data_model.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/utils_general.dart';

class FormManager {
  static final FormManager _sharedInstance = FormManager._internal();

  factory FormManager() {
    return _sharedInstance;
  }

  FormManager._internal();

  static FormManager get sharedInstance => _sharedInstance;

  List<FormDefinitionDataModel> arrayForms = [];

  addFormIfNeeded(FormDefinitionDataModel newForm) {
    if (!newForm.isValid()) return;
    // Add Form if needed
    var index = 0;
    for (var form in arrayForms) {
      if (form.id == newForm.id) {
        arrayForms[index] = newForm;
        return;
      }
      index++;
    }
    arrayForms.add(newForm);
  }

  FormDefinitionDataModel? getFormById(String? formId) {
    for (var form in arrayForms) {
      if (form.id == formId) return form;
    }
    return null;
  }

  Future<void> requestGetForms(NetworkManagerResponse? callback) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    if (currentUser == null) {
      callback?.call(NetworkResponseDataModel.forFailure());
      return;
    }
    for (var transOrg in currentUser.arrayOrganizations) {
      final String urlString = UrlManager.routeFormsApi.getForms(
        transOrg.organizationId,
      );
      NetworkManager.get(urlString, {}, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
        if (responseDataModel.isSuccess) {
          if (responseDataModel.payload.containsKey("data") && responseDataModel.payload["data"] != null) {
            try {
              final List<dynamic> array = responseDataModel.payload["data"];
              for (int i in Iterable.generate(array.length)) {
                final dict = array[i];
                final form = FormDefinitionDataModel();
                form.deserialize(dict);
                addFormIfNeeded(form);
              }
            } catch (e) {
              UtilsGeneral.log("response: " + e.toString());
            }
          }
        }
        callback?.call(responseDataModel);
      });
    }
  }

  Future<void> requestGetRouteFormById(String formId, bool forceLoad, NetworkManagerResponse callback) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    if (!forceLoad) {
      // Load from array if possible
      final FormDefinitionDataModel? formDef = getFormById(formId);
      if (formDef != null) {
        final NetworkResponseDataModel response = NetworkResponseDataModel.forSuccess();
        response.parsedObject = formDef;
        callback.call(response);
        return;
      }
    }
    final String urlString = UrlManager.routeFormsApi.getFormById(transOrg.organizationId, formId);
    NetworkManager.get(urlString, {}, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        final formDef = FormDefinitionDataModel();
        formDef.deserialize(responseDataModel.payload);
        addFormIfNeeded(formDef);
        responseDataModel.parsedObject = formDef;
      }
      callback.call(responseDataModel);
    });
  }

  Future<void> requestGetRouteFormSubmissionById(String routeId, String formId, String submissionId, NetworkManagerResponse callback) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    final String urlString = UrlManager.routeFormsApi.getFormSubmissionById(transOrg.organizationId, routeId, formId, submissionId);
    NetworkManager.get(urlString, {}, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        final submission = FormSubmissionDataModel();
        submission.deserialize(responseDataModel.payload);
        responseDataModel.parsedObject = submission;
      }
      callback.call(responseDataModel);
    });
  }

  Future<void> requestCreateRouteFormSubmission(
      RouteDataModel route, FormRefDataModel formRef, FormSubmissionDataModel submission, NetworkManagerResponse callback) async {
    final organizationId = route.refOrganization?.organizationId;
    if (organizationId == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    final String urlString = UrlManager.routeFormsApi.createFormSubmission(
      organizationId,
      route.id,
      formRef.formId,
    );
    final Map<String, dynamic> params = submission.serialize();
    NetworkManager.post(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        final newSubmission = FormSubmissionDataModel();
        newSubmission.deserialize(responseDataModel.payload);
        responseDataModel.parsedObject = newSubmission;
        final submissionRef = FormSubmissionRefDataModel();
        submissionRef.submissionId = submission.id;
        submissionRef.szFormName = submission.modelFormData.szFormName;
      }
      callback.call(responseDataModel);
    });
  }

  Future<void> requestUpdateRouteFormSubmission(
      RouteDataModel route, FormRefDataModel formRef, FormSubmissionDataModel submission, NetworkManagerResponse callback) async {
    final organizationId = route.refOrganization?.organizationId;
    if (organizationId == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    final String urlString = UrlManager.routeFormsApi.updateFormSubmission(organizationId, route.id, formRef.formId, submission.id);

    final Map<String, dynamic> params = submission.serialize();
    NetworkManager.put(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      callback.call(responseDataModel);
    });
  }

  Future<void> requestGetRequestFormById(String formId, bool forceLoad, NetworkManagerResponse callback) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }
    if (!forceLoad) {
      // Load from array if possible
      final FormDefinitionDataModel? formDef = getFormById(formId);
      if (formDef != null) {
        final NetworkResponseDataModel response = NetworkResponseDataModel.forSuccess();
        response.parsedObject = formDef;
        callback.call(response);
        return;
      }
    }
    final String urlString = UrlManager.serviceRequestFormsApi.getFormById(transOrg.organizationId, formId);
    NetworkManager.get(urlString, {}, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        final formDef = FormDefinitionDataModel();
        formDef.deserialize(responseDataModel.payload);
        addFormIfNeeded(formDef);
        responseDataModel.parsedObject = formDef;
      }
      callback.call(responseDataModel);
    });
  }

  Future<void> requestGetRequestFormSubmissionById(String routeId, String formId, String submissionId, NetworkManagerResponse callback) async {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    final String urlString = UrlManager.serviceRequestFormsApi.getFormSubmissionById(transOrg.organizationId, routeId, formId, submissionId);
    NetworkManager.get(urlString, {}, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) async {
      if (responseDataModel.isSuccess) {
        final submission = FormSubmissionDataModel();
        submission.deserialize(responseDataModel.payload);
        responseDataModel.parsedObject = submission;
      }
      callback.call(responseDataModel);
    });
  }

  Future<void> requestCreateFormSubmissionForTask(
      RequestDataModel route, String formId, FormSubmissionDataModel submission, NetworkManagerResponse callback) async {
    final organizationId = route.refOrganization.organizationId;
    final String urlString = UrlManager.serviceRequestFormsApi.createFormSubmission(
      organizationId,
      route.id,
      formId,
    );

    final Map<String, dynamic> params = submission.serialize();

    NetworkManager.post(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        final newSubmission = FormSubmissionDataModel();
        newSubmission.deserialize(responseDataModel.payload);
        responseDataModel.parsedObject = newSubmission;
        final submissionRef = FormSubmissionRefDataModel();
        submissionRef.submissionId = submission.id;
        submissionRef.szFormName = submission.modelFormData.szFormName;
      }
      callback.call(responseDataModel);
    });
  }

  Future<void> requestUpdateFormSubmission(RequestDataModel route, String formId, FormSubmissionDataModel submission, NetworkManagerResponse callback) async {
    final organizationId = route.refOrganization.organizationId;
    final String urlString = UrlManager.serviceRequestFormsApi.updateFormSubmission(organizationId, route.id, formId, submission.id);

    final Map<String, dynamic> params = submission.serialize();
    NetworkManager.put(urlString, params, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      callback.call(responseDataModel);
    });
  }

  Future<void> requestUploadPhotoForRoute(RouteDataModel route, FormRefDataModel formRef, File image, NetworkManagerResponse callback) async {
    final organizationId = route.refOrganization?.organizationId;
    if (organizationId == null) {
      callback.call(NetworkResponseDataModel.forFailure());
      return;
    }

    final String urlString = UrlManager.routeFormsApi.uploadMedia(organizationId, route.id, formRef.formId);

    NetworkManager.upload(urlString, "file", true, image, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        final media = MediaDataModel();
        media.deserialize(responseDataModel.payload);
        responseDataModel.parsedObject = media;
      }
      callback.call(responseDataModel);
    });
  }

  Future<void> requestUploadPhotoForRequest(RequestDataModel request, FormRefDataModel formRef, File image, NetworkManagerResponse callback) async {
    final organizationId = request.refOrganization.organizationId;
    final String urlString = UrlManager.serviceRequestFormsApi.uploadMedia(organizationId, request.id, formRef.formId);

    NetworkManager.upload(urlString, "file", true, image, EnumNetworkAuthOptions.authRequired.value).then((responseDataModel) {
      if (responseDataModel.isSuccess) {
        final media = MediaDataModel();
        media.deserialize(responseDataModel.payload);
        responseDataModel.parsedObject = media;
      }
      callback.call(responseDataModel);
    });
  }
}
