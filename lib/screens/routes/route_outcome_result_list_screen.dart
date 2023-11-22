import 'package:flutter/material.dart';
import 'package:livecare/components/listView/outcome_result_listview.dart';
import 'package:livecare/listeners/outcome_result_listener.dart';
import 'package:livecare/listeners/request_note_popup_listener.dart';
import 'package:livecare/models/route/dataModel/route_data_model.dart';
import 'package:livecare/models/route/transport_route_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/serviceRequests/request_note_popup_dialog.dart';


class OutcomeResultListScreen extends BaseScreen {
  final RouteDataModel? modelRoute;
  final OutcomeResultListener? listener;

  const OutcomeResultListScreen(
      {Key? key, required this.modelRoute, required this.listener})
      : super(key: key);

  @override
  _OutcomeResultListScreenState createState() => _OutcomeResultListScreenState();

}


class _OutcomeResultListScreenState
    extends BaseScreenState<OutcomeResultListScreen>
    with RequestNotePopupListener {
  int _indexSelected = 0;


  _onButtonDoneClick() {
    final route = widget.modelRoute;
    if (route == null) return;

    for (var outcome in route.arrayOutcomeResults) {
      if (outcome.szOutcome.isEmpty) {
        showToast("Please enter notes for all consumers.");
        return;
      }
    }
    showProgressHUD();
    TransportRouteManager.sharedInstance.requestSubmitOutcomeResults(route,
            (responseDataModel) {
          hideProgressHUD();
          if (responseDataModel.isSuccess || responseDataModel.isOffline) {
            widget.listener?.didRouteOutcomeResultScreenDoneClick();
            onBackPressed();
          } else {
            showToast(responseDataModel.beautifiedErrorMessage);
          }
        });
  }

  _onButtonCancelClick() {
    widget.listener?.didRouteOutcomeResultScreenCancelClick();
    onBackPressed();
  }

  _showDialogForNotes() {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          RequestNotePopupDialog(szNotes: "", popupListener: this),
    );
  }


  @override
  didRequestNotePopupCancelClick() {}

  @override
  didRequestNotePopupOkClick(String notes) {
    widget.modelRoute!.arrayOutcomeResults[_indexSelected].szOutcome = notes;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.profileBackground,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text(
          AppStrings.submitOutcomeResults,
          style: AppStyles.textTitleStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: AppDimens.kHorizontalMarginBig.copyWith(left: 0),
            child: GestureDetector(
              onTap: () {
                _onButtonCancelClick();
              },
              child:  const Icon(Icons.clear,
                  size: 24, color: AppColors.primaryColor),
            ),
          )
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 78,
              left: 0,
              right: 0,
              child: OutcomeResultListView(
                modelRoute: widget.modelRoute,
                itemClickListener: (obj, position) {
                  _indexSelected = position;
                  _showDialogForNotes();
                },
              ),

            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: AppDimens.kMarginNormal,
                child: ElevatedButton(
                  style: AppStyles.roundButtonStyle,
                  onPressed: () {
                    _onButtonDoneClick();
                  },
                  child: const Text(
                    AppStrings.done,
                    textAlign: TextAlign.center,
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
