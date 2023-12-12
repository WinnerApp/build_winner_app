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

  /// Unity所在Flutter项目的工程目录
  late String unityWorkspace;

  /// iOS Unity工程的相对路径
  late String iosUnityPath;

  /// Android Unity工程的相对路径
  late String androidUnityPath;

  /// Unity 引擎的路径
  late String unityEnginePath;

  /// 打包的名称
  late String buildName;

  late String dingdingIosHookUrl;
  late String dingdingAndroidHookUrl;

  setup() {
    workspace = env('WORKSPACE');
    iosHookUrl = env('IOS_HOOK_URL');
    androidHookUrl = env('ANDROID_HOOK_URL');
    appStoreConnectApiKeyId = env('APP_STORE_CONNECT_API_KEY_ID');
    appStoreConnectApiIssuerId = env('APP_STORE_CONNECT_API_ISSUER_ID');
    appStoreConnectApiKeyFilepath = env('APP_STORE_CONNECT_API_KEY_FILEPATH');
    appIdentifier = env('APP_IDENTIFIER');
    appId = env('APP_ID');
    pgyerApiKey = env('PGYER_API_KEY');
    unityWorkspace = env('UNITY_WORKSPACE');
    iosUnityPath = env('IOS_UNITY_PATH');
    androidUnityPath = env('ANDROID_UNITY_PATH');
    unityEnginePath = env('UNITY_ENGINE_PATH');
    buildName = env('BUILD_NAME');
    dingdingIosHookUrl = env('DINGDING_IOS_HOOK_URL');
    dingdingAndroidHookUrl = env('DINGDING_ANDROID_HOOK_URL');
  }

  String env(String name) {
    if (Platform.environment[name] == null) {
      logger.log('$name 环境变量未配置', status: LogStatus.error);
      exit(1);
    }
    return Platform.environment[name]!;
  }

  /// 安卓Unity工程的完整路径
  String get androidUnityFullPath => join(unityWorkspace, androidUnityPath);

  /// iOS Unity工程的完整路径
  String get iosUnityFullPath => join(unityWorkspace, iosUnityPath);
}
