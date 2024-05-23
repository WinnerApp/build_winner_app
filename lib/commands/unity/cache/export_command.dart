import 'dart:async';
import 'dart:io';

import 'package:build_winner_app/commands/unity/cache/cache_command.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/update_unity.dart';
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
    late UnityPlatform unityPlatform;
    late String workspace;
    if (platform == 'ios') {
      unityPlatform = UnityPlatform.ios;
      workspace = iosUnityDir.path;
    } else {
      unityPlatform = UnityPlatform.android;
      workspace = androidUnityDir.path;
    }
    // /Users/king/Documents/2021.3.16f1c1/Unity.app/Contents/MacOS/unity -quit -batchmode -executeMethod ExportAppData.exportAndroid -nographics -projectPath ./
    // 看到日志[Exiting batchmode successfully now!]代表成功
    await UpdateUnity(
      workspace: workspace,
      unityEnginePath: unity,
      platform: unityPlatform,
    ).update();
    if (platform == 'ios') {
      // FixIosUnityCache(root: )
    }
  }

  @override
  String get name => 'export';
}
