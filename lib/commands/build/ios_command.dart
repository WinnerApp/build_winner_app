import 'dart:async';
import 'dart:io';

import 'package:build_winner_app/build_app.dart';
import 'package:build_winner_app/commands/build/build_command.dart';
import 'package:build_winner_app/common/build_config.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/environment.dart';
import 'package:build_winner_app/fix_ios_unity_cache.dart';
import 'package:build_winner_app/setup_fastlane.dart';
import 'package:build_winner_app/update_unity.dart';
import 'package:color_logger/color_logger.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class IosCommand extends BaseBuildCommand {
  @override
  String get description => '打包 ipa 并且上传到TestFlight';

  @override
  String get name => 'ios';

  @override
  Future updateUnity(UnityEnvironment unityEnvironment) async {
    final updateUnity = UpdateUnity(
      workspace: unityEnvironment.iosUnityFullPath,
      unityEnginePath: unityEnvironment.unityEnginePath,
      platform: UnityPlatform.ios,
    );
    final result = await updateUnity.update();
    if (!result) {
      logger.log('导出iOS Unity最新的包失败!', status: LogStatus.error);
      exit(2);
    }
    logger.log('导出iOS Unity最新的包成功!', status: LogStatus.success);

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

  @override
  Future build(String root) async {
    await BuildApp(
      platform: BuildPlatform.ios,
      root: root,
      buildName: environment.buildName,
      buildNumber: environment.buildNumber,
    ).build();
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
  String? get unityFullPath => environment.unityEnvironment?.iosUnityFullPath;

  @override
  String get logHeader => '✅iOS新测试包已经发布!';

  @override
  String get logFooter => '👉请前往TestFlight查看';

  @override
  String get dingdingHookUrl => environment.dingdingIosHookUrl;

  @override
  BuildInfo getBuildInfo(BuildConfig buildConfig) {
    return buildConfig.ios;
  }

  @override
  BuildConfigManager getBuildConfigManager(
      {required AppwriteEnvironment appwriteEnvironment}) {
    return BuildConfigManager(
      environment: appwriteEnvironment,
      platform: 'ios',
    );
  }

  @override
  init() async {
    final supportLdClassic = JSON(argResults?['supportLdClassic']).boolValue;

    /// 是否要去掉ld_classic
    if (!supportLdClassic) {
      final projectPath = join(
          environment.workspace, 'ios', 'Runner.xcodeproj', 'project.pbxproj');
      final contents = await File(projectPath).readAsLines();
      if (!contents.any((value) => value.contains('ld_classic'))) {
        logger.log('已经去掉ld_classic', status: LogStatus.success);
        return;
      }
      contents.removeWhere((element) => element.contains('ld_classic'));
      final newContent = contents.join('\n');
      if (newContent.contains('-ld_classic')) {
        logger.log('ld_classic依然存在', status: LogStatus.error);
        return;
      }
      await File(projectPath).writeAsString(newContent);
    }
  }
}
