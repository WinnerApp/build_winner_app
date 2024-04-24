import 'package:args/command_runner.dart';
import 'package:build_winner_app/commands/build/build_command.dart';

void main(List<String> arguments) async {
  for (var arg in arguments) {
    if (arg.startsWith('--dart-define=')) {
      dartDefineArgs.add(arg);
    }
  }

  final runner = CommandRunner(
    'build_winner_app',
    '打包并上传到Testflight/到蒲公英 企业微信通知',
  )..addCommand(BuildCommand());

  await runner.run(arguments);
}
