import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:build_winner_app/upload_apk.dart';

class UploadApkChannel extends Command {
  UploadApkChannel() {
    argParser.addOption('workspce', help: '工作目录');
  }

  @override
  String get description => '上传Apk到指定的频道';

  @override
  String get name => 'upload_apk_channel';

  @override
  FutureOr? run() => UploadApk(root: argResults?['workspce']).upload();
}
