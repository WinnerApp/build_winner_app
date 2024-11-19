import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/environment.dart';
import 'package:build_winner_app/fix_ios_unity_cache.dart';
import 'package:build_winner_app/update_unity.dart';
import 'package:color_logger/color_logger.dart';

class ExportCommand extends Command {
  ExportCommand() {
    argParser.addOption(
      'platform',
      abbr: 'p',
      help: '请选择平台',
      allowed: ['ios', 'android'],
      defaultsTo: 'ios',
    );
  }

  @override
  String get description => '导出iOS和安卓的unity包';

  @override
  FutureOr? run() async {
    final platform = argResults?['platform'] ?? 'ios';

    /// 当前打包运行环境的参数
    Environment environment = Environment();
    environment.setup(true);

    final unityEnvironment = environment.unityEnvironment;
    if (unityEnvironment == null) {
      logger.log('unity环境参数为空', status: LogStatus.error);
      exit(1);
    }

    late UnityPlatform unityPlatform;
    late String workspace;
    if (platform == 'ios') {
      unityPlatform = UnityPlatform.ios;
      workspace = unityEnvironment.iosUnityFullPath;
    } else {
      unityPlatform = UnityPlatform.android;
      workspace = unityEnvironment.androidUnityFullPath;
    }

    final updateUnity = UpdateUnity(
      workspace: workspace,
      unityEnginePath: unityEnvironment.unityEnginePath,
      platform: unityPlatform,
    );
    final result = await updateUnity.update();
    if (!result) {
      logger.log('导出$platform Unity最新的包失败!', status: LogStatus.error);
      exit(2);
    }
    logger.log('导出$platform Unity最新的包成功!', status: LogStatus.success);

    if (unityPlatform == UnityPlatform.ios) {
      final fix = FixIosUnityCache(
        root: unityEnvironment.unityWorkspace,
        iosUnityPath: unityEnvironment.iosUnityFullPath,
      );
      final fixResult = await fix.fix();
      if (!fixResult) {
        logger.log('修复iOS失败!', status: LogStatus.error);
        exit(2);
      }
      logger.log('修复iOS成功!', status: LogStatus.success);
    }
  }

  @override
  String get name => 'export';
}
