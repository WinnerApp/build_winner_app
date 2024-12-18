import 'package:build_winner_app/common/define.dart';

gitReset(String workingDirectory) async {
  await runCommand(
    workingDirectory,
    'git reset --hard',
  );
  final result = await runCommand(
    workingDirectory,
    'git status',
  ).then((value) => value.first.stdout);
  final linText = result.toString().split('\n');
  List<String> needDeleteFiles = [];
  bool start = false;
  for (var i = 0; i < linText.length; i++) {
    final text = linText[i];
    if (text.contains(
        '(use "git add <file>..." to include in what will be committed)')) {
      start = true;
      continue;
    }
    if (!start) continue;
    if (text.contains(
        'nothing added to commit but untracked files present (use "git add" to track)')) {
      start = false;
      break;
    } else if (text.isNotEmpty) {
      needDeleteFiles.add(text.trimLeft().trimRight());
    }
  }

  for (var i = 0; i < needDeleteFiles.length; i++) {
    final file = needDeleteFiles[i];
    await runCommand(
      workingDirectory,
      'rm -rf $file',
    );
  }

  await runCommand(
    workingDirectory,
    'git fetch origin',
  );
}
