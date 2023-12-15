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

  test('upload log to ios dingding ', () async {
    final log = '''
✅iOS新测试包已经发布!
-----------------------
Unity更新日志:
棉循环绿地部分碰撞和lod修复
出掉场景异常模型
1.修改bug
增加阶段4测试动画
nature renderer和unity渲染拆成不同的关卡
* 'ArtStyle_1.0' of codeup.aliyun.com:dayu/winner-meta/meta-winner-unity:
棉循环的棉花道路碰撞修改
修复编译报错
稳健馆实验室玻璃罩子开关动画
1.修改一些bug
删除urpwater
修改万翼测试碰撞bug
露营地台阶修改、飞艇动画降速
1.隐藏玩家头顶气泡
1.修改测试bug
t.drawTreesAndFoliage不要运行时赋值
水材质修改
桥碰撞坐标修改、贴图设置修改
棉循环
splatmap压缩
地形缝修复
家居生活找回
shader stripping 修改
修复咨询站粒子
场景depth替代方案
飞艇动画
路灯碰撞修复
指路牌BUG修复
棉柔巾拆开
文件整理
稳健资产检查
修改default SRP settings
13日二次优化
程序优化
客户资产合并new
工具代码修改
splatmap 压缩
客户资产调优

Flutter更新日志:
同上
修复：新品体验奖励未及时更新/注销提示条件/好友变陌生人限制3条数据/聊天用户在线更新/举报提示/搜索中可通过好友申请/删除聊天记录参数修改
🟢升级工程最低支持Flutter 3.7.0
🟢新增宇宙咨询和活动公告增加已读功能
🟡AssistantCommonItems 组件新增支持自定义已读字段
🟡调整changeStateTime格式化时间统一DateTimeFormatter类进行输出
🔴修复推送时间显示格式不正确
🟢新增MakeMessageReadApi接口处理已读
🟢新增MakeMessageReadManager类统一处理已读
🔴修复首页无法打开小稳助手的bug;
🔴代码风格检查.
fixed 关闭棉历史入口
fixed 抽奖页面回到交易所页面没有刷新棉能量
修改banner无链接不关闭当前页面/节日限定暂注释/好友列表最新消息排序/棉循环视频加音量控件/
🔴修复: 修复了活动公告和宇宙咨询推送时间显示为活动时间
🔴修复: 修改小稳气泡的宽度从250到200 修复宽度遮挡棉
🟢功能: 🟢新增JumpJSBridge支持通用跳转
-----------------------
👉请前往TestFlight查看

''';

    await sendTextToWeixinWebhooks(log,
        'https://oapi.dingtalk.com/robot/send?access_token=424f2612144d93f2681db7321e62cab19647952c3344834ea0607614bd03ea23');
  });
}

Future<bool> testRunCommand(String root, String script) =>
    runCommand(root, script).then((value) => value.first.exitCode == 0);
