import 'dart:async';
import 'dart:io';

import 'package:build_winner_app/build_app.dart';
import 'package:build_winner_app/commands/build/build_command.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/fix_ios_unity_cache.dart';
import 'package:build_winner_app/setup_fastlane.dart';
import 'package:build_winner_app/update_unity.dart';
import 'package:color_logger/color_logger.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:yaml/yaml.dart';

class IosCommand extends BaseBuildCommand {
  @override
  String get description => '打包 ipa 并且上传到TestFlight';

  @override
  String get name => 'ios';

  @override
  Future updateUnity(String unityPath) async {
    final updateUnity = UpdateUnity(
      workspace: unityPath,
      unityEnginePath: environment.unityEnginePath,
      platform: UnityPlatform.ios,
    );
    final result = await updateUnity.update();
    if (!result) {
      logger.log('导出iOS Unity最新的包失败!', status: LogStatus.error);
      exit(2);
    }
    logger.log('导出iOS Unity最新的包成功!', status: LogStatus.success);

    final fix = FixIosUnityCache(
      root: environment.workspace,
      iosUnityPath: unityPath,
    );
    final fixResult = await fix.fix();
    if (!fixResult) {
      logger.log('修复iOS失败!', status: LogStatus.error);
      exit(2);
    }
    logger.log('修复iOS成功!', status: LogStatus.success);
  }

  @override
  Future build(String root) async {
    await BuildApp(platform: BuildPlatform.ios, root: root).build();
  }

  @override
  Future upload(String root) async {
    // build/ios/ipa/meta_winner_app.ipa
    final yaml = loadYaml(File(join(root, 'pubspec.yaml')).readAsStringSync());

    final ipaPath = join(root, 'build', 'ios', 'ipa', '${yaml['name']}.ipa');
    if (!await File(ipaPath).exists()) {
      logger.log('$ipaPath路径不存在!', status: LogStatus.error);
      exit(2);
    }
    final result = await runCommand(
            join(root, 'ios'), 'fastlane upload_testflight ipa:"$ipaPath"')
        .then((value) => value.first);
    if (result.exitCode != 0) {
      logger.log('上传失败!', status: LogStatus.error);
      exit(result.exitCode);
    }
  }

  @override
  String get hookUrl => environment.iosHookUrl;

  @override
  SetupFastlane get setupFastlane =>
      SetupIosFastlane(root: environment.workspace);

  @override
  String get unityFrameworkPath => 'ios/UnityLibrary';

  @override
  String get unityFullPath => environment.iosUnityFullPath;

  @override
  String get platformFileName => '.ios_build_id';

  @override
  String get logHeader => '✅iOS新测试包已经发布!';

  @override
  String get logFooter => '👉请前往TestFlight查看';
}
