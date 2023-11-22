abstract class PurchaseReceiptsListener {
  didTransactionDetailsConsumerSelected(int indexConsumer, int indexRow);

  didTransactionDetailsAccountSelected(int indexAccount, int indexRow);

  didTransactionDetailsAmountChanged(double amount, int indexRow);

  didTransactionDetailsDeleteClick(int indexRow);
}