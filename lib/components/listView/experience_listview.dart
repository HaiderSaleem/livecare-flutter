import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/experience/dataModel/experience_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_date.dart';

class ExperienceListView extends BaseScreen {
  final List<ExperienceDataModel> arrayExperience;
  final RowItemClickListener<ExperienceDataModel>? itemClickListener;

  const ExperienceListView(
      {Key? key, required this.arrayExperience, this.itemClickListener})
      : super(key: key);

  @override
  _ExperienceListViewState createState() => _ExperienceListViewState();
}

class _ExperienceListViewState extends BaseScreenState<ExperienceListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.arrayExperience.length,
      padding: AppDimens.kVerticalMarginNormal.copyWith(top: 0),
      itemBuilder: (context, index) {
        var experience = widget.arrayExperience[index];

        String _txtExperienceName = experience.szName;
        String _txtStatus = experience.enumStatus.value.toUpperCase();
        final DateTime? dateTime = experience.getBestDate();
        String _txtDate = UtilsDate.getStringFromDateTimeWithFormat(
            dateTime, EnumDateTimeFormat.MMdd.value, false);
        String _txtTime = UtilsDate.getStringFromDateTimeWithFormat(
            dateTime, EnumDateTimeFormat.hhmma.value, false);
        String _txtAddress = "";
        final location = experience.modelLocation;
        if (location == null) {
          _txtAddress = "N/A";
        } else {
          _txtAddress = experience.modelLocation?.szAddress ?? "";
        }

        return InkWell(
          onTap: () {
            widget.itemClickListener?.call(experience, index);
          },
          child: Container(
            margin: AppDimens.kMarginNormal.copyWith(bottom: 0),
            decoration: const BoxDecoration(
                color: AppColors.textWhite,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.separatorLineGray,
                    blurRadius: 3.0,
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            padding: AppDimens.kMarginNormal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(_txtDate,
                            style: AppStyles.textCellTitleBoldStyle
                                .copyWith(color: AppColors.primaryColor)),
                        const SizedBox(width: 10),
                        Text(
                          _txtTime,
                          style: AppStyles.textCellTitleBoldStyle
                              .copyWith(color: AppColors.primaryColor),
                        ),
                      ],
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        child: Icon(Icons.arrow_forward_ios_outlined,
                            size: 16, color: Colors.grey),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(_txtExperienceName,
                    style: AppStyles.textCellTitleBoldStyle),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Image.asset("assets/images/icon_pin.png",
                        height: 16, width: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_txtAddress,
                          style: AppStyles.textCellTextStyle
                              .copyWith(color: AppColors.purpleColor)),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(_txtStatus,
                    style: AppStyles.textCellTitleStyle
                        .copyWith(color: AppColors.textGrayDark)),
              ],
            ),
          ),
        );
      },
    );
  }
}
