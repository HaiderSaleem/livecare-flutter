
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';

class UtilsBaseFunction {

  static bool containsKey(Map<String, dynamic>? json, String key) {
    if (json == null || key.isEmpty) return false;
    if (json.containsKey(key) && json[key] != null) return true;
    return false;
  }

  static showAlert(BuildContext context, String title, String message, [buttonHandler]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => buttonHandler ?? Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static showAlertWithMultipleButton(
      BuildContext context, String title, String message, onYes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onYes();
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

  static removeItemBottomSheet(BuildContext context, onRemove) {
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
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                child: ListTile(
                  title: const Text(
                    AppStrings.buttonRemove,
                    textAlign: TextAlign.center,
                    style: AppStyles.dialogbutton,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onRemove();
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


  static showImagePicker(BuildContext context, onCamera, onGallery) {
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
                    AppStrings.userGallery,
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onGallery();
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
                  title: const Text(
                    AppStrings.useCamera,
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onCamera();
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

  static showRidePopup(BuildContext context, onServiceRequest, onTransportationRequest) {
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
                   AppStrings.homeService,
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onServiceRequest();
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
                  title: const Text(
                    AppStrings.transportation,
                    textAlign: TextAlign.center,
                    style: AppStyles.bottomMenuText,),
                  onTap: () {
                    Navigator.pop(context);
                    onTransportationRequest();
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

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

}
