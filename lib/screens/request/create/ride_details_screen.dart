import 'package:flutter/material.dart';
import 'package:livecare/components/listView/autocomplete_places_listview.dart';
import 'package:livecare/components/listView/autocomplete_search_listview.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/consumer/consumer_manager.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/organization/organization_manager.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/shared/companion_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/request/create/ride_recurring_screen.dart';
import 'package:livecare/screens/request/viewModel/place_api_provider.dart';
import 'package:livecare/screens/request/viewModel/ride_view_model.dart';
import 'package:livecare/screens/settings/setting_companion_list_screen.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';
import '../../../utils/auto_complete_consumer_searchitem.dart';
import '../../../utils/utils_base_function.dart';
import 'package:geocoding/geocoding.dart';

class RideDetailsScreen extends BaseScreen {
  final RideViewModel? vmRide;

  const RideDetailsScreen({Key? key, required this.vmRide}) : super(key: key);

  @override
  _RideDetailsScreenState createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends BaseScreenState<RideDetailsScreen>
    with SettingsCompanionsListListener {
  // Location selected
  List<LocationDataModel> _arrayLocations = [];
  final List<AutoCompleteConsumerSearchItem> _arrayOrganizations = [];
  final List<AutoCompleteConsumerSearchItem> _arrayConsumers = [];
  final List<String> _arrayBillingTypes = [];
  final List<String> _arrayAllTimes = [];
  String _txtDate = AppStrings.hintSelectDate;
  String _txtReturnDate = AppStrings.hintSelectReturnDate;
  bool _mySelfRide = true;
  bool _roundTrip = false;
  bool _readyBy = true;
  bool _returnReadyBy = true;

  final List<AutoCompleteSearchItem> _arrayPickupLocation = [];
  final List<AutoCompleteSearchItem> _arrayDropOffLocation = [];
  //GooglePlace? googlePlace;

  bool _isGoogleAddressAvailableForPickup = true;
  bool _isGoogleAddressAvailableForDropOff = true;
  bool _isLocationAvailableForPickup = true;
  bool _isLocationAvailableForDropOff = true;

  AutoCompleteSearchItem? _itemSelectedForPickup;
  AutoCompleteSearchItem? _itemSelectedForDropOff;

  var _edtOrganization = TextEditingController();
  var _edtConsumer = TextEditingController();
  var _edtPickupAddress = TextEditingController();
  var _edtDropOffAddress = TextEditingController();

  var _edtTime = TextEditingController();
  var _edtReturnTime = TextEditingController();

  var isLoadingPickUp = false;
  var isLoadingDropOff = false;
  final user = UserManager.sharedInstance.currentUser;


  @override
  void initState() {
    //googlePlace = GooglePlace(UtilsConfig.GOOGLE_PLACE_API_KEY);
    super.initState();
    _initUI();
  }

  _initUI() {
    if (widget.vmRide == null) return;

    _refreshReturnDateTimePanel();
    _refreshTimingPanel();

    //Organizations
    final arrayOrg = OrganizationManager.sharedInstance.arrayOrganizations;
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

    //Pre-select organization
    int indexOrg = -1;
    if (widget.vmRide!.refOrganization != null) {
      int i = 0;
      for (var c in arrayOrg) {
        if (c.id == widget.vmRide!.refOrganization!.organizationId) {
          indexOrg = i;
          break;
        }
        i += 1;
      }

      if (indexOrg != -1) {
        _edtOrganization.text = arrayOrgNames[i].szName;
      }
    }

    if (arrayOrgNames.length == 1) {
      // If user is belonging to single org, we select it by default
      _edtOrganization.text = arrayOrgNames[0].szName;
      final org = OrganizationManager.sharedInstance.arrayOrganizations[0];
      widget.vmRide!.refOrganization = org.toRef();

      _requestLocations();
      _refreshConsumersPanel();
    }

    //Billing Type
    final List<String> arrayBillingTypes = [];
    for (var t in EnumRequestBillingCategoryType.values) {
      if (t.value.isNotEmpty) {
        arrayBillingTypes.add(t.value);
      }
    }
    _arrayBillingTypes.addAll(arrayBillingTypes);

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

  _gotoCompanionsScreen(ConsumerDataModel? consumer) {
    final ride = widget.vmRide;
    if (ride == null) return;
    Navigator.push(
      context,
      createRoute(SettingCompanionListScreen(
          modelConsumer: consumer,
          arrayConsumerCompanions: consumer == null
              ? ride.arrayMyCompanions
              : ride.arrayConsumerCompanions,
          selector: true,
          mListener: this)),
    );
  }

  _refreshConsumersPanel() {
    final ride = widget.vmRide;
    if (ride == null) return;

    ride.arrayConsumers = [];
    ride.arrayConsumerCompanions = [];

    _refreshConsumersDropdown();

    if (_arrayConsumers.length == 1) {
      final consumer = _arrayConsumers.first;
      _addConsumerChip(consumer);
    }
  }

  _refreshConsumersDropdown() {
    final ride = widget.vmRide;
    if (ride == null) return;
    final refOrg = ride.refOrganization;
    if (refOrg == null) return;

    final List<ConsumerDataModel> arrayOrgConsumers = ConsumerManager
        .sharedInstance
        .getConsumersByOrganizationId(refOrg.organizationId);
    _arrayConsumers.clear();
    var consumerIndex = 0;
    for (var consumer in arrayOrgConsumers) {
      var exist = false;
      for (var selectedConsumer in widget.vmRide!.arrayConsumers) {
        if (consumer.id == selectedConsumer.id) {
          exist = true;
          break;
        }
      }
      if (!exist) {
        final item = AutoCompleteConsumerSearchItem();
        item.szName = consumer.szName;
        item.index = consumerIndex;
        item.obj = consumer;
        _arrayConsumers.add(item);
      }
      consumerIndex += 1;
    }
    setState(() {});
  }

  _addConsumerChip(AutoCompleteConsumerSearchItem item) {
    final ConsumerDataModel? consumer = item.obj as ConsumerDataModel;
    if (consumer == null) return;
    widget.vmRide!.arrayConsumers.add(consumer);
    widget.vmRide!.arrayConsumerCompanions = [];

    _refreshConsumersDropdown();
  }

  _refreshMePanel() {
    final ride = widget.vmRide;
    if (ride == null) return;
    final currentUser = UserManager.sharedInstance.currentUser;
    if (currentUser == null) return;
    final orgRef = ride.refOrganization;
    if (orgRef == null) return;
    setState(() {
      if (currentUser.getRoleByOrganizationId(orgRef.organizationId) ==
          EnumOrganizationUserRole.guardian) {
        _mySelfRide = false;
      } else {
        _mySelfRide = true;
      }
    });
  }

  _refreshReturnDateTimePanel() {
    setState(() {
      if (widget.vmRide!.enumWayType == EnumRequestWayType.oneWay) {
        _roundTrip = false;
      } else {
        _roundTrip = true;
      }
    });
    _refreshReturnTimingPanel();
  }

  _refreshTimingPanel() {
    setState(() {
      if (widget.vmRide!.enumTiming == EnumRequestTiming.readyBy) {
        _readyBy = true;
      } else {
        _readyBy = false;
      }
    });
  }

  _refreshReturnTimingPanel() {
    setState(() {
      if (widget.vmRide!.enumReturnTiming == EnumRequestTiming.readyBy) {
        _returnReadyBy = true;
      } else {
        _returnReadyBy = false;
      }
    });
  }

  _showCalendar(BuildContext context, EnumCalendarFor type) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Refer step 1
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    ).then((value) {
      if (value == null) return;
      if (type == EnumCalendarFor.date) {
        widget.vmRide!.date = value;
        setState(() {
          _txtDate = UtilsDate.getStringFromDateTimeWithFormat(
              value, EnumDateTimeFormat.MMddyyyy.value, false);
        });
      } else if (type == EnumCalendarFor.returnDate) {
        widget.vmRide!.dateReturnDate = value;
        setState(() {
          _txtReturnDate = UtilsDate.getStringFromDateTimeWithFormat(
              value, EnumDateTimeFormat.MMddyyyy.value, false);
        });
      }
    });
  }

