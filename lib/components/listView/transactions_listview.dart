import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/transaction/dataModel/transaction_data_model.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class TransactionListView extends BaseScreen {
  final List<TransactionDataModel> arrayTransactions;
  final RowItemClickListener<TransactionDataModel>? itemClickListener;

  const TransactionListView({Key? key, required this.arrayTransactions, this.itemClickListener}) : super(key: key);

  @override
  _TransactionListViewState createState() => _TransactionListViewState();
}

class _TransactionListViewState extends BaseScreenState<TransactionListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.arrayTransactions.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var transaction = widget.arrayTransactions[index];
        var title = transaction.isForLocationAccount() ? transaction.refLocation.szName : transaction.refConsumer.szName;
        final primaryRole = UserManager.sharedInstance.currentUser?.getPrimaryRole();
        if (primaryRole == null) return Container();

        return Card(
          color: transaction.enumStatus == EnumTransactionStatus.pending ? AppColors.pendingTransaction : Colors.white,
          elevation: 3.0,
          shadowColor: Colors.grey,
          margin: AppDimens.kVerticalMarginSsmall,
          child: Container(
            decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(6))),
            padding: AppDimens.kMarginSmall,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          transaction.enumType == EnumTransactionType.debit
                              ? const ImageIcon(
                                  AssetImage('assets/images/ic_withdrawal.png'),
                                  size: 12,
                                  color: Colors.grey,
                                )
                              : transaction.enumType == EnumTransactionType.credit
                                  ? const ImageIcon(
                                      AssetImage('assets/images/ic_deposit.png'),
                                      size: 12,
                                      color: Colors.grey,
                                    )
                                  : Container(),
                          Container(
                            margin: AppDimens.kHorizontalMarginSssmall,
                            child: Text(
                              transaction.enumType.getBeautifiedText,
                              textAlign: TextAlign.left,
                              style: AppStyles.textTiny,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        margin: AppDimens.kHorizontalMarginNormal,
                        child: Text(
                          UtilsDate.getStringFromDateTimeWithFormat(transaction.getTransactionDate(), EnumDateTimeFormat.hhmma_MMMd.value, false),
                          textAlign: TextAlign.left,
                          style: AppStyles.textCellDescriptionStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    //account panel
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          transaction.refAccount.szName,
                          textAlign: TextAlign.right,
                          style: AppStyles.textTiny,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "\$${transaction.fAmount.toStringAsFixed(2)}",
                          textAlign: TextAlign.right,
                          style: AppStyles.boldText,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: AppDimens.kHorizontalMarginSssmall,
                              child: Text(
                                transaction.enumStatus.value,
                                textAlign: TextAlign.right,
                                style: AppStyles.textTiny,
                              ),
                            ),
                            transaction.enumStatus == EnumTransactionStatus.pending
                                ? const Icon(Icons.circle, size: 12.0, color: Colors.grey)
                                : transaction.enumStatus == EnumTransactionStatus.submitted
                                    ? const Icon(
                                        Icons.check_circle_outline,
                                        size: 12.0,
                                      )
                                    : transaction.enumStatus == EnumTransactionStatus.approved
                                        ? const Icon(
                                            Icons.check_circle,
                                            size: 12.0,
                                            color: AppColors.signed,
                                          )
                                        : Container()
                          ],
                        ),
                      ],
                    ),

                    //balance panel
                    primaryRole == EnumOrganizationUserRole.leadDSP
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Balance",
                                textAlign: TextAlign.right,
                                style: AppStyles.textTiny,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                UtilsString.beautifyAmount(transaction.fBalance),
                                textAlign: TextAlign.right,
                                style: AppStyles.boldText,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: AppDimens.kHorizontalMarginSssmall,
                                    child: Text(
                                      transaction.enumStatus.value,
                                      textAlign: TextAlign.right,
                                      style: AppStyles.textTiny,
                                    ),
                                  ),
                                  transaction.enumStatus == EnumTransactionStatus.pending
                                      ? const Icon(Icons.circle, size: 12.0, color: Colors.grey)
                                      : transaction.enumStatus == EnumTransactionStatus.submitted
                                          ? const Icon(
                                              Icons.check_circle_outline,
                                              size: 12.0,
                                            )
                                          : transaction.enumStatus == EnumTransactionStatus.approved
                                              ? const Icon(
                                                  Icons.check_circle,
                                                  size: 12.0,
                                                  color: AppColors.signed,
                                                )
                                              : Container()
                                ],
                              ),
                            ],
                          )
                        : Container(),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
