import 'package:flutter/material.dart';
import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class FormPhotoNotePopupDialog extends BaseScreen {
  final MediaDataModel? modelMedia;
  final Function(String notes)? popupListener;

  const FormPhotoNotePopupDialog(
      {Key? key, required this.modelMedia, this.popupListener})
      : super(key: key);

  @override
  _FormPhotoNotePopupDialogState createState() => _FormPhotoNotePopupDialogState();

}

class _FormPhotoNotePopupDialogState extends BaseScreenState<FormPhotoNotePopupDialog> {
  final _edtNotes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _edtNotes.text = widget.modelMedia?.szNote ?? "";
  }

  _onButtonOkClick() {
      widget.modelMedia?.szNote = _edtNotes.text;
    widget.popupListener?.call(_edtNotes.text);
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
                      Container(
                        margin: AppDimens.kVerticalMarginSsmall.copyWith(top: 0),
                        child: TextFormField(
                          style: AppStyles.inputTextStyle,
                          cursorColor: AppColors.hintColor,
                          maxLines: 7,
                          keyboardType: TextInputType.multiline,
                          controller: _edtNotes,
                          decoration: AppStyles.autoCompleteField,
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
