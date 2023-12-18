import 'dart:async';
import 'package:args/command_runner.dart';
import 'package:build_winner_app/environment.dart';

abstract class BaseCommand extends Command {
  Environment environment = Environment();

  @override
  FutureOr? run() async {}
}
