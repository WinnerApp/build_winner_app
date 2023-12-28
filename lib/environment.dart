import 'dart:io';

import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';
import 'package:path/path.dart';

class Environment {
  /// 打包的工程路径
  late String workspace;

  /// 发送iOS端日志的Hook的企业微信的地址
  late String iosHookUrl;

  /// 发送Android端日志的Hook的企业微信的地址
  late String androidHookUrl;

  /// App Store Connect API Key ID
  late String appStoreConnectApiKeyId;

  /// App Store Connect API Issuer ID
  late String appStoreConnectApiIssuerId;

  /// App Store Connect API Key Filepath
  late String appStoreConnectApiKeyFilepath;

  /// 应用标识符
  late String appIdentifier;

  /// 应用的ID
  late String appId;

  /// 蒲公英上传的Key
  late String pgyerApiKey;

  /// 打包的名称
  late String buildName;

  /// 钉钉发送iOS日志的钉钉机器人地址
  late String dingdingIosHookUrl;

  /// 钉钉发送Android日志的钉钉机器人地址
  late String dingdingAndroidHookUrl;

  /// 当前打包的分支
  late String branch;

  UnityEnvironment? unityEnvironment;

  late AppwriteEnvironment appwriteEnvironment;

  setup(bool updateUnity) {
    workspace = env('WORKSPACE');
    iosHookUrl = env('IOS_HOOK_URL');
    androidHookUrl = env('ANDROID_HOOK_URL');
    appStoreConnectApiKeyId = env('APP_STORE_CONNECT_API_KEY_ID');
    appStoreConnectApiIssuerId = env('APP_STORE_CONNECT_API_ISSUER_ID');
    appStoreConnectApiKeyFilepath = env('APP_STORE_CONNECT_API_KEY_FILEPATH');
    appIdentifier = env('APP_IDENTIFIER');
    appId = env('APP_ID');
    pgyerApiKey = env('PGYER_API_KEY');
    if (updateUnity) {
      final unityWorkspace = env('UNITY_WORKSPACE');
      final iosUnityPath = env('IOS_UNITY_PATH');
      final androidUnityPath = env('ANDROID_UNITY_PATH');
      final unityEnginePath = env('UNITY_ENGINE_PATH');
      unityEnvironment = UnityEnvironment(
        unityWorkspace: unityWorkspace,
        iosUnityPath: iosUnityPath,
        androidUnityPath: androidUnityPath,
        unityEnginePath: unityEnginePath,
      );
    }

    buildName = env('BUILD_NAME');
    dingdingIosHookUrl = env('DINGDING_IOS_HOOK_URL');
    dingdingAndroidHookUrl = env('DINGDING_ANDROID_HOOK_URL');
    branch = env('BRANCH').replaceFirst('origin/', '');

    appwriteEnvironment = AppwriteEnvironment(
      endPoint: env('APPWRITE_ENDPOINT'),
      projectId: env('APPWRITE_PROJECT_ID'),
      apiKey: env('APPWRITE_API_KEY'),
      databaseId: env('APPWRITE_DATABASE_ID'),
      collectionId: env('APPWRITE_COLLECTION_ID'),
    );
  }

  String env(String name) {
    if (Platform.environment[name] == null) {
      logger.log('$name 环境变量未配置', status: LogStatus.error);
      exit(1);
    }
    return Platform.environment[name]!;
  }
}

class UnityEnvironment {
  /// Unity所在Flutter项目的工程目录
  final String unityWorkspace;

  /// iOS Unity工程的相对路径
  final String iosUnityPath;

  /// Android Unity工程的相对路径
  final String? androidUnityPath;

  /// Unity 引擎的路径
  final String unityEnginePath;

  const UnityEnvironment({
    required this.unityWorkspace,
    required this.iosUnityPath,
    required this.androidUnityPath,
    required this.unityEnginePath,
  });

  /// 安卓Unity工程的完整路径
  String get androidUnityFullPath => join(unityWorkspace, androidUnityPath);

  /// iOS Unity工程的完整路径
  String get iosUnityFullPath => join(unityWorkspace, iosUnityPath);
}

class AppwriteEnvironment {
  final String endPoint;
  final String projectId;
  final String apiKey;
  final String databaseId;
  final String collectionId;
  AppwriteEnvironment({
    required this.endPoint,
    required this.projectId,
    required this.apiKey,
    required this.databaseId,
    required this.collectionId,
  });
}
