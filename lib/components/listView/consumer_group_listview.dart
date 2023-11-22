import 'package:flutter/material.dart';
import 'package:livecare/components/listView/consumers_listview.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/consumers/viewModel/consumers_group_view_model.dart';
import 'package:sticky_headers/sticky_headers.dart';

class ConsumerGroupListView extends BaseScreen {
  final List<ConsumersGroupViewModel> consumersGroupList;
  final RowItemClickListener<ConsumersGroupViewModel>? groupClickListener;
  final RowItemClickListener<ConsumerDataModel>? consumerClickListener;

  const ConsumerGroupListView({Key? key, required this.consumersGroupList, this.groupClickListener, this.consumerClickListener}) : super(key: key);

  @override
  _ConsumerGroupListViewState createState() => _ConsumerGroupListViewState();
}

class _ConsumerGroupListViewState extends BaseScreenState<ConsumerGroupListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.consumersGroupList.length,
      itemBuilder: (context, index) {
        var consumerGroup = widget.consumersGroupList[index];
        return StickyHeader(
          header: InkWell(
            onTap: () {
              widget.groupClickListener?.call(consumerGroup, index);
            },
            child: Container(
              decoration: const BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.all(Radius.circular(6))),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              alignment: Alignment.centerLeft,
              child: Text(
                consumerGroup.getLocationName().toUpperCase(),
                style: AppStyles.textCellHeaderStyle,
              ),
            ),
          ),
          content: ConsumersListView(
            arrayConsumers: consumerGroup.arrayConsumers,
            consumerClickListener: widget.consumerClickListener,
          ),
        );
      },
    );
  }
}
