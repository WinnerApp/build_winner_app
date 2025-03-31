import 'dart:io';

import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';
import 'package:path/path.dart';

class FixIosUnityCache {
  final String root;
  final String iosUnityPath;

  FixIosUnityCache({
    required this.root,
    required this.iosUnityPath,
  });

  Future<bool> fix() async {
    /// 修复iOS不支持BitCode
    logger.log('修复iOS不支持BitCode');

    final lineTexts = await File(projectPath).readAsLines();
    for (int i = 0; i < lineTexts.length; i++) {
      final lineText = lineTexts[i];
      if (containsBitCode(lineText)) {
        final newText = lineText.replaceAll(
          'ENABLE_BITCODE = YES',
          'ENABLE_BITCODE = false',
        );
        lineTexts[i] = newText;
      }
    }
    await File(projectPath).writeAsString(lineTexts.join('\n'));
    logger.log('修复iOS不支持BitCode完毕!', status: LogStatus.success);

    if (!await Directory(iosBuidDir).exists()) {
      return true;
    }

    /// 删除之前的缓存
    final buildDir = Directory(join(iosBuidDir, 'build'));
    if (await buildDir.exists()) {
      await buildDir.delete(recursive: true);
    }
    logger.log('修复 libil2cpp.a 报错');
    await runCommand(
      iosBuidDir,
      'bash build_libil2cpp.sh',
      ignoreError: true,
    );
    final libil2cppAFile = File(join(iosBuidDir, 'build', 'libil2cpp.a'));
    if (!await libil2cppAFile.exists()) {
      logger.log('${libil2cppAFile.path}路径不存在!', status: LogStatus.error);
      return false;
    }

    if (await libil2cppAFile.length() < 50 * 1024 * 1024) {
      /// 如果大小于50M则代表文件存在问题
      logger.log(
        '${libil2cppAFile.path}文件异常请重新生成libil2cpp.a!',
        status: LogStatus.error,
      );
      return false;
    }

    await libil2cppAFile.copy(toLibil2cppPath);
    logger.log('修复 libil2cpp.a 报错完毕!', status: LogStatus.success);
    return true;
  }

  String get projectPath => join(
        root,
        'ios',
        'UnityLibrary',
        'Unity-iPhone.xcodeproj',
        'project.pbxproj',
      );

  bool containsBitCode(String content) {
    return content.contains('ENABLE_BITCODE = YES');
  }

  String get iosBuidDir => join(
        iosUnityPath,
        'HybridCLRData',
        'iOSBuild',
      );

  String get toLibil2cppPath => join(
        root,
        'ios',
        'UnityLibrary',
        'Libraries',
        'libil2cpp.a',
      );
}
