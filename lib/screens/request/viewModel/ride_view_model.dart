import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/dataModel/schedule_data_model.dart';
import 'package:livecare/models/request/dataModel/transfer_data_model.dart';
import 'package:livecare/models/shared/companion_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/utils/utils_date.dart';

class RideViewModel {
  OrganizationRefDataModel? refOrganization;
  List<ConsumerDataModel> arrayConsumers = [];
  bool isSelfIncluded = false;
  List<CompanionDataModel> arrayConsumerCompanions = [];
  List<CompanionDataModel> arrayMyCompanions = [];

  LocationDataModel pickup = LocationDataModel();
  LocationDataModel delivery = LocationDataModel();

  EnumRequestWayType enumWayType = EnumRequestWayType.oneWay;
  EnumRequestTiming enumTiming = EnumRequestTiming.arriveBy;
  EnumRequestTiming enumReturnTiming = EnumRequestTiming.readyBy;
  EnumRequestBillingCategoryType enumBillingCategory = EnumRequestBillingCategoryType.none;

  DateTime? date;
  String szTime = "";
  DateTime? dateReturnDate;
  String szReturnTime = "";

  bool isRecurring = false;
  DateTime? dateRepeatUntil;
  List<bool> flagWeekdays = [false, false, false, false, false, false, false];
  bool isReturnTbd = false;

  // Location, LocationOptions;
  LocationDataModel? modelLocationSelected;

  _initialize() {
    refOrganization = null;

    arrayConsumers = [];
    isSelfIncluded = false;
    arrayConsumerCompanions = [];
    arrayMyCompanions = [];

    enumWayType = EnumRequestWayType.oneWay;
    enumTiming = EnumRequestTiming.arriveBy;
    enumReturnTiming = EnumRequestTiming.readyBy;
    enumBillingCategory = EnumRequestBillingCategoryType.none;

    date = null;
    szTime = "";
    dateReturnDate = null;
    szReturnTime = "";

    isRecurring = false;
    dateRepeatUntil = null;
    flagWeekdays = [false, false, false, false, false, false, false];
    isReturnTbd = false;
    modelLocationSelected = null;
  }


  ScheduleDataModel toDataModel() {
    final schedule = ScheduleDataModel();
    schedule.refOrganization = refOrganization!;
    schedule.enumTiming = enumTiming;
    schedule.dateTime = UtilsDate.mergeDateTime(date!, szTime);
    schedule.enumBillingCategory = enumBillingCategory;

    if (enumWayType == EnumRequestWayType.round) {
      schedule.isRoundTrip = true;
      schedule.dateReturn = UtilsDate.mergeDateTime(dateReturnDate, szReturnTime);
      schedule.isReturnTbd = isReturnTbd;
      schedule.enumReturnTiming = enumReturnTiming;
    }

    if (isRecurring) {
      schedule.enumRecurringType = EnumRequestRecurringType.weekly;
      schedule.isSunday = flagWeekdays[0];
      schedule.isMonday = flagWeekdays[1];
      schedule.isTuesday = flagWeekdays[2];
      schedule.isWednesday = flagWeekdays[3];
      schedule.isThursday = flagWeekdays[4];
      schedule.isFriday = flagWeekdays[5];
      schedule.isSaturday = flagWeekdays[6];

      schedule.dateEnd = UtilsDate.mergeDateTime(dateRepeatUntil, szTime);
    }

    schedule.refPickup = pickup;
    schedule.refDelivery = delivery;

    schedule.arrayTransfers = [];
    for (var c in arrayConsumers) {
      final t = TransferDataModel();
      t.transferId = c.id;
      t.enumType = EnumTransferType.consumer;
      t.arrayCompanions = c.arrayConsumerCompanions;
      schedule.arrayTransfers.add(t);
    }

    if (isSelfIncluded) {
      if (UserManager.sharedInstance.currentUser != null) {
        final t = TransferDataModel();
        t.transferId = UserManager.sharedInstance.currentUser!.id;
        t.enumType = EnumTransferType.user;
        schedule.arrayTransfers.add(t);
      }
    }

    if (modelLocationSelected != null) {
      //TODO FIX
      // schedule.refLocation = modelLocationSelected!.toRef();
    }

    return schedule;
  }

  String getBeautifiedConsumersText() {
    // If more than 1 consumers, it will return "{{Me, }}Yurii, +1 more"
    // If only 1 consumer, it will return "Yurii"
    // If I am the only rider, it will return "Me"
    // No rider? return empty

    final count = arrayConsumers.length;
    var text = "";

    final firstConsumer =
        arrayConsumers.isNotEmpty ? arrayConsumers.first : null;
    if (firstConsumer != null) {
      text = firstConsumer.szName;
      if (firstConsumer.arrayConsumerCompanions.isNotEmpty) {
        text = "$text (+ ${firstConsumer.arrayConsumerCompanions.length})";
      }
      if (count > 1) {
        text = "$text + ${count - 1} more";
      }
    }

    if (isSelfIncluded) {
      var textMe = "Me";
      if (arrayMyCompanions.isNotEmpty) {
        textMe = "$textMe (+ ${arrayConsumerCompanions.length})";
      }
      if (count > 0) {
        text = "$textMe, $text";
      } else {
        text = textMe;
      }
    }
    return text;
  }

  String getBeautifiedConsumerCompanionsText() {
    // If more than 1 companions, it will return "{{Yurii}}, +1 more"
    // If only 1 consumer, it will return "Yurii"
    // No rider? return empty

    final count = arrayConsumerCompanions.length;
    var text = "";
    final firstCompanion = arrayConsumerCompanions.isNotEmpty
        ? arrayConsumerCompanions.first
        : null;
    if (firstCompanion != null) {
      text = firstCompanion.szName;
      if (count > 1) {
        text = "$text, +${count - 1} more";
      }
    }
    return text;
  }

  String getBeautifiedMyCompanionsText() {
    // If more than 1 companions, it will return "{{Yurii}}, +1 more"
    // If only 1 consumer, it will return "Yurii"
    // No rider? return empty
    final count = arrayMyCompanions.length;
    var text = "";
    final firstCompanion =
        arrayMyCompanions.isNotEmpty ? arrayMyCompanions.first : null;
    if (firstCompanion != null) {
      text = firstCompanion.szName;
      if (count > 1) {
        text = "$text, +$count";
      }
    }
    return text;
  }

  onOrganizationSelect() {
    // Initialize org-specific data
    arrayConsumers = [];
    arrayConsumerCompanions = [];
    isSelfIncluded = false;
    date = null;
    dateReturnDate = null;
    szTime = "";
    szReturnTime = "";
    for (var consumer in arrayConsumers) {
      consumer.arrayConsumerCompanions = [];
    }
  }
}
