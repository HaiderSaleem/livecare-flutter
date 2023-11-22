import 'dart:io';

import 'package:livecare/resources/app_strings.dart';
import 'package:path_provider/path_provider.dart';

class UtilsFile {
  static Future<Directory> getFileDirectory() async {
    Directory dir = await getApplicationSupportDirectory();
    final path = Directory('${dir.path}/${AppStrings.appName}');
    if (await path.exists()) {
      return path;
    } else {
      return path.create(recursive: true);
    }
  }

  static Future<File> createPNGFile(String filename) async {
    Directory dir = await getFileDirectory();
    String path = dir.path;
    return File('$path/$filename.png');
  }


}
