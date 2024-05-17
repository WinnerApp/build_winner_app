import 'dart:io';

import 'package:path/path.dart';

class RemoveIosSettingBundle {
  final String root;
  const RemoveIosSettingBundle({required this.root});

  Future<void> remove() async {
    final projectFile =
        File(join(root, 'ios', 'Runner.xcodeproj', 'project.pbxproj'));
    final contents = <String>[];
    for (final line in await projectFile.readAsLines()) {
      if (!line.contains('Settings.bundle')) {
        contents.add(line);
      }
    }
    await projectFile.writeAsString(contents.join('\n'));
  }
}
