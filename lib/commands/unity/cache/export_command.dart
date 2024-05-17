import 'dart:async';
import 'dart:io';

import 'package:build_winner_app/commands/unity/cache/cache_command.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';

class ExportCommand extends BaseCacheCommand {
  ExportCommand() {
    argParser.addOption(
      'platform',
      abbr: 'p',
      help: '请选择平台',
      allowed: ['ios', 'android'],
      defaultsTo: 'ios',
    );
    argParser.addOption(
      'unity',
      abbr: 'u',
      help: 'unity版本对应执行文件路径',
    );
  }

  @override
  String get description => '导出iOS和安卓的unity包';

  @override
  FutureOr? cacheRun() async {
    final platform = argResults?['platform'] ?? 'ios';
    final unity = argResults?['unity'];
    if (unity == null) {
      logger.log('unity版本对应执行文件路径不能为空', status: LogStatus.error);
      exit(1);
    }
    late String exportMethod;
    late String workspace;
    if (platform == 'ios') {
      exportMethod = 'ExportAppData.exportIOS';
      workspace = iosUnityDir.path;
    } else {
      exportMethod = 'ExportAppData.exportAndroid';
      workspace = androidUnityDir.path;
    }
    // /Users/king/Documents/2021.3.16f1c1/Unity.app/Contents/MacOS/unity -quit -batchmode -executeMethod ExportAppData.exportAndroid -nographics -projectPath ./
    // 看到日志[Exiting batchmode successfully now!]代表成功
    bool success = false;

    final stdoutController = StreamController<List<int>>.broadcast();
    stdoutController.stream.listen((event) {
      final content = String.fromCharCodes(event);
      if (content.contains('[Exiting batchmode successfully now!]')) {
        success = true;
      }
    });

    final result = await runCommand(
      workspace,
      '$unity -quit -batchmode -executeMethod $exportMethod -nographics -projectPath ./',
      ignoreError: true,
      verbose: true,
      stdout: stdoutController.sink,
    ).then((value) => value.first);
    if (success) exit(0);
    logger.log(result.stderr, status: LogStatus.error);
    exit(2);
  }

  @override
  String get name => 'export';
}
