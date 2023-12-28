import 'dart:io';

import 'package:build_winner_app/appwrite_server.dart';
import 'package:build_winner_app/common/build_config.dart';
import 'package:build_winner_app/environment.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() async {
  const yamlFilePath = '/Users/king/Documents/build_winner_app/appwrite.yaml';
  final yaml = await File(yamlFilePath).readAsString().then((value) {
    return loadYaml(value);
  });
  final appwriteEnvironment = AppwriteEnvironment(
    endPoint: JSON(yaml['end_point']).stringValue,
    projectId: JSON(yaml['project_id']).stringValue,
    apiKey: JSON(yaml['api_key']).stringValue,
    databaseId: JSON(yaml['database_id']).stringValue,
    collectionId: JSON(yaml['collection_id']).stringValue,
  );

  test(
    'test databse exit',
    () async {
      final appwriteServer = AppwriteServer(appwriteEnvironment);
      final database = await appwriteServer.getDatabase();
      expect(database != null, true);
    },
    timeout: Timeout(Duration(seconds: 30)),
  );

  test(
    'test collection exit',
    () async {
      final appwriteServer = AppwriteServer(appwriteEnvironment);
      final collection = await appwriteServer.getCollection();
      expect(collection != null, true);
    },
    timeout: Timeout(Duration(seconds: 30)),
  );

  test(
    'test attributes exit',
    () async {
      final collection =
          await AppwriteServer(appwriteEnvironment).getCollection();
      final attributes = collection?.attributes ?? [];
      final attributeKeys =
          attributes.map((e) => JSON(e)['key'].stringValue).toList();
      const keys = [
        'platform',
        'build_name',
        'build_number',
        'build_time',
        'build_config_json'
      ];
      final isExit = keys.any((element) => attributeKeys.contains(element));
      expect(isExit, true);
    },
    timeout: Timeout(Duration(seconds: 30)),
  );

  test(
    'test get new config',
    () async {
      final buildConfigManager =
          BuildConfigManager(environment: appwriteEnvironment, platform: 'ios');

      final result = await buildConfigManager.setBuildConfig(
        buildInfo: BuildInfo.fromJson({'flutter': '1'}),
        buildName: '1.0.0',
        buildTime: DateTime.now().millisecondsSinceEpoch,
      );
      final result1 = await buildConfigManager.setBuildConfig(
        buildInfo: BuildInfo.fromJson({'flutter': '2'}),
        buildName: '1.0.0',
        buildTime: DateTime.now().millisecondsSinceEpoch,
      );

      final buildConfig = await buildConfigManager.getBuildConfig();
      expect(buildConfig?.flutter == '2' && result && result1, true);
    },
    timeout: Timeout(Duration(seconds: 30)),
  );

  test(
    'test read flutter commit',
    () async {
      final databases = AppwriteServer(appwriteEnvironment).databases;
      final document = await databases.getDocument(
        databaseId: appwriteEnvironment.databaseId,
        collectionId: appwriteEnvironment.collectionId,
        documentId: '658d1d7bc995e96f9299',
      );
      final flutterCommit = JSON(document.data)['flutter_conmit'].stringValue;
      expect(flutterCommit == '0d666fe80a4d558ce1bf5bcee57c5c47433911df', true);
    },
    timeout: Timeout.none,
  );
}
