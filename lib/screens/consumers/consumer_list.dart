import 'package:flutter/material.dart';
import 'package:livecare/components/listView/consumer_group_listview.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_observer.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/consumers/consumer_details.dart';
import 'package:livecare/screens/consumers/viewModel/consumers_group_view_model.dart';
import 'package:livecare/utils/utils_general.dart';

class ConsumerListScreen extends BaseScreen {
  const ConsumerListScreen({Key? key}) : super(key: key);

  @override
  _ConsumerListScreenState createState() => _ConsumerListScreenState();
}

class _ConsumerListScreenState extends BaseScreenState<ConsumerListScreen>
    with LocalNotificationObserver {
  final edtSearchQuery = TextEditingController();
  List<ConsumersGroupViewModel> consumersGroupList = [];
  List<ConsumerDataModel> arrayConsumers = [];

  @override
  void initState() {
    super.initState();
    LocalNotificationManager.sharedInstance.addObserver(this);
    reloadData();
  }

  reloadData() {
    final String keyword = edtSearchQuery.text;
    final results = ConsumerManager.sharedInstance.arrayConsumers
        .where((element) => element.searchWithKeyword(keyword));

    arrayConsumers.clear();
    arrayConsumers.addAll(results);

    setState(() {
      consumersGroupList =
          ConsumersGroupViewModel.buildConsumersGroup(arrayConsumers);
      for (var group in consumersGroupList) {
        UtilsGeneral.log("Location Name: ${group.getLocationName()}  "
            " Total Consumer: ${group.arrayConsumers.length}");
      }
    });
  }

  gotoConsumerDetailsScreen(ConsumerDataModel? consumer,
      LocationDataModel? location, bool sharedFinancialAccount) {
    Navigator.push(
      context,
      createRoute(ConsumerDetailsScreen(
          modelConsumer: consumer,
          modelLocation: location,
          isSharedFinancialAccount: sharedFinancialAccount)),
    );
  }

  @override
  consumerListUpdated() {
    super.consumerListUpdated();
    reloadData();
  }

  @override
  void dispose() {
    super.dispose();
    LocalNotificationManager.sharedInstance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: Container(
          margin: AppDimens.kMarginNormal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              //Search Bar view
              Container(
                height: AppDimens.kEdittextHeight,
                margin: AppDimens.kVerticalMarginNormal.copyWith(top: 0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextFormField(
                    style: AppStyles.inputTextStyle,
                    onChanged: (val) {
                      reloadData();
                    },
                    controller: edtSearchQuery,
                    cursorColor: Colors.black,
                    decoration: AppStyles.searchInputDecoration.copyWith(
                        prefixIcon: const Icon(Icons.search),
                        hintText: AppStrings.hintSearch),
                  ),
                ),
              ),
              //Refreshable Consumer Listview
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () {
                    if (NetworkReachabilityManager.sharedInstance
                        .isConnected()) {
                      ConsumerManager.sharedInstance
                          .requestGetConsumers((responseDataModel) {
                        if (responseDataModel.isSuccess) {
                          reloadData();
                        }
                      });
                    }
                    return Future.delayed(const Duration(milliseconds: 1000));
                  },
                  child: ConsumerGroupListView(
                      consumersGroupList: consumersGroupList,
                      groupClickListener: (consumerGroup, index) {
                        if (!NetworkReachabilityManager.sharedInstance
                            .isConnected()) return;
                        var location = consumerGroup.modelLocation;
                        if (location != null) {
                          gotoConsumerDetailsScreen(
                              null, consumerGroup.modelLocation, true);
                        }
                      },
                      consumerClickListener: (consumer, index) {
                        if (!NetworkReachabilityManager.sharedInstance
                            .isConnected()) return;
                        gotoConsumerDetailsScreen(consumer, null, false);
                      }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
