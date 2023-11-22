import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';


class ConsumersListView extends BaseScreen {
  final List<ConsumerDataModel> arrayConsumers;
  final RowItemClickListener<ConsumerDataModel>? consumerClickListener;

  const ConsumersListView(
      {Key? key, required this.arrayConsumers, this.consumerClickListener})
      : super(key: key);

  @override
  _ConsumersListViewState createState() => _ConsumersListViewState();
}

class _ConsumersListViewState extends BaseScreenState<ConsumersListView> {
 
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.arrayConsumers.length,
      itemBuilder: (context, index) {
        var consumer = widget.arrayConsumers[index];
        return InkWell(
          onTap: () {
            widget.consumerClickListener?.call(consumer, index);
          },
          child: Card(
            margin: AppDimens.kVerticalMarginSmall,
            color: Colors.white,
            elevation: 3.0,
            shadowColor: Colors.grey,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 0.5, color: Colors.grey),
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(
                      Radius.circular(6))),
              padding: AppDimens.kMarginSmall,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        consumer.szName,
                        textAlign: TextAlign.left,
                        style: AppStyles.textCellHeaderStyle
                            .copyWith(
                            color: AppColors.textBlack),
                      ),
                      const ImageIcon(
                        AssetImage(
                            'assets/images/ic_right.png'),
                        size: 12,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    consumer.szExternalKey,
                    textAlign: TextAlign.left,
                    style: AppStyles
                        .textCellDescriptionStyle
                        .copyWith(fontSize: null),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    consumer.szRegion,
                    textAlign: TextAlign.left,
                    style:
                    AppStyles.textCellDescriptionStyle,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}