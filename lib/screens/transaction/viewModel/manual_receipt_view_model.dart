import 'package:livecare/models/transaction/dataModel/receipt_data_model.dart';

class ManualReceiptViewModel {
  String szVendor = "";
  double fAmount = 0.0;
  DateTime? date;
  List<String> arrayNames = [""];

  initialize() {
    fAmount = 0.0;
    date = null;
    arrayNames = [""];
  }


  ReceiptDataModel toDataModel() {
    final r = ReceiptDataModel();
    r.szVendor = szVendor;
    r.arrayItems.addAll(arrayNames);
    r.date = date ?? DateTime.now();
    return r;
  }
}
