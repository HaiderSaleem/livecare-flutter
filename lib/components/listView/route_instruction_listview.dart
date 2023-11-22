import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/route/dataModel/instruction_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class RouteInstructionListView extends BaseScreen {
  final List<InstructionDataModel> arrayInstructions;
  final RowItemClickListener<InstructionDataModel>? itemClickListener;

  const RouteInstructionListView(
      {Key? key, required this.arrayInstructions, this.itemClickListener})
      : super(key: key);

  @override
  _RouteInstructionListViewState createState() =>
      _RouteInstructionListViewState();
}

class _RouteInstructionListViewState
    extends BaseScreenState<RouteInstructionListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.arrayInstructions.length,
      itemBuilder: (BuildContext context, int index) {
        final instruction = widget.arrayInstructions[index];
        String _iconSign = "assets/images/direction_continue.png";
        String _txtName = "";
        String _txtDurationDistance = "";

        String _travelTime = "";
        if (instruction.intTravelTime % 60 > 0) {
          _travelTime = "${instruction.intTravelTime % 60} min";
        } else {
          _travelTime = "< 1 min";
        }

        _txtName = instruction.szText + " " + instruction.szStreetName;
        _txtDurationDistance =
            "$_travelTime (${instruction.fDistance.toStringAsFixed(2)} mi)";

        if (instruction.enumSign == EnumInstructionSing.turnSharpLeft) {
          _iconSign = "assets/images/direction_sharp_left.png";
        } else if (instruction.enumSign == EnumInstructionSing.turnLeft) {
          _iconSign = "assets/images/direction_turn_left.png";
        } else if (instruction.enumSign == EnumInstructionSing.turnSlightLeft) {
          _iconSign = "assets/images/direction_slight_left.png";
        } else if (instruction.enumSign ==
            EnumInstructionSing.continueOnStreet) {
          _iconSign = "assets/images/direction_continue.png";
        } else if (instruction.enumSign ==
            EnumInstructionSing.turnSlightRight) {
          _iconSign = "assets/images/direction_slight_right.png";
        } else if (instruction.enumSign == EnumInstructionSing.turnRight) {
          _iconSign = "assets/images/direction_turn_right.png";
        } else if (instruction.enumSign == EnumInstructionSing.turnSharpRight) {
          _iconSign = "assets/images/direction_sharp_right.png";
        } else if (instruction.enumSign == EnumInstructionSing.finish) {
          _iconSign = "assets/images/direction_finish.png";
        } else if (instruction.enumSign == EnumInstructionSing.viaReached) {
          _iconSign = "assets/images/direction_via_reached.png";
        } else if (instruction.enumSign == EnumInstructionSing.useRoundabout) {
          _iconSign = "assets/images/direction_roundabout.png";
        } else if (instruction.enumSign == EnumInstructionSing.keepRight) {
          _iconSign = "assets/images/direction_turn_right.png";
        }

        return Container(
          padding: AppDimens.kMarginSsmall,
          margin: AppDimens.kMarginSmall.copyWith(top: 4, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(_iconSign, width: 24, height: 24),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_txtName,
                            style: AppStyles.textCellTitleBoldStyle
                                .copyWith(color: AppColors.textBlack)),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(
                    width: 36,
                  ),
                  Text(_txtDurationDistance,
                      style: AppStyles.textCellTextStyle
                          .copyWith(color: AppColors.textGray)),
                  const SizedBox(
                    width: 8,
                  ),
                  const Expanded(
                      flex: 1,
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                      ))
                  // Divider(height: 10, thickness:10, color: Colors.red,),
                  ,
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
