import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner(
    'build_winner_app',
    '打包并上传到Testflight/到蒲公英 企业微信通知',
  )..addCommand(BuildWinnerApp());
  await runner.run(arguments);
}

class BuildWinnerApp extends Command {
  BuildWinnerApp() {
    argParser.addOption(
      'root',
      help: '打包项目的路径',
    );
    argParser.addOption(
      'build_name',
      help: '打包的版本比如1.0.0',
    );
  }

  @override
  String get description => '打包并上传到Testflight/到蒲公英 企业微信通知';

  @override
  String get name => 'build';

  @override
  FutureOr? run() async {
    stdout.writeln('欢迎使用棉宇宙自动打包上传Testfligh/到蒲公英 企业微信通知工具');
    final root = argResults?['root'] ?? Platform.environment['PWD']!;

    stdout.writeln('项目路径：$root');

    /// 打包之前需要修改版本
    final buildName = argResults?['build_name'];
    final pubspec = join(root, 'pubspec.yaml');
  }
}
