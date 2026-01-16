import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:build_winner_app/commands/unity/cache/generate_command.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';
import 'package:path/path.dart';

class CacheCommand extends Command {
  CacheCommand() {
    // addSubcommand(CopyCommand());
    addSubcommand(GenerateCommand());
    // addSubcommand(ExportCommand());
  }

  @override
  String get description => '操作Unity缓存';

  @override
  String get name => 'cache';
}

abstract class BaseCacheCommand extends Command {
  BaseCacheCommand() {
    argParser.addOption(
      'root',
      abbr: 'r',
      help: '项目根目录，默认为当前目录',
    );
    argParser.addOption(
      'iosUnityPath',
      abbr: 'i',
      help: 'iOS项目的Unity路径,默认为【unity/meta_winner_unity_ios】',
    );
    argParser.addOption(
      'androidUnityPath',
      abbr: 'a',
      help: 'Android项目的Unity路径,默认为【unity/meta_winner_unity_android】',
    );
  }

  late Directory iosUnityDir;
  late Directory androidUnityDir;
  late String root;

  @override
  FutureOr? run() async {
    for(var key in Platform.environment.keys) {
      print('$key: ${Platform.environment[key]}');
    }
    /// 获取操作缓存的项目主目录
    root = argResults?['root'] ?? Platform.environment['PWD'] ?? "";
    if (root.isEmpty) {
      logger.log('项目根目录不能为空!', status: LogStatus.error);
      exit(1);
    }

    final iosUnityPath =
        Platform.environment["IOS_UNITY_PATH"] ?? "";
    final androidUnityPath = Platform.environment["ANDROID_UNITY_PATH"] ?? "";
    iosUnityDir = Directory(join(root, iosUnityPath));
    if (!await iosUnityDir.exists()) {
      logger.log('${iosUnityDir.path}路径不存在!', status: LogStatus.error);
      exit(1);
    }

    androidUnityDir = Directory(join(root, androidUnityPath));
    if (!await androidUnityDir.exists()) {
      logger.log('${androidUnityDir.path}路径不存在!', status: LogStatus.error);
      exit(1);
    }
    await cacheRun();
  }

  FutureOr? cacheRun();
}
