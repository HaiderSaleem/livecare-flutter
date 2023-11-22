import 'package:flutter/material.dart';
import 'package:livecare/components/listView/autocomplete_search_listview.dart';
import 'package:livecare/models/organization/organization_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/serviceRequests/homeservice.create/home_service_create_recurring_screen.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';
import '../../../components/listView/autocomplete_locations_listview.dart';
import '../../../models/communication/network_reachability_manager.dart';
import '../../../models/consumer/consumer_manager.dart';
import '../../../models/request/dataModel/location_data_model.dart';
import '../../../models/user/user_manager.dart';
import '../../../utils/auto_complete_consumer_searchitem.dart';
import '../viewModel/home_service_request_view_model.dart';


class HomeServiceRequestCreateScreen extends BaseScreen {
  final HomeServiceRequestViewModel? vmRequest;

  const HomeServiceRequestCreateScreen({Key? key, required this.vmRequest}) : super(key: key);

  @override
  _HomeServiceRequestCreateScreenState createState() => _HomeServiceRequestCreateScreenState();

}

class _HomeServiceRequestCreateScreenState
    extends BaseScreenState<HomeServiceRequestCreateScreen> {
  String _txtDate = "Select the date";
  final List<AutoCompleteConsumerSearchItem> _arrayConsumers = [];
  List<LocationDataModel> _arrayLocations = [];

  final List<String> _arrayAllTimes = [];
   var _edtConsumer = TextEditingController();
  var _edtLocationService = TextEditingController();
  var _edtTime = TextEditingController();
  final _edtHours = TextEditingController();
  final _edtMinutes = TextEditingController();
  final _edtDescription = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  _initUI() {
    final request = widget.vmRequest;
    if (request == null) {
      return;
    }

    _requestLocations();
    /*  final arrayOrg = OrganizationManager.sharedInstance.arrayOrganizations;
    final List<AutoCompleteConsumerSearchItem> arrayOrgNames = [];
    int orgIndex = 0;
    for (var organization in arrayOrg) {
      final item = AutoCompleteConsumerSearchItem();
      item.szName = organization.szName;
      item.index = orgIndex;
      arrayOrgNames.add(item);
      orgIndex += 1;
    }
    _arrayOrganizations.addAll(arrayOrgNames);
*/
    //Consumers
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

    /*   //Pre-select organization
    int indexOrg = -1;
    final refOrg = request.refOrganization;
    if (refOrg != null) {
      _edtOrganization.text = refOrg.szName;
      int i = 0;
      for (var c in arrayOrg) {
        if (c.id == refOrg.organizationId) {
          indexOrg = i;
          break;
        }
        i += 1;
      }
    }

    if (arrayOrgNames.length == 1) {
      // If user is belonging to single org, we select it by default
      _edtOrganization.text = arrayOrgNames[0].szName;
      final org = arrayOrg[0];
      request.refOrganization = org.toRef();
    }*/

    // Time & Return Time
    // building all time-slots from "00:00 AM" to "11:30 PM"

    for (int hh in Iterable.generate(23)) {
      var hour = hh % 12;
      final ampm = hh >= 12 ? "PM" : "AM";
      if (hour == 0) hour = 12;
      final title = UtilsString.padLeadingZerosForTwoDigits(hour) +
          ":" +
          UtilsString.padLeadingZerosForTwoDigits(00) +
          " " +
          ampm;
      _arrayAllTimes.add(title);
      final title1 = UtilsString.padLeadingZerosForTwoDigits(hour) +
          ":" +
          UtilsString.padLeadingZerosForTwoDigits(30) +
          " " +
          ampm;
      _arrayAllTimes.add(title1);
    }
  }

  _requestLocations() {
    final currentUser = UserManager.sharedInstance.currentUser;
    final transOrg = currentUser?.getPrimaryOrganization();
    if (currentUser == null || transOrg == null) {
      return;
    }

    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    // Do not loading-indicator, for better UX, assuming that it doesn't take more than couple of seconds
    OrganizationManager.sharedInstance.requestGetLocationsByOrganizationId(
        transOrg.organizationId, false,
        (responseDataModel) {
      if (responseDataModel.isSuccess) {
        if (responseDataModel.parsedObject != null) {
          final List<LocationDataModel> locations =
              responseDataModel.parsedObject as List<LocationDataModel>;
          _arrayLocations = locations;
        }
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  bool _validateFields() {
    final request = widget.vmRequest;
    if (request == null) return false;

    if (request.refOrganization == null) {
      showToast("Please select the Organization.");
      return false;
    }

    if (request.date == null) {
      showToast("Please select the date.");
      return false;
    }

    request.szTime = _edtTime.text;
    if (request.szTime.isEmpty) {
      showToast("Please select the time.");
      return false;
    }

    request.nDurationHours = UtilsString.parseInt(_edtHours.text, 0);
    request.nDurationMins = UtilsString.parseInt(_edtMinutes.text, 0);
    request.szDescription = _edtDescription.text;

    if (request.nDurationHours == 0 && request.nDurationMins == 0) {
      showToast("Please enter duration in HH:MM format.");
      return false;
    }
    if (request.szDescription.isEmpty || request.szDescription.length < 5) {
      showToast("Please enter description.");
      return false;
    }
    return true;
  }

 /* _calendarPopup(BuildContext context){
    showDatePicker(context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2025),
    ).then((value) {
      if (value == null) return;
      setState(() {
        widget.vmRequest!.date = value;
        _txtDate = UtilsDate.getStringFromDateTimeWithFormat(value,
            EnumDateTimeFormat.MMddyyyy.value, false);
      });
    });
  }*/

  _showCalendar(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Refer step 1
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    ).then((value) {
      if (value == null) return;
      setState(() {
        widget.vmRequest!.date = value;
        _txtDate = UtilsDate.getStringFromDateTimeWithFormat(
            value, EnumDateTimeFormat.MMddyyyy.value, false);
      });
    });
  }

  _gotoServiceRequestRecurringScreen() {
    // Recurring a Ride
    Navigator.push(context,
      createRoute(HomeServiceRequestCreateRecurringScreen(vmRequest: widget.vmRequest)),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      appBar: AppBar(
        /*leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/images/ic_menu.png'),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),*/
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.newServiceRequest,
          style: AppStyles.textCellHeaderStyle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                if (_validateFields()) {
                  _gotoServiceRequestRecurringScreen();
                }
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.buttonNext,
                    style: AppStyles.buttonTextStyle)),
            ),
          )
        ],
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
              Container(
                margin: AppDimens.kMarginNormal,
                child: const Text(AppStrings.requestDetails,
                    style: AppStyles.rideInformation),
              ),
              Expanded(
                child: Container(
                  margin: AppDimens.kMarginNormal.copyWith(top: 0),
                  padding: AppDimens.kMarginNormal,
                  decoration: BoxDecoration(color: AppColors.textWhite,
                      borderRadius: BorderRadius.circular(10)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Consumer:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: AppDimens.kEdittextHeight,
                          child: Autocomplete<AutoCompleteConsumerSearchItem>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              return _arrayConsumers.where(
                                  (AutoCompleteConsumerSearchItem option) {
                                return option.szName.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase());
                              });
                            },
                            displayStringForOption:
                                (AutoCompleteConsumerSearchItem option) =>
                                    option.szName,
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController textEditingController,
                                FocusNode focusNode,
                                VoidCallback onFieldSubmitted) {
                              if (textEditingController.text.isEmpty) {
                                _edtConsumer = textEditingController;
                              }
                              return TextFormField(
                                textInputAction: TextInputAction.next,
                                style: AppStyles.inputTextStyle,
                                cursorColor: Colors.grey,
                                controller: _edtConsumer,
                                focusNode: focusNode,
                                onFieldSubmitted: (String value) {
                                  onFieldSubmitted();
                                },
                                decoration: AppStyles.autoCompleteField
                                    .copyWith(
                                        hintText: AppStrings.selectConsumer),
                              );
                            },
                            onSelected: (selection) {
                              final consumer = _arrayConsumers[selection.index].szName;
                              widget.vmRequest!.szConsumer = consumer;
                            },
                            optionsViewBuilder: (BuildContext context,
                                AutocompleteOnSelected<
                                        AutoCompleteConsumerSearchItem>
                                    onSelected,
                                Iterable<AutoCompleteConsumerSearchItem> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  color: Colors.white,
                                  elevation: 3.0,
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 200),
                                    width: MediaQuery.of(context).size.width -
                                        AppDimens.kMarginNormal.top * 4,
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

                        const SizedBox(height: 20),
                        const Text(
                          "Location of Service:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                            height: AppDimens.kEdittextHeight,
                            child: Autocomplete<LocationDataModel>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                return _arrayLocations
                                    .where((LocationDataModel option) {
                                  return option.szName.toLowerCase().contains(
                                          textEditingValue.text
                                              .toLowerCase()) ||
                                      option.szAddress.toLowerCase().contains(
                                          textEditingValue.text.toLowerCase());
                                });
                              },
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) {
                                _edtLocationService = textEditingController;
                                return TextFormField(
                                  textInputAction: TextInputAction.next,
                                  style: AppStyles.inputTextStyle,
                                  cursorColor: Colors.grey,
                                  controller: _edtLocationService,
                                  onChanged: (value) {},
                                  focusNode: focusNode,
                                  onFieldSubmitted: (String value) {
                                    onFieldSubmitted();
                                  },
                                  decoration: AppStyles.autoCompleteField
                                      .copyWith(
                                          hintText: AppStrings.hintEnterAddress),
                                );
                              },
                              displayStringForOption: (selection) =>
                                  selection.szAddress,
                              onSelected: (selection) {
                                widget.vmRequest!.refLocationDataPoint = selection;
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<LocationDataModel>
                                      onSelected,
                                  Iterable<LocationDataModel> options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    color: Colors.white,
                                    elevation: 3.0,
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(maxHeight: 200),
                                      width: MediaQuery.of(context).size.width -
                                          AppDimens.kMarginNormal.top * 4,
                                      child: AutocompleteLocationsListView(
                                        options: options,
                                        onSelected: (option) {
                                          onSelected(option);
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),
                        const SizedBox(height: 20),
                        const Text(
                          "Service Date:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            _showCalendar(context);
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: AppDimens.kEdittextHeight,
                              padding: AppDimens.kMarginSsmall,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  border: Border.all(
                                      width: 1,
                                      color: AppColors.separatorLineGray)),
                              child: Text(
                                _txtDate,
                                style: _txtDate == "Select the date"
                                    ? AppStyles.inputTextStyle
                                        .copyWith(color: AppColors.hintColor)
                                    : AppStyles.inputTextStyle,
                              )),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Start Time:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: AppDimens.kEdittextHeight,
                          child: Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              return _arrayAllTimes.where((String option) {
                                return option.contains(
                                    textEditingValue.text.toLowerCase());
                              });
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController textEditingController,
                                FocusNode focusNode,
                                VoidCallback onFieldSubmitted) {
                              _edtTime = textEditingController;
                              return TextFormField(
                                textInputAction: TextInputAction.next,
                                style: AppStyles.inputTextStyle,
                                cursorColor: Colors.grey,
                                controller: _edtTime,
                                focusNode: focusNode,
                                onFieldSubmitted: (String value) {
                                  onFieldSubmitted();
                                },
                                decoration: AppStyles.autoCompleteField
                                    .copyWith(hintText: "Select the Time"),
                              );
                            },
                            onSelected: (selection) {},
                            optionsViewBuilder: (BuildContext context,
                                AutocompleteOnSelected<String> onSelected,
                                Iterable<String> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  color: Colors.white,
                                  elevation: 3.0,
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 200),
                                    width: MediaQuery.of(context).size.width -
                                        AppDimens.kMarginNormal.top * 4,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.all(8.0),
                                      itemCount: options.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final String option =
                                            options.elementAt(index);
                                        return GestureDetector(
                                          onTap: () {
                                            onSelected(option);
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding: AppDimens
                                                    .kVerticalMarginSsmall,
                                                child: Text(
                                                  option,
                                                  style: AppStyles.dropDownText,
                                                ),
                                              ),
                                              const Divider(
                                                height: 0.5,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Duration:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: AppDimens.kEdittextHeight,
                              width: 100,
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                style: AppStyles.inputTextStyle,
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.grey,
                                controller: _edtHours,
                                onFieldSubmitted: (String value) {},
                                decoration: AppStyles.autoCompleteField
                                    .copyWith(hintText: "Hours"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              ":",
                              style: AppStyles.textBlackStyle,
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: AppDimens.kEdittextHeight,
                              width: 100,
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                style: AppStyles.inputTextStyle,
                                cursorColor: Colors.grey,
                                keyboardType: TextInputType.number,
                                controller: _edtMinutes,
                                onFieldSubmitted: (String value) {},
                                decoration: AppStyles.autoCompleteField
                                    .copyWith(hintText: "Mins"),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Description of Service Requested:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                            textInputAction: TextInputAction.next,
                            style: AppStyles.inputTextStyle,
                            maxLines: 7,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.grey,
                            controller: _edtDescription,
                            onFieldSubmitted: (String value) {},
                            decoration: AppStyles.autoCompleteField),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
