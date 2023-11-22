import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/transaction/dataModel/transaction_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_date.dart';

class ReturnedTransactionsListView extends BaseScreen {
  final List<TransactionDataModel> arrayTransactions;
  final RowItemClickListener<TransactionDataModel>? itemClickListener;

  const ReturnedTransactionsListView(
      {Key? key, required this.arrayTransactions, this.itemClickListener})
      : super(key: key);

  @override
  _ReturnedTransactionsListViewState createState() =>
      _ReturnedTransactionsListViewState();
}

class _ReturnedTransactionsListViewState
    extends BaseScreenState<ReturnedTransactionsListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.arrayTransactions.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var transaction = widget.arrayTransactions[index];
        var title = transaction.isForLocationAccount()
            ? transaction.refLocation.szName
            : transaction.refConsumer.szName;
        final primaryRole =
            UserManager.sharedInstance.currentUser?.getPrimaryRole();
        if (primaryRole == null) return Container();

        return GestureDetector(
          onTap: () {
            widget.itemClickListener?.call(transaction, index);
          },
          child: Card(
            color: transaction.enumStatus == EnumTransactionStatus.pending
                ? AppColors.pendingTransaction
                : Colors.white,
            elevation: 3.0,
            shadowColor: Colors.grey,
            margin: AppDimens.kVerticalMarginSsmall,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(6))),
              padding: AppDimens.kMarginSmall,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.left,
                          style: AppStyles.boldText,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          margin: AppDimens.kHorizontalMarginNormal,
                          child: Text(
                            UtilsDate.getStringFromDateTimeWithFormat(
                                transaction.getTransactionDate(),
                                EnumDateTimeFormat.hhmma_MMMd.value,
                                false),
                            textAlign: TextAlign.left,
                            style: AppStyles.textCellDescriptionStyle,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          margin: AppDimens.kHorizontalMarginNormal,
                          child: Text(
                            transaction.returnReason,
                            textAlign: TextAlign.left,
                            style: AppStyles.textCellDescriptionStyle
                                .copyWith(color: AppColors.buttonRed),
                          ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        transaction.refAccount.szName,
                        textAlign: TextAlign.right,
                        style: AppStyles.textTiny,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "\$${transaction.fAmount.toStringAsFixed(2)}",
                        textAlign: TextAlign.right,
                        style: AppStyles.boldText,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ) ;
      },
    );
  }
}
