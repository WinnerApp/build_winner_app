import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';
import 'package:process_run/process_run.dart';

class BuildApp {
  final BuildPlatform platform;
  final String buildName;
  final int buildNumber;
  final String root;

  BuildApp({
    required this.platform,
    required this.root,
    required this.buildName,
    required this.buildNumber,
  });
  Future<bool> build() async {
    var script =
        'flutter build ${platform.name} --build-name $buildName --build-number $buildNumber';
    logger.log('👉开始进行打包......');
    final result = await runCommand(root, script).then((value) => value.first);
    if (result.exitCode != 0) {
      logger.log('打包失败:${result.errText}', status: LogStatus.error);
      return false;
    }
    logger.log('打包成功!', status: LogStatus.success);
    return true;
  }
}

enum BuildPlatform {
  ios("ipa"),
  android("apk");

  final String name;
  const BuildPlatform(this.name);
}