  _requestLocations() {
    if (widget.vmRide == null || widget.vmRide!.refOrganization == null) return;

    if (!NetworkReachabilityManager.sharedInstance.isConnected()) return;
    // Do not loading-indicator, for better UX, assuming that it doesn't take more than couple of seconds
    OrganizationManager.sharedInstance.requestGetLocationsByOrganizationId(
        widget.vmRide!.refOrganization!.organizationId, false,
        (responseDataModel) {
      if (responseDataModel.isSuccess) {
        if (responseDataModel.parsedObject != null) {
          final List<LocationDataModel> locations =
              responseDataModel.parsedObject as List<LocationDataModel>;
          _arrayLocations = locations;
          _clearAddressFields();
        }
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  bool _validateFields() {
    if (widget.vmRide == null) return false;

    if (widget.vmRide!.arrayConsumers.isEmpty &&
        !widget.vmRide!.isSelfIncluded) {
      showToast("Please select consumer.");
      return false;
    }

    // if (widget.vmRide!.arrayConsumerCompanions.isEmpty) {
    //   showToast("Please select consumer companions.");
    //   return false;
    // }

    if (!widget.vmRide!.pickup.isValidGeoPoint()) {
      showToast("Please enter pickup address");
      return false;
    }

    if (!widget.vmRide!.delivery.isValidGeoPoint()) {
      showToast("Please enter drop-off address");
      return false;
    }

    if (widget.vmRide!.enumBillingCategory ==
        EnumRequestBillingCategoryType.none) {
      showToast("Please select purpose of request");
      return false;
    }

    if (widget.vmRide!.date == null) {
      showToast("Please select the Date.");
      return false;
    }

    if (_edtTime.text.isEmpty) {
      showToast("Please select the time.");
      return false;
    } else {
      widget.vmRide!.szTime = _edtTime.text;
    }

    if (widget.vmRide!.enumWayType == EnumRequestWayType.round) {
      if (widget.vmRide!.dateReturnDate == null) {
        showToast("Please select the return date.");
        return false;
      }
      if (widget.vmRide!.dateReturnDate!.isBefore(widget.vmRide!.date!)) {
        showToast("A return trip cannot occur before the pickup trip.");
        return false;
      }
      if (_edtReturnTime.text.isEmpty) {
        showToast("Please select the return time.");
        return false;
      } else {
        widget.vmRide!.szReturnTime = _edtReturnTime.text;
      }
    }

    return true;
  }

  _clearAddressFields() {
    _clearPickupAddressField();
    _clearDropOffAddressField();
  }

  _clearPickupAddressField() {
    if (widget.vmRide == null) return;

    widget.vmRide!.pickup.initialize();
    _edtPickupAddress.text = "";
    _itemSelectedForPickup = null;
    _detectPickupAddressPlaceholderText();

    if (_isLocationAvailableForPickup) {
      _refreshLocationPickupField(_getPickupItemCandidates(null));
    } else {
      _refreshLocationPickupField([]);
    }
  }

  _clearDropOffAddressField() {
    if (widget.vmRide == null) return;

    widget.vmRide!.delivery.initialize();
    _edtDropOffAddress.text = "";
    _itemSelectedForDropOff = null;
    _detectDropOffAddressPlaceholderText();

    if (_isLocationAvailableForDropOff) {
      _refreshLocationDropOffField(_getDropOffItemCandidates(null));
    } else {
      _refreshLocationDropOffField([]);
    }
  }

  String _detectPickupAddressPlaceholderText() {
    _isGoogleAddressAvailableForPickup =
        _checkGoogleAddressAvailableForPickup();
    _isLocationAvailableForPickup = _checkLocationAvailableForPickup();

    if (_isGoogleAddressAvailableForPickup && _isLocationAvailableForPickup) {
      return "Enter address or select location";
    } else if (_isGoogleAddressAvailableForPickup &&
        !_isLocationAvailableForPickup) {
      return "Enter address";
    } else if (!_isGoogleAddressAvailableForPickup &&
        _isLocationAvailableForPickup) {
      return "Select location";
    } else {
      return "Select location";
    }
  }

  String _detectDropOffAddressPlaceholderText() {
    _isGoogleAddressAvailableForDropOff =
        _checkGoogleAddressAvailableForDropOff();
    _isLocationAvailableForDropOff = _checkLocationAvailableForDropOff();

    if (_isGoogleAddressAvailableForDropOff && _isLocationAvailableForDropOff) {
      return "Enter address or select location";
    } else if (_isGoogleAddressAvailableForDropOff &&
        !_isLocationAvailableForDropOff) {
      return "Enter address";
    } else if (!_isGoogleAddressAvailableForDropOff &&
        _isLocationAvailableForDropOff) {
      return "Select location";
    } else {
      return "Select location";
    }
  }

  bool _checkGoogleAddressAvailableForPickup() {
    // for (var offer in _arrayLocations) {
    //     if (!offer.isValid()) {
    //         return true;
    //     }
    // }
    return true;
  }

  bool _checkGoogleAddressAvailableForDropOff() {
    // If pickup is selected
    if (_itemSelectedForPickup != null) {
      // if(_itemSelectedForPickup!.type == EnumAutoCompleteSearchItemType.organizationLocation){
      //     final location = _itemSelectedForPickup!.obj as LocationDataModel?;
      //     if(location!.isValid()){
      //         return false;
      //     }
      // }else if(_itemSelectedForPickup!.type == EnumAutoCompleteSearchItemType.googlePlace){
      //     return false;
      // }
      return true;
    }

    return _checkGoogleAddressAvailableForPickup();
  }

  bool _checkLocationAvailableForPickup() {
    return (_arrayLocations.isNotEmpty);
  }

  bool _checkLocationAvailableForDropOff() {
    if (_arrayLocations.isEmpty) return false;

    // If pickup is selected
    if (_itemSelectedForPickup != null) {}
    return true;
  }

  List<AutoCompleteSearchItem> _getPickupItemCandidates(
      List<AutoCompleteSearchItem>? itemsGoogle) {
    // Google Places + Locations
    final List<AutoCompleteSearchItem> array =
        _getGooglePlaceCandidates(itemsGoogle);
    array.addAll(_getPickupLocationCandidates());
    return array;
  }

  List<AutoCompleteSearchItem> _getPickupLocationCandidates() {
    if (!_isLocationAvailableForPickup) return [];

    final List<AutoCompleteSearchItem> array = [];
    for (var location in _arrayLocations) {
      final _item = AutoCompleteSearchItem();
      _item.szName = location.szName;
      _item.szAddress = location.szAddress;
      _item.obj = location;
      _item.type = EnumAutoCompleteSearchItemType.organizationLocation;

      array.add(_item);
    }

    return array;
  }

  List<AutoCompleteSearchItem> _getDropOffItemCandidates(
      List<AutoCompleteSearchItem>? itemsGoogle) {
    // Google Places + Locations
    final List<AutoCompleteSearchItem> array =
        _getGooglePlaceCandidates(itemsGoogle);
    array.addAll(_getDropOffLocationCandidates());
    return array;
  }

  List<AutoCompleteSearchItem> _getDropOffLocationCandidates() {
    if (!_isLocationAvailableForDropOff) return [];

    final List<AutoCompleteSearchItem> array = [];
    for (var location in _arrayLocations) {
      final _item = AutoCompleteSearchItem();
      _item.szName = location.szName;
      _item.szAddress = location.szAddress;
      _item.obj = location;
      _item.type = EnumAutoCompleteSearchItemType.organizationLocation;

      array.add(_item);
    }

    return array;
  }

  List<AutoCompleteSearchItem> _getGooglePlaceCandidates(
      List<AutoCompleteSearchItem>? itemsGoogle) {
    final List<AutoCompleteSearchItem> array = [];

    // Add GoogleAutoComplete List
    if (itemsGoogle != null) {
      for (var item in itemsGoogle) {
        final AutoCompleteSearchItem _item = AutoCompleteSearchItem();
        _item.szName = item.structuredFormatting!.mainText.toString();
        _item.szAddress = item.szAddress;
        _item.obj = item;
        array.add(_item);
      }
    }

    return array;
  }

  _onPickupPlaceItemSelected(AutoCompleteSearchItem? item) async {
    if (widget.vmRide == null) return;

    if (item == null) return;
    List<Location> locations = await locationFromAddress(item.szAddress.toString());

    if (item.type == EnumAutoCompleteSearchItemType.googlePlace) {
      if (item.obj != null) {
        //final googlePlace = item.obj as SearchResult;
        widget.vmRide!.pickup.szAddress = item.szAddress;

       // final address = googlePlace.geometry?.location;
        if (locations.isEmpty) {
          widget.vmRide!.pickup.initialize();
          showToast("Location Failed...");
        } else {

          widget.vmRide!.pickup.fLatitude = locations[0].latitude;
          widget.vmRide!.pickup.fLongitude =locations[0].longitude;
        }
      }
    } else if (item.type ==
        EnumAutoCompleteSearchItemType.organizationLocation) {
      final location = item.obj as LocationDataModel?;
      if (location == null) return;
      widget.vmRide!.pickup.szName = location.szName;
      widget.vmRide!.pickup.szAddress = location.szAddress;
      widget.vmRide!.pickup.szCounty = location.szCounty;
      widget.vmRide!.pickup.fLatitude = location.fLatitude;
      widget.vmRide!.pickup.fLongitude = location.fLongitude;
      widget.vmRide!.pickup.isOffer = true;
      widget.vmRide!.modelLocationSelected = location;
    }
    _itemSelectedForPickup = item;
    _clearDropOffAddressField();

  }

  _onDropOffPlaceItemSelected(AutoCompleteSearchItem? item) async {
    if (widget.vmRide == null) return;
    if (item == null) return;
    List<Location> locations = await locationFromAddress(item.szAddress.toString());

    if (item.type == EnumAutoCompleteSearchItemType.googlePlace) {
     // final googlePlace = item.obj as SearchResult;
      widget.vmRide!.delivery.szAddress = item.szAddress;

      //final address = googlePlace.geometry?.location;
      if (locations.isEmpty) {
        widget.vmRide!.delivery.initialize();
        showToast("Location Failed...");
      } else {

        widget.vmRide!.delivery.fLatitude = locations[0].latitude;
        widget.vmRide!.delivery.fLongitude = locations[0].longitude;
      }

    } else if (item.type ==
        EnumAutoCompleteSearchItemType.organizationLocation) {
      final location = item.obj as LocationDataModel?;
      if (location == null) return;

      widget.vmRide!.delivery.szName = location.szName;
      widget.vmRide!.delivery.szAddress = location.szAddress;
      widget.vmRide!.delivery.szCounty = location.szCounty;
      widget.vmRide!.delivery.fLatitude = location.fLatitude;
      widget.vmRide!.delivery.fLongitude = location.fLongitude;
      widget.vmRide!.delivery.isOffer = true;
      widget.vmRide!.modelLocationSelected = location;
    }

    _itemSelectedForDropOff = item;
  }

  _refreshLocationPickupField(
      List<AutoCompleteSearchItem> arrayPickupLocation) {
    setState(() {
      _arrayPickupLocation.addAll(arrayPickupLocation);
    });
  }

  _refreshLocationDropOffField(
      List<AutoCompleteSearchItem> arrayDropOffLocation) {
    setState(() {
      _arrayDropOffLocation.addAll(arrayDropOffLocation);
    });
  }

  _gotoRecurringScreen() {
    if (_validateFields()) {
      Navigator.push(
        context,
        createRoute(RideRecurringScreen(
          vmRide: widget.vmRide,
        )),
      );
    }
  }

  @override
  didSettingsCompanionsListSelected(ConsumerDataModel modelConsumer,
      List<CompanionDataModel> selectedCompanions) {
    if (widget.vmRide == null) return;
    for (var consumer in widget.vmRide!.arrayConsumers) {
      if (consumer.id == modelConsumer.id) {
        consumer.arrayConsumerCompanions = selectedCompanions;
      }
    }

    setState(() {
      widget.vmRide!.arrayConsumerCompanions = selectedCompanions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.titleScheduleRide,
          style: AppStyles.textCellHeaderStyle,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                _gotoRecurringScreen();
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.buttonNext,
                    style: AppStyles.buttonTextStyle),
              ),
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
                child: const Text(AppStrings.labelRideInformation,
                    style: AppStyles.rideInformation),
              ),
              Expanded(
                child: Container(
                  margin: AppDimens.kMarginNormal.copyWith(top: 0),
                  padding: AppDimens.kMarginNormal,
                  decoration: BoxDecoration(
                      color: AppColors.textWhite,
                      borderRadius: BorderRadius.circular(10)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        user!.getPrimaryRole() == EnumOrganizationUserRole.guardian ?Text(
                          OrganizationManager.sharedInstance.arrayOrganizations[0].bookingWindows!.message.toString(),
                          style: AppStyles.tripInformation.copyWith(
                            color: AppColors.textBlack,fontSize: 13
                          ),
                          textAlign: TextAlign.center,
                        ):Container(),
                        Container(
                          margin: AppDimens.kVerticalMarginNormal,
                          child: const Text(
                            "Trip information",
                            style: AppStyles.tripInformation,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Organization:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: AppDimens.kEdittextHeight,
                          child: Autocomplete<AutoCompleteConsumerSearchItem>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              return _arrayOrganizations.where(
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
                                _edtOrganization = textEditingController;
                              }
                              return TextFormField(
                                textInputAction: TextInputAction.next,
                                style: AppStyles.inputTextStyle,
                                cursorColor: Colors.grey,
                                controller: _edtOrganization,
                                focusNode: focusNode,
                                onFieldSubmitted: (String value) {
                                  onFieldSubmitted();
                                },
                                decoration: AppStyles.autoCompleteField
                                    .copyWith(
                                        hintText:
                                            AppStrings.selectOrganization),
                              );
                            },
                            onSelected: (selection) {
                              final org = OrganizationManager.sharedInstance
                                  .arrayOrganizations[selection.index];
                              widget.vmRide!.refOrganization = org.toRef();
                              widget.vmRide!.onOrganizationSelect();
                              _requestLocations();
                              _refreshConsumersPanel();
                              _refreshMePanel();
                            },
                            optionsViewBuilder: (BuildContext context,
                                AutocompleteOnSelected<
                                        AutoCompleteConsumerSearchItem>
                                    onSelected,
                                Iterable<AutoCompleteConsumerSearchItem>
                                    options) {
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
                          "Consumer:",
                          style: AppStyles.textBlackStyle,
                        ),
//********************************* ChipChoice  View ******************************************
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 5,
                          children: List.generate(
                            widget.vmRide!.arrayConsumers.length,
                            (index) {
                              return Chip(
                                deleteIcon: const Icon(
                                  Icons.cancel,
                                  size: 20,
                                  color: AppColors.textWhite,
                                ),
                                deleteButtonTooltipMessage: "Remove",
                                backgroundColor: AppColors.primaryColor,
                                labelPadding: AppDimens.kHorizontalMarginSsmall,
                                label: Text(
                                  widget.vmRide!.arrayConsumers[index].szName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Colors.white, fontSize: 14),
                                ),
                                deleteIconColor: Colors.red,
                                onDeleted: () {
                                  final List<ConsumerDataModel> consumers =
                                      List.from(widget.vmRide!.arrayConsumers);
                                  final consumer =
                                      widget.vmRide!.arrayConsumers[index];
                                  consumer.arrayConsumerCompanions = [];
                                  consumers.remove(consumer);
                                  widget.vmRide!.arrayConsumers.clear();
                                  widget.vmRide!.arrayConsumers
                                      .addAll(consumers);
                                  _refreshConsumersDropdown();
                                },
                                elevation: 1,
                                padding: AppDimens.kHorizontalMarginSssmall,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 5),
                    //*********************** Consumer View  *******************************
                        SizedBox(
                          height: AppDimens.kEdittextHeight,
                          child: Autocomplete<AutoCompleteConsumerSearchItem>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
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
                              _edtConsumer = textEditingController;
                              return TextFormField(
                                onTap: () {
                                  if (widget.vmRide!.refOrganization == null) {
                                    showToast("Please select organization.");
                                  }
                                },
                                textInputAction: TextInputAction.next,
                                style: AppStyles.inputTextStyle,
                                cursorColor: Colors.grey,
                                controller: textEditingController,
                                focusNode: focusNode,
                                onFieldSubmitted: (String value) {
                                  onFieldSubmitted();
                                  textEditingController.clear();
                                },
                                decoration: AppStyles.autoCompleteField
                                    .copyWith(
                                        hintText: AppStrings.selectConsumers1),
                              );
                            },
                            onSelected: (selection) {
                              _edtConsumer.clear();
                              _addConsumerChip(selection);
                            },
                            optionsViewBuilder: (BuildContext context,
                                AutocompleteOnSelected<
                                        AutoCompleteConsumerSearchItem>
                                    onSelected,
                                Iterable<AutoCompleteConsumerSearchItem>
                                    options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 3.0,
                                  color: Colors.white,
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
                      //********************************Companion View**************************
                        const SizedBox(height: 20),
                        widget.vmRide!.arrayConsumers.isNotEmpty
                            ? const Text(
                                "Companions:",
                                style: AppStyles.textBlackStyle,
                              )
                            : Container(),
                        const SizedBox(height: 5),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.vmRide!.arrayConsumers.length,
                          itemBuilder: (BuildContext context, int index) {
                            final consumer =
                                widget.vmRide!.arrayConsumers[index];
                            final companions = consumer.arrayConsumerCompanions;
                            final txtCompanions = companions.isNotEmpty
                                ? companions.map((e) => e.szName).join(", ")
                                : "No companions to display";
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      border: Border.all(
                                        color: AppColors.separatorLineGray,
                                      )),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Text(
                                              "${consumer.szName} Companions",
                                              style: AppStyles.rideInformation,
                                              textAlign: TextAlign.start,
                                            ),
                                            margin: AppDimens
                                                .kHorizontalMarginSmall,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              _gotoCompanionsScreen(consumer);
                                            },
                                            child: Container(
                                                padding:
                                                    AppDimens.kMarginSsmall,
                                                child: const Icon(Icons.add,
                                                    size: 20,
                                                    color: AppColors
                                                        .primaryColor)),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 1, color: AppColors.separatorLineGray),
                                      Container(
                                        width: double.infinity,
                                        child: Text(
                                          txtCompanions,
                                          style: AppStyles.textGrey,
                                          textAlign: companions.isEmpty
                                              ? TextAlign.center
                                              : TextAlign.left,
                                        ),
                                        margin: AppDimens.kMarginSsmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                )
                              ],
                            );
                          },
                        ),
//********************************* Taking Ride View ******************************************
                        Visibility(
                          visible: _mySelfRide,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                widget.vmRide!.isSelfIncluded =
                                    !widget.vmRide!.isSelfIncluded;
                              });
                              _refreshMePanel();
                            },
                            child: Row(
                              children: [
                                Image.asset(
                                  widget.vmRide!.isSelfIncluded
                                      ? 'assets/images/rect_selected_gray.png'
                                      : 'assets/images/rect_not_selected_gray.png',
                                  width: 25,
                                  height: 25,
                                ),
                                Container(
                                  margin: AppDimens.kHorizontalMarginSmall,
                                  child: const Text(
                                    "I am also taking ride",
                                    style: AppStyles.textBlackStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
//**************************** Pickup location View  ******************************************
                        const SizedBox(height: 25),
                        const Text(
                          "Pickup Location:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                            height: AppDimens.kEdittextHeight,
                            child: RawAutocomplete<AutoCompleteSearchItem>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                return _arrayPickupLocation
                                    .where((AutoCompleteSearchItem option) {
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
                                _edtPickupAddress = textEditingController;
                                return Stack(
                                  children: [
                                    TextFormField(
                                      textInputAction: TextInputAction.next,
                                      style: AppStyles.inputTextStyle,
                                      cursorColor: Colors.grey,
                                      controller: _edtPickupAddress,
                                      onChanged: (value) async {
                                        if(value.isNotEmpty){
                                          setState(() {
                                            isLoadingPickUp = true;

                                          });
                                        }
                                        else {
                                          setState(() {
                                            isLoadingPickUp = false;
                                          });
                                        }

                                        await PlaceApiProvider()
                                            .fetchSuggestions(value)
                                            .then((response) {
                                          setState(() {
                                            isLoadingPickUp = false;
                                          });
                                          if (response.isNotEmpty) {

                                            _refreshLocationPickupField(
                                                _getPickupItemCandidates(response));
                                          }
                                        }).catchError((error) {
                                          setState(() {
                                            isLoadingPickUp = false;
                                          });
                                          _refreshLocationPickupField(
                                              _getDropOffItemCandidates(null));
                                        });

                                        /*   await googlePlace!.search.getTextSearch(value)
                                            .then((response) {
                                          if (response != null) {
                                            print("Dharam--> Response "+response.results!.length.toString());
                                            if(response.results!.isNotEmpty){
                                              for (var element in response.results!) {
                                                print("Dharam "+element.formattedAddress.toString());
                                                print("Dharam "+element.id.toString());
                                                print("Dharam "+element.name.toString());
                                              }
                                            }

                                           */ /* _refreshLocationPickupField(
                                                _getPickupItemCandidates(
                                                    response.results));*/ /*
                                          }

                                        }).catchError((error) {

                                          _refreshLocationPickupField(
                                              _getPickupItemCandidates(null));
                                        });*/
                                      },
                                      focusNode: focusNode,
                                      onFieldSubmitted: (String value) {
                                        onFieldSubmitted();
                                      },
                                      decoration: AppStyles.autoCompleteField.copyWith(
                                          hintText: _detectPickupAddressPlaceholderText())),
                                    isLoadingPickUp == true
                                        ? const Positioned(
                                        top: 10,
                                        right: 10,
                                        child: SizedBox(
                                          child: CircularProgressIndicator(
                                            color: AppColors.hintColor,
                                            strokeWidth: 1.5,
                                          ),
                                          width: 15,height: 15,
                                        ))
                                        : Container()
                                  ],
                                );
                              },
                              displayStringForOption: (selection) =>
                                  selection.szAddress,
                              onSelected: (selection) {
                                _onPickupPlaceItemSelected(selection);
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<AutoCompleteSearchItem>
                                  onSelected,
                                  Iterable<AutoCompleteSearchItem> options) {
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
                                      child: AutocompletePlacesListView(
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
                        //************************ Drop Off Location *******************************
                        const SizedBox(height: 25),
                        const Text(
                          "Dropoff Location:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                            height: AppDimens.kEdittextHeight,
                            child: Autocomplete<AutoCompleteSearchItem>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                return _arrayDropOffLocation
                                    .where((AutoCompleteSearchItem option) {
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
                                _edtDropOffAddress = textEditingController;
                                return Stack(
                                  children: [
                                    TextFormField(
                                      textInputAction: TextInputAction.next,
                                      style: AppStyles.inputTextStyle,
                                      cursorColor: Colors.grey,
                                      controller: _edtDropOffAddress,
                                      onChanged: (value) async {
                                        if(value.isNotEmpty){
                                          setState(() {
                                            isLoadingDropOff = true;

                                          });
                                        }
                                        else {
                                          setState(() {
                                            isLoadingDropOff = false;

                                          });
                                        }
                                        await PlaceApiProvider()
                                            .fetchSuggestions(value)
                                            .then((response) {
                                          setState(() {
                                            isLoadingDropOff = false;
                                          });

                                          if (response.isNotEmpty) {

                                            _refreshLocationDropOffField(_getDropOffItemCandidates(
                                                    response));
                                          }
                                        }).catchError((error) {
                                          setState(() {
                                            isLoadingDropOff = false;

                                          });
                                          _refreshLocationPickupField(
                                              _getDropOffItemCandidates(null));
                                        });

                                        /*  googlePlace!.search
                                            .getTextSearch(value,
                                                type: "address",
                                                region: "US",
                                                location: Location(
                                                    lat: 40.177570,
                                                    lng: -82.947630),
                                                radius: 150000)
                                            .then((response) {
                                          if (response != null) {
                                            _refreshLocationDropOffField(
                                                _getDropOffItemCandidates(
                                                    response.results));
                                          }
                                        }).catchError((error) {
                                          _refreshLocationPickupField(
                                              _getDropOffItemCandidates(null));
                                        });*/
                                      },
                                      focusNode: focusNode,
                                      onFieldSubmitted: (String value) {
                                        onFieldSubmitted();
                                      },
                                      decoration: AppStyles.autoCompleteField
                                          .copyWith(
                                              hintText:
                                                  _detectDropOffAddressPlaceholderText()),
                                    ),
                                    isLoadingDropOff == true
                                        ? const Positioned(
                                            top: 10,
                                            right: 10,
                                            child: SizedBox(
                                                child: CircularProgressIndicator(
                                                  color: AppColors.hintColor,
                                                  strokeWidth: 1.5,
                                                ),
                                            width: 15,height: 15,
                                            ))
                                        : Container()
                                  ],
                                );
                              },
                              displayStringForOption: (selection) =>
                                  selection.szAddress,
                              onSelected: (selection) {
                                _onDropOffPlaceItemSelected(selection);
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<AutoCompleteSearchItem>
                                      onSelected,
                                  Iterable<AutoCompleteSearchItem> options) {
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
                                      child: AutocompletePlacesListView(
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

//************************ Purpose of request ********************

                        const SizedBox(height: 25),
                        const Text(
                          "Purpose of request:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                            height: AppDimens.kEdittextHeight,
                            child: Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                return _arrayBillingTypes
                                    .where((String option) {
                                  return option.contains(
                                      textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (selection) {
                                widget.vmRide!.enumBillingCategory =
                                    RequestBillingCategoryTypeExtension
                                        .fromString(selection);
                              },
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) {
                                return TextFormField(
                                  textInputAction: TextInputAction.next,
                                  style: AppStyles.inputTextStyle,
                                  cursorColor: Colors.grey,
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  onFieldSubmitted: (String value) {
                                    onFieldSubmitted();
                                  },
                                  decoration: AppStyles.autoCompleteField
                                      .copyWith(
                                          hintText:
                                              "Select purpose of request"),
                                );
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<String> onSelected,
                                  Iterable<String> options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    color: Colors.white,
                                    elevation: 3.0,
                                    child: Container(
                                        constraints: const BoxConstraints(
                                            maxHeight: 200),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                AppDimens.kMarginNormal.top * 4,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.all(8.0),
                                          itemCount: options.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
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
                                                        style: AppStyles
                                                            .dropDownText,
                                                      ),
                                                    ),
                                                    const Divider(
                                                      height: 0.5,
                                                    ),
                                                  ],
                                                ));
                                          },
                                        )),
                                  ),
                                );
                              },
                            )),

//*************************** Round Trip ****************************

                        const SizedBox(height: 25),
                        const Text(
                          "Round Trip:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            widget.vmRide!.enumWayType =
                                EnumRequestWayType.oneWay;
                            _refreshReturnDateTimePanel();
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                _roundTrip
                                    ? 'assets/images/circle_not_selected_gray.png'
                                    : 'assets/images/circle_selected_gray.png',
                                width: 20,
                                height: 20,
                              ),
                              Container(
                                margin: AppDimens.kHorizontalMarginSsmall,
                                child: const Text(
                                  "No,Just One Way",
                                  style: AppStyles.textBlackStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            widget.vmRide!.enumWayType =
                                EnumRequestWayType.round;
                            _refreshReturnDateTimePanel();
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                _roundTrip
                                    ? 'assets/images/circle_selected_gray.png'
                                    : 'assets/images/circle_not_selected_gray.png',
                                width: 20,
                                height: 20,
                              ),
                              Container(
                                margin: AppDimens.kHorizontalMarginSsmall,
                                child: const Text(
                                  "Yes,I need a Round trip",
                                  style: AppStyles.textBlackStyle,
                                ),
                              ),
                            ],
                          ),
                        ),

//********************************* DropOff Details/Pickup ***************************

                        const SizedBox(height: 25),
                        Text(
                          _readyBy ? "Pickup Details" : "DropOff Details",
                          style: AppStyles.tripInformation,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Date:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            _showCalendar(context, EnumCalendarFor.date);
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
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
                                    ? AppStyles.hintText
                                    : AppStyles.textBlackStyle,
                              )),
                        ),

//************************* Time ************************

                        const SizedBox(height: 25),
                        const Text(
                          "Time:",
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
                                  enabled: true,
                                  textInputAction: TextInputAction.next,
                                  style: AppStyles.inputTextStyle,
                                  cursorColor: Colors.grey,
                                  controller: _edtTime,
                                  focusNode: focusNode,
                                  onFieldSubmitted: (String value) {
                                    onFieldSubmitted();
                                  },
                                  decoration: AppStyles.autoCompleteField
                                      .copyWith(hintText: "Select the time"),
                                );
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<String> onSelected,
                                  Iterable<String> options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    color: Colors.white,
                                    elevation: 3.0,
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxHeight: _roundTrip ? 200 : 100),
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
                                                      style: AppStyles
                                                          .dropDownText,
                                                    ),
                                                  ),
                                                  const Divider(
                                                    height: 0.5,
                                                  ),
                                                ],
                                              ));
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),

                        //********************** Timing Radio **********************************

                        const SizedBox(height: 25),
                        const Text(
                          "Timing:",
                          style: AppStyles.textBlackStyle,
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            widget.vmRide!.enumTiming =
                                EnumRequestTiming.readyBy;
                            _refreshTimingPanel();
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                _readyBy
                                    ? 'assets/images/circle_selected_gray.png'
                                    : 'assets/images/circle_not_selected_gray.png',
                                width: 20,
                                height: 20,
                              ),
                              Container(
                                margin: AppDimens.kHorizontalMarginSsmall,
                                child: const Text(
                                  "Ready By",
                                  style: AppStyles.textBlackStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            setState(() {
                              widget.vmRide!.enumTiming =
                                  EnumRequestTiming.arriveBy;
                              _refreshTimingPanel();
                            });
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                _readyBy
                                    ? 'assets/images/circle_not_selected_gray.png'
                                    : 'assets/images/circle_selected_gray.png',
                                width: 20,
                                height: 20,
                              ),
                              Container(
                                margin: AppDimens.kHorizontalMarginSsmall,
                                child: const Text(
                                  "Arrive By",
                                  style: AppStyles.textBlackStyle,
                                ),
                              ),
                            ],
                          ),
                        ),

                        //************************** Return Details ***************************

                        Visibility(
                          visible: _roundTrip,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //********************************* DropOff Details/Pickup ***************************
                              const SizedBox(height: 25),
                              const Text(
                                "Return Details",
                                style: AppStyles.tripInformation,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Return Date:",
                                style: AppStyles.textBlackStyle,
                              ),
                              const SizedBox(height: 5),
                              InkWell(
                                onTap: () {
                                  _showCalendar(
                                      context, EnumCalendarFor.returnDate);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: AppDimens.kMarginSsmall,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      border: Border.all(
                                          width: 1,
                                          color: AppColors.separatorLineGray)),
                                  child: Text(
                                    _txtReturnDate,
                                    style: _txtReturnDate ==
                                            "Select the Return Date"
                                        ? AppStyles.hintText
                                        : AppStyles.textBlackStyle,
                                  ),
                                ),
                              ),

