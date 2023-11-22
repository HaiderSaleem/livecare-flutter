import 'package:flutter/material.dart';
import 'package:livecare/components/listView/transactions_listview.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/consumers/consumer_transaction_list.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:sticky_headers/sticky_headers.dart';

class TransactionsSectionListView extends BaseScreen {
  final List<TransactionsSectionModel> arrayTransactionSections;
  final RowItemClickListener<TransactionsSectionModel>? itemClickListener;

  const TransactionsSectionListView(
      {Key? key,
      required this.arrayTransactionSections,
      this.itemClickListener})
      : super(key: key);

  @override
  _TransactionsSectionListViewState createState() =>
      _TransactionsSectionListViewState();
}

class _TransactionsSectionListViewState
    extends BaseScreenState<TransactionsSectionListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.arrayTransactionSections.length,
      itemBuilder: (context, index) {
        var transactionSection = widget.arrayTransactionSections[index];
        return StickyHeader(
          header: Container(
            padding: AppDimens.kVerticalMarginSmall,
            color: AppColors.defaultBackground,
            alignment: Alignment.centerLeft,
            child: Text(
              UtilsDate.getStringFromDateTimeWithFormat(
                  transactionSection.sectionDate,
                  EnumDateTimeFormat.EEEEMMMMdyyyy.value,
                  false),
              style: AppStyles.boldText
                  .copyWith(color: AppColors.buttonBackground),
            ),
          ),
          content: TransactionListView(
              arrayTransactions: transactionSection.arrayTransactions),
        );
      },
    );
  }
}
