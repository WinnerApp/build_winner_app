import 'package:build_winner_app/commands/build/build_command.dart';
import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';

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
        'flutter build ${platform.name} --build-name=$buildName --build-number=$buildNumber';
    for (var args in dartDefineArgs) {
      script = '$script $args';
    }
    logger.log('👉开始进行打包......');
    final result = await runCommand(root, script).then((value) => value.first);
    if (result.exitCode != 0) {
      logger.log('打包失败:${result.stderr}', status: LogStatus.error);
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
