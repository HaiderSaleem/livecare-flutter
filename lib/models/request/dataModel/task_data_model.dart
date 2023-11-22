import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class TaskDataModel {
  String szName = "";
  EnumTaskStatus enumStatus = EnumTaskStatus.newTask;

  initialize() {
    szName = "";
    enumStatus = EnumTaskStatus.newTask;
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = TaskStatusExtension.fromString(
          UtilsString.parseString(dictionary["status"]));
    }
  }

  Map<String, dynamic> serialize() {
    final Map<String, dynamic> jsonObject = {};
    jsonObject["name"] = szName;
    jsonObject["status"] = enumStatus.value;
    return jsonObject;
  }

  bool isValid() {
    if (szName.isEmpty) return false;
    return true;
  }
}

enum EnumTaskStatus {
  none,
  newTask,
  completed,
}

extension TaskStatusExtension on EnumTaskStatus {
  static EnumTaskStatus fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumTaskStatus.none;
    }
    for (var t in EnumTaskStatus.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumTaskStatus.none;
  }

  String get value {
    switch (this) {
      case EnumTaskStatus.none:
        return "";
      case EnumTaskStatus.newTask:
        return "New";
      case EnumTaskStatus.completed:
        return "Completed";
    }
  }
}
