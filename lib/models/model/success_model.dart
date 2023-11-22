class SuccessModel {
  String? message;
  int? status;

  SuccessModel({this.message, this.status});

  SuccessModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
  }

  SuccessModel.withError(String msg) : message = msg;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}
