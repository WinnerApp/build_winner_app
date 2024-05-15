import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';
// import 'package:dart_ops_engine/dart_ops_engine.dart' hide logger;

class SendTextToWebHooksCommand extends Command {
  SendTextToWebHooksCommand() {
    argParser.addOption('url', help: 'WebHooks地址');
    argParser.addOption('text', help: '文本内容');
  }

  @override
  String get description => '发送文本到WebHooks';

  @override
  String get name => 'sendTextToWebHooks';

  @override
  FutureOr? run() async {
    final url = argResults?['url'];
    final text = argResults?['text'];
    if (url == null || text == null) {
      logger.log('url 或 text 未配置', status: LogStatus.error);
      exit(1);
    }
    await sendTextToWeixinWebhooks(url, text);
  }
}

// class SendTextToWebHooksAction extends ActionRun {
//   @override
//   Future<Map> run(Env env, Map request) async {
//     final url = request['url'];
//     final text = request['text'];
//     if (url == null || text == null) {
//       logger.log('url 或 text 未配置', status: LogStatus.error);
//       exit(1);
//     }
//     await sendTextToWeixinWebhooks(url, text);
//     return {};
//   }
// }
