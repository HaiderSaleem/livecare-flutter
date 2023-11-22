import 'package:livecare/utils/utils_general.dart';

class UrlManager {
  static UserApi userApi = const UserApi();
  static OrganizationApi organizationApi = const OrganizationApi();
  static InviteApi inviteApi = const InviteApi();
  static ConsumerApi consumerApi = const ConsumerApi();
  static FinancialAccountApi financialAccountApi = const FinancialAccountApi();
  static TransactionApi transactionApi = const TransactionApi();
  static RequestApi requestApi = const RequestApi();
  static HomeRequestApi homeRequestApi = const HomeRequestApi();
  static LocationApi locationApi = const LocationApi();
  static ExperienceApi experienceApi = const ExperienceApi();
  static RouteApi routeApi = const RouteApi();
  static RouteFormsApi routeFormsApi = const RouteFormsApi();
  static ServiceRequestFormsApi serviceRequestFormsApi =
      const ServiceRequestFormsApi();
  static ServiceRequestApi serviceRequestApi = const ServiceRequestApi();
}

///*************** Global: User ****************/
class UserApi {
  const UserApi();

  String login() {
    return UtilsGeneral.getApiBaseUrl() + "/users/login";
  }

  String ssoAuth() {
    return UtilsGeneral.getApiBaseUrl() + "/users/login/auth0";
  }

  String signup() {
    return UtilsGeneral.getApiBaseUrl() + "/users/sign-up";
  }

  String updateMyProfile() {
    return UtilsGeneral.getApiBaseUrl() + "/users/me";
  }

  String uploadProfilePhoto() {
    return UtilsGeneral.getApiBaseUrl() + "/users/me/photo";
  }

  String getMyProfile() {
    return UtilsGeneral.getApiBaseUrl() + "/users/me";
  }

  String refreshToken(String token) {
    return UtilsGeneral.getApiBaseUrl() + "/users/refresh/" + token;
  }

  String forgotPassword() {
    return UtilsGeneral.getApiBaseUrl() + "/users/forget-password";
  }
}

///*************** Global: Organization ****************/
class OrganizationApi {
  const OrganizationApi();

  /* String getOrganizations() {
    return UtilsGeneral.getApiBaseUrl() + "/organizations";
  }*/
  String getOrganizations(String userId) {
    return UtilsGeneral.getApiBaseUrl() + "/users/" + userId + "/organizations";
  }
}

///*************** Global: Invites ****************/
class InviteApi {
  const InviteApi();

  String getInvites(String userId) {
    return UtilsGeneral.getApiBaseUrl() + "/users/" + userId + "/invites";
  }

  String acceptInvite(String userId, String token) {
    return UtilsGeneral.getApiBaseUrl() +
        "/users/" +
        userId +
        "/invites/" +
        token +
        "/accept";
  }

  String declineInvite(String userId, String token) {
    return UtilsGeneral.getApiBaseUrl() +
        "/users/" +
        userId +
        "/invites/" +
        token +
        "/decline";
  }

}

///*************** Global: Consumers ****************/
class ConsumerApi {
  const ConsumerApi();

  String getConsumers() {
    return UtilsGeneral.getApiBaseUrl() + "/consumers";
  }

  String getOrganizationConsumers(String organizationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers";
  }

  String getMediaWithId(String organizationId, String consumerId,
      String documentId, String mediaId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/documents/" +
        documentId +
        "/media/" +
        mediaId;
  }

  String updateConsumerById(
    String organizationId,
    String consumerId,
  ) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId;
  }
}

///*************** Global: Financial Accounts ****************/
class FinancialAccountApi {
  const FinancialAccountApi();

  String createAccount(String organizationId, String consumerId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/accounts";
  }

  String audit(String organizationId, String consumerId, String accountId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/accounts/" +
        accountId +
        "/audits";
  }

  String auditForLocationFinancialAccount(
      String organizationId, String locationId, String accountId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations/" +
        locationId +
        "/accounts/" +
        accountId +
        "/audits";
  }

  String getFinancialAccounts(String organizationId, String consumerId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/accounts";
  }

  String getFinancialAccountsByLocationId(
      String organizationId, String locationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations/" +
        locationId +
        "/accounts";
  }

  String uploadMediaForFinancialAccount(
      String organizationId, String consumerId, String accountId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/accounts/" +
        accountId +
        "/media";
  }

  String uploadMediaForLocationFinancialAccount(
      String organizationId, String locationId, String accountId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations/" +
        locationId +
        "/accounts/" +
        accountId +
        "/media";
  }

