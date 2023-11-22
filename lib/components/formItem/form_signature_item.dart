import 'dart:io';

import 'package:flutter/material.dart';
import 'package:livecare/components/signature_pad.dart';
import 'package:livecare/listeners/form_details_listener.dart';
import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class FormSignatureItem extends BaseScreen {
  final FormSectionDataModel? modelSection;
  final int indexSection;
  final int position;
  final FormDetailsListener? callback;

  const FormSignatureItem(
      {Key? key,
      required this.modelSection,
      required this.indexSection,
      required this.position,
      required this.callback})
      : super(key: key);

  @override
  _FormSignatureItemState createState() => _FormSignatureItemState();
}

class _FormSignatureItemState extends BaseScreenState<FormSignatureItem> {
  MediaDataModel? modelMedia;
  String _txtTitle = "";
  String _asterisk = "";

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  @override
  void didUpdateWidget(FormSignatureItem oldWidget) {
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
            onTap: () async {
              final data = await Navigator.push(
                context,
                createRoute(
                  const SignaturePad(
                    forUser: false,
                  ),
                ),
              );
              if (data == null) return;
              final File file = data as File;
              widget.callback
                  ?.onUpdateValue(widget.indexSection, widget.position, file);
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
                border: Border.all(color: AppColors.separatorLineGray),
              ),
              child: modelMedia == null || modelMedia!.getUrlString().isEmpty
                  ? Column(
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
                          height: 8,
                        ),
                        Text(
                          "Add Signature",
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
