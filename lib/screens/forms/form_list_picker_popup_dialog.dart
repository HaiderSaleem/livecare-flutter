import 'package:flutter/material.dart';
import 'package:livecare/components/listView/form_list_picker_listview.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/forms/viewModel/form_list_item_view_model.dart';

class FormListPickerPopupDialog extends BaseScreen {
  final List<FormListItemViewModel> arrayListItems;
  final bool isMultiSelect;
  final FormListPickerPopupListener listener;

  const FormListPickerPopupDialog({
    Key? key,
    required this.arrayListItems,
    required this.isMultiSelect,
    required this.listener,
  }) : super(key: key);

  @override
  _FormListPickerPopupDialogState createState() =>
      _FormListPickerPopupDialogState();
}

class _FormListPickerPopupDialogState
    extends BaseScreenState<FormListPickerPopupDialog> {
  List<bool> _arraySelected = [];

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  _initUI() {
    for (var item in widget.arrayListItems) {
      _arraySelected.add(item.isSelected);
    }
  }

  _onButtonOkClick() {
    int index = 0;
    for (var selected in _arraySelected) {
      widget.arrayListItems[index].isSelected = selected;
      index = index + 1;
    }
    final selectedItems =
        widget.arrayListItems.where((element) => element.isSelected).toList();
    widget.listener.call(selectedItems);
    onBackPressed();
  }

  _onButtonCancelClick() {
    onBackPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: AppDimens.kMarginNormal,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: FormListPickerListView(
                  arrayListItems: widget.arrayListItems,
                  arraySelected: _arraySelected,
                  isMultiSelect: widget.isMultiSelect,
                  itemClickListener: (data, position) {
                    setState(() {
                      if (!widget.isMultiSelect) {
                        _arraySelected = List.filled(widget.arrayListItems.length, false);
                      }
                      _arraySelected[position] = !_arraySelected[position];
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.textWhite, backgroundColor: AppColors.textWhite,
                    minimumSize: const Size(100, 35),
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: AppColors.primaryColor, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  child: Text(AppStrings.buttonCancel,
                      style: AppStyles.buttonTextStyle
                          .copyWith(color: AppColors.primaryColor)),
                  onPressed: () {
                    _onButtonCancelClick();
                  },
                ),
                const SizedBox(
                  width: 12,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor, backgroundColor: AppColors.primaryColor,
                    minimumSize: const Size(100, 35),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  child: const Text(AppStrings.buttonKk,
                      style: AppStyles.buttonTextStyle),
                  onPressed: () {
                    _onButtonOkClick();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

typedef FormListPickerPopupListener = Function(
    List<FormListItemViewModel> completed);
