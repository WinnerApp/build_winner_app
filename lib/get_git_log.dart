import 'dart:io';

import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';

class GetGitLog {
  final String root;
  final String lastCommitId;
  final String? currentCommitId;

  GetGitLog({
    required this.root,
    required this.lastCommitId,
    required this.currentCommitId,
  });

  Future<String?> get() async {
    logger.log('[git log $currentCommitId..$lastCommitId]');
    if (lastCommitId.isEmpty) {
      logger.log('lastCommitId is empty', status: LogStatus.error);
      exit(2);
    }
    ProcessResult result;
    if (currentCommitId == null) {
      result = await runCommand(root, 'git log -1').then(
        (value) => value.first,
      );
    } else {
      result = await runCommand(root, 'git log $currentCommitId..$lastCommitId')
          .then(
        (value) => value.first,
      );
    }
    if (result.exitCode != 0) {
      logger.log(result.stderr, status: LogStatus.error);
      return null;
    }
    final messages = <String>[];
    for (var element in result.stdout) {
      /// 删除日志左右的空格
      final message = element.trim();
      if (message.isEmpty) continue;
      if (message.isNotEmpty) {
        messages.add(message);
      }
    }
    final logContent = messages.join('\n');
    return logContent;
  }
}
