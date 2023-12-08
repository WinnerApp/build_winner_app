import 'dart:async';
import 'dart:io';
import 'package:build_winner_app/commands/unity/cache/cache_command.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';
import 'package:path/path.dart';

class CopyCommand extends BaseCacheCommand {
  CopyCommand() {
    argParser.addOption('to', abbr: 't', help: '缓存所在的目标项目地址', mandatory: true);
  }

  @override
  String get description => '复制缓存到其他项目';

  @override
  String get name => 'copy';

  @override
  FutureOr? cacheRun() async {
    final to = argResults?['to'] as String;

    logger.log('删除原始安卓的unity缓存的build目录');
    final androidBuildDir = Directory(join(
      root,
      'android',
      'unityLibrary',
      'build',
    ));
    if (await androidBuildDir.exists()) {
      await androidBuildDir.delete(recursive: true);
    }

    logger.log('删除目标项目untiy ios和安卓缓存');
    final toIosUnityCacheDir = Directory(join(to, 'ios', 'UnityLibrary'));
    if (await toIosUnityCacheDir.exists()) {
      await toIosUnityCacheDir.delete(recursive: true);
    }

    final toAndroidUnityCacheDir =
        Directory(join(to, 'android', 'unityLibrary'));
    if (await toAndroidUnityCacheDir.exists()) {
      await toAndroidUnityCacheDir.delete(recursive: true);
    }

    logger.log('将原iOS的缓存复制到目标项目');
    final iosUnityCacheDir = Directory(join(root, 'ios', 'UnityLibrary'));
    await toIosUnityCacheDir.create(recursive: true);
    await runCommand(
        to, 'cp -rf ${iosUnityCacheDir.path} ${toIosUnityCacheDir.path}');
    logger.log('复制iOS Unity到目录${toIosUnityCacheDir.path}成功!',
        status: LogStatus.success);

    logger.log('将原安卓的缓存复制到目标项目');
    final androidUnityCacheDir =
        Directory(join(root, 'android', 'unityLibrary'));
    await toAndroidUnityCacheDir.create(recursive: true);
    await runCommand(to,
        'cp -rf ${androidUnityCacheDir.path} ${toAndroidUnityCacheDir.path}');
    logger.log('复制android Unity到目录${toAndroidUnityCacheDir.path}成功!',
        status: LogStatus.success);
    logger.log('Success OK!', status: LogStatus.success);
  }
}
