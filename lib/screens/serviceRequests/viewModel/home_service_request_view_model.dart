import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/dataModel/schedule_data_model.dart';
import 'package:livecare/utils/utils_date.dart';

class HomeServiceRequestViewModel {

  OrganizationRefDataModel refOrganization = OrganizationRefDataModel();
  LocationDataModel refLocationDataPoint = LocationDataModel();

  String szDescription = "";
  DateTime? date;
  String szTime = "";
  int nDurationHours = 0;
  int nDurationMins = 0;

  //new params added
  String szConsumer = "";
  String szLocationService = "";
  int indexConsumer = 0;

  bool isRecurring = false;
  DateTime? dateRepeatUntil;
  List<bool> flagWeekdays = [false, false, false, false, false, false, false];

  initialize() {

    date = null;
    szTime = "";

    isRecurring = false;
    dateRepeatUntil = null;
    flagWeekdays = [false, false, false, false, false, false, false];
  }

  HomeServiceRequestViewModel fromDataModel(RequestDataModel? modelRequest) {
    final vm = HomeServiceRequestViewModel();
    final request = modelRequest;
    if (request == null) return vm;

    vm.refOrganization = request.refOrganization;
    vm.szDescription = request.szDescription;
    vm.date = request.dateTime;
    vm.szTime = UtilsDate.getStringFromDateTimeWithFormat(
        request.dateTime, EnumDateTimeFormat.hhmma.value, false);
    vm.nDurationHours = request.intDuration ~/ 60;
    vm.nDurationMins = request.intDuration % 60;
    vm.isRecurring = false;
    vm.dateRepeatUntil = null;
    vm.flagWeekdays = [false, false, false, false, false, false, false];
    return vm;

  }

  ScheduleDataModel toDataModel() {

    final schedule = ScheduleDataModel();
    schedule.refOrganization = refOrganization;
    schedule.szDescription = szDescription;
    schedule.dateTime = UtilsDate.mergeDateTime(date, szTime);
    schedule.intDuration = nDurationHours * 60 + nDurationMins;

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
    return schedule;
  }


}
