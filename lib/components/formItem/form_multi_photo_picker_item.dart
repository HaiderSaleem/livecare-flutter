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

class FormMultiPhotoPickerItem extends BaseScreen {
  final FormSectionDataModel? modelSection;
  final int indexSection;
  final int position;
  final FormDetailsListener? callback;

  const FormMultiPhotoPickerItem(
      {Key? key,
      required this.modelSection,
      required this.indexSection,
      required this.position,
      required this.callback}) : super(key: key);

  @override
  _FormMultiPhotoPickerItemState createState() =>
      _FormMultiPhotoPickerItemState();
}

class _FormMultiPhotoPickerItemState extends BaseScreenState<FormMultiPhotoPickerItem> {
  final _picker = ImagePicker();

  List<MediaDataModel> arrayMedia = [];
  String _txtTitle = "";
  String _asterisk = "";
  late File _image = File("");


  _showTakePhotoDialog() {
    UtilsBaseFunction.showImagePicker(context, _takePhotoFromCamera, _choosePhotoFromGallery);
  }

  Future _choosePhotoFromGallery() async {
    _picker.pickMultiImage().then((values) {
      List<File> images = [];
      for (var item in values) {
        final File file = File(item.path);
        images.add(file);
      }
      widget.callback?.onUpdateValue(
          widget.indexSection, widget.position, images);

    });
  }

  Future _takePhotoFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      setState(() {
        _image = file;
        widget.callback?.onUpdateValue(
            widget.indexSection, widget.position, _image);
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _initUI();
  }

  @override
  void didUpdateWidget(FormMultiPhotoPickerItem oldWidget) {
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
    arrayMedia = [];
    if (field.parsedObject is List<MediaDataModel>) {
      arrayMedia = field.parsedObject as List<MediaDataModel>;
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
          Column(
            children: [
              GestureDetector(
                onTap: () async {
                  _showTakePhotoDialog();
                },
                child: Container(
                  height: 50,
                  padding: AppDimens.kHorizontalMarginSsmall,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                    border: Border.all(color: AppColors.separatorLineGray),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        "Add Photos",
                        style: AppStyles.textCellTitleStyle
                            .copyWith(color: AppColors.textGrayDark),
                      )
                    ],
                  ),
                ),
              ),
              arrayMedia.isEmpty
                  ? Container()
                  : GridView.builder(
                      padding:
                          AppDimens.kVerticalMarginSmall.copyWith(bottom: 0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                        maxCrossAxisExtent: 100,
                      ),
                      itemCount: arrayMedia.length,
                      itemBuilder: (BuildContext ctx, index) {
                        final modelMedia = arrayMedia[index];
                        return GestureDetector(
                          onTap: () {
                            _showPhotoOptionSheet(widget.indexSection,
                                widget.position, modelMedia,
                                valueIndex: index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                              border: Border.all(
                                  color: modelMedia.szNote.isEmpty
                                      ? AppColors.separatorLineGray
                                      : AppColors.unsigned,
                                  width: modelMedia.szNote.isEmpty ? 1 : 2),
                            ),
                            child: Image.network(modelMedia.getUrlString()),
                          ),
                        );
                      },
                    )
            ],
          ),
        ],
      ),
    );
  }
}
