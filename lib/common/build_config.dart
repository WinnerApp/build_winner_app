import 'dart:convert';
import 'dart:io';

import 'package:darty_json_safe/darty_json_safe.dart';

class BuildConfig {
  final String flutter;
  final String unity;
  const BuildConfig({required this.flutter, required this.unity});
}

class BuildConfigManager {
  final String filePath;

  const BuildConfigManager({required this.filePath});

  Future<BuildConfig> getBuildConfig() async {
    final buildConfigText = await File(filePath).readAsString();
    final buildConfigJson = JSON(buildConfigText);
    final buildConfig = BuildConfig(
      flutter: buildConfigJson['flutter'].string!,
      unity: buildConfigJson['unity'].string!,
    );
    return buildConfig;
  }

  Future<void> setBuildConfig(BuildConfig buildConfig) async {
    await File(filePath).writeAsString(json.encode({
      'flutter': buildConfig.flutter,
      'unity': buildConfig.unity,
    }));
  }
}
