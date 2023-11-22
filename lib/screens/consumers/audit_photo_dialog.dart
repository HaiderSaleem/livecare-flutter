import 'package:flutter/material.dart';
import 'package:livecare/models/financialAccount/financial_account_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livecare/screens/consumers/audit_warning_dialog.dart';
import 'dart:io';
import 'package:livecare/screens/consumers/viewModel/audit_view_model.dart';

class AuditPhotoDialog extends BaseScreen {
  final AuditViewModel? vmAudit;

  const AuditPhotoDialog({Key? key, required this.vmAudit}) : super(key: key);

  @override
  _AuditPhotoDialogState createState() => _AuditPhotoDialogState();
}

class _AuditPhotoDialogState extends BaseScreenState<AuditPhotoDialog> {
  final _picker = ImagePicker();
  File? file;

 
  _requestAudit() {
    if (widget.vmAudit == null) return;

    if (widget.vmAudit!.imagePhoto == null) {
      showToast("Please take a photo of the cash");
      return;
    }

    if (widget.vmAudit!.modelAccount == null) {
      showToast("Something went wrong.");
      return;
    }

    showProgressHUD();
    widget.vmAudit!.toDataModel((audit, message) {
      if (audit != null) {
        FinancialAccountManager.sharedInstance.requestAuditForAccount(
            audit, widget.vmAudit!.modelConsumer, widget.vmAudit!.modelAccount!,
            (responseDataModel) {
          hideProgressHUD();
          if (responseDataModel.isSuccess) {
            _closeDialog();
          } else {
            _gotoWarningDialog();
          }
        });
      } else {
        hideProgressHUD();
        showToast(message);
      }
    });
  }

  _gotoWarningDialog() {
    _closeDialog();
    showDialog(
      context: context,
      builder: (BuildContext context) => const AuditWarningDialog(),
    );
  }


  _closeDialog() {
    Navigator.pop(context);
  }

  Future onPicFromCamera() async {
    PickedFile? pickedFile = await _picker.getImage(source: ImageSource.camera);
    final image = File(pickedFile!.path);
    widget.vmAudit!.imagePhoto = image;
    setState(() {
      file = image;
    });
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
            decoration: const BoxDecoration(
              color: AppColors.modalBackground,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            height: AppDimens.kAuditModalHeight,
            width: AppDimens.kAuditModalWidth,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      Image.asset(
                        'assets/images/ic_camera.png',
                        height: 70,
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      const Text(AppStrings.pleaseUseCameraToTakePhotofCash,
                          textAlign: TextAlign.center,
                          style: AppStyles.headingText),
                      const SizedBox(height: 32),
                      file == null
                          ? InkWell(
                              onTap: () {
                                onPicFromCamera();
                              },
                              child: Container(
                                  height: 80,
                                  width: 110,
                                  color: Colors.white,
                                  child: const Icon(
                                    Icons.add,
                                    size: 32,
                                    color: AppColors.textGray,
                                  )),
                            )
                          : InkWell(
                              onTap: () {
                                onPicFromCamera();
                              },
                              child: Container(
                                height: 80,
                                width: 110,
                                color: Colors.white,
                                child: Image.file(file!,
                                    fit: BoxFit.cover, height: 80, width: 110),
                              ),
                            )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _closeDialog();
                          },
                          child: Container(
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(AppStrings.buttonCancel,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.buttonTextStyle),
                            ),
                            color: AppColors.primaryColor,
                            height: AppDimens.kButtonHeight,
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _requestAudit();
                          },
                          child: Container(
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(AppStrings.buttonNext,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.buttonTextStyle),
                            ),
                            color: AppColors.primaryColorDark,
                            height: AppDimens.kButtonHeight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