  String downloadMediaForFinancialAccount(String organizationId,
      String consumerId, String accountId, String mediaId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/accounts/" +
        accountId +
        "/media/" +
        mediaId;
  }

  String downloadMediaForLocationFinancialAccount(String organizationId,
      String locationId, String accountId, String mediaId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations/" +
        locationId +
        "/accounts/" +
        accountId +
        "/media/" +
        mediaId;
  }
}

///*************** Global: Transactions ****************/
class TransactionApi {
  const TransactionApi();

  String getTransactions() {
    return UtilsGeneral.getApiBaseUrl() + "/transactions";
  }

  String getTransactionsByConsumerId(String organizationId, String consumerId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/transactions";
  }

  String getTransactionsByAccountId(
      String organizationId, String consumerId, String accountId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/accounts/" +
        accountId +
        "/transactions";
  }

  String getTransactionsByLocationId(String organizationId, String locationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations/" +
        locationId +
        "/transactions";
  }

  String createTransaction(
      String organizationId, String consumerId, String accountId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/accounts/" +
        accountId +
        "/transactions";
  }

  String createTransactionForLocationAccount(
      String organizationId, String locationId, String accountId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations/" +
        locationId +
        "/accounts/" +
        accountId +
        "/transactions";
  }

  String createPurchaseForConsumerId(
      String organizationId, String consumerId, String accountId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/accounts/" +
        accountId +
        "/transactions/purchase";
  }

  String createPurchaseForLocationAccount(
      String organizationId, String locationId, String accountId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations/" +
        locationId +
        "/accounts/" +
        accountId +
        "/transactions/purchase";
  }

  String updateTransaction(String organizationId, String consumerId,
      String accountId, String transactionId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/accounts/" +
        accountId +
        "/transactions/" +
        transactionId;
  }

  String updateTransactionForLocationAccount(String organizationId,
      String locationId, String accountId, String transactionId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations/" +
        locationId +
        "/accounts/" +
        accountId +
        "/transactions/" +
        transactionId;
  }
}

///*************** Global: Requests ****************/
class RequestApi {
  const RequestApi();

  String getRequestsForMe() {
    return UtilsGeneral.getApiBaseUrl() + "/users/me/requests";
  }

  String getRequestsByOrganizationId(String organizationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/requests";
  }

  String getRequestsForConsumer(String organizationId, String consumerId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/requests";
  }

  String getRequests(String organizationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/requests";
  }

  String getRequestsForRoute(String organizationId, String routeId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/routes/" +
        routeId +
        "/requests";
  }

  String createRequest(String organizationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/requests";
  }

  String updateRequest(
      String organizationId, String requestId, String consumerId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/requests/" +
        requestId;
  }

  String cancelRequest(String organizationId, String requestId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/requests/" +
        requestId +
        "/cancel";
  }

  String createSchedule(String organizationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/schedules";
  }
}

///*************** Global: Home Service Requests ****************/

class HomeRequestApi {
  const HomeRequestApi();

  String createHomeServiceRequest(String organizationId, String consumerId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/requests";
  }

  String createHomeServiceSchedule(String organizationId, String consumerId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/schedules";
  }
}

///*************** Global: Locations ****************/
class LocationApi {
  const LocationApi();

  String getLocationsByOrganizationId(String organizationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations";
  }
}

///*************** Global: Experiences ****************/
class ExperienceApi {
  const ExperienceApi();

  String getExperiencesByOrganizationId(String organizationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/experiences";
  }

  String getExperiences() {
    return UtilsGeneral.getApiBaseUrl() + "/experiences";
  }

  String getExperienceById(String experiencedId) {
    return UtilsGeneral.getApiBaseUrl() + "/experiences/" + experiencedId;
  }

  String beginExperience(
      String organizationId, String locationId, String experiencedId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations/" +
        locationId +
        "/experiences/" +
        experiencedId +
        "/begin";
  }

  String endExperience(
      String organizationId, String locationId, String experiencedId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations/" +
        locationId +
        "/experiences/" +
        experiencedId +
        "/end";
  }

  String cancelExperience(
      String organizationId, String locationId, String experiencedId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/locations/" +
        locationId +
        "/experiences/" +
        experiencedId +
        "/cancel";
  }
}

///*************** Global: Route ****************/
class RouteApi {
  const RouteApi();

  String getRoutes(String organizationId, String driverId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/drivers/" +
        driverId +
        "/routes";
  }

  String getRouteById(String organizationId, String routeId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/routes/" +
        routeId;
  }

