import 'package:args/command_runner.dart';
import 'package:build_winner_app/commands/unity/cache/cache_command.dart';

class UnityCommand extends Command {
  UnityCommand() {
    addSubcommand(CacheCommand());
  }

  @override
  String get description => 'unity操作的相关命令';

  @override
  String get name => 'unity';
}
