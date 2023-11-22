import 'package:flutter/material.dart';
import 'package:livecare/listeners/request_note_popup_listener.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_base_function.dart';

class RequestNotePopupDialog extends BaseScreen {
  final String szNotes;
  final RequestNotePopupListener? popupListener;

  const RequestNotePopupDialog(
      {Key? key, required this.szNotes, required this.popupListener}) : super(key: key);

  @override
  _RequestNotePopupDialogState createState() => _RequestNotePopupDialogState();
}

class _RequestNotePopupDialogState
    extends BaseScreenState<RequestNotePopupDialog> {
  final _edtNotes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _edtNotes.text = widget.szNotes;
  }

  _onButtonOkClick() {
    final String notes = _edtNotes.text;
    if (notes.isEmpty) {
      UtilsBaseFunction.showAlert(context, "Error", "Please enter notes.");
      return;
    }
    widget.popupListener?.didRequestNotePopupOkClick(notes);
    onBackPressed();
  }

  _onButtonCancelClick() {
    widget.popupListener?.didRequestNotePopupCancelClick();
    onBackPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            color: AppColors.textWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: AppColors.primaryColor,
                  height: AppDimens.kButtonHeight,
                  child: Center(
                    child: Text("Notes",
                        style: AppStyles.textTitleBoldStyle
                            .copyWith(color: AppColors.textWhite)),
                  ),
                ),
                Container(
                  margin: AppDimens.kMarginNormal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Please enter notes",
                          style: AppStyles.textCellTitleBoldStyle
                              .copyWith(color: AppColors.textBlack)),
                      const SizedBox(height: 16),
                      Container(
                        margin:
                            AppDimens.kVerticalMarginSsmall.copyWith(top: 0),
                        child: TextFormField(
                          style: AppStyles.inputTextStyle,
                          cursorColor: AppColors.hintColor,
                          maxLines: 7,
                          keyboardType: TextInputType.multiline,
                          controller: _edtNotes,
                          decoration: AppStyles.autoCompleteField
                              .copyWith(hintText: AppStrings.hintEnterNotes),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextButton(
                              child: Text(
                                'Cancel',
                                style: AppStyles.buttonTextStyle
                                    .copyWith(color: AppColors.textGray),
                              ),
                              onPressed: () {
                                _onButtonCancelClick();
                              },
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor)
                                  .merge(AppStyles.normalButtonStyle),
                              child: const Text('OK',
                                  style: AppStyles.buttonTextStyle),
                              onPressed: () {
                                _onButtonOkClick();
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
