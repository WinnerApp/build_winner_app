import 'dart:io';

import 'package:build_winner_app/build_app.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:build_winner_app/fix_ios_unity_cache.dart';
import 'package:build_winner_app/setup_fastlane.dart';
import 'package:build_winner_app/update_unity.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('测试初始化 iOS Fastlane', () async {
    final root = '/Users/king/Documents/winner-docs/meta-winner-app';
    final fastlane = SetupIosFastlane(root: root);
    final fastlaneDir = Directory(join(root, 'ios', 'fastlane'));
    if (await fastlaneDir.exists()) {
      await fastlaneDir.delete(recursive: true);
    }
    await fastlane.setup();
    expect(await fastlane.fastlaneFile(root).exists(), true);
  });

  test('测试初始化 Android Fastlane', () async {
    final root = '/Users/king/Documents/winner-docs/meta-winner-app';
    final fastlane = SetupAndroidFastlane(root: root);
    final fastlaneDir = Directory(join(root, 'android', 'fastlane'));
    if (await fastlaneDir.exists()) {
      await fastlaneDir.delete(recursive: true);
    }
    await fastlane.setup();
    expect(await fastlane.fastlaneFile(root).exists(), true);
  });

  test('测试获取本地分支', () async {
    final root = '/Users/king/Downloads/build_winner_app/packages/dcm';
    expect(await getLocalBranchName(root), 'main');
  });

  test('测试获取本地Hash', () async {
    final root = '/Users/king/Downloads/build_winner_app/packages/dcm';
    final localHash = "502b0f205212085e460fb6098685521cdadd0a73";
    final result = await runCommand(root, 'git reset --hard $localHash')
        .then((value) => value.first);
    expect(result.exitCode, 0);
    final hashCode = await getGitLastCommitHash(root);
    expect(hashCode == localHash, true);
  });

  test('测试获取远程Hash', () async {
    final root = '/Users/king/Downloads/build_winner_app/packages/dcm';
    // export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
    // expect(
    //     await testRunCommand(root,
    //         'export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'),
    //     true);

    /// git reset --hard
    expect(
      await runCommand(root, 'git reset --hard').then((value) {
        return value.first.exitCode == 0;
      }),
      true,
    );
    final branch = await getLocalBranchName(root);

    /// git pull origin
    expect(
      await runCommand(root, 'git pull origin $branch')
          .then((value) => value.first.exitCode == 0),
      true,
    );

    expect(
      await getGitLastRemoteCommitHash(root) ==
          await getGitLastRemoteCommitHash(root),
      true,
    );
  });

  test(
    'update unity ios cache',
    () async {
      final root =
          "/Users/king/Documents/winner-docs/meta-winner-app/unity/meta_winner_unity_ios";

      final update = UpdateUnity(
        workspace: root,
        unityEnginePath:
            '/Users/king/Documents/2021.3.16f1c1/Unity.app/Contents/MacOS/unity',
        platform: UnityPlatform.ios,
      );
      expect(await update.update(), true);
    },
    timeout: Timeout.none,
  );

  test(
    'update unity android cache',
    () async {
      final root =
          "/Users/king/Documents/winner-docs/meta-winner-app/unity/meta_winner_unity_android";

      final update = UpdateUnity(
        workspace: root,
        unityEnginePath:
            '/Users/king/Documents/2021.3.16f1c1/Unity.app/Contents/MacOS/unity',
        platform: UnityPlatform.android,
      );
      expect(await update.update(), true);
    },
    timeout: Timeout.none,
  );

  test(
    '测试修复iOS Unity 缓存',
    () async {
      final root = '/Users/king/Documents/winner-docs/meta-winner-app';
      final fixCache = FixIosUnityCache(
        root: root,
        iosUnityPath: join(root, 'unity', 'meta_winner_unity_ios'),
      );
      final toLibil2cppPath = fixCache.toLibil2cppPath;
      if (await File(toLibil2cppPath).exists()) {
        await File(toLibil2cppPath).delete(recursive: true);
      }
      await fixCache.fix();
      bool hasBitcode = await File(fixCache.projectPath)
          .readAsString()
          .then((value) => fixCache.containsBitCode(value));

      bool hasBuiled = await File(toLibil2cppPath).exists();
      expect(!hasBitcode && hasBuiled, true);
    },
    timeout: Timeout.none,
  );

  test('test build ipa', () async {
    final root = '/Users/king/Downloads/pgyer_api_example';
    final ipaPath = join(root, 'build', 'ios', 'ipa', 'pgyer_api_example.ipa');

    if (await File(ipaPath).exists()) {
      await File(ipaPath).delete();
    }
    final buildApp = BuildApp(platform: BuildPlatform.ios, root: root);
    await buildApp.build();
    expect(await File(ipaPath).exists(), true);
  }, timeout: Timeout.none);

  test('test build apk', () async {
    final root = '/Users/king/Downloads/pgyer_api_example';
    final apkPath =
        join(root, 'build', 'app', 'outputs', 'flutter-apk', 'app-release.apk');

    if (await File(apkPath).exists()) {
      await File(apkPath).delete();
    }
    final buildApp = BuildApp(platform: BuildPlatform.android, root: root);
    await buildApp.build();
    expect(await File(apkPath).exists(), true);
  }, timeout: Timeout.none);
}

Future<bool> testRunCommand(String root, String script) =>
    runCommand(root, script).then((value) => value.first.exitCode == 0);
