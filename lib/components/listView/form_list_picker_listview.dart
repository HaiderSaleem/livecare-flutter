import 'package:flutter/material.dart';
import 'package:livecare/listeners/row_item_click_listener.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/forms/viewModel/form_list_item_view_model.dart';

class FormListPickerListView extends BaseScreen {
  final List<FormListItemViewModel> arrayListItems;
  final List<bool> arraySelected;
  final bool isMultiSelect;
  final RowItemClickListener<FormListItemViewModel>? itemClickListener;

  const FormListPickerListView(
      {Key? key,
      required this.arrayListItems,
      required this.arraySelected,
      required this.isMultiSelect,
      this.itemClickListener})
      : super(key: key);

  @override
  _FormListPickerListViewState createState() => _FormListPickerListViewState();
}

class _FormListPickerListViewState
    extends BaseScreenState<FormListPickerListView> {
  String _iconPath = "assets/images/ic_forms_selected.png";

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  _initUI() {
    if (widget.isMultiSelect) {
      _iconPath = "assets/images/ic_tick.png";
    } else {
      _iconPath = "assets/images/ic_forms_selected.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.arraySelected.length,
      itemBuilder: (BuildContext context, int index) {
        final data = widget.arrayListItems[index];
        return GestureDetector(
          onTap: () {
            widget.itemClickListener?.call(data, index);
          },
          child: Container(
            color: Colors.white,
            padding: AppDimens.kMarginSsmall,
            margin: AppDimens.kVerticalMarginSssmall.copyWith(top: 0),
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    data.szValue,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Visibility(
                    visible: widget.arraySelected[index],
                    child: Image.asset(
                      _iconPath,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