  //TODO- Start Route API
  String startRoute(String organizationId, String routeId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/routes/" +
        routeId +
        "/start";
  }

  String updateActivityStatus(
      String organizationId, String routeId, String activityId, String status) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/routes/" +
        routeId +
        "/activities/" +
        activityId +
        "/" +
        status;
  }

  String updatePayloads(
      String organizationId, String routeId, String activityId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/routes/" +
        routeId +
        "/activities/" +
        activityId +
        "/payloads";
  }

  String submitOutcomeResults(String organizationId, String routeId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/routes/" +
        routeId +
        "/outcomes";
  }

  String completeRoute(String organizationId, String routeId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/routes/" +
        routeId +
        "/complete";
  }
}

///*************** Driver: Forms ****************/
class RouteFormsApi {
  const RouteFormsApi();

  String getForms(String organizationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/forms";
  }

  String getFormById(String organizationId, String formId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/forms/" +
        formId;
  }

  String getFormSubmissions(String organizationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/submissions";
  }

  String getFormSubmissionById(String organizationId, String routeId,
      String formId, String submissionId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/routes/" +
        routeId +
        "/forms/" +
        formId +
        "/submissions/" +
        submissionId;
  }

  String createFormSubmission(
      String organizationId, String routeId, String formId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/routes/" +
        routeId +
        "/forms/" +
        formId +
        "/submissions";
  }

  String updateFormSubmission(String organizationId, String routeId,
      String formId, String submissionId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/routes/" +
        routeId +
        "/forms/" +
        formId +
        "/submissions/" +
        submissionId;
  }

  String uploadMedia(String organizationId, String routeId, String formId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/routes/" +
        routeId +
        "/forms/" +
        formId +
        "/media";
  }

  String getMediaWithId(
      String organizationId, String routeId, String formId, String mediaId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/transport-organizations/" +
        organizationId +
        "/routes/" +
        routeId +
        "/forms/" +
        formId +
        "/media/" +
        mediaId;
  }
}

///*************** Service Requests Forms ****************/
class ServiceRequestFormsApi {
  const ServiceRequestFormsApi();

  String getForms(String organizationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/forms";
  }

  String getFormById(String organizationId, String formId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/forms/";
  }

  String getFormSubmissions(String organizationId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/submissions";
  }

  String getFormSubmissionById(String organizationId, String requestId,
      String formId, String submissionId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/requests/" +
        requestId +
        "/forms/" +
        formId +
        "/submissions/" +
        submissionId;
  }

  String createFormSubmission(
      String organizationId, String requestId, String formId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/requests/" +
        requestId +
        "/forms/" +
        formId +
        "/submissions";
  }

  String updateFormSubmission(String organizationId, String requestId,
      String formId, String submissionId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/requests/" +
        formId +
        "/forms/" +
        formId +
        "/submissions/" +
        submissionId;
  }

  String uploadMedia(String organizationId, String requestId, String formId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/requests/" +
        requestId +
        "/forms/" +
        formId +
        "/media";
  }

  String getMediaWithId(
      String organizationId, String requestId, String formId, String mediaId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/requests/" +
        formId +
        "/forms/" +
        formId +
        "/media/" +
        mediaId;
  }
}

///*************** Service Requests ****************/
class ServiceRequestApi {
  const ServiceRequestApi();

  String getRequestsForMe() {
    return UtilsGeneral.getApiBaseUrl() + "/users/me/requests";
  }

  String getRequestForMeById(String requestId) {
    return UtilsGeneral.getApiBaseUrl() + "/users/me/requests/" + requestId;
  }

  String updateRequest(String organizationId, String requestId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/requests/" +
        requestId;
  }

  String cancelRequest(String organizationId, String requestId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/requests/" +
        requestId +
        "/cancel";
  }

  String startRequest(
      String organizationId, String requestId, String consumerId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/requests/" +
        requestId +
        "/start";
  }

  String completeRequest(
      String organizationId, String requestId, String consumerId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/organizations/" +
        organizationId +
        "/consumers/" +
        consumerId +
        "/requests/" +
        requestId +
        "/complete";
  }

  String createRequest() {
    return UtilsGeneral.getApiBaseUrl() + "/users/me/requests";
  }

  String cancelSchedule(String scheduleId) {
    return UtilsGeneral.getApiBaseUrl() +
        "/users/me/schedules/" +
        scheduleId +
        "/cancel";
  }

  String createSchedule() {
    return UtilsGeneral.getApiBaseUrl() + "/users/me/schedules";
  }
}


