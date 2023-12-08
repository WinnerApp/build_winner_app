import 'dart:async';
import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';

class UpdateUnity {
  final String workspace;
  final String unityEnginePath;
  final UnityPlatform platform;

  UpdateUnity({
    required this.workspace,
    required this.unityEnginePath,
    required this.platform,
  });

  Future<bool> update() async {
    // /Users/king/Documents/2021.3.16f1c1/Unity.app/Contents/MacOS/unity -quit -batchmode -executeMethod ExportAppData.exportAndroid -nographics -projectPath ./
    // 看到日志[Exiting batchmode successfully now!]代表成功
    bool success = false;
    final stdoutController = StreamController<List<int>>.broadcast();
    stdoutController.stream.listen((event) {
      final content = String.fromCharCodes(event);
      logger.log(content);
      if (content.contains('Exiting batchmode successfully now!')) {
        success = true;
      }
    });

    await runCommand(
      workspace,
      '$unityEnginePath -quit -batchmode -executeMethod ${platform.exportMethod} -nographics -projectPath ./',
      ignoreError: true,
      verbose: true,
      stdout: stdoutController.sink,
    ).then((value) => value.first);
    if (success) {
      return true;
    } else {
      logger.log('导出$workspace最新的包失败!', status: LogStatus.error);
      return false;
    }
  }
}

enum UnityPlatform {
  ios("ExportAppData.exportIOS"),
  android("ExportAppData.exportAndroid");

  final String exportMethod;
  const UnityPlatform(this.exportMethod);
}
