import 'dart:io';

import 'package:build_winner_app/common/define.dart';
import 'package:color_logger/color_logger.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';

abstract class SetupFastlane {
  final String root;
  SetupFastlane({required this.root});

  File fastlaneFile(String root);
  String get fastlaneContent;

  Future setup() async {
    final fastlane = await which('fastlane');
    if (fastlane == null) {
      logger.log('fastlane未安装', status: LogStatus.error);
      exit(2);
    }

    logger.log('正在初始化Fastlane配置');
    if (!await fastlaneFile(root).exists()) {
      await fastlaneFile(root).create(recursive: true);
    }
    await fastlaneFile(root).writeAsString(fastlaneContent);
    logger.log('初始化Fastlane配置完成', status: LogStatus.success);
  }
}

class SetupIosFastlane extends SetupFastlane {
  SetupIosFastlane({required super.root});

  @override
  String get fastlaneContent => '''
default_platform(:ios)

lane :upload_testflight do |options|
  ipa = options[:ipa]
  changelog = options[:changelog] || "新的版本发布了,快来下载呀!"
  api_key = app_store_connect_api_key(
    key_id: ENV['APP_STORE_CONNECT_API_KEY_ID'],
    issuer_id: ENV['APP_STORE_CONNECT_API_ISSUER_ID'],
    key_filepath: ENV['APP_STORE_CONNECT_API_KEY_FILEPATH'],
    duration: 1200, # optional (maximum 1200)
    in_house: false # optional but may be required if using match/sigh
  )

  upload_to_testflight(
    api_key: api_key,
    app_identifier: ENV['APP_IDENTIFIER'],
    apple_id: ENV['APP_ID'],
    ipa: ipa,
    changelog: changelog,
    skip_waiting_for_build_processing: true,
    distribute_external: true,
    groups: ["TEST1"],
  )
end
''';

  @override
  File fastlaneFile(String root) =>
      File(join(root, 'ios', 'fastlane', 'Fastfile'));
}

class SetupAndroidFastlane extends SetupFastlane {
  SetupAndroidFastlane({required super.root});

  @override
  String get fastlaneContent => '''
default_platform(:android)

lane :deploy do |options|
  apk = options[:apk]
  zealot(
    endpoint: ENV['ZEALOT_ENDPOINT'],
    token: ENV['ZEALOT_TOKEN'],
    channel_key: ENV['ZEALOT_CHANNEL_KEY'],
    file: apk,
  )
end

''';

  @override
  File fastlaneFile(String root) =>
      File(join(root, 'android', 'fastlane', 'Fastfile'));

  @override
  Future setup() async {
    super.setup();
    final pluginFileContent = '''
# Autogenerated by fastlane
#
# Ensure this file is checked in to source control!

source "https://rubygems.org"

gem 'fastlane'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
''';

    final pluginFile = File(join(root, 'android', 'Gemfile'));
    if (!await pluginFile.exists()) {
      await pluginFile.create(recursive: true);
    }
    await pluginFile.writeAsString(pluginFileContent);

    // await runCommand(join(root, 'android'), 'fastlane add_plugin pgyer');
  }
}
