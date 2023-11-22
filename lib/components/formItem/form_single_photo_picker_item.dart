import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livecare/listeners/form_details_listener.dart';
import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/forms/form_photo_note_popup_dialog.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:photo_view/photo_view.dart';

class FormSinglePhotoPickerItem extends BaseScreen {
  final FormSectionDataModel? modelSection;
  final int indexSection;
  final int position;
  final FormDetailsListener? callback;

  const FormSinglePhotoPickerItem(
      {Key? key,
      required this.modelSection,
      required this.indexSection,
      required this.position,
      required this.callback})
      : super(key: key);

  @override
  _FormSinglePhotoPickerItemState createState() =>
      _FormSinglePhotoPickerItemState();
}

class _FormSinglePhotoPickerItemState
    extends BaseScreenState<FormSinglePhotoPickerItem> {
  final _picker = ImagePicker();

  MediaDataModel? modelMedia;
  String _txtTitle = "";
  String _asterisk = "";

  late File _image = File("");

  _showTakePhotoDialog() {
    UtilsBaseFunction.showImagePicker(
        context, _takePhotoFromCamera, _choosePhotoFromGallery);
  }

  Future _choosePhotoFromGallery() async {
    _picker.pickImage(source: ImageSource.gallery).then((value) {
      final File file = File(value!.path);
      widget.callback
          ?.onUpdateValue(widget.indexSection, widget.position, file);
    });
  }

  Future _takePhotoFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      setState(() {

        _image = file;
        widget.callback
            ?.onUpdateValue(widget.indexSection, widget.position, _image);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  @override
  void didUpdateWidget(FormSinglePhotoPickerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initUI();
  }

  _initUI() {
    final FormFieldDataModel field =
        widget.modelSection!.arrayFields[widget.position];
    _txtTitle = field.szFieldName;
    _asterisk = "";
    if (field.isRequired) {
      _asterisk = " *";
    }

    if (field.parsedObject is MediaDataModel) {
      modelMedia = field.parsedObject as MediaDataModel?;
    }
  }

  _showPhotoOptionSheet(
      int indexSection, int position, MediaDataModel modelMedia,
      {valueIndex = 0}) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          margin: AppDimens.kMarginSmall,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: ListTile(
                  title: const Text(
                    "View",
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showPhotoGallery(modelMedia.getUrlString());
                  },
                ),
              ),
              const Divider(height: 0.5, color: Colors.grey),
              Container(
                color: Colors.white,
                child: ListTile(
                  title: const Text(
                    "View Note",
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          FormPhotoNotePopupDialog(
                        modelMedia: modelMedia,
                        popupListener: (notes) {
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 0.5, color: Colors.grey),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    AppStrings.buttonRemove,
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuText.copyWith(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    UtilsBaseFunction.showAlertWithMultipleButton(
                        context,
                        "Warning",
                        "Are you sure you want to delete this photo?",
                        () => _deletePhoto(indexSection, position, valueIndex));
                  },
                ),
              ),
              const Divider(height: 8, color: Colors.transparent),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                child: ListTile(
                  title: const Text(
                    AppStrings.buttonCancel,
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuCancelText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _showPhotoGallery(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        insetPadding: AppDimens.kMarginNormal,
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              padding: AppDimens.kMarginBig,
              width: double.infinity,
              height: double.infinity,
              child: PhotoView(
                imageProvider: NetworkImage(imageUrl),
                backgroundDecoration:
                    const BoxDecoration(color: Colors.transparent),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child:
                  const Icon(Icons.clear, size: 24, color: AppColors.textWhite),
            ),
          ],
        ),
      ),
    );
  }

  _deletePhoto(int sectionIndex, int fieldIndex, int valueIndex) {
    widget.callback?.onDeleteValue(sectionIndex, fieldIndex, valueIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppDimens.kMarginSsmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: _txtTitle,
              style: AppStyles.textCellTitleStyle,
              children: <TextSpan>[
                TextSpan(
                    text: _asterisk,
                    style: AppStyles.textCellTitleBoldStyle
                        .copyWith(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          GestureDetector(
            onTap: () {
              if (modelMedia != null) {
                _showPhotoOptionSheet(
                    widget.indexSection, widget.position, modelMedia!);
              } else {
                _showTakePhotoDialog();
                /* _picker.pickImage(source: ImageSource.gallery).then((value) {
                  final File file = File(value!.path);
                  widget.callback?.onUpdateValue(
                      widget.indexSection, widget.position, file);
                });*/
              }
            },
            child: Container(
              height: 120,
              padding: AppDimens.kHorizontalMarginSsmall,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
                border: Border.all(
                    color: modelMedia == null || modelMedia!.szNote.isEmpty
                        ? AppColors.separatorLineGray
                        : AppColors.unsigned,
                    width: modelMedia == null || modelMedia!.szNote.isEmpty
                        ? 1
                        : 2),
              ),
              child: modelMedia == null || modelMedia!.getUrlString().isEmpty
                  ? Row(
                      children: [
                        Container(
                          padding: AppDimens.kMarginSssmall,
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20 / 2),
                            ),
                          ),
                          child: Image.asset(
                            "assets/images/ic_add.png",
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Add Photo",
                          style: AppStyles.textCellTitleStyle
                              .copyWith(color: AppColors.textGrayDark),
                        )
                      ],
                    )
                  : Image.network(modelMedia!.getUrlString()),
            ),
          ),
        ],
      ),
    );
  }
}
