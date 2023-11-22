import 'package:flutter/material.dart';
import 'package:livecare/components/listView/route_instruction_listview.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/route/dataModel/instruction_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class RouteInstructionsPopupDialog extends BaseScreen {
  final LocationDataModel? modalLocationFrom;
  final LocationDataModel? modalLocationTo;
  final List<InstructionDataModel> arrayInstructions;

  const RouteInstructionsPopupDialog(
      {Key? key,
      required this.modalLocationFrom,
      required this.modalLocationTo,
      required this.arrayInstructions})
      : super(key: key);

  @override
  _RouteInstructionsPopupDialogState createState() =>
      _RouteInstructionsPopupDialogState();
}


class _RouteInstructionsPopupDialogState
    extends BaseScreenState<RouteInstructionsPopupDialog> {
  String _txtFromLocationName = "";
  String _txtFromLocationAddress = "";
  String _txtToLocationName = "";
  String _txtToLocationAddress = "";

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  _initUI() {
    final fromLocation = widget.modalLocationFrom;
    if (fromLocation == null) return;
    final toLocation = widget.modalLocationTo;
    if (toLocation == null) return;

    final List<String> arrAddressFrom = [];
    arrAddressFrom.addAll(fromLocation.szAddress.split(","));

    final locationNameFrom = arrAddressFrom.removeAt(0);
    _txtFromLocationName = locationNameFrom;
    _txtFromLocationAddress = arrAddressFrom.join(", ");

    final List<String> arrAddressTo = [];
    arrAddressTo.addAll(toLocation.szAddress.split(","));

    final locationNameTo = arrAddressTo.removeAt(0);
    _txtToLocationName = locationNameTo;
    _txtToLocationAddress = arrAddressTo.join(", ");
  }

  _onButtonCancelClick() {
    onBackPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: AppDimens.kMarginNormal,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: AppDimens.kMarginBig,
        color: AppColors.textWhite,
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.submitOutcomeResults,
                  style: AppStyles.textTitleStyle,
                ),
                GestureDetector(
                  onTap: () {
                    _onButtonCancelClick();
                  },
                  child: const Icon(Icons.clear,
                      size: 24, color: AppColors.primaryColor),
                )
              ],
            ),
            const Divider(
              height: 32,
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _txtFromLocationName,
                      style: AppStyles.textTitleBoldStyle
                          .copyWith(color: AppColors.textBlack),
                    ),
                    Text(
                      _txtFromLocationAddress,
                      style: AppStyles.inputTextStyle
                          .copyWith(color: AppColors.textGray),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    RouteInstructionListView(
                      arrayInstructions: widget.arrayInstructions,
                      itemClickListener: (instruction, position) {},
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      _txtToLocationName,
                      style: AppStyles.textTitleBoldStyle
                          .copyWith(color: AppColors.textBlack),
                    ),
                    Text(
                      _txtToLocationAddress,
                      style: AppStyles.inputTextStyle
                          .copyWith(color: AppColors.textGray),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
