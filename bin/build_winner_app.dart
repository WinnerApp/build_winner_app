import 'package:build_winner_app/commands/add_umeng_push_config_command.dart';
import 'package:build_winner_app/commands/build/build_command.dart';
import 'package:build_winner_app/commands/build/upload_apk_channel.dart';
import 'package:build_winner_app/commands/send_text_to_webhooks.dart';
import 'package:dart_ops_engine/dart_ops_engine.dart';
// import 'package:dart_ops_engine/commons/dart_ops_engine.dart';

void main(List<String> arguments) async {
  var arguments0 = [...arguments];
  for (var arg in arguments) {
    if (arg.startsWith('--dart-define=')) {
      dartDefineArgs.add(arg);
      arguments0.remove(arg);
    }
  }

  final engine = DartOpsEngine(
    'build_winner_app',
    arguments0,
    description: '打包并上传到Testflight/到蒲公英 企业微信通知',
  );
  engine.addAction('addUmengPushConfig', AddUmengPushConfigCommand());
  engine.runner
    ..addCommand(BuildCommand())
    ..addCommand(SendTextToWebHooksCommand())
    ..addCommand(UploadApkChannel());
  await engine.run();

  // final runner = CommandRunner(
  //   'build_winner_app',
  //   '打包并上传到Testflight/到蒲公英 企业微信通知',
  // )
  //   ..addCommand(BuildCommand())
  //   ..addCommand(SendTextToWebHooksCommand())
  //   ..addCommand(UploadApkChannel());

  // await runner.run(arguments0);
}

// Future<void> main(List<String> args) async {
//   DartOpsEngine('build_winner_app', args)
//     ..addAction('sendTextToWebHooks', SendTextToWebHooksAction())
//     ..run();
// }
