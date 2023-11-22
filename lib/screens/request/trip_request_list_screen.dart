import 'package:flutter/material.dart';
import 'package:livecare/components/listView/autocomplete_search_listview.dart';
import 'package:livecare/components/listView/request_listview.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/communication/socket_request_manager.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_manager.dart';
import 'package:livecare/models/localNotifications/local_notification_observer.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/organization/organization_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/transport_request_manager.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/request/create/ride_details_screen.dart';
import 'package:livecare/screens/request/service_detail_screen.dart';
import 'package:livecare/screens/request/trip_request_details_screen_modify.dart';
import 'package:livecare/screens/request/viewModel/ride_view_model.dart';
import 'package:livecare/screens/serviceRequests/homeservice.create/home_service_create_screen.dart';
import 'package:livecare/utils/auto_complete_consumer_searchitem.dart';

import '../../models/user/dataModel/user_data_model.dart';
import '../serviceRequests/viewModel/home_service_request_view_model.dart';

class TripRequestListScreen extends BaseScreen {
  const TripRequestListScreen({Key? key}) : super(key: key);

  @override
  _TripRequestListScreenState createState() => _TripRequestListScreenState();
}

class _TripRequestListScreenState extends BaseScreenState<TripRequestListScreen> with LocalNotificationObserver, SocketDelegate {
  final List<AutoCompleteConsumerSearchItem> _arrayConsumers = [];
  var _edtConsumer = TextEditingController();
  var _consumerFocus = FocusNode();
  int _indexConsumer = -1;
  var allowConsumerRequests = true;

  List<RequestDataModel> _arrayRequests = [];

