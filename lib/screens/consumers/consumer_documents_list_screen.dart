import 'package:flutter/material.dart';
import 'package:livecare/components/listView/consumer_document_listview.dart';
import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/consumer/dataModel/document_data_model.dart';
import 'package:livecare/resources/app_colors.dart';
import 'package:livecare/resources/app_dimens.dart';
import 'package:livecare/resources/app_styles.dart';
import 'package:livecare/screens/base/base_screen.dart';
import 'package:livecare/screens/settings/setting_webview_screen.dart';

class ConsumerDocumentsListScreen extends BaseScreen {
  final ConsumerDataModel? modelConsumer;

  const ConsumerDocumentsListScreen({Key? key, required this.modelConsumer})
      : super(key: key);

  @override
  _ConsumerDocumentsListScreenState createState() =>
      _ConsumerDocumentsListScreenState();
}

class _ConsumerDocumentsListScreenState
    extends BaseScreenState<ConsumerDocumentsListScreen> {
  List<DocumentDataModel> _arrayDocuments = [];

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  _reloadData() {
    final consumer = widget.modelConsumer;
    if (consumer == null) return;
    setState(() {
      _arrayDocuments = consumer.arrayDocuments;
    });
  }

  _openDocumentOnWebFragment(DocumentDataModel document) async {
    final consumer = widget.modelConsumer;
    if (consumer == null) return;

    final String urlString = UrlManager.consumerApi.getMediaWithId(
        consumer.organizationId,
        consumer.id,
        document.documentId,
        document.modelMedia!.id);

    Navigator.push(
      context,
      createRoute(SettingWebViewScreen(
        szTitle: document.modelMedia!.szFileName,
        szUrl: urlString,
        tokenRequired: true,
      )),
    );
  }
  _onButtonCancelClick() {
    onBackPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.profileBackground,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text(
          "Consumer Documents",
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
        child: ConsumerDocumentListView(
          arrayDocuments: _arrayDocuments,
          itemClickListener: (document, position) {
            _openDocumentOnWebFragment(document);
          },
        ),
      ),
    );
  }
}