//************************* Time ************************

                              const SizedBox(height: 25),
                              const Text(
                                "Return Time:",
                                style: AppStyles.textBlackStyle,
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                height: AppDimens.kEdittextHeight,
                                child: Autocomplete<String>(
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    return _arrayAllTimes
                                        .where((String option) {
                                      return option.contains(
                                          textEditingValue.text.toLowerCase());
                                    });
                                  },
                                  fieldViewBuilder: (BuildContext context,
                                      TextEditingController
                                          textEditingController,
                                      FocusNode focusNode,
                                      VoidCallback onFieldSubmitted) {
                                    _edtReturnTime = textEditingController;
                                    return TextFormField(
                                      enabled: true,
                                      textInputAction: TextInputAction.next,
                                      style: AppStyles.inputTextStyle,
                                      cursorColor: Colors.grey,
                                      controller: _edtReturnTime,
                                      focusNode: focusNode,
                                      onFieldSubmitted: (String value) {
                                        onFieldSubmitted();
                                      },
                                      decoration: AppStyles.autoCompleteField
                                          .copyWith(
                                              hintText:
                                                  "Select the Return Time"),
                                    );
                                  },
                                  optionsViewBuilder: (BuildContext context,
                                      AutocompleteOnSelected<String> onSelected,
                                      Iterable<String> options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        color: Colors.white,
                                        elevation: 3.0,
                                        child: Container(
                                          constraints: const BoxConstraints(
                                              maxHeight: 130),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              AppDimens.kMarginNormal.top * 4,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.all(8.0),
                                            itemCount: options.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
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
                                                        style: AppStyles
                                                            .dropDownText,
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

                              //********************** Timing Radio **********************************

                              const SizedBox(height: 25),
                              const Text(
                                "Return Timing:",
                                style: AppStyles.textBlackStyle,
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  widget.vmRide!.enumReturnTiming =
                                      EnumRequestTiming.readyBy;
                                  _refreshReturnTimingPanel();
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      _returnReadyBy
                                          ? 'assets/images/circle_selected_gray.png'
                                          : 'assets/images/circle_not_selected_gray.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    Container(
                                      margin: AppDimens.kHorizontalMarginSsmall,
                                      child: const Text(
                                        "Ready By",
                                        style: AppStyles.textBlackStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  widget.vmRide!.enumReturnTiming =
                                      EnumRequestTiming.arriveBy;
                                  _refreshReturnTimingPanel();
                                },
                                child: Row(
                                  children: [
                                    Image.asset(
                                      _returnReadyBy
                                          ? 'assets/images/circle_not_selected_gray.png'
                                          : 'assets/images/circle_selected_gray.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    Container(
                                      margin: AppDimens.kHorizontalMarginSsmall,
                                      child: const Text(
                                        "Arrive By",
                                        style: AppStyles.textBlackStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
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

class AutoCompleteSearchItem {
  dynamic obj;
  String szName = "";
  String szAddress = "";
  StructuredFormatting? structuredFormatting;
  EnumAutoCompleteSearchItemType type =
      EnumAutoCompleteSearchItemType.googlePlace;

  AutoCompleteSearchItem() {
    obj = null;
    szName = "";
    szAddress = "";
    structuredFormatting=null;
    type = EnumAutoCompleteSearchItemType.googlePlace;
  }

  AutoCompleteSearchItem.fromJson(Map<String, dynamic>? json) {

    if (json == null) return;

    if (UtilsBaseFunction.containsKey(json, "description")) {
      szName = UtilsString.parseString(json["description"]);
    }

    if (UtilsBaseFunction.containsKey(json, "description")) {
      szAddress = UtilsString.parseString(json["description"]);
    }

    if (UtilsBaseFunction.containsKey(json, "structured_formatting")) {
      structuredFormatting = json['structured_formatting'] != null
          ?  StructuredFormatting.fromJson(json['structured_formatting'])
          : null;
    }

  }
}

class StructuredFormatting{
  String mainText="";


  StructuredFormatting(){
    mainText = "";
  }

  StructuredFormatting.fromJson(Map<String, dynamic>? json) {

    if (json == null) return;

    if (UtilsBaseFunction.containsKey(json, "main_text")) {
      mainText = UtilsString.parseString(json["main_text"]);
    }

  }

}

enum EnumCalendarFor {
  date,
  returnDate,
}

extension CalendarForExtension on EnumCalendarFor {
  int get value {
    switch (this) {
      case EnumCalendarFor.date:
        return 0;
      case EnumCalendarFor.returnDate:
        return 1;
    }
  }
}

enum EnumAutoCompleteSearchItemType {
  googlePlace,
  organizationLocation,
  preset
}

extension AutoCompleteSearchItemTypeExtension
    on EnumAutoCompleteSearchItemType {
  int get value {
    switch (this) {
      case EnumAutoCompleteSearchItemType.googlePlace:
        return 0;
      case EnumAutoCompleteSearchItemType.organizationLocation:
        return 1;
      case EnumAutoCompleteSearchItemType.preset:
        return 2;
    }
  }
}
