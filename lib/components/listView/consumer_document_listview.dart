import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/consumer/dataModel/document_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_date.dart';

class ConsumerDocumentListView extends BaseScreen {
  final List<DocumentDataModel> arrayDocuments;
  final RowItemClickListener<DocumentDataModel>? itemClickListener;

  const ConsumerDocumentListView({Key? key, required this.arrayDocuments, this.itemClickListener}) : super(key: key);

  @override
  _ConsumerDocumentListViewState createState() => _ConsumerDocumentListViewState();
}

class _ConsumerDocumentListViewState extends BaseScreenState<ConsumerDocumentListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.arrayDocuments.length,
      itemBuilder: (BuildContext context, int index) {
        var document = widget.arrayDocuments[index];

        String _txtTitle = document.szName;
        String _txtFileName = document.modelMedia?.szFileName ?? "";
        String _txtDateTime =
            "${document.modelMedia?.getBeautifiedFileSize()} - ${UtilsDate.getStringFromDateTimeWithFormat(document.dateUploadedAt, EnumDateTimeFormat.MMMdyyyy.value, false)}";

        return InkWell(
          onTap: () {
            widget.itemClickListener?.call(document, index);
          },
          child: Container(
            margin: AppDimens.kMarginSmall.copyWith(bottom: 0),
            padding: AppDimens.kMarginSmall,
            decoration: const BoxDecoration(
                color: AppColors.textWhite,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.separatorLineGray,
                    blurRadius: 3.0,
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/ic_file_any.png',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _txtTitle,
                        style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.shareLightBlue),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(_txtFileName, style: AppStyles.textCellTextStyle),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        _txtDateTime,
                        style: AppStyles.textCellTitleBoldStyle.copyWith(color: AppColors.textGray),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
