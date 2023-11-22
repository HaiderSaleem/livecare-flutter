import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livecare/models/user/user_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/settings/viewModel/profile_view_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class SettingsProfileScreen extends BaseScreen {
  const SettingsProfileScreen({Key? key}) : super(key: key);

  @override
  _SettingsProfileScreenState createState() => _SettingsProfileScreenState();
}

class _SettingsProfileScreenState extends BaseScreenState<SettingsProfileScreen> {
  ProfileViewModel vmProfile = ProfileViewModel();
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final _picker = ImagePicker();
  late File _image = File("");

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  bool validateFields() {
    vmProfile.szName = name.text.toString();
    if (vmProfile.szName.isEmpty) {
      showToast("Please enter name");
      return false;
    }
    vmProfile.szPhone = phone.text.toString();
    return true;
  }

  _refreshFields() {
    vmProfile.initializeFromProfile();
    name.text = vmProfile.szName;
    email.text = vmProfile.szEmail;
    phone.text = UtilsString.beautifyPhoneNumber(vmProfile.szPhone);
  }

  updateUserProfile() {
    showProgressHUD();
    UserManager.sharedInstance.requestUpdateUserWithDictionary(vmProfile.serialize(), (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        showToast("Your profile is successfully updated.");
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  onSaveProfile() {
    if (!validateFields()) {
      return;
    }
    if (vmProfile.szPhone.isEmpty && vmProfile.isNotifyBySMS) {
      UtilsBaseFunction.showAlertWithMultipleButton(
          context, "Warning", "You won't be able to receive SMS until you enter phone number.\nAre you sure you want to continue?", updateUserProfile);
    } else {
      updateUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.defaultBackground,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  margin: AppDimens.kMarginNormal.copyWith(top: 0),
                  padding: AppDimens.kMarginNormal,
                  decoration: BoxDecoration(
                    color: AppColors.profileFrame,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Container(
                      //   margin: AppDimens.kMarginNormal,
                      //   child: const Text(
                      //     AppStrings.labelProfileDetail,
                      //     style: AppStyles.rideInformation,
                      //   ),
                      // ),
                      const SizedBox(
                        height: 60,
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Name",
                              style: AppStyles.textGrey,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              height: AppDimens.kEdittextHeight,
                              child: TextFormField(
                                onChanged: (value) {},
                                cursorColor: AppColors.textGray,
                                style: AppStyles.headingValue,
                                keyboardType: TextInputType.name,
                                controller: name,
                                decoration: AppStyles.autoCompleteField,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              AppStrings.email,
                              style: AppStyles.textGrey,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              height: AppDimens.kEdittextHeight,
                              child: TextFormField(
                                enabled: false,
                                cursorColor: AppColors.textGray,
                                controller: email,
                                style: AppStyles.headingValue,
                                decoration: AppStyles.autoCompleteField,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Phone",
                              style: AppStyles.textGrey,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              height: AppDimens.kEdittextHeight,
                              child: TextFormField(
                                cursorColor: AppColors.textGray,
                                onChanged: (value) {},
                                style: AppStyles.headingValue,
                                controller: phone,
                                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                decoration: AppStyles.autoCompleteField,
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              "Notification Preferences",
                              style: AppStyles.textGrey,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  vmProfile.isNotifyByMessage = !vmProfile.isNotifyByMessage;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(20, 0, 15, 0),
                                      child: Image.asset(
                                        vmProfile.isNotifyByMessage ? 'assets/images/rect_selected_gray.png' : 'assets/images/rect_not_selected_gray.png',
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                    const Text(
                                      "Push Notification",
                                      style: AppStyles.textGrey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  vmProfile.isNotifyByEmail = !vmProfile.isNotifyByEmail;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(20, 0, 15, 0),
                                      child: Image.asset(
                                        vmProfile.isNotifyByEmail ? 'assets/images/rect_selected_gray.png' : 'assets/images/rect_not_selected_gray.png',
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                    const Text(
                                      "Email",
                                      style: AppStyles.textGrey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  vmProfile.isNotifyBySMS = !vmProfile.isNotifyBySMS;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(20, 0, 15, 0),
                                      child: Image.asset(
                                        vmProfile.isNotifyBySMS ? 'assets/images/rect_selected_gray.png' : 'assets/images/rect_not_selected_gray.png',
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                    const Text(
                                      "SMS",
                                      style: AppStyles.textGrey,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                      Container(
                        padding: AppDimens.kMarginNormal,
                        child: ElevatedButton(
                          style: AppStyles.roundButtonStyle,
                          onPressed: () {
                            onSaveProfile();
                          },
                          child: const Text(
                            AppStrings.buttonSave,
                            textAlign: TextAlign.center,
                            style: AppStyles.buttonTextStyle,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Stack(
                    children: [
                      _image.path.isEmpty
                          ? vmProfile.szPhoto.isEmpty
                              ? const CircleAvatar(
                                  backgroundColor: AppColors.textGray, radius: 40, backgroundImage: AssetImage("assets/images/user_default.png"))
                              : ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(60)),
                                  child: Image.network(
                                    vmProfile.szPhoto,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.fill,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 80,
                                        width: 80,
                                        padding: const EdgeInsets.all(5),
                                        color: AppColors.separatorLineWhite,
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                )
                          : ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(60)),
                              child: Image.file(
                                _image,
                                height: 80,
                                width: 80,
                                fit: BoxFit.fill,
                              ),
                            ),
                      Positioned(
                          top: 40,
                          left: 40,
                          child: IconButton(
                            iconSize: 5,
                            onPressed: () {
                              _showTakePhotoDialog();
                            },
                            icon: Image.asset("assets/images/ic_edit_circle_blue.png"),
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _showTakePhotoDialog() {
    UtilsBaseFunction.showImagePicker(context, _takePhotoFromCamera, _choosePhotoFromGallery);
  }

  uploadProfilePhoto() {
    showProgressHUD();
  }

  photoUpdate() {
    showProgressHUD();
    UserManager.sharedInstance.requestUpdateUserPhoto(_image, (responseDataModel) {
      hideProgressHUD();
      if (responseDataModel.isSuccess) {
        showToast("Your profile photo is successfully updated.");
        var url = UtilsString.parseString(responseDataModel.payload["url"]);
        vmProfile.szPhoto = url;
      } else {
        showToast(responseDataModel.beautifiedErrorMessage);
      }
    });
  }

  Future _choosePhotoFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      setState(() {
        _image = file;
        photoUpdate();
      });
    }
  }

  Future _takePhotoFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      setState(() {
        _image = file;
        photoUpdate();
      });
    }
  }
}
