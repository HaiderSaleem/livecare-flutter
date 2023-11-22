import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/route/dataModel/payload_data_model.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/route/dataModel/route_outcome_result_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class OutcomeResultListView extends BaseScreen {
  final RouteDataModel? modelRoute;
  final RowItemClickListener<RouteDataModel>? itemClickListener;

  const OutcomeResultListView(
      {Key? key, required this.modelRoute, this.itemClickListener})
      : super(key: key);

  @override
  _OutcomeResultListViewState createState() => _OutcomeResultListViewState();
}

class _OutcomeResultListViewState
    extends BaseScreenState<OutcomeResultListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.modelRoute!.arrayOutcomeResults.length,
      padding: AppDimens.kVerticalMarginNormal.copyWith(top: 0),
      itemBuilder: (BuildContext context, int index) {
        final route = widget.modelRoute;
        if (route == null) return Container();

        String _txtName = "";
        String _txtPhone = "";
        String _txtSpecialNeeds = "";
        String _txtNotes = "";
        bool _iconSpecialNeeds = false;
        String _iconOutcomeResult =
            "assets/images/ic_circle_not_selected_blue.png";

        final RouteOutcomeResultDataModel modelOutcomeResult =
            route.arrayOutcomeResults[index];
        final PayloadDataModel? payload =
            route.getPayloadByConsumerId(modelOutcomeResult.consumerId);
        final bool hasOutcome = modelOutcomeResult.szOutcome.isNotEmpty;

        if (payload == null) {
          _txtName = "N/A";
          _txtPhone = "N/A";
          _txtSpecialNeeds = "N/A";
          _txtNotes = "N/A";
        } else {
          _txtName = payload.modelTransfer.szName;
          _txtPhone = payload.modelTransfer.getBestContactNumber();
          if (payload.modelTransfer.modelSpecialNeeds.requiresCare()) {
            _txtSpecialNeeds = payload.modelTransfer.modelSpecialNeeds
                .getNeedsArray()
                .join(", ");
            _iconSpecialNeeds = true;
          } else {
            _txtSpecialNeeds = "N/A";
            _iconSpecialNeeds = false;
          }

          _txtNotes = payload.modelTransfer.szNotes;

          if (hasOutcome) {
            _iconOutcomeResult = "assets/images/ic_circle_checked_blue.png";
          } else {
            _iconOutcomeResult =
                "assets/images/ic_circle_not_selected_blue.png";
          }
        }

        return GestureDetector(
          onTap: () {
            widget.itemClickListener?.call(widget.modelRoute!, index);
          },
          child: Container(
            margin: AppDimens.kMarginNormal.copyWith(bottom: 0),
            decoration: const BoxDecoration(
                color: AppColors.textWhite,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.separatorLineGray,
                    blurRadius: 5.0,
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            width: MediaQuery.of(context).size.width,
            padding: AppDimens.kMarginNormal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.textGray,
                              radius: 40,
                              backgroundImage: ExactAssetImage(
                                  "assets/images/user_default.png"),
                            ),
                            Visibility(
                                visible: _iconSpecialNeeds,
                                child: Image.asset(
                                  'assets/images/ic_warning_red.png',
                                  width: 20,
                                  height: 20,
                                )),
                            Positioned(
                                right: 0,
                                bottom: 0,
                                child: Image.asset(
                                  'assets/images/ic_call_circle_blue.png',
                                  width: 20,
                                  height: 20,
                                ))
                          ],
                        )
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _txtName,
                          style: AppStyles.textCellTitleBoldStyle
                              .copyWith(color: AppColors.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _txtPhone,
                          style: AppStyles.textCellTextStyle
                              .copyWith(color: AppColors.textGrayDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _txtSpecialNeeds,
                          style: AppStyles.textCellTitleStyle
                              .copyWith(color: AppColors.buttonRed),
                        ),
                      ],
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                child: Image.asset(_iconOutcomeResult,
                                    width: 30, height: 30),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  _txtNotes,
                  style: AppStyles.textCellTextStyle
                      .copyWith(color: AppColors.textGrayDark),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
