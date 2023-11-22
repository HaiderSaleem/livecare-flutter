import 'package:livecare/models/communication/url_manager.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class MediaDataModel {
  String id = "";
  String organizationId = "";
  EnumMediaMimeType enumType = EnumMediaMimeType.png;
  String routeId = "";
  String requestId = "";
  String formId = "";
  String szFileName = "";
  String szEncoding = "";
  int nSize = 0;
  String szNote = "";
  String mediaId = "";
  String szOriginalName = "";
  String? szDownloadedUrl;

  // extra property. used for different purposes, same as tag of UIButton
  int tag = 0;

  initialize() {
    id = "";
    organizationId = "";
    enumType = EnumMediaMimeType.png;
    requestId = "";
    formId = "";
    szFileName = "";
    szEncoding = "";
    nSize = 0;
    szNote = "";
    mediaId = "";
    szOriginalName = "";
    szDownloadedUrl = null;

    tag = 0;
  }

  bool isValid() {
    return id.isNotEmpty && mediaId.isNotEmpty;
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "id")) {
      id = UtilsString.parseString(dictionary["id"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "organizationId")) {
      organizationId = UtilsString.parseString(dictionary["organizationId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "routeId")) {
      routeId = UtilsString.parseString(dictionary["routeId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "requestId")) {
      requestId = UtilsString.parseString(dictionary["requestId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "formId")) {
      formId = UtilsString.parseString(dictionary["formId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "mediaId")) {
      mediaId = UtilsString.parseString(dictionary["mediaId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "mimeType")) {
      enumType = MediaMimeTypeExtension.fromString(
          UtilsString.parseString(dictionary["mimeType"]));
    }
    if (UtilsBaseFunction.containsKey(dictionary, "fileName")) {
      szFileName = UtilsString.parseString(dictionary["fileName"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "originalName")) {
      szOriginalName = UtilsString.parseString(dictionary["originalName"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "encoding")) {
      szEncoding = UtilsString.parseString(dictionary["encoding"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "size")) {
      nSize = UtilsString.parseInt(dictionary["size"], 0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "note")) {
      szNote = UtilsString.parseString(dictionary["note"]);
    }

    if (id.isEmpty) {
      id = mediaId;
    } else if (mediaId.isEmpty) {
      mediaId = id;
    }
  }

  String getUrlString() {
    if (routeId.isNotEmpty) {
      return UrlManager.routeFormsApi
          .getMediaWithId(organizationId, routeId, formId, mediaId);
    } else if (requestId.isNotEmpty) {
      return UrlManager.serviceRequestFormsApi
          .getMediaWithId(organizationId, requestId, formId, mediaId);
    }
    return "";
  }

  String getSafeFileName() {
    /// For safe download, we need to replace all special characters by '-'
    var safeName = szFileName.split("[-+.^:,]").join("-");
    safeName = safeName.replaceAll(" ", "-");
    return safeName;
  }

  Map<String, dynamic> serializeForCreateTransactionMedia() {
    return {
      "organizationId": organizationId,
      "mediaId": id,
      "mimeType": enumType.value,
      "fileName": szFileName,
      "encoding": szEncoding,
      "size": nSize,
      "note": szNote
    };
  }

  Map<String, dynamic> serializeForCreateFormMedia() {
    return {
      "organizationId": organizationId,
      "routeId": routeId,
      "requestId": requestId,
      "formId": formId,
      "mediaId": id,
      "mimeType": enumType,
      "fileName": szFileName,
      "encoding": szEncoding,
      "size": nSize,
      "note": szNote
    };
  }

  String getBeautifiedFileSize() {
    final int bytes = nSize;
    if (bytes < 1000) {
      return "$bytes B";
    }
    final double kb = bytes.toDouble() / 1024.0;
    if (kb < 1000) {
      return "${kb.toStringAsFixed(1)} KB";
    }
    final double mb = kb / 1024.0;
    if (mb < 1000) {
      return "${mb.toStringAsFixed(1)} MB";
    }
    final double gb = mb / 1024.0;
    return "${gb.toStringAsFixed(1)} GB";
  }
}

enum EnumMediaMimeType { png, jpg, pdf }

extension MediaMimeTypeExtension on EnumMediaMimeType {
  static EnumMediaMimeType fromString(String? string) {
    if (string == null || string.isEmpty) return EnumMediaMimeType.png;

    if (string.toLowerCase() == EnumMediaMimeType.png.value.toLowerCase()) {
      return EnumMediaMimeType.png;
    } else if (string.toLowerCase() ==
        EnumMediaMimeType.jpg.value.toLowerCase()) {
      return EnumMediaMimeType.jpg;
    } else if (string.toLowerCase() ==
        EnumMediaMimeType.pdf.value.toLowerCase()) {
      return EnumMediaMimeType.pdf;
    }
    return EnumMediaMimeType.png;
  }

  String get value {
    switch (this) {
      case EnumMediaMimeType.png:
        return "image/png";
      case EnumMediaMimeType.jpg:
        return "image/jpg";
      case EnumMediaMimeType.pdf:
        return "application/pdf";
    }
  }
}
