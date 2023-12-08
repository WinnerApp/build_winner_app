import 'dart:async';

import 'package:build_winner_app/commands/unity/cache/cache_command.dart';

class UploadCommand extends BaseCacheCommand {
  UploadCommand() {
    argParser.addOption(
      'cache',
      abbr: 'c',
      help: '缓存所在的目标项目地址 默认为当前目录 /unity/meta-winner-app-unity-cache',
    );
  }

  @override
  FutureOr? cacheRun() async {}

  @override
  String get description => '上传缓存到远程仓库';

  @override
  String get name => 'upload';
}
