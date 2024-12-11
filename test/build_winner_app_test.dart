import 'package:build_winner_app/common/build_config.dart';
import 'package:build_winner_app/environment.dart';
import 'package:test/test.dart';

void main() {
  test('test', () async {
    final manager = BuildConfigManager(
      environment: AppwriteEnvironment(
        endPoint: 'https://cloud.appwrite.io/v1',
        projectId: 'mianyuzhouapp',
        apiKey:
            'standard_e89b74ed2d4b45bc89b625dc67e82417cc88889f93fe26cc3cd90f54e56d2eab6f74e8663e2ec1489f05a2c096087fd0fe03ff61950976480d5302d616860cf9c29e0915dc182b82dc0d1dea23c8def78a16e3c15cd23790df24c7dd43ca1379e20c298ca355123a999ff1a49c497bdf008a578715fa5f22a6357d4cc50ffdc1',
        databaseId: 'shorebird_patchs',
        collectionId: 'build_info',
      ),
      platform: 'android',
      branch: 'dev_2.0',
    );

    var info = await manager.getBuildConfig();

    expect(info?.flutter, '9a4a60f0ee5a3626130f586d8257e98db9029436');
  });
}
