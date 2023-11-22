import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/form/dataModel/form_page_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class FormPageListView extends BaseScreen {
  final List<FormPageDataModel> arrayFormPage;
  final RowItemClickListener<FormPageDataModel>? itemClickListener;

  const FormPageListView(
      {Key? key, required this.arrayFormPage, this.itemClickListener})
      : super(key: key);

  @override
  _FormPageListViewState createState() => _FormPageListViewState();
}

class _FormPageListViewState extends BaseScreenState<FormPageListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.arrayFormPage.length,
      padding: AppDimens.kVerticalMarginNormal.copyWith(bottom: 0),
      itemBuilder: (BuildContext context, int index) {
        var formPage = widget.arrayFormPage[index];
        return GestureDetector(
          onTap: () {
            widget.itemClickListener?.call(formPage, index);
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
                Image.asset("assets/images/ic_form_page.png",
                    width: 20, height: 20),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    formPage.szName,
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
