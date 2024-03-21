// ignore: file_names
import 'dart:io';

import 'package:build_winner_app/common/define.dart';
import 'package:path/path.dart';

class UploadSentrySymbols {
  final String root;
  final String symbolsPath;
  UploadSentrySymbols(this.root, this.symbolsPath);

  Future<void> run() async {
    final rootSymbolsPath = join(root, 'sentry.properties');
    if (!await File(rootSymbolsPath).exists()) {
      File(rootSymbolsPath).create(recursive: true);
    }
    final content = await File(symbolsPath).readAsString();
    await File(rootSymbolsPath).writeAsString(content);

    await runCommand(root, 'flutter packages pub run sentry_dart_plugin');
  }
}
