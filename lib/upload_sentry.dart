import 'dart:io';

import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/environment.dart';
import 'package:path/path.dart';

class UploadSentrySymbols {
  final Environment environment;
  const UploadSentrySymbols({required this.environment});

  Future<void> run() async {
    final flutterWorkspace = join(environment.workspace, 'metaapp_flutter');
    final sentrypropertiesFile = join(flutterWorkspace, 'sentry.properties');
    if (!await File(sentrypropertiesFile).exists()) {
      throw Exception('sentry.properties文件不存在');
    }
    final properties = await File(sentrypropertiesFile).readAsLines();
    final sentryEnvironment = environment.sentryEnvironment;
    for (var i = 0; i < properties.length; i++) {
      final property = properties[i];
      if (property.startsWith('project=')) {
        properties[i] = 'project=${sentryEnvironment.project}';
      } else if (property.startsWith('url=')) {
        properties[i] = 'url=${sentryEnvironment.url}';
      } else if (property.startsWith('auth_token=')) {
        properties[i] = 'auth_token=${sentryEnvironment.authToken}';
      } else if (property.startsWith('org=')) {
        properties[i] = 'org=${sentryEnvironment.org}';
      } else if (property.startsWith('dist=')) {
        properties[i] = 'dist=${sentryEnvironment.dist}';
      } else if (property.startsWith('release=')) {
        properties[i] = 'release=${sentryEnvironment.release}';
      }
    }
    await File(sentrypropertiesFile).writeAsString(properties.join('\n'));
    await runCommand(
      flutterWorkspace,
      'flutter packages pub run sentry_dart_plugin',
    );
  }
}
