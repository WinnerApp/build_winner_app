import 'dart:async';
import 'dart:io';

import 'package:build_winner_app/commands/build/build_command.dart';
import 'package:build_winner_app/common/build_config.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/environment.dart';
import 'package:build_winner_app/fix_ios_unity_cache.dart';
import 'package:build_winner_app/remove_ios_setting_bundle.dart';
import 'package:build_winner_app/set_version_build_number.dart';
import 'package:build_winner_app/setup_fastlane.dart';
import 'package:build_winner_app/update_unity.dart';
import 'package:color_logger/color_logger.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';
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
    final supportLdClassic = JSON(argResults?['supportLdClassic']).boolValue;
    logger.log('supportLdClassic: $supportLdClassic');

    /// 是否要去掉ld_classic
    if (!supportLdClassic) {
      final projectPath = join(
          environment.workspace, 'ios', 'Runner.xcodeproj', 'project.pbxproj');
      var contents = await File(projectPath).readAsString();
      contents = contents.replaceAll('''
				OTHER_LDFLAGS = (
					"\$(inherited)",
					"-ld_classic",
				);
''', '''
				OTHER_LDFLAGS = (
					"\$(inherited)",
				);
''');
      if (contents.contains('ld_classic')) {
        logger.log('去掉ld_classic失败!', status: LogStatus.error);
        exit(2);
      }
      await File(projectPath).writeAsString(contents);

      logger.log('已经去掉ld_classic', status: LogStatus.success);
    }

    if (dartDefineArgs
        .any((element) => element == '--dart-define=isStoreVersion=true')) {
      await RemoveIosSettingBundle(root: root).remove();
      logger.log('移出Setting.bundle 成功!');
    }

    await SetVersionBuildNumber(environment: environment).runInIos();

    await Shell(workingDirectory: environment.iosDir)
        .run('pod install --verbose');

    await Shell(workingDirectory: environment.iosDir).run(
        'xcrun xcodebuild -configuration Release -workspace Runner.xcworkspace -scheme Runner -sdk iphoneos -destination generic/platform=iOS -archivePath ../build/ios/archive/Runner archive');
    await Shell(workingDirectory: environment.iosDir).run(
        'xcrun xcodebuild -exportArchive -archivePath ../build/ios/archive/Runner.xcarchive -exportPath ../build/ios/ipa -exportOptionsPlist exportOptions.plist');
    // await BuildApp(
    //   platform: BuildPlatform.ios,
    //   root: root,
    //   buildName: environment.buildName,
    //   buildNumber: environment.buildNumber,
    // ).build();
  }

  @override
  Future upload(String root) async {
    // build/ios/ipa/meta_winner_app.ipa
    final yaml = loadYaml(
        File(join(environment.flutterDir, 'pubspec.yaml')).readAsStringSync());

    final ipaPath = join(root, 'build', 'ios', 'ipa', '${yaml['name']}.ipa');
    if (!await File(ipaPath).exists()) {
      logger.log('$ipaPath路径不存在!', status: LogStatus.error);
      exit(2);
    }
    final result = await runCommand(environment.iosDir,
            'fastlane upload_testflight ipa:$ipaPath changelog:${environment.branch}')
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
      branch: environment.branch,
    );
  }

  @override
  init() async {}
}
