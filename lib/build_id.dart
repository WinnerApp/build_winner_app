import 'dart:io';

import 'package:path/path.dart';

class BuildId {
  final String root;
  final String fileName;

  BuildId({required this.root, this.fileName = '.build_id'});
  String get path => join(root, fileName);

  Future<String?> get buildId async {
    if (!await File(path).exists()) {
      return null;
    }
    return File(path).readAsString().then((value) => value.trim());
  }

  Future<void> setBuildId(String buildId) async {
    if (!await File(path).exists()) {
      await File(path).create(recursive: true);
    }
    await File(path).writeAsString(buildId);
  }
}
