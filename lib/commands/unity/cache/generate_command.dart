import 'dart:async';
import 'dart:io';
import 'package:build_winner_app/commands/unity/cache/cache_command.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';
import 'package:path/path.dart';

class GenerateCommand extends BaseCacheCommand {
  @override
  String get description => '对生成的缓存进行操作,主要对于目前iOS的需要进行修复';

  @override
  String get name => 'generate';

  @override
  FutureOr? cacheRun() async {
    /// 获取iOS Unity项目最后更新的hash
    final iosHashCode = await getGitLastCommitHash(iosUnityDir.path);

    final iosCurrentBranch = await runCommand(
      iosUnityDir.path,
      'git rev-parse --abbrev-ref HEAD',
    ).then((value) => value.first.stdout.toString().trim());

    /// 更新远程仓库
    await runCommand(iosUnityDir.path, '''
git reset --hard
git fetch origin
''');
    final iosLastHashCode = await runCommand(
      iosUnityDir.path,
      'git ls-remote --heads origin $iosCurrentBranch | awk \'{print \$1}\'',
    ).then((value) {
      /// bb2b2fb44d073c7cbea05e11c905543072b10b63	refs/heads/ArtStyle_1.0
      final reg = RegExp('[0-9+a-z]*');
      return reg.firstMatch(value.first.stdout.toString())!.group(0);
    });

    if (iosLastHashCode != iosHashCode) {
      logger.log('${iosUnityDir.path}代码已经不是最新，请拉取最新导出包',
          status: LogStatus.error);
      exit(1);
    }

    /// 获取安卓 Unity项目最后更新的hash
    final androidHashCode = await getGitLastCommitHash(androidUnityDir.path);

    final androidCurrentBranch = await runCommand(
      androidUnityDir.path,
      'git rev-parse --abbrev-ref HEAD',
    ).then((value) => value.first.stdout.toString().trim());

    /// 更新远程仓库
    await runCommand(androidUnityDir.path, '''
git reset --hard
git fetch origin
''');
    final androidLastHashCode = await runCommand(
      androidUnityDir.path,
      'git ls-remote --heads origin $androidCurrentBranch | awk \'{print \$1}\'',
    ).then((value) {
      /// bb2b2fb44d073c7cbea05e11c905543072b10b63	refs/heads/ArtStyle_1.0
      final reg = RegExp('[0-9+a-z]*');
      return reg.firstMatch(value.first.stdout.toString())!.group(0);
    });

    if (androidLastHashCode != androidHashCode) {
      logger.log('${androidUnityDir.path}代码已经不是最新，请拉取最新导出包',
          status: LogStatus.error);
      exit(1);
    }

    /// 修复iOS不支持BitCode
    logger.log('修复iOS不支持BitCode');
    final projectPath = join(
      root,
      'ios',
      'UnityLibrary',
      'Unity-iPhone.xcodeproj',
      'project.pbxproj',
    );

    final lineTexts = await File(projectPath).readAsLines();
    for (int i = 0; i < lineTexts.length; i++) {
      final lineText = lineTexts[i];
      if (lineText.contains('ENABLE_BITCODE = YES')) {
        final newText = lineText.replaceAll(
          'ENABLE_BITCODE = YES',
          'ENABLE_BITCODE = false',
        );
        lineTexts[i] = newText;
      }
    }
    logger.log('修复iOS不支持BitCode完毕!', status: LogStatus.success);

    final iosBuidDir = Directory(join(
      iosUnityDir.path,
      'HybridCLRData',
      'iOSBuild',
    ));

    if (!await iosBuidDir.exists()) {
      logger.log(
        '${iosBuidDir.path}路径不存在,请先通过Unity导出包!',
        status: LogStatus.error,
      );
      exit(1);
    }

    /// 删除之前的缓存
    final buildDir = Directory(join(iosBuidDir.path, 'build'));
    if (await buildDir.exists()) {
      await buildDir.delete(recursive: true);
    }

    await runCommand(
      iosBuidDir.path,
      'bash build_libil2cpp.sh',
      ignoreError: true,
    );
    final libil2cppAFile = File(join(iosBuidDir.path, 'build', 'libil2cpp.a'));
    if (!await libil2cppAFile.exists()) {
      logger.log('${libil2cppAFile.path}路径不存在!', status: LogStatus.error);
      exit(1);
    }

    if (await libil2cppAFile.length() < 50 * 1024 * 1024) {
      /// 如果大小于50M则代表文件存在问题
      logger.log(
        '${libil2cppAFile.path}文件异常请重新生成libil2cpp.a!',
        status: LogStatus.error,
      );
      exit(1);
    }

    final toPath = join(
      root,
      'ios',
      'UnityLibrary',
      'Libraries',
      'libil2cpp.a',
    );

    await libil2cppAFile.copy(toPath);

    logger.log('unity缓存生成成功', status: LogStatus.success);
  }

  Future<String> getGitLastCommitHash(String root) async {
    final result = await runCommand(root, 'git log -n 1 --pretty=format:"%H"');
    return result.first.stdout;
  }
}
