import 'package:flutter/material.dart';
import 'package:livecare/components/listView/experience_listview.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/experience/dataModel/experience_data_model.dart';
import 'package:livecare/models/experience/experience_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_observer.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/experience/experience_details_fragment.dart';

class ExperienceListScreen extends BaseScreen {
  const ExperienceListScreen({Key? key}) : super(key: key);

  @override
  _ExperienceListScreenState createState() => _ExperienceListScreenState();
}

class _ExperienceListScreenState extends BaseScreenState<ExperienceListScreen>
    with LocalNotificationObserver {
  final List<ExperienceDataModel> _arrayExperience = [];

  @override
  void initState() {
    super.initState();
    LocalNotificationManager.sharedInstance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestGetExperience();
    });
  }

  _reloadData() {
    final results = ExperienceManager.sharedInstance.arrayExperiences;

    setState(() {
      _arrayExperience.clear();
      _arrayExperience.addAll(results);
    });
  }

  _requestGetExperience() {
    if (!UserManager.sharedInstance.isLoggedIn()) return;
    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    showProgressHUD();
    ExperienceManager.sharedInstance.requestGetExperiences((responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        _reloadData();
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  _gotoExperienceDetailsScreen(ExperienceDataModel experience) {
    Navigator.push(
      context,
      createRoute(ExperienceDetailsScreen(
        modelExperience: experience,
      )),
    );
  }

  @override
  experiencesListUpdated() {
    super.experiencesListUpdated();
    _reloadData();
  }

  @override
  void dispose() {
    super.dispose();
    LocalNotificationManager.sharedInstance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      body: SafeArea(
        bottom: true,
        child: Container(
          color: AppColors.defaultBackground,
          child: _arrayExperience.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.noExperience,
                    style: AppStyles.tripInformation
                        .copyWith(color: AppColors.textBlack),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () {
                    _requestGetExperience();
                    return Future.delayed(const Duration(milliseconds: 1000));
                  },
                  child: ExperienceListView(
                    arrayExperience: _arrayExperience,
                    itemClickListener: (experience, position) {
                      _gotoExperienceDetailsScreen(experience);
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
