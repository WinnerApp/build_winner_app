import 'dart:async';
import 'dart:io';

import 'package:build_winner_app/environment.dart';
import 'package:path/path.dart';

class SetVersionBuildNumber {
  final Environment environment;

  const SetVersionBuildNumber({required this.environment});

  Future<void> runInIos() async {
    final iosConfigFile = File(iosConfigPath);
    if (!await iosConfigFile.exists()) {
      throw Exception('iOS配置文件不存在');
    }
    final lineTexts = await iosConfigFile.readAsLines();
    for (int i = 0; i < lineTexts.length; i++) {
      if (lineTexts[i].contains('FLUTTER_BUILD_NAME')) {
        lineTexts[i] = 'FLUTTER_BUILD_NAME = ${environment.buildName}';
      } else if (lineTexts[i].contains('FLUTTER_BUILD_NUMBER')) {
        lineTexts[i] = 'FLUTTER_BUILD_NUMBER = ${environment.buildNumber}';
      }
    }
    await iosConfigFile.writeAsString(lineTexts.join('\n'));
  }

  Future<void> runInAndroid() async {
    final androidConfigFile = File(androidConfigPath);
    if (!await androidConfigFile.exists()) {
      throw Exception('Android配置文件不存在');
    }
    final lineTexts = await androidConfigFile.readAsLines();
    for (int i = 0; i < lineTexts.length; i++) {
      if (lineTexts[i].contains('flutter.versionName')) {
        lineTexts[i] = 'flutter.versionName=${environment.buildName}';
      } else if (lineTexts[i].contains('flutter.versionCode')) {
        lineTexts[i] = 'flutter.versionCode=${environment.buildNumber}';
      }
    }
  }

  String get iosConfigPath =>
      join(environment.workspace, 'ios', 'flutter', 'Generated.xcconfig');

  String get androidConfigPath =>
      join(environment.workspace, 'android', 'local.properties');
}
