import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class FormListView extends BaseScreen {
  final List<FormRefDataModel> arrayForms;
  final RowItemClickListener<FormRefDataModel>? itemClickListener;

  const FormListView(
      {Key? key, required this.arrayForms, this.itemClickListener})
      : super(key: key);

  @override
  _FormListViewState createState() => _FormListViewState();
}

class _FormListViewState extends BaseScreenState<FormListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.arrayForms.length,
      padding: AppDimens.kVerticalMarginBig.copyWith(bottom: 0),
      itemBuilder: (BuildContext context, int index) {
        var form = widget.arrayForms[index];
        return GestureDetector(
          onTap: () {
            widget.itemClickListener?.call(form, index);
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
                    form.szName,
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
