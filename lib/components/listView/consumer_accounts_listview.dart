import 'package:flutter/material.dart';
import 'package:livecare/listeners/consumer_account_button_listener.dart';
import 'package:livecare/models/financialAccount/dataModel/financial_account_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class ConsumerAccountsListView extends BaseScreen {
  final List<FinancialAccountDataModel> arrayAccounts;
  final ConsumerAccountButtonListener? buttonListener;

  const ConsumerAccountsListView({Key? key, required this.arrayAccounts, this.buttonListener}) : super(key: key);

  @override
  _ConsumerAccountsListViewState createState() => _ConsumerAccountsListViewState();
}

class _ConsumerAccountsListViewState extends BaseScreenState<ConsumerAccountsListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppDimens.kVerticalMarginNormal.copyWith(bottom: 0),
      shrinkWrap: true,
      itemCount: widget.arrayAccounts.length,
      itemBuilder: (context, index) {
        var account = widget.arrayAccounts[index];
        return Card(
          margin: AppDimens.kVerticalMarginNormal.copyWith(top: 0),
          color: Colors.white,
          elevation: 3.0,
          shadowColor: Colors.grey,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(width: 0.5, color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(6))),
            padding: AppDimens.kMarginNormal,
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      account.szName,
                      textAlign: TextAlign.left,
                      style: AppStyles.boldText,
                    ),
                    Text(
                      account.getGiftCardNumber(),
                      textAlign: TextAlign.left,
                      style: AppStyles.textGrey.copyWith(color: AppColors.textBlack),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        "\$ ${account.fBalance.toStringAsFixed(2)}",
                        textAlign: TextAlign.center,
                        style: AppStyles.dollarText,
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "USD",
                        textAlign: TextAlign.left,
                        style: AppStyles.textGrey,
                      ),
                    )
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                  height: 18,
                  thickness: 0.5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //New
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          widget.buttonListener?.onClickedNewTransaction(account, index);
                        },
                        child: const Text(
                          AppStrings.buttonNewTransaction,
                          textAlign: TextAlign.center,
                          style: AppStyles.textGrey,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: AppColors.textGray,
                    ),
                    //History Button
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          widget.buttonListener?.onClickedHistory(account, index);
                        },
                        child: const Text(
                          AppStrings.buttonHistoryAccount,
                          textAlign: TextAlign.center,
                          style: AppStyles.textBlackStyle,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey,
                    ),
                    //Audit
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          widget.buttonListener?.onClickedAudit(account, index);
                        },
                        child: const Text(
                          AppStrings.buttonAuditAccount,
                          textAlign: TextAlign.center,
                          style: AppStyles.textBlackStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
