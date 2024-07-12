import 'dart:async';
import 'dart:io';

import 'package:build_winner_app/add_umeng_push_config.dart';
import 'package:build_winner_app/commands/build/build_command.dart';
import 'package:build_winner_app/common/build_config.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/environment.dart';
import 'package:build_winner_app/set_version_build_number.dart';
import 'package:build_winner_app/setup_fastlane.dart';
import 'package:build_winner_app/update_unity.dart';
import 'package:build_winner_app/upload_apk.dart';
import 'package:color_logger/color_logger.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';

class AndroidCommand extends BaseBuildCommand {
  @override
  String get description => '打包安卓包上传到蒲公英';

  @override
  String get name => 'android';

  @override
  Future updateUnity(UnityEnvironment unityEnvironment) async {
    // 导出包之前修复Graphics Api的问题
    // ../ProjectSettings/ProjectSettings.asset
    final projectSettingPath = join(unityEnvironment.androidUnityFullPath,
        'ProjectSettings', 'ProjectSettings.asset');
    if (!await File(projectSettingPath).exists()) {
      logger.log('$projectSettingPath路径不存在!', status: LogStatus.error);
      exit(2);
    }

    var contents = await File(projectSettingPath).readAsString();
    final lines = contents.split('\n');
    final index = lines.indexWhere((element) => element.contains('m_APIs'));
    if (index != -1) {
      // m_APIs: 0b000000
      lines[index] = '    m_APIs: 0b000000';
    }
    await File(projectSettingPath).writeAsString(lines.join('\n'));
    final success = await UpdateUnity(
      workspace: unityEnvironment.androidUnityFullPath,
      unityEnginePath: unityEnvironment.unityEnginePath,
      platform: UnityPlatform.android,
    ).update();
    if (!success) {
      logger.log('导出Android Unity最新的包失败!', status: LogStatus.error);
      exit(2);
    }
    logger.log('导出Android Unity最新的包成功!', status: LogStatus.success);
  }

  @override
  Future build(String root) async {
//     final keyPropertyFile = File(join(root, 'android', 'key.properties'));
//     if (await keyPropertyFile.exists()) {
//       await keyPropertyFile.delete(recursive: true);
//     }
//     final keyPropertyContent = '''
// storePassword=winer2023
// keyPassword=winer2023
// keyAlias=upload
// storeFile=/Users/king/android_keys/winner-metaapp-keystore.jks
// ''';
//     await keyPropertyFile.create();
//     await keyPropertyFile.writeAsString(keyPropertyContent);

//     final localPropertyFile = File(join(root, 'android', 'local.properties'));
//     if (await localPropertyFile.exists()) {
//       await localPropertyFile.delete(recursive: true);
//     }

//     final localPropertyContent = '''
// sdk.dir=/Users/king/Library/Android/sdk
// flutter.sdk=/Users/king/fvm/versions/3.13.2
// ndk.dir=/Users/king/Documents/2021.3.16f1c1/PlaybackEngines/AndroidPlayer/NDK
// flutter.buildMode=debug
// flutter.versionName=1.0.0
// flutter.versionCode=1701424978
// flutter.compileSdkVersion=32
// flutter.minSdkVersion=20
// ''';
//     await localPropertyFile.create();
//     await localPropertyFile.writeAsString(localPropertyContent);

    await AddUmengPushConfig(
      root: root,
      umengAppKey: environment.umengPushEnvironment.umengAppKey,
      umengMessageSecret: environment.umengPushEnvironment.umengMessageSecret,
      umengChannel: environment.umengPushEnvironment.umengChannel,
    ).add();
    await SetVersionBuildNumber(environment: environment).runInAndroid();
    /**
     * WROKSPACE=$PWD

cd $WROKSPACE/metaapp_flutter
fvm flutter clean
fvm flutter pub get
cd $WROKSPACE/android
./gradlew clean
./gradlew assembleRelease
     */

    await Shell(workingDirectory: '${environment.workspace}/metaapp_flutter')
        .run('''
fvm flutter clean
fvm flutter pub get
''');

    await Shell(workingDirectory: '${environment.workspace}/android').run('''
./gradlew clean
./gradlew assembleRelease
''');

    // await BuildApp(
    //   platform: BuildPlatform.android,
    //   root: root,
    //   buildName: environment.buildName,
    //   buildNumber: environment.buildNumber,
    // ).build();
  }

  @override
  Future upload(String root) async {
    // build/app/outputs/apk/release/app-release.apk
    if (JSON(platformEnvironment)['ZEALOT_CHANNEL_KEY'].stringValue.isEmpty) {
      return;
    }
    await UploadApk(root: root, log: environment.branch).upload();
  }

  @override
  String get hookUrl => environment.androidHookUrl;

  @override
  SetupFastlane get setupFastlane =>
      SetupAndroidFastlane(root: environment.workspace);

  @override
  String? get unityFullPath =>
      environment.unityEnvironment?.androidUnityFullPath;

  @override
  String get unityFrameworkPath => 'android/unityLibrary';

  @override
  String get logHeader => '✅Android 新测试包已经发布!';

  @override
  String get logFooter => '👉请前往蒲公英下载';

  @override
  String get dingdingHookUrl => environment.dingdingAndroidHookUrl;

  @override
  BuildInfo getBuildInfo(BuildConfig buildConfig) {
    return buildConfig.android;
  }

  @override
  BuildConfigManager getBuildConfigManager(
      {required AppwriteEnvironment appwriteEnvironment}) {
    return BuildConfigManager(
      environment: appwriteEnvironment,
      platform: 'android',
      branch: environment.branch,
    );
  }
}
