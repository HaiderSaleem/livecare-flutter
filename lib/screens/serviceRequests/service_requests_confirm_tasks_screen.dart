import 'package:flutter/material.dart';
import 'package:livecare/components/listView/confirm_task_listview.dart';
import 'package:livecare/listeners/request_confirm_task_listener.dart';
import 'package:livecare/models/communication/network_reachability_manager.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/dataModel/task_data_model.dart';
import 'package:livecare/models/request/service_request_manager.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';

class ServiceRequestsConfirmTasksScreen extends BaseScreen {
  final RequestDataModel? modelRequest;
  final RequestConfirmTaskListener? listener;

  const ServiceRequestsConfirmTasksScreen(
      {Key? key, required this.modelRequest, required this.listener}) : super(key: key);

  @override
  _ServiceRequestsConfirmTasksScreenState createState() =>
      _ServiceRequestsConfirmTasksScreenState();
}

class _ServiceRequestsConfirmTasksScreenState
    extends BaseScreenState<ServiceRequestsConfirmTasksScreen> {
  List<TaskDataModel> _arrayTasks = [];
  final List<EnumTaskStatus> _arrayStatus = [];

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  _reloadData() {
    setState(() {
      final request = widget.modelRequest;
      if (request == null) return;
      _arrayTasks = request.arrayTasks;
      for (var task in request.arrayTasks) {
        _arrayStatus.add(task.enumStatus);
      }
    });
  }
  _updateTasks() {
    final request = widget.modelRequest;
    if (request == null) return;
    int index = 0;

    for (var task in _arrayTasks) {
      task.enumStatus = _arrayStatus[index];
      index += 1;
    }
    if (NetworkReachabilityManager.sharedInstance.isConnected()) {
      showProgressHUD();
      ServiceRequestManager.sharedInstance.requestUpdateRequest(
          request, request.serializeForUpdateService(), EnumRequestType.service,
          (responseDataModel) {
        hideProgressHUD();
        if (responseDataModel.isSuccess) {
          onBackPressed();
          widget.listener?.didRequestConfirmTaskDoneClick();
        } else {
          showToast(responseDataModel.beautifiedErrorMessage);
        }
      });
    } else {
      //Call API with null callback to queue request
      ServiceRequestManager.sharedInstance.requestUpdateRequest(request,
          request.serializeForUpdateService(), EnumRequestType.service, null);
      ServiceRequestManager.sharedInstance.updateRequestOffline(request, null);
      onBackPressed();
      widget.listener?.didRequestConfirmTaskDoneClick();
    }
  }

  _onButtonDoneClick() {
    _updateTasks();
  }

  _onButtonCancelClick() {
    onBackPressed();
    widget.listener?.didRequestConfirmTaskCancelClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.profileBackground,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text(
          "Confirm Tasks",
          style: AppStyles.textTitleStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: AppDimens.kHorizontalMarginBig.copyWith(left: 0),
            child: GestureDetector(
              onTap: () {
                _onButtonCancelClick();
              },
              child: const Icon(Icons.clear,
                  size: 24, color: AppColors.primaryColor),
            ),
          )
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: ConfirmTaskListView(
                arrayTasks: _arrayTasks,
                arrayStatus: _arrayStatus,
                itemClickListener: (obj, position) {
                  final status = _arrayStatus[position];
                  setState(() {
                    if (status == EnumTaskStatus.newTask) {
                      _arrayStatus[position] = EnumTaskStatus.completed;
                    } else {
                      _arrayStatus[position] = EnumTaskStatus.newTask;
                    }
                  });
                },
              ),
            ),
            Container(
              padding: AppDimens.kMarginNormal,
              child: ElevatedButton(
                style: AppStyles.roundButtonStyle,
                onPressed: () {
                  _onButtonDoneClick();
                },
                child: const Text(
                  "Done",
                  textAlign: TextAlign.center,
                  style: AppStyles.buttonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
