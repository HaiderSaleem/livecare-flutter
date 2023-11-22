import 'package:flutter/material.dart';
import 'package:livecare/models/route/dataModel/payload_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteRiderDetailsPopupDialog extends BaseScreen {
  final PayloadDataModel? modelPayload;

  const RouteRiderDetailsPopupDialog({Key? key, required this.modelPayload})
      : super(key: key);

  @override
  _RouteRiderDetailsPopupDialogState createState() =>
      _RouteRiderDetailsPopupDialogState();
}

class _RouteRiderDetailsPopupDialogState
    extends BaseScreenState<RouteRiderDetailsPopupDialog> {
  String _txtName = "";
  String _txtPhone = "";
  String _txtCompanions = "";
  String _txtNotes = "";
  String _txtSpecialNeeds = "";
  bool _iconWarning = false;
  var _nameColor = AppColors.textGray;

  @override
  void initState() {
    super.initState();
    _initUI();
  }

  _initUI() {
    final payload = widget.modelPayload;
    if (payload == null) return;

    setState(() {
      _txtName = payload.modelTransfer.szName;
      _txtPhone = payload.modelTransfer.getBestContactNumber();
      if (payload.modelTransfer.arrayCompanions.isNotEmpty) {
        _txtCompanions = "${payload.modelTransfer.arrayCompanions.length}";
      } else {
        _txtCompanions = "N/A";
      }
      if (payload.modelTransfer.szNotes.isEmpty) {
        _txtNotes = "N/A";
      } else {
        _txtNotes = payload.modelTransfer.szNotes;
      }

      if (payload.modelTransfer.modelSpecialNeeds.requiresCare()) {
        _txtSpecialNeeds =
            payload.modelTransfer.modelSpecialNeeds.getNeedsArray().join("\n");
        _iconWarning = true;
      } else {
        _txtSpecialNeeds = "N/A";
        _iconWarning = false;
      }

      if (payload.enumType == EnumPayloadType.pickup) {
        _nameColor = AppColors.purpleColor;
      } else {
        _nameColor = AppColors.primaryColor;
      }
    });
  }

  Future<void> customLaunch(String command) async {
    if (await canLaunchUrl(Uri.parse(command))) {
      await launchUrl(Uri.parse(command));
    } else {
      UtilsGeneral.log(' could not launch $command');
    }
  }

  _closeDialog() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: AppDimens.kHorizontalMarginSmall,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            padding: AppDimens.kMarginNormal,
            color: AppColors.textWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                      onTap: () {
                        _closeDialog();
                      },
                      child: const Icon(Icons.clear,
                          size: 24, color: AppColors.separatorLineGray)),
                ),
                InkWell(
                  onTap: () {
                    final payload = widget.modelPayload;
                    if (payload == null) return;

                    if (payload.modelTransfer.szPhone.isNotEmpty) {
                      final phoneNumber = UtilsString.beautifyPhoneNumber(
                          payload.modelTransfer.szPhone);
                      customLaunch("tel://" + phoneNumber);
                    } else {
                      UtilsBaseFunction.showAlert(context, "Confirmation",
                          "No phone number found.\nPlease contact administrator.");
                    }
                  },
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppColors.textGray,
                                radius: 35,
                                backgroundImage: ExactAssetImage(
                                    "assets/images/user_default.png"),
                              ),
                              Positioned(
                                right: 3,
                                bottom: 3,
                                child: Image.asset(
                                  'assets/images/ic_call_circle_blue.png',
                                  width: 20,
                                  height: 20,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_txtName,
                              style: AppStyles.boldText
                                  .copyWith(color: _nameColor)),
                          const SizedBox(height: 5),
                          Text(_txtPhone,
                              style: AppStyles.textBlackStyle
                                  .copyWith(color: AppColors.textGray)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 36, color: AppColors.separatorLineGray),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Special Assistance",
                                    style: AppStyles.textBlackStyle
                                        .copyWith(
                                        color: AppColors.textGray),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Visibility(
                                    visible: _iconWarning,
                                    child: Image.asset(
                                      'assets/images/ic_warning_red.png',
                                      width: 16,
                                      height: 16,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(_txtSpecialNeeds,
                                  style: AppStyles.textBlackStyle),
                            ],
                          ),
                        ),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.companies,
                                    style: AppStyles.textBlackStyle
                                        .copyWith(color: AppColors.textGray)),
                                const SizedBox(height: 5),
                                Text(_txtCompanions,
                                    style: AppStyles.textBlackStyle),
                              ],
                            ))
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.notes,
                            style: AppStyles.textBlackStyle
                                .copyWith(color: AppColors.textGray)),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(_txtNotes,
                              style: AppStyles.textBlackStyle),
                        )
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
