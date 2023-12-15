import 'dart:convert';
import 'dart:io';

import 'package:darty_json_safe/darty_json_safe.dart';

class BuildConfig {
  late BuildInfo ios;
  late BuildInfo android;

  BuildConfig.fromJson(Map<String, dynamic> json) {
    ios = BuildInfo.fromJson(JSON(json)['ios']
        .mapValue
        .map((key, value) => MapEntry(key.toString(), value)));
    android = BuildInfo.fromJson(JSON(json)['android']
        .mapValue
        .map((key, value) => MapEntry(key.toString(), value)));
  }

  Map<String, dynamic> toJson() {
    return {
      'ios': ios.toJson(),
      'android': android.toJson(),
    };
  }
}

class BuildInfo {
  /// flutter最后一次打包的ID
  late String flutter;

  /// unity最后的打包配置信息
  late BuildUnityConfig unity;

  BuildInfo.fromJson(Map<String, dynamic> json) {
    flutter = JSON(json)['flutter'].stringValue;
    unity = BuildUnityConfig.fromJson(JSON(json)['unity']
        .mapValue
        .map((key, value) => MapEntry(key.toString(), value)));
  }

  Map<String, dynamic> toJson() {
    return {
      'flutter': flutter,
      'unity': unity.toJson(),
    };
  }
}

class BuildUnityConfig {
  /// unity 最后一次缓存的ID
  late String cache;

  /// unity 最后一次日志的ID
  late String log;

  BuildUnityConfig.fromJson(Map<String, dynamic> json) {
    cache = JSON(json)['cache'].stringValue;
    log = JSON(json)['log'].stringValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'cache': cache,
      'log': log,
    };
  }
}

class BuildConfigManager {
  final String filePath;

  const BuildConfigManager({required this.filePath});

  Future<BuildConfig> getBuildConfig() async {
    final buildConfigText = await File(filePath).readAsString();
    final buildConfigJson = JSON(buildConfigText);
    final buildConfig = BuildConfig.fromJson(buildConfigJson.mapValue
        .map((key, value) => MapEntry(key.toString(), value)));
    return buildConfig;
  }

  Future<void> setBuildConfig(BuildConfig buildConfig) async {
    await File(filePath).writeAsString(json.encode(buildConfig.toJson()));
  }
}
