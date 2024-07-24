import 'dart:io';

import 'package:color_logger/color_logger.dart';
import 'package:path/path.dart';

import 'common/define.dart';

class UploadApk {
  final String root;
  final String? log;

  UploadApk({required this.root, this.log});

  Future upload() async {
    final apkPath = join(
        root, 'build', 'app', 'outputs', 'apk', 'release', 'app-release.apk');
    if (!await File(apkPath).exists()) {
      logger.log('$apkPath路径不存在!', status: LogStatus.error);
      exit(2);
    }
    String command = 'fastlane deploy apk:$apkPath';
    if (log != null) {
      command = '$command changelog:\'$log\'';
    }

    final result = await runCommand(join(root, 'android'), command)
        .then((value) => value.first);
    if (result.exitCode != 0) {
      logger.log('上传失败!', status: LogStatus.error);
      exit(result.exitCode);
    }
  }
}
