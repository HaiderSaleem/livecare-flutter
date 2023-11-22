import 'package:flutter/material.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/shared/companion_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/settings/setting_companion_details_screen.dart';

class SettingCompanionListScreen extends BaseScreen {
  final ConsumerDataModel? modelConsumer;
  final bool selector;
  final List<CompanionDataModel> arrayConsumerCompanions;

  final SettingsCompanionsListListener? mListener;

  const SettingCompanionListScreen(
      {Key? key,
      required this.modelConsumer,
      required this.selector,
      required this.arrayConsumerCompanions,
      required this.mListener})
      : super(key: key);

  @override
  _SettingCompanionListScreenState createState() =>
      _SettingCompanionListScreenState();
}

class _SettingCompanionListScreenState
    extends BaseScreenState<SettingCompanionListScreen> {
  List<CompanionDataModel> arrayCompanions = [];
  List<bool> arraySelected = [];

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  _reloadData() {
    final consumer = widget.modelConsumer;
    if (consumer == null) return;

   /* for (var consumer in arrayConsumers) {
      arrayCompanions.addAll(consumer.arrayCompanions);
    }*/
    arrayCompanions = consumer.arrayCompanions;

    arraySelected = [];
    for (var companion in arrayCompanions) {
      bool found = false;
      for (var selectedCompanion in widget.arrayConsumerCompanions) {
        if (companion.id == selectedCompanion.id) {
          found = true;
          break;
        }
      }
      arraySelected.add(found);
    }
    setState(() {});
  }

  _gotoCompanionDetailsScreen(int index) {
    Navigator.push(
      context,
      createRoute(SettingCompanionDetailsScreen(
        modelConsumer: widget.modelConsumer,
        modelCompanion: (index == -1) ? null : arrayCompanions[index],
      )),
    ).then((value) {
      _reloadData();
    });
  }

  _onSaveClicked() {
    int index = 0;
    final List<CompanionDataModel> selectedCompanions = [];
    for (var companion in arrayCompanions) {
      if (arraySelected[index]) {
        selectedCompanions.add(companion);
      }
      index += 1;
    }
    widget.mListener?.didSettingsCompanionsListSelected(
        widget.modelConsumer!, selectedCompanions);
    onBackPressed();
  }

  _editCompanionBottomSheet(BuildContext context, int index) {
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
                    "Edit",
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _gotoCompanionDetailsScreen(index);
                  },
                ),
              ),
              const Divider(height: 0.5, color: Colors.transparent),
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
                    arraySelected[index] ? "Deselect" : "Select",
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      arraySelected[index] = !arraySelected[index];
                    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.titleSettings,
          style: AppStyles.textCellHeaderStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                _onSaveClicked();
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text(AppStrings.buttonSave,
                    style: AppStyles.buttonTextStyle),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _gotoCompanionDetailsScreen(-1);
        },
        child: const Icon(Icons.add, size: 30),
        backgroundColor: AppColors.buttonBackground,
      ),
      body: Container(
        child: arrayCompanions.isEmpty
            ? Center(
                child: Text(
                  "No companions found.",
                  style: AppStyles.tripInformation
                      .copyWith(color: AppColors.textBlack),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                padding: AppDimens.kVerticalMarginSmall,
                itemCount: arrayCompanions.length,
                itemBuilder: (BuildContext context, int index) {
                  final companion = arrayCompanions[index];
                  return GestureDetector(
                    onTap: () {
                      _editCompanionBottomSheet(context, index);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          decoration: const BoxDecoration(
                              color: AppColors.textWhite,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.separatorLineGray,
                                  blurRadius: 5.0,
                                ),
                              ],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          width: MediaQuery.of(context).size.width,
                          padding: AppDimens.kMarginNormal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: AppColors.textGray,
                                    radius: 35,
                                    backgroundImage: ExactAssetImage(
                                        "assets/images/user_default.png"),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(companion.szName,
                                          style: AppStyles.boldText.copyWith(
                                              color: AppColors.primaryColor)),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.5,
                                        child: Text(
                                            companion.modelSpecialNeeds
                                                .getNeedsArray().join(", "),
                                            style: AppStyles.textBlackStyle
                                                .copyWith()))
                                    ],
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Visibility(
                                      visible: widget.selector,
                                      child: Align(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: InkWell(
                                                child: Image.asset(
                                                    arraySelected[index]
                                                        ? "assets/images/ic_circle_checked_blue.png"
                                                        : "assets/images/circle_not_selected_blue.png",
                                                    width: 24,
                                                    height: 24),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10)
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

abstract class SettingsCompanionsListListener {
  didSettingsCompanionsListSelected(ConsumerDataModel modelConsumer,
      List<CompanionDataModel> selectedCompanions);
}
