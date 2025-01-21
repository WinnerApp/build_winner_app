import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:build_winner_app/environment.dart';
import 'package:color_logger/color_logger.dart';
import 'package:dio/dio.dart';
import 'package:process_run/shell.dart';

final logger = ColorLogger();
final env = Environment();

Future<List<ProcessResult>> runCommand(
  String workingDirectory,
  String command, {
  bool verbose = true,
  bool ignoreError = false,
  StreamSink<List<int>>? stdout,
}) async {
  logger.log('执行命令：[$workingDirectory] [$command]');
  final shell = Shell(
    workingDirectory: workingDirectory,
    verbose: verbose,
    stdout: stdout,
  );
  final results = await shell.run(command);
  final errorTexts =
      results.map((e) => e.errText).where((element) => element.isNotEmpty);
  if (results.any((element) => element.exitCode != 0) && !ignoreError) {
    logger.log(errorTexts.join('\n'), status: LogStatus.error);
    exit(2);
  }
  logger.log('执行命令: $command 完成', status: LogStatus.success);
  return results;
}

/// 获取本地代码最新的哈希
Future<String> getGitLastCommitHash(String root) async {
  final result = await runCommand(
    root,
    'git log -n 1 --pretty=format:"%H"',
    ignoreError: true,
  );
  return result.first.stdout.toString().trim();
}

/// 获取代码的远程分支的最新哈希
Future<String> getGitLastRemoteCommitHash(String root) async {
  final localCurrentBranch = await getLocalBranchName(root);

  /// 更新远程仓库
  await runCommand(root, '''
git reset --hard
git fetch origin
''');
  final remoteCommitHashCode = await runCommand(
    root,
    'git ls-remote --heads origin $localCurrentBranch | awk \'{print \$1}\'',
  ).then((value) {
    /// bb2b2fb44d073c7cbea05e11c905543072b10b63	refs/heads/ArtStyle_1.0
    final reg = RegExp('[0-9+a-z]*');
    return reg.firstMatch(value.first.stdout.toString())!.group(0);
  });
  return remoteCommitHashCode!.trim();
}

/// 检查代码是否是最新
Future<bool> checkGitLastCommitHash(String root) async {
  final localCommitHash = await getGitLastCommitHash(root);
  final remoteCommitHash = await getGitLastRemoteCommitHash(root);
  return localCommitHash == remoteCommitHash;
}

/// 发送文本到企业微信
Future<bool> sendTextToWeixinWebhooks(String text, String hookUrl) async {
  final dio = Dio();
  final response = await dio.post(
    hookUrl,
    options: Options(headers: {
      'Content-Type': 'application/json',
    }),
    data: json.encode({
      'msgtype': 'text',
      'text': {'content': text},
    }),
  );

  final status = response.statusCode;
  if (status != 200) {
    logger.log('企业微信发送失败', status: LogStatus.error);
    return false;
  }
  return true;
}

Future<String> getLocalBranchName(String root) => runCommand(
      root,
      'git rev-parse --abbrev-ref HEAD',
    ).then((value) => value.first.stdout.toString().trim());

String formatGitLog(String flutterLog, String unityLog) {
  List<String> filterLogs(String log) {
    List<String> logs = [];
    for (var log in log.split("\n")) {
      /// 如果当前行存在以下关键字 则忽略
      if (['commit', 'Author', 'Date', 'Merge', '# Conflicts', '#    ']
          .any((e) => log.toLowerCase().startsWith(e.toLowerCase()))) {
        continue;
      }
      logs.add(log);
    }
    return logs;
  }

  List<String> logs = [];
  final flutterLogs = filterLogs(flutterLog);
  final unityLogs = filterLogs(unityLog);
  if (flutterLogs.length + unityLogs.length > 100) {
    logs.addAll(unityLogs.sublist(0, min(unityLogs.length, 30)));
    logs.addAll(flutterLogs.sublist(0, min(flutterLogs.length, 30)));
  } else {
    logs.addAll(unityLogs);
    logs.addAll(flutterLogs);
  }
  return logs.join('\n');
}
