import 'dart:convert';
import 'dart:io';

import 'package:build_winner_app/appwrite_server.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/environment.dart';
import 'package:color_logger/color_logger.dart';
import 'package:dart_appwrite/dart_appwrite.dart';
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
  final AppwriteEnvironment environment;
  final String platform;
  final String branch;

  const BuildConfigManager(
      {required this.environment,
      required this.platform,
      required this.branch});

  Future<BuildInfo?> getBuildConfig() async {
    final appwriteServer = AppwriteServer(environment);

    final databases = appwriteServer.databases;
    final documents = await databases.listDocuments(
      databaseId: environment.databaseId,
      collectionId: environment.collectionId,
      queries: [
        Query.equal('platform', platform),
        Query.equal('branch', branch),
        Query.orderDesc('build_time'),
      ],
    );

    if (documents.documents.isEmpty) {
      return null;
    }

    /// 按照最新创建时间排序
    documents.documents.sort((a, b) {
      return DateTime.parse(a.$createdAt)
          .compareTo(DateTime.parse(b.$createdAt));
    });

    final document = documents.documents.last;
    final buildInfo = BuildInfo.fromJson({
      'flutter': JSON(document.data)['flutter_conmit'].stringValue,
      'unity': BuildUnityConfig.fromJson({
        'cache': JSON(document.data)['unity_cache_commit'].stringValue,
        'log': JSON(document.data)['unity_log_commit'].stringValue,
      }).toJson(),
    });
    return buildInfo;
  }

  Future<bool> setBuildConfig({
    required BuildInfo buildInfo,
    required String buildName,
    required int buildTime,
  }) async {
    final appwriteServer = AppwriteServer(environment);
    final databases = appwriteServer.databases;
    if (buildInfo.flutter.isEmpty ||
        buildInfo.unity.cache.isEmpty ||
        buildInfo.unity.log.isEmpty) {
      logger.log('buildInfo is empty', status: LogStatus.error);
      return false;
    }

    try {
      await databases.createDocument(
        databaseId: environment.databaseId,
        collectionId: environment.collectionId,
        documentId: ID.unique(),
        data: {
          'platform': platform,
          'build_name': buildName,
          'build_time': DateTime.fromMillisecondsSinceEpoch(buildTime * 1000)
              .toIso8601String(),
          'build_number': buildTime,
          'flutter_conmit': buildInfo.flutter,
          'unity_cache_commit': buildInfo.unity.cache,
          'unity_log_commit': buildInfo.unity.log,
          'branch': branch,
        },
      );
      return true;
    } catch (e) {
      logger.log(e.toString(), status: LogStatus.error);
      return false;
    }
  }
}
