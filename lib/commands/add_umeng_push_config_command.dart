import 'dart:io';

import 'package:build_winner_app/add_umeng_push_config.dart';
import 'package:color_logger/color_logger.dart';
import 'package:dart_ops_engine/dart_ops_engine.dart';

class AddUmengPushConfigCommand extends ActionRun {
  @override
  Future<Map> run(Env env, Map request) async {
    String read(String name) {
      final value = request[name];
      if (value == null) {
        logger.log('$name 未配置', status: LogStatus.error);
        exit(1);
      }
      return value;
    }

    final root = read('root');
    final umengAppKey = read('umengAppKey');
    final umengMessageSecret = read('umengMessageSecret');
    final umengChannel = read('umengChannel');
    await AddUmengPushConfig(
      root: root,
      umengAppKey: umengAppKey,
      umengMessageSecret: umengMessageSecret,
      umengChannel: umengChannel,
    ).add();
    return {};
  }
}
