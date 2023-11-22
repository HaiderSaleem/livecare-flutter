import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/form/dataModel/sub_form_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class SubFormListView extends BaseScreen {
  final List<SubFormDataModel> arraySubForms;
  final RowItemClickListener<SubFormDataModel>? itemClickListener;

  const SubFormListView(
      {Key? key, required this.arraySubForms, this.itemClickListener})
      : super(key: key);

  @override
  _SubFormListViewState createState() => _SubFormListViewState();
}

class _SubFormListViewState extends BaseScreenState<SubFormListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.arraySubForms.length,
      padding: AppDimens.kVerticalMarginBig.copyWith(bottom: 0),
      itemBuilder: (BuildContext context, int index) {
        var subForm = widget.arraySubForms[index];
        return GestureDetector(
          onTap: () {
            widget.itemClickListener?.call(subForm, index);
          },
          child: Container(
            margin: AppDimens.kVerticalMarginSsmall,
            decoration: const BoxDecoration(
                color: AppColors.textWhite,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.separatorLineGray,
                    blurRadius: 5.0,
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            padding: AppDimens.kMarginNormal,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    subForm.getFormTitle(),
                    style: AppStyles.textTitleStyle
                        .copyWith(color: AppColors.buttonTextGray),
                  ),
                ),
                Image.asset("assets/images/ic_right.png",
                    width: 15, height: 15),
              ],
            ),
          ),
        );
      },
    );
  }
}