  @override
  void initState() {
    super.initState();
    LocalNotificationManager.sharedInstance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initUI());
    SocketRequestManager.sharedInstance.addListener(this);
    UserDataModel? currentUser = UserManager.sharedInstance.currentUser;
    String? organizationId = currentUser?.getPrimaryOrganization()?.organizationId;
    if (organizationId != null) {
      allowConsumerRequests = OrganizationManager.sharedInstance.allowConsumerRequests(organizationId);
    }
  }

  _initUI() {
    _refreshFields();
    _reloadData();
    _requestGetRequests(true);
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestGetRequests(true);
    });*/
  }

  _refreshFields() {
    final List<AutoCompleteConsumerSearchItem> arrayItems = [];
    var index = 0;
    for (var consumer in ConsumerManager.sharedInstance.arrayConsumers) {
      final item = AutoCompleteConsumerSearchItem();
      item.szName = consumer.szName;
      item.index = index;
      arrayItems.add(item);
      index += 1;
    }
    _arrayConsumers.addAll(arrayItems);

    // If user = guardian, and has only 1 consumer -- default to that consumer
    final user = UserManager.sharedInstance.currentUser;
    if (user == null) return;
    if (user.getPrimaryRole() != EnumOrganizationUserRole.guardian) return;
    if (arrayItems.length > 1) return;

    if (arrayItems.length == 1) {
      var consumer = arrayItems.first;
      _indexConsumer = consumer.index;
      _requestGetRequests(true);
      _edtConsumer.text = consumer.szName;
    }
  }

  _reloadData() {
    setState(() {
      _arrayRequests = _arrayRequests;
    });
  }

  _requestGetRequests(bool forceLoad) {
    if (!UserManager.sharedInstance.isLoggedIn()) return;
    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      showProgressHUD();

      if (_indexConsumer == -1) {
        // Requests for myself
        TransportRequestManager.sharedInstance.requestGetRequestsForMe(forceLoad, EnumRouteType.transport, (responseDataModel) {
          hideProgressHUD();
          if (responseDataModel.isSuccess && responseDataModel.parsedObject != null) {
            final requests = responseDataModel.parsedObject as List<RequestDataModel>;
            _arrayRequests.clear();
            _arrayRequests.addAll(requests);
            _reloadData();
          } else {
            showToast(responseDataModel.beautifiedErrorMessage);
          }
        });
      } else {
        // Request for consumer

        final consumer = ConsumerManager.sharedInstance.arrayConsumers[_indexConsumer];
        TransportRequestManager.sharedInstance.requestGetRequestsForConsumer(consumer, forceLoad, (responseDataModel) {
          hideProgressHUD();
          if (responseDataModel.isSuccess) {
            final requests = responseDataModel.parsedObject as List<RequestDataModel>;
            _arrayRequests.clear();
            _arrayRequests.addAll(requests.where((element) => element.isActiveRequest()));
            _reloadData();
          } else {
            showToast(responseDataModel.beautifiedErrorMessage);
          }
        });
      }
    } else {
      final requests = TransportRequestManager.sharedInstance.arrayRequests;
      _arrayRequests.clear();
      _arrayRequests.addAll(requests.where((element) => element.isActiveRequest()));
      _reloadData();
    }
  }

  _gotoRideDetailsScreen() {
    final ride = RideViewModel();
    Navigator.push(
      context,
      createRoute(RideDetailsScreen(vmRide: ride)),
    ).then((value) {
      _initUI();
    });
  }

  _gotoRequestDetailsScreen(RequestDataModel request) {
    if (request.enumType.value == EnumRouteType.service.value) {
      Navigator.push(
        context,
        createRoute(ServiceDetailScreen(modelRequest: request)),
      );
    } else {
      Navigator.push(context, createRoute(TripRequestDetailsScreenModify(modelRequest: request)));
    }
  }

  _gotoRequestCreateScreen() {
    final request = HomeServiceRequestViewModel();
    Navigator.push(
      context,
      createRoute(HomeServiceRequestCreateScreen(vmRequest: request)),
    );
  }

  @override
  routeListUpdated() {
    _reloadData();
  }

  @override
  void dispose() {
    super.dispose();
    LocalNotificationManager.sharedInstance.removeObserver(this);
  }

  @override
  onAnyEventFired() {}

  @override
  onConnected() {}

  @override
  onConnectionStatusChanged() {}

  @override
  onRequestCancelled(RequestDataModel request) {
    _reloadData();
  }

  @override
  onRequestUpdated(RequestDataModel request) {
    _reloadData();
  }

  @override
  onRouteDriverLocationUpdated(String routeId, double lat, double lng) {}

  @override
  onRouteLocationStatusUpdated(RouteDataModel route) {
    _reloadData();
  }

  @override
  onRouteUpdated(RouteDataModel route) {
    _reloadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      floatingActionButton: Visibility(
        visible: allowConsumerRequests,
        child: FloatingActionButton(
          onPressed: () {
            if (NetworkReachabilityManager.sharedInstance.isConnected()) {
              _showRequestDialog();
              // _gotoRideDetailsScreen();
            }
          },
          child: const Icon(Icons.add, size: 30),
          backgroundColor: AppColors.buttonBackground,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Search View
              Container(
                margin: AppDimens.kMarginNormal,
                width: MediaQuery.of(context).size.width,
                child: SizedBox(
                  height: AppDimens.kEdittextHeight,
                  child: Autocomplete<AutoCompleteConsumerSearchItem>(
                    optionsMaxHeight: MediaQuery.of(context).size.height,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return _arrayConsumers.where((AutoCompleteConsumerSearchItem option) {
                        return option.szName.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    displayStringForOption: (AutoCompleteConsumerSearchItem option) => option.szName,
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      _consumerFocus = focusNode;
                      if (textEditingController.text.isEmpty) {
                        _edtConsumer = textEditingController;
                      }
                      return TextFormField(
                        textInputAction: TextInputAction.next,
                        style: AppStyles.inputTextStyle,
                        cursorColor: Colors.grey,
                        controller: _edtConsumer,
                        focusNode: _consumerFocus,
                        onFieldSubmitted: (String value) {
                          onFieldSubmitted();
                        },
                        decoration: AppStyles.searchInputDecoration.copyWith(prefixIcon: const Icon(Icons.search), hintText: "Please select consumer"),
                      );
                    },
                    onSelected: (selection) {
                      _indexConsumer = selection.index;
                      _requestGetRequests(true);
                    },
                    optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<AutoCompleteConsumerSearchItem> onSelected,
                        Iterable<AutoCompleteConsumerSearchItem> options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          color: Colors.white,
                          elevation: 3.0,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            width: MediaQuery.of(context).size.width - AppDimens.kMarginNormal.top * 2,
                            child: AutocompleteSearchListView(
                              options: options,
                              onSelected: (option) {
                                onSelected(option);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                  child: _arrayRequests.isEmpty
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: AppColors.defaultBackground,
                          child: Center(
                            child: Text(AppStrings.noRequest, style: AppStyles.tripInformation.copyWith(color: AppColors.textBlack)),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () {
                            _requestGetRequests(true);
                            return Future.delayed(const Duration(milliseconds: 1000));
                          },
                          child: RequestListView(
                            arrayRequests: _arrayRequests,
                            itemClickListener: (RequestDataModel request, int index) {
                              if (_consumerFocus.hasFocus) {
                                FocusScope.of(context).requestFocus(FocusNode());
                              } else {
                                _gotoRequestDetailsScreen(request);
                              }
                            },
                          ),
                        ))
            ],
          ),
        ),
      ),
    );
  }

  _showRequestDialog() {
    _transportRequest();
  }

  _homeServiceRequest() {
    _gotoRequestCreateScreen();
  }

  _transportRequest() {
    _gotoRideDetailsScreen();
  }
}
