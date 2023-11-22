class FormFieldRuleDataModel {
  EnumFormFieldRuleCondition enumCondition = EnumFormFieldRuleCondition.equals;
  EnumFormFieldRuleAction enumAction = EnumFormFieldRuleAction.show;
  EnumFormFieldRuleAction enumElseAction = EnumFormFieldRuleAction.hide;
  List<String> arrayValues = [];
  List<String> arrayTargetKeys = [];

  FormFieldRuleDataModel() {
    initialize();
  }

  initialize() {
    enumCondition = EnumFormFieldRuleCondition.equals;
    enumAction = EnumFormFieldRuleAction.show;
    enumElseAction = EnumFormFieldRuleAction.hide;
    arrayValues = [];
    arrayTargetKeys = [];
  }

  deserialize(Map<String, dynamic> dictionary) {
    initialize();
    enumCondition =
        FormFieldRuleConditionExtension.fromString(dictionary["condition"]);
    enumAction = FormFieldRuleActionExtension.fromString(dictionary["action"]);
    enumElseAction =
        FormFieldRuleActionExtension.fromString(dictionary["elseAction"]);
    var values = dictionary["values"];
    if (values is List<String>) {
      arrayValues = values;
    } else {
      arrayValues = [];
    }
    var targetKeys = dictionary["targetKeys"];
    if (targetKeys is List<String>) {
      arrayTargetKeys = targetKeys;
    } else {
      arrayTargetKeys = [];
    }
  }

  Map<String, dynamic> serialize() {
    final Map<String, dynamic> jsonObject = {};
    final List<dynamic> values = [];
    final List<dynamic> keys = [];
    values.add(arrayValues);
    keys.add(arrayTargetKeys);
    jsonObject["condition"] = enumCondition.value;
    jsonObject["values"] = values;
    jsonObject["action"] = enumAction.value;
    jsonObject["elseAction"] = enumElseAction.value;
    jsonObject["arrayTargetKeys"] = keys;
    return jsonObject;
  }

  bool isValid() => arrayValues.isNotEmpty && arrayTargetKeys.isNotEmpty;

  bool testValue(dynamic value) {
    if (enumCondition == EnumFormFieldRuleCondition.equals) {
      if (arrayValues.length != 1) return false;
      var parsedValue = "";
      if (value is String) parsedValue = value;
      return parsedValue == arrayValues[0];
    } else if (enumCondition == EnumFormFieldRuleCondition.equalsAny) {
      var parsedValue = "";
      if (value is String) parsedValue = value;
      if (arrayValues.isNotEmpty) {
        for (var str in arrayValues) {
          if (parsedValue.toLowerCase() == str.toLowerCase()) return true;
        }
      }
      return false;
    } else if (enumCondition == EnumFormFieldRuleCondition.notEquals) {
      var parsedValue = "";
      if (value is String) parsedValue = value;
      if (arrayValues.isNotEmpty) {
        for (var str in arrayValues) {
          if (parsedValue.toLowerCase() == str.toLowerCase()) return false;
        }
      }
      return true;
    } else if (enumCondition == EnumFormFieldRuleCondition.containsAny) {
      List<String?> parsedValues = [];
      if (value is List<dynamic>) {
        parsedValues = value as List<String?>;
      }
      for (var v in arrayValues) {
        if (parsedValues.contains(v)) return true;
      }
      return false;
    } else if (enumCondition == EnumFormFieldRuleCondition.containsAll) {
      List<String?> parsedValues = [];
      if (value is List<dynamic>) parsedValues = value as List<String?>;
      for (var v in arrayValues) {
        if (!parsedValues.contains(v)) return false;
      }
      return true;
    } else if (enumCondition == EnumFormFieldRuleCondition.notContains) {
      List<String?> parsedValues = [];
      if (value is List<dynamic>) parsedValues = value as List<String?>;
      for (var v in arrayValues) {
        if (parsedValues.contains(v)) return false;
      }
      return true;
    } else {
      return false;
    }
  }
}

enum EnumFormFieldRuleCondition {
  equals,
  equalsAny,
  notEquals,
  containsAny,
  containsAll,
  notContains
}

extension FormFieldRuleConditionExtension on EnumFormFieldRuleCondition {
  static EnumFormFieldRuleCondition fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumFormFieldRuleCondition.equals;
    }
    for (var t in EnumFormFieldRuleCondition.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumFormFieldRuleCondition.equals;
  }

  String get value {
    switch (this) {
      case EnumFormFieldRuleCondition.equals:
        return "equals";
      case EnumFormFieldRuleCondition.equalsAny:
        return "equals_any";
      case EnumFormFieldRuleCondition.notEquals:
        return "not_equals";
      case EnumFormFieldRuleCondition.containsAny:
        return "contains_any";
      case EnumFormFieldRuleCondition.containsAll:
        return "contains_all";
      case EnumFormFieldRuleCondition.notContains:
        return "not_contains";
    }
  }
}

enum EnumFormFieldRuleAction {
  show,
  hide,
}

extension FormFieldRuleActionExtension on EnumFormFieldRuleAction {
  static EnumFormFieldRuleAction fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumFormFieldRuleAction.show;
    }
    for (var t in EnumFormFieldRuleAction.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumFormFieldRuleAction.show;
  }

  String get value {
    switch (this) {
      case EnumFormFieldRuleAction.show:
        return "show";
      case EnumFormFieldRuleAction.hide:
        return "hide";
    }
  }
}
