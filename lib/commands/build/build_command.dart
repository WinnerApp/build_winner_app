import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:build_winner_app/commands/build/android_command.dart';
import 'package:build_winner_app/commands/build/ios_command.dart';
import 'package:build_winner_app/common/build_config.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/environment.dart';
import 'package:build_winner_app/get_git_log.dart';
import 'package:build_winner_app/setup_fastlane.dart';
import 'package:build_winner_app/upload_sentry_symbols.dart';
import 'package:color_logger/color_logger.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:path/path.dart';

List<String> dartDefineArgs = [];

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
  BaseBuildCommand() {
    argParser.addFlag('skipUnityUpdate', help: '跳过Unity自动更新!');
    argParser.addOption('tag', help: '当前打包的Tag');
    argParser.addFlag(
      'supportLdClassic',
      help: '是否支持 ld_classic',
      defaultsTo: true,
    );
    argParser.addOption(
      'sentry_properties_path',
      help: 'sentry.properties 的配置文件',
    );
  }

  /// 当前打包运行环境的参数
  Environment environment = Environment();

  /// Unity工程的全路径 如果iOS则是iOSUnity的路径 如果Android则是AndroidUnity的路径
  String? get unityFullPath;

  /// 需要复制到对应工程Unity路径
  String get unityFrameworkPath;

  /// 日志头
  String get logHeader;

  /// 日志尾
  String get logFooter;

  String _log = '';

  String get log => _log;

  @override
  FutureOr? run() async {
    /// 是否跳过Unity自动更新
    final skipUnityUpdate = JSON(argResults?['skipUnityUpdate']).boolValue;
    logger.log('skipUnityUpdate: $skipUnityUpdate', status: LogStatus.debug);

    final tag = JSON(argResults?['tag']).string;
    logger.log('tag: $tag', status: LogStatus.debug);

    final sentryPropertiesPath =
        JSON(argResults?['sentry_properties_path']).string;
    logger.log(
      'sentryPropertiesPath: $sentryPropertiesPath',
      status: LogStatus.debug,
    );

    /// 初始化环境变量 提示用户必须设置对应的环境变量
    environment.setup(!skipUnityUpdate);

    /// 初始化Fastlane 支持后面上传iPA或者APK
    await setupFastlane.setup();

    /// 初始化打包配置管理器
    final buildConfigManager = getBuildConfigManager(
        appwriteEnvironment: environment.appwriteEnvironment);

    /// 本地的Unity提交
    String? localUnityCommit;

    /// 远程的Unity提交
    String? remoteUnityCommit;

    /// 如果不跳过Unity自动更新则获取对应的Uity提交
    if (unityFullPath != null) {
      /// 获取Unity项目的本地提交
      localUnityCommit = await getGitLastCommitHash(unityFullPath!);
      logger.log('本地Unity提交: $localUnityCommit');

      /// 获取网络上最新的Unity提交
      remoteUnityCommit = await getGitLastRemoteCommitHash(unityFullPath!);
      logger.log('网络上最新的Unity提交: $remoteUnityCommit');
    }

    /// 获取当前打包平台的上一次打包配置
    final buildInfo = await buildConfigManager.getBuildConfig();
    // if (buildInfo == null) {
    //   logger.log('打包配置不存在!', status: LogStatus.error);
    //   exit(2);
    // }

    /// 获取上一次Unity打包的ID
    final lastUnityBuildId = buildInfo?.unity.cache;

    /// Unity是否需要更新 通过本地和远程的对比 可以防止打包失败了 但是依然需要重新导包
    bool needUpdateUnity = lastUnityBuildId != remoteUnityCommit &&
        environment.unityEnvironment != null;

    /// 如果当前的分支和目标分支不是一个分支 则切换
    if (await getLocalBranchName(environment.workspace) != environment.branch) {
      await runCommand(
        environment.workspace,
        'git switch ${environment.branch}',
      );
    }

    /// 获取当前本地工程的最后一次提交
    final localRootCommit = await getGitLastCommitHash(environment.workspace);
    logger.log('本地项目提交: $localRootCommit');

    /// 获取当前本地工程的最后一次远程的提交
    final remoteRootCommit = await getGitLastRemoteCommitHash(
      environment.workspace,
    );
    logger.log('网络上最新的项目提交: $remoteRootCommit');

    var log = '';

    /// 如果unity最后一次日志的ID和目前远程的不是一致 并且没有跳过Unity更新
    if (buildInfo?.unity.log != remoteUnityCommit && unityFullPath != null) {
      /// 将Unity更新到最新
      await updateGitBranch(unityFullPath!);

      /// 获取Unity更新日志
      final unityLog = await GetGitLog(
        root: unityFullPath!,
        lastCommitId: remoteUnityCommit!,
        currentCommitId: buildInfo?.unity.log,
      ).get();

      if (JSON(unityLog).stringValue.isNotEmpty) {
        log += '''
Unity更新日志:
$unityLog

''';
      }
    }

    if (buildInfo?.flutter != remoteRootCommit) {
      /// 更新当前打包工程的代码
      await updateGitBranch(environment.workspace);

      /// 获取当前打包工程的更新日志
      final rootLog = await GetGitLog(
        root: environment.workspace,
        lastCommitId: remoteRootCommit,
        currentCommitId: buildInfo?.flutter,
      ).get();

      if (JSON(rootLog).stringValue.isNotEmpty) {
        log += '''
Flutter更新日志:
$rootLog

''';
      }
    }

    /// 格式化当前的日志
    log = formatGitLog(log);

    if (log.isNotEmpty) {
      log = '''
[Branch]: ${environment.branch}
[Tag]: ${tag ?? ''}
[version]: ${environment.buildName}(${environment.buildNumber})
$logHeader
-----------------------
$log
-----------------------
$logFooter
''';

      _log = '[Branch]: ${environment.branch} 新版本发布了，请下载体验!';

      logger.log('''
更新日志:
$log
''', status: LogStatus.warning);
    }

    final unityEnvironment = environment.unityEnvironment;
    if (unityEnvironment != null && unityFullPath != null) {
      /// 原始的对应打包平台Unity的出包位置
      final fromUnityFrameworkPath = join(
        unityEnvironment.unityWorkspace,
        unityFrameworkPath,
      );

      /// 如果需要更新Unity 并且本地的Unity不存在
      if (needUpdateUnity ||
          !await Directory(fromUnityFrameworkPath).exists()) {
        /// 导出Unity包
        await updateUnity(unityEnvironment);
        buildInfo?.unity.cache = remoteUnityCommit!;

        /// 更新当前最后一次Unity缓存的ID
        await buildConfigManager.setBuildConfig(
          buildInfo: buildInfo,
          buildName: environment.buildName,
          buildTime: environment.buildNumber,
        );
      }

      /// 复制最新的Unity包所到的位置
      final toUnityFrameworkPath = join(
        environment.workspace,
        unityFrameworkPath,
      );

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
    }

    /// 判断是否需要更新
    bool needUpdateRoot = buildInfo?.flutter != remoteRootCommit;
    if (!needUpdateRoot && !needUpdateUnity) {
      logger.log('没有任何的变动，打包停止!', status: LogStatus.warning);
      exit(0);
    }

    /// 进行打包
    await build(environment.workspace);

    logger.log('正在上传安装包');
    await upload(environment.workspace);
    logger.log('上传安装包完成', status: LogStatus.success);

    /// 发送更新日志到企业微信
    logger.log('正在发送更新日志到企业微信');
    await sendWeChat(log);
    logger.log('发送更新日志到企业微信完成', status: LogStatus.success);

    logger.log('正在发送更新日志到钉钉');
    await sendTextToWeixinWebhooks(log, dingdingHookUrl);
    logger.log('发送更新日志到钉钉完成', status: LogStatus.success);

    /// 打包完毕更新打包配置
    buildInfo?.flutter = remoteRootCommit;
    if (!skipUnityUpdate) {
      buildInfo?.unity.log = remoteUnityCommit!;
    }
    await buildConfigManager.setBuildConfig(
      buildInfo: buildInfo,
      buildName: environment.buildName,
      buildTime: environment.buildNumber,
    );

    if (sentryPropertiesPath != null) {
      await UploadSentrySymbols(
        environment.workspace,
        sentryPropertiesPath,
        environment.buildName,
        environment.buildNumber.toString(),
      ).run();
    }

    logger.log('✅打包完成', status: LogStatus.success);
    exit(0);
  }

  Future updateUnity(UnityEnvironment unityEnvironment);

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

  // int get buildNumber => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String get dingdingHookUrl;

  BuildInfo getBuildInfo(BuildConfig buildConfig);

  BuildConfigManager getBuildConfigManager(
      {required AppwriteEnvironment appwriteEnvironment});

  init() async {}
}
