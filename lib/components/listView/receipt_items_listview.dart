import 'package:flutter/material.dart';
import 'package:livecare/listeners/receipt_items_listener.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class ReceiptItemsListView extends BaseScreen {
  final List<String> arrayReceipts;
  final ReceiptItemsListener? itemClickListener;

  const ReceiptItemsListView(
      {Key? key, required this.arrayReceipts, required this.itemClickListener})
      : super(key: key);

  @override
  _ReceiptItemsListViewState createState() => _ReceiptItemsListViewState();
}

class _ReceiptItemsListViewState extends BaseScreenState<ReceiptItemsListView> {
  final List<TextEditingController> _controllers = [];

 
  @override
  dispose() {
    super.dispose();
    for (TextEditingController c in _controllers) {
      c.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.arrayReceipts.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        //textField controllers
        _controllers.add(TextEditingController());

        var name = widget.arrayReceipts[index];
        _controllers[index].text = name;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: AppDimens.kEdittextHeight,
                  alignment: Alignment.centerRight,
                  margin: AppDimens.kVerticalMarginSsmall,
                  child: const Text(AppStrings.labelItemName,
                      textAlign: TextAlign.left, style: AppStyles.textGrey),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _controllers[index],
                    cursorColor: Colors.grey,
                    textAlign: TextAlign.left,
                    onChanged: (value) {
                      widget.itemClickListener
                          ?.didReceiptItemNameChanged(value, index);
                    },
                    style: AppStyles.textGrey,
                    textInputAction: TextInputAction.done,
                    decoration: AppStyles.transactionInputDecoration
                        .copyWith(hintText: AppStrings.enterItemName),
                  ),
                ),
                Container(
                  margin: AppDimens.kVerticalMarginSsmall,
                  child: ElevatedButton(
                    onPressed: () {
                      _controllers.removeAt(index);
                      widget.itemClickListener
                          ?.didReceiptItemDeleteClick(index);
                    },
                    style: AppStyles.deleteButtonStyle,
                    child: const Text(
                      AppStrings.buttonDelete,
                      textAlign: TextAlign.center,
                      style: AppStyles.buttonTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 0.5, color: Colors.grey),
          ],
        );
      },
    );
  }
}
