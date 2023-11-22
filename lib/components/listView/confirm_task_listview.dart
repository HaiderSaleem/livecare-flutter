import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/models/request/dataModel/task_data_model.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class ConfirmTaskListView extends BaseScreen {
  final List<TaskDataModel> arrayTasks;
  final List<EnumTaskStatus> arrayStatus;
  final RowItemClickListener<TaskDataModel>? itemClickListener;

  const ConfirmTaskListView({Key? key, required this.arrayTasks, required this.arrayStatus, this.itemClickListener}) : super(key: key);

  @override
  _ConfirmTaskListViewState createState() => _ConfirmTaskListViewState();
}

class _ConfirmTaskListViewState extends BaseScreenState<ConfirmTaskListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: AppDimens.kVerticalMarginNormal.copyWith(top: 0),
      itemCount: widget.arrayTasks.length,
      itemBuilder: (BuildContext context, int index) {
        final task = widget.arrayTasks[index];
        final status = widget.arrayStatus[index];

        String _txtName = "";
        String _iconSelect = "assets/images/ic_rect_not_selected_gray.png";
        _txtName = task.szName;
        final bool selected = status == EnumTaskStatus.completed;
        if (selected) {
          _iconSelect = "assets/images/ic_rect_selected_gray.png";
        } else {
          _iconSelect = "assets/images/ic_rect_not_selected_gray.png";
        }

        return GestureDetector(
          onTap: () {
            widget.itemClickListener?.call(task, index);
          },
          child: Container(
            margin: AppDimens.kMarginSmall,
            padding: AppDimens.kMarginSmall,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  _iconSelect,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    _txtName,
                    style: AppStyles.textCellTitleStyle,
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
