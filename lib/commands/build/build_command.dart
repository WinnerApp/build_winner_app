import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:build_winner_app/build_id.dart';
import 'package:build_winner_app/commands/base_command.dart';
import 'package:build_winner_app/commands/build/android_command.dart';
import 'package:build_winner_app/commands/build/ios_command.dart';
import 'package:build_winner_app/common/build_config.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/environment.dart';
import 'package:build_winner_app/get_git_log.dart';
import 'package:build_winner_app/setup_fastlane.dart';
import 'package:build_winner_app/update_unity.dart';
import 'package:color_logger/color_logger.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';

class BuildCommand extends Command {
  BuildCommand() {
    addSubcommand(IosCommand());
    addSubcommand(AndroidCommand());
  }
  @override
  String get description => '编译发布最新的安装包';

  @override
  String get name => 'build';

  @override
  FutureOr? run() async {}
}

abstract class BaseBuildCommand extends Command {
  Environment environment = Environment();

  /// Unity工程的全路径
  String get unityFullPath;

  /// 需要复制到对应工程Unity路径
  String get unityFrameworkPath;

  String get platformFileName;

  String get logHeader;

  String get logFooter;

  // String get unityFileName;

  @override
  FutureOr? run() async {
    environment.setup();

    await setupFastlane.setup();

    final buildConfigFilePath =
        File(join(environment.workspace, platformFileName));
    final buildConfigManager =
        BuildConfigManager(filePath: buildConfigFilePath.path);

    final buildConfig = await buildConfigManager.getBuildConfig();

    /// 获取Unity项目的本地提交
    final localUnityCommit = await getGitLastCommitHash(unityFullPath);
    logger.log('本地Unity提交: $localUnityCommit');

    /// 获取网络上最新的Unity提交
    final remoteUnityCommit = await getGitLastCommitHash(unityFullPath);
    logger.log('网络上最新的Unity提交: $remoteUnityCommit');

    final unityBuildId = BuildId(root: unityFullPath);

    /// 获取上一次Unity打包的ID
    final lastUnityBuildId = await unityBuildId.buildId ?? "";
    logger.log('上一次Unity打包的ID: $lastUnityBuildId');

    /// Unity是否需要更新 通过本地和远程的对比 可以防止打包失败了 但是依然需要重新导包
    bool needUpdateUnity = lastUnityBuildId != remoteUnityCommit;

    final fromUnityFrameworkPath =
        join(environment.unityWorkspace, unityFrameworkPath);

    if (!needUpdateUnity && await Directory(fromUnityFrameworkPath).exists()) {
      logger.log('$unityFullPath 不需要更新已经跳过!', status: LogStatus.success);
    } else {
      if (localUnityCommit != remoteUnityCommit) {
        // 更新代码
        await updateGitBranch(unityFullPath);
      }

      /// 导出Unity包
      await updateUnity(unityFullPath);

      await unityBuildId.setBuildId(remoteUnityCommit);
    }

    /// 复制最新的Unity资源
    final toUnityFrameworkPath =
        join(environment.workspace, unityFrameworkPath);

    /// 将最新的Unity复制到打包的项目
    if (await Directory(toUnityFrameworkPath).exists()) {
      await Directory(toUnityFrameworkPath).delete(recursive: true);
    }

    /// 复制缓存到对应的目录
    await runCommand(
      environment.workspace,
      'cp -rf $fromUnityFrameworkPath $toUnityFrameworkPath',
    );

    /// 如果是安卓项目则删除build目录
    final buildUnityDir = Directory(join(toUnityFrameworkPath, 'build'));
    if (await buildUnityDir.exists()) {
      await buildUnityDir.delete(recursive: true);
    }

    final localRootCommit = await getGitLastCommitHash(environment.workspace);
    logger.log('本地项目提交: $localRootCommit');

    final remoteRootCommit = await getGitLastCommitHash(environment.workspace);
    logger.log('网络上最新的项目提交: $remoteRootCommit');

    logger.log('上一次项目打包的ID: ${buildConfig.flutter}');

    bool needUpdateRoot = buildConfig.flutter != remoteRootCommit;
    if (!needUpdateRoot) {
      if (!needUpdateUnity) {
        logger.log('没有任何的变动，打包停止!', status: LogStatus.warning);
        exit(0);
      } else {
        logger.log('${environment.workspace} 不需要更新已经跳过!',
            status: LogStatus.success);
      }
    } else {
      logger.log('正在更新Flutter代码');

      // 更新代码
      await updateGitBranch(environment.workspace);
      logger.log('更新Flutter代码完成', status: LogStatus.success);
    }

    await build(environment.workspace);

    logger.log('正在上传安装包');
    await upload(environment.workspace);
    logger.log('上传安装包完成', status: LogStatus.success);

    /// 发送更新日志到企业微信
    logger.log('正在发送更新日志到企业微信');

    var log = '';

    if (needUpdateUnity) {
      /// 获取Unity更新日志
      final unityLog = await GetGitLog(
        root: environment.unityWorkspace,
        lastCommitId: remoteUnityCommit,
        currentCommitId: buildConfig.unity,
      ).get();

      if (JSON(unityLog).stringValue.isNotEmpty) {
        log += '''
Unity更新日志:
$unityLog

''';
      }
    }

    if (needUpdateRoot) {
      /// 获取当前打包工程的更新日志
      final rootLog = await GetGitLog(
        root: environment.workspace,
        lastCommitId: remoteRootCommit,
        currentCommitId: buildConfig.flutter,
      ).get();

      if (JSON(rootLog).stringValue.isNotEmpty) {
        log += '''
Flutter更新日志:
$rootLog

''';
      }
    }

    log = formatGitLog(log);

    if (log.isNotEmpty) {
      log = '''
$logHeader
-----------------------
$log
-----------------------
$logFooter
''';
      await sendWeChat(log);
      logger.log('发送更新日志到企业微信完成', status: LogStatus.success);

      await sendTextToWeixinWebhooks(log, dingdingHookUrl);

      logger.log('发送更新日志到钉钉完成', status: LogStatus.success);
    }

    await buildConfigManager.setBuildConfig(BuildConfig(
      flutter: remoteRootCommit,
      unity: remoteUnityCommit,
    ));

    logger.log('✅打包完成', status: LogStatus.success);
    exit(0);
  }

  Future updateUnity(String unityPath);

  Future build(String root);

  Future<bool> updateGitBranch(String root) async {
    /// 回滚代码为本地最后提交 防止因为本地改动无法拉取下来
    await runCommand(root, 'git reset --hard');

    /// 获取当前分支名称
    final branchName = await getLocalBranchName(root);

    /// 更新远程仓库
    final result = await runCommand(root, 'git pull origin $branchName')
        .then((value) => value.first);

    if (result.exitCode != 0) {
      logger.log('更新代码失败!', status: LogStatus.error);
      return false;
    }

    logger.log('[$root] 代码已经更新完成', status: LogStatus.success);
    return true;
  }

  Future upload(String root);

  sendWeChat(String log) async {
    await sendTextToWeixinWebhooks(log, hookUrl);
  }

  String get hookUrl;

  SetupFastlane get setupFastlane;

  int get buildNumber => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String get dingdingHookUrl;
}
