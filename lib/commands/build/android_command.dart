import 'dart:async';
import 'dart:io';

import 'package:build_winner_app/build_app.dart';
import 'package:build_winner_app/commands/build/build_command.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/setup_fastlane.dart';
import 'package:build_winner_app/update_unity.dart';
import 'package:color_logger/color_logger.dart';
import 'package:path/path.dart';

class AndroidCommand extends BaseBuildCommand {
  @override
  String get description => '打包安卓包上传到蒲公英';

  @override
  String get name => 'android';

  @override
  Future updateUnity(String unityPath) async {
    final success = await UpdateUnity(
      workspace: unityPath,
      unityEnginePath: environment.unityEnginePath,
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
    final keyPropertyFile = File(join(root, 'android', 'key.properties'));
    if (await keyPropertyFile.exists()) {
      await keyPropertyFile.delete(recursive: true);
    }
    final keyPropertyContent = '''
storePassword=winer2023
keyPassword=winer2023
keyAlias=upload
storeFile=/Users/king/android_keys/winner-metaapp-keystore.jks
''';
    await keyPropertyFile.create();
    await keyPropertyFile.writeAsString(keyPropertyContent);

    final localPropertyFile = File(join(root, 'android', 'local.properties'));
    if (await localPropertyFile.exists()) {
      await localPropertyFile.delete(recursive: true);
    }

    final localPropertyContent = '''
sdk.dir=/Users/king/Library/Android/sdk
flutter.sdk=/Users/king/fvm/versions/3.13.2
ndk.dir=/Users/king/Documents/2021.3.16f1c1/PlaybackEngines/AndroidPlayer/NDK
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1701424978
flutter.compileSdkVersion=32
flutter.minSdkVersion=20
''';
    await localPropertyFile.create();
    await localPropertyFile.writeAsString(localPropertyContent);

    await BuildApp(
      platform: BuildPlatform.android,
      root: root,
      buildName: environment.buildName,
    ).build();
  }

  @override
  Future upload(String root) async {
    // build/app/outputs/apk/release/app-release.apk

    final apkPath = join(
        root, 'build', 'app', 'outputs', 'apk', 'release', 'app-release.apk');
    if (!await File(apkPath).exists()) {
      logger.log('$apkPath路径不存在!', status: LogStatus.error);
      exit(2);
    }
    final result = await runCommand(
            join(root, 'android'), 'fastlane deploy apk:"$apkPath"')
        .then((value) => value.first);
    if (result.exitCode != 0) {
      logger.log('上传失败!', status: LogStatus.error);
      exit(result.exitCode);
    }
  }

  @override
  String get hookUrl => environment.androidHookUrl;

  @override
  SetupFastlane get setupFastlane =>
      SetupAndroidFastlane(root: environment.workspace);

  @override
  String get unityFullPath => environment.androidUnityFullPath;

  @override
  String get unityFrameworkPath => 'android/unityLibrary';

  @override
  String get platformFileName => '.android_build_id.json';

  @override
  String get logHeader => '✅Android 新测试包已经发布!';

  @override
  String get logFooter => '👉请前往蒲公英下载';

  @override
  String get dingdingHookUrl => environment.dingdingAndroidHookUrl;
}
