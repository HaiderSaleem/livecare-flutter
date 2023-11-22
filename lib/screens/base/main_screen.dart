import 'dart:async';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:livecare/models/Invite/dataModel/invite_data_model.dart';
import 'package:livecare/models/Invite/invite_manager.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/communication/offline_request_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_observer.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/user/dataModel/user_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/consumers/consumer_list.dart';
import 'package:livecare/screens/experience/experience_list_screen.dart';
import 'package:livecare/screens/login/login.dart';
import 'package:livecare/screens/notifications/returned_transactions_list_screen.dart';
import 'package:livecare/screens/request/trip_request_list_screen.dart';
import 'package:livecare/screens/routes/routes_history_screen.dart';
import 'package:livecare/screens/serviceRequests/service_requests_list_screen.dart';
import 'package:livecare/screens/settings/settings_profile_screen.dart';
import 'package:livecare/screens/settings/settings_screen.dart';
import 'package:livecare/utils/utils_general.dart';

import '../../models/organization/organization_manager.dart';
import '../../models/request/base_request_manager.dart';
import '../routes/routes_list_screen.dart';

class MainScreen extends BaseScreen {
  final bool? fromServiceRoute;

  MainScreen({Key? key, this.fromServiceRoute}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends BaseScreenState<MainScreen> with ConnectivityReceiverListener, LocalNotificationObserver {
  late final UserDataModel currentUser;
  late final BuildContext dialogContext;
  late final Auth0 auth0;

  final snackBar = const SnackBar(content: Text('You\'re Offline!'));
  final List<EnumMenuItem> arrayMenuItems = [];
  InviteDataModel modelInvite = InviteDataModel();

  String labelName = "";
  String labelEmail = "";
  String labelInfo = "";
  int selectedIndex = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initCall();
  }

  void initCall() {
    currentUser = UserManager.sharedInstance.currentUser!;
    _determineSelectedIndex();
    _setupListeners();
    _refreshFields();
  }

  void _determineSelectedIndex() {
    if (widget.fromServiceRoute == true) {
      selectedIndex = currentUser.getPrimaryRole() == EnumOrganizationUserRole.driver ? 2 : 5;
    }
  }

  void _setupListeners() {
    LocalNotificationManager.sharedInstance.addObserver(this);
    NetworkReachabilityManager.sharedInstance.addListener(this);
  }

  void _refreshFields() async {
    if (currentUser.id.isEmpty) return;
    labelInfo = await UtilsGeneral.getBeautifiedAppVersionInfo();
    _updateUserRelatedFields();
  }

  void _updateUserRelatedFields() {
    setState(() {
      labelName = currentUser.szName;
      labelEmail = currentUser.szEmail;
      _updateMenuItems();
      isLoading = false;
    });
  }

  void _updateMenuItems() {
    arrayMenuItems.clear();
    arrayMenuItems.addAll(_getMenuItems());
  }

  List<EnumMenuItem> _getMenuItems() {
    final managerUser = UserManager.sharedInstance;
    return [
      EnumMenuItem.settingsProfile,
      if (managerUser.isAccessControlItem(EnumAccessControlItem.consumerLedgers)) EnumMenuItem.consumerLedgers,
      EnumMenuItem.notifications,
      if (managerUser.isAccessControlItem(EnumAccessControlItem.transportRequests)) EnumMenuItem.transportRequests,
      if (managerUser.isAccessControlItem(EnumAccessControlItem.experiences)) EnumMenuItem.experiences,
      if (managerUser.isAccessControlItem(EnumAccessControlItem.serviceRequests)) EnumMenuItem.serviceRoutes,
      if (managerUser.isAccessControlItem(EnumAccessControlItem.routesHistory)) EnumMenuItem.routesHistory,
      if (managerUser.isAccessControlItem(EnumAccessControlItem.serviceRequests)) EnumMenuItem.serviceOutOfOffice,
      EnumMenuItem.settings,
      EnumMenuItem.logout,
    ];
  }

  Future<void> sendRequest() async {
    final requests = OfflineRequestManager.sharedInstance.arrayRequestQueue;
    for (var request in requests) {
      final responseDataModel = await BaseRequestManager.sharedInstance.sendRequest(request);
      if (responseDataModel != null) {
        OfflineRequestManager.sharedInstance.dequeueRequest(request);
      }
      // Introduce a small delay before processing the next request
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  @override
  void inviteListUpdated() {
    super.inviteListUpdated();
    _checkPendingInvites();
  }

  void _checkPendingInvites() {
    var pendingInvites = InviteManager.sharedInstance.getPendingInvites();
    if (pendingInvites.isEmpty) return;
    modelInvite = pendingInvites.first;
    _presentInvitePrompt();
  }

  void _presentInvitePrompt() {
    if (modelInvite.token.isEmpty) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 20, top: 20 + 20, right: 20, bottom: 20),
                margin: const EdgeInsets.only(top: 45),
                decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
                ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 42),
                    Text(AppStrings.invitationReceived, textAlign: TextAlign.center, style: AppStyles.boldText.copyWith(color: AppColors.disabledBackground)),
                    const SizedBox(height: 10),
                    const Text(AppStrings.receivedInvitation, textAlign: TextAlign.center, style: AppStyles.headingText),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: AppStyles.defaultButtonStyle.copyWith(backgroundColor: MaterialStateProperty.all(AppColors.primaryColorLight)),
                      onPressed: () {
                        acceptInvite();
                      },
                      child: const Text(
                        AppStrings.accept,
                        textAlign: TextAlign.center,
                        style: AppStyles.buttonTextStyle,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: AppStyles.defaultButtonStyle.copyWith(backgroundColor: MaterialStateProperty.all(AppColors.primaryColorLight)),
                      onPressed: () {
                        declineInvite();
                      },
                      child: const Text(
                        AppStrings.decline,
                        textAlign: TextAlign.center,
                        style: AppStyles.buttonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 45,
                  child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(45)), child: Image.asset("assets/images/ic_invite_round.png")),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  acceptInvite() async {
    if (modelInvite.token.isEmpty) return;
    showProgressHUD();

    await InviteManager.sharedInstance.requestAcceptInvite(modelInvite, (responseDataModel) {
      if (responseDataModel.isSuccess) {
        OrganizationManager.sharedInstance.requestGetOrganizations2(currentUser.id, (responseDataModel2) {
          if (responseDataModel2.isSuccess) {
            hideProgressHUD();
            Navigator.pop(dialogContext);
            WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
                  _refreshFields();
                }));
          } else {
            showToast(responseDataModel2.beautifiedErrorMessage);
          }
        });
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  declineInvite() async {
    if (modelInvite.token.isEmpty) return;

    showProgressHUD();

    var response = await InviteManager.sharedInstance.requestDeclineInvite(modelInvite);

    if (response == true) {
      hideProgressHUD();
      Navigator.pop(dialogContext);
    }
  }

  @override
  onNetworkConnectionChanged(bool isConnected) {
    if (isConnected) {
      sendRequest();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: !isLoading
          ? Scaffold(
              appBar: appBar(arrayMenuItems[selectedIndex].pageTitle),
              body: arrayMenuItems.isNotEmpty ? arrayMenuItems[selectedIndex].screen : Container(),
              resizeToAvoidBottomInset: true,
              drawer: Drawer(
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 100,
                      top: 0,
                      child: Column(
                        children: <Widget>[
                          DrawerHeader(
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  selectedIndex = 0;
                                });
                              },
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(60)),
                                    child: FadeInImage(
                                      height: 80,
                                      width: 80,
                                      fadeInDuration: const Duration(milliseconds: 500),
                                      fadeInCurve: Curves.easeInExpo,
                                      fadeOutCurve: Curves.easeOutExpo,
                                      placeholder: const AssetImage("assets/images/user_default.png"),
                                      image: NetworkImage(currentUser.szPhoto),
                                      imageErrorBuilder: (context, error, stackTrace) {
                                        return SizedBox(width: 80, height: 80, child: Image.asset("assets/images/user_default.png"));
                                      },
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: AppDimens.kHorizontalMarginSmall.copyWith(right: 0),
                                          child: Text(
                                            labelName,
                                            style: AppStyles.textStyle.copyWith(fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        Container(
                                          padding: AppDimens.kMarginSmall,
                                          child: Text(
                                            labelEmail,
                                            overflow: TextOverflow.clip,
                                            style: AppStyles.textStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(0),
                              shrinkWrap: true,
                              itemCount: arrayMenuItems.length,
                              itemBuilder: (context, index) {
                                var menuItem = arrayMenuItems[index];
                                return (menuItem == EnumMenuItem.settingsProfile)
                                    ? Container()
                                    : InkWell(
                                        child: Container(
                                          color: selectedIndex == index ? AppColors.draweritemcolor : Colors.transparent,
                                          child: Padding(
                                            padding: const EdgeInsets.all(13.0),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  menuItem.menuIcon,
                                                  width: 20,
                                                  height: 20,
                                                  color: selectedIndex == index ? AppColors.primaryColorLight : AppColors.textGray,
                                                ),
                                                Padding(
                                                  //padding: AppDimens.kHorizontalMarginBbig,
                                                  padding: const EdgeInsets.only(left: 30),
                                                  child: Text(
                                                    menuItem.menuTitle,
                                                    style: TextStyle(
                                                        color: selectedIndex == index ? AppColors.primaryColorLight : AppColors.textGray,
                                                        fontSize: AppDimens.kFontLabel,
                                                        fontWeight: FontWeight.w600,
                                                        fontFamily: 'Lato'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          if (index + 1 == arrayMenuItems.length) {
                                            Navigator.pushReplacement(context, createRoute(const LoginScreen()));
                                          } else {
                                            setState(() {
                                              selectedIndex = index;
                                            });
                                          }
                                        },
                                      );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 50,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(color: AppColors.primaryColor),
                        child: Text(
                          labelInfo,
                          style: AppStyles.buttonTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(color: AppColors.white),
    );
  }
}

enum EnumMenuItem {
  notifications,
  settingsProfile,
  consumerLedgers,
  transportRequests,
  serviceOutOfOffice,
  serviceRoutes,
  experiences,
  routesHistory,
  settings,
  // routes,
  logout
}

extension MenuItemExtension on EnumMenuItem {
  String get menuTitle {
    switch (this) {
      case EnumMenuItem.notifications:
        return AppStrings.tabNotifications;
      case EnumMenuItem.consumerLedgers:
        return AppStrings.tabConsumers;
      case EnumMenuItem.transportRequests:
        return AppStrings.tabTransportation;
      case EnumMenuItem.routesHistory:
        return AppStrings.tabRouteHistory;
      case EnumMenuItem.experiences:
        return AppStrings.tabExperiences;
      case EnumMenuItem.serviceRoutes:
        return AppStrings.titleMySchedule;
      case EnumMenuItem.serviceOutOfOffice:
        return AppStrings.tabOutOfOffice;
      case EnumMenuItem.settings:
        return AppStrings.titleSettings;
      case EnumMenuItem.logout:
        return AppStrings.logout;
      // case EnumMenuItem.routes:
      //   return AppStrings.titleMySchedule;
      default:
        return "";
    }
  }

  /*  */

  String get menuIcon {
    switch (this) {
      case EnumMenuItem.notifications:
        return "assets/images/ic_tab_notifications.png";
      case EnumMenuItem.consumerLedgers:
        return "assets/images/ic_tab_consumer_fill.png";
      case EnumMenuItem.transportRequests:
        return "assets/images/ic_map.png";
      case EnumMenuItem.routesHistory:
        return "assets/images/ic_clock.png";
      case EnumMenuItem.experiences:
        return "assets/images/ic_experience.png";
      case EnumMenuItem.serviceRoutes:
        return "assets/images/icon_schedule.png";
      case EnumMenuItem.serviceOutOfOffice:
        return "assets/images/ic_tab_tasks.png";
      case EnumMenuItem.settings:
        return "assets/images/ic_tab_settings.png";
      case EnumMenuItem.logout:
        return "assets/images/ic_logout.png";
      // case EnumMenuItem.routes:
      //   return "assets/images/icon_schedule.png";
      default:
        return "";
    }
  }

  /* */

  String get pageTitle {
    switch (this) {
      case EnumMenuItem.notifications:
        return AppStrings.tabNotifications;
      case EnumMenuItem.settingsProfile:
        return AppStrings.tabProfile;
      case EnumMenuItem.consumerLedgers:
        return AppStrings.titleConsumers;
      case EnumMenuItem.transportRequests:
        return AppStrings.titleTransportation;
      case EnumMenuItem.serviceOutOfOffice:
        return AppStrings.serviceRequest;
      // case EnumMenuItem.routes:
      //   return AppStrings.titleMySchedule;
      case EnumMenuItem.experiences:
        return AppStrings.titleExperience;
      case EnumMenuItem.routesHistory:
        return AppStrings.titleDrivingHistory;
      case EnumMenuItem.settings:
        return AppStrings.titleSettings;
      case EnumMenuItem.logout:
        return AppStrings.logout;
      case EnumMenuItem.serviceRoutes:
        return AppStrings.titleMySchedule;
    }
  }

  /*
  *   //  case EnumMenuItem.serviceRoutes:
     //   return AppStrings.titleMySchedule; */
  Widget? get screen {
    switch (this) {
      case EnumMenuItem.notifications:
        return const ReturnedTransactionsListScreen();
      case EnumMenuItem.settingsProfile:
        return const SettingsProfileScreen();
      case EnumMenuItem.consumerLedgers:
        return const ConsumerListScreen();
      case EnumMenuItem.transportRequests:
        return const TripRequestListScreen();
      case EnumMenuItem.settings:
        return const SettingsScreen();
      // case EnumMenuItem.routes:
      //   return const RoutesListScreen();
      case EnumMenuItem.routesHistory:
        return const RoutesHistoryScreen();
      case EnumMenuItem.serviceRoutes:
        //return const ServiceRoutesListScreen();
        return const RoutesListScreen();
      case EnumMenuItem.serviceOutOfOffice:
        return const ServiceRequestsListScreen();
      case EnumMenuItem.experiences:
        return const ExperienceListScreen();
      case EnumMenuItem.logout:
        return Container();
      default:
        null;
    }
    return null;
  }
}
