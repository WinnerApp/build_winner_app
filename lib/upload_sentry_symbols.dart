import 'dart:io';

import 'package:build_winner_app/common/define.dart';
import 'package:path/path.dart';

class UploadSentrySymbols {
  final String root;
  final String symbolsPath;
  final String version;
  final String build;
  UploadSentrySymbols(this.root, this.symbolsPath, this.version, this.build);

  Future<void> run() async {
    final rootSymbolsPath = join(root, 'sentry.properties');
    if (!await File(rootSymbolsPath).exists()) {
      File(rootSymbolsPath).create(recursive: true);
    }
    final contents = await File(symbolsPath).readAsLines();
    for (var i = 0; i < contents.length; i++) {
      final content = contents[i];
      if (content.startsWith('release')) {
        contents[i] = 'release=$version';
      } else if (content.startsWith('dist')) {
        contents[i] = 'dist=$build';
      }
    }

    await File(rootSymbolsPath).writeAsString(contents.join('\n'));
    await runCommand(root, 'flutter packages pub run sentry_dart_plugin');
  }
}
