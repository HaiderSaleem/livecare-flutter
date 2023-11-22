import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_strings.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class SignaturePad extends BaseScreen {
  final bool forUser;

  const SignaturePad({Key? key, required this.forUser}) : super(key: key);

  @override
  _SignaturePadState createState() => _SignaturePadState();
}

class _SignaturePadState extends BaseScreenState<SignaturePad> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

 
  void _handleClearButtonPressed() {
    signatureGlobalKey.currentState!.clear();
  }

  void _handleSaveButtonPressed() async {
    final data =
        await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    String tempPath = (await getTemporaryDirectory()).path;
    File imgFile = await _writeToFile(bytes!,
        "$tempPath/sign_${DateTime.now().millisecondsSinceEpoch.toString()}.png");
    Navigator.pop(context, imgFile);
  }

  Future<File> _writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.signature,
          style: AppStyles.textCellHeaderStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                _handleClearButtonPressed();
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child:
                      Text(AppStrings.buttonClear, style: AppStyles.buttonTextStyle),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () {
                _handleSaveButtonPressed();
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Text("Done", style: AppStyles.buttonTextStyle),
              ),
            ),
          )
        ],
      ),
      body: SfSignaturePad(
          key: signatureGlobalKey,
          backgroundColor: Colors.white,
          strokeColor: AppColors.shareLightBlue,
          minimumStrokeWidth: 1.0,
          maximumStrokeWidth: 4.0),
    );
  }
}
