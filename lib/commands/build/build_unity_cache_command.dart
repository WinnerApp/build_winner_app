import 'dart:async';
import 'dart:io';

import 'package:build_winner_app/commands/base_command.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:path/path.dart';

class BuildUnityCacheCommand extends BaseCommand {
  BuildUnityCacheCommand() {
    argParser.addOption('platform',
        abbr: 'p', help: '请选择平台', allowed: ['ios', 'android']);
    argParser.addOption('buildType',
        abbr: 'b', help: '请选择打包类型', allowed: ['debug', 'release']);
    argParser.addOption('root',
        abbr: 'r', help: '项目根目录', defaultsTo: Platform.environment['PWD']!);
  }

  @override
  String get description => '根据当前Unity工程进行导包';

  @override
  String get name => 'build_unity_cache';

  @override
  FutureOr? run() async {
    final platform = JSON(argResults?['platform']).stringValue;
    final buildType = JSON(argResults?['buildType']).stringValue;
    final root = JSON(argResults?['root']).stringValue;
    final assetPath = join(root, 'ProjectSettings', 'ProjectSettings.asset');
    if (platform == 'ios') {
      final contents = await File(assetPath).readAsLines();
      for (int i = 0; i < contents.length; i++) {
        var content = contents[i];
        if (content.contains('selectedPlatform:')) {
          contents[i] = 'selectedPlatform: ${buildType == 'debug' ? 3 : 2}';
        }
      }
      await File(assetPath).writeAsString(contents.join('\n'));
      if (buildType == 'debug') {
        final clrData = Directory(join(root, 'HybridCLRData'));
        if (await clrData.exists()) {
          await clrData.delete(recursive: true);
        }
      }
    }
  }
}
