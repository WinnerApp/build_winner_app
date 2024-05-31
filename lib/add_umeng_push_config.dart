import 'dart:io';

import 'package:path/path.dart';

class AddUmengPushConfig {
  final String root;
  final String umengAppKey;
  final String umengMessageSecret;
  final String umengChannel;

  const AddUmengPushConfig({
    required this.root,
    required this.umengAppKey,
    required this.umengMessageSecret,
    required this.umengChannel,
  });
  Future<void> add() async {
    final localPropertyFile = File(join(root, 'android', 'local.properties'));
    final lines = await localPropertyFile.readAsLines();
    final keyValues = {
      'UMENG_APPKEY': umengAppKey,
      'UMENG_MESSAGE_SECRET': umengMessageSecret,
      'UMENG_CHANNEL': umengChannel,
    };

    keyValues.forEach((key, value) {
      final index = lines.indexWhere((element) => element.startsWith(key));
      if (index == -1) {
        lines.add('$key=$value');
      } else {
        lines[index] = '$key=$value';
      }
    });

    await localPropertyFile.writeAsString(lines.join('\n'));
  }
}
