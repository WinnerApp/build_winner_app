import 'package:build_winner_app/git_reset.dart';
import 'package:test/test.dart';

void main() {
  test(
    'test',
    () async {
      await gitReset(
          '/Users/king/Documents/winner-docs/meta-winner-app/unity/meta_winner_unity_android');
    },
    timeout: Timeout.none,
  );
}
