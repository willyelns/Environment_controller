library environment_controller;

import 'dart:convert';
import 'dart:core';
import 'package:flutter/services.dart' show rootBundle;
import 'package:meta/meta.dart';

const String DEFAULT_FLAG = 'ENV';
const String DEFAULT_ENV_VALUE = 'dev';
// const String DEFAULT_ENV_PATH = 'lib/environments';
const String DEFAULT_ENV_PATH = 'package:nix_voce_core/environments';

class EnvironmentConfig {
  final String runFlag;
  final String defaultEnv;
  final String envFilePath;

  EnvironmentConfig({
    this.runFlag = DEFAULT_FLAG,
    this.defaultEnv = DEFAULT_ENV_VALUE,
    this.envFilePath = DEFAULT_ENV_PATH,
  });
}

class EnvironmentController {
  factory EnvironmentController() {
    return _singleton;
  }

  EnvironmentController._internal({@required EnvironmentConfig config})
      : _config = config;

  static final EnvironmentController _singleton =
      EnvironmentController._internal(
    config: EnvironmentConfig(),
  );

  set config(EnvironmentConfig config) {
    _config = config;
  }

  Map<String, dynamic> get environments => _appEnv;

  final Map<String, dynamic> _appEnv = <String, dynamic>{};

  EnvironmentConfig _config;

  ///
  /// Loads the Env using the main flag
  /// Uses the [env] to define what the file will be load

  Future<void> loadEnv(
    String env, {
    String dir,
    Map<String, String> envData,
  }) async {
    print('chamou aqui $env');
    // TODO(loadEnv): Find a way to get the flag value from here instead the main
    env ??= String.fromEnvironment(_config.runFlag,
        defaultValue: _config.envFilePath);
    if (dir != null)
      await _loadFromPath(dir);
    else if (envData != null)
      await _loadFromMap(envData);
    else
      await _loadFromAsset(env);
  }

  ///
  /// Reads a value of any type from persistent storage for the given [key].
  ///
  dynamic get(String key) => _appEnv[key];

  ///
  /// Reads a [String] value from persistent storage for the given [key], throwing an exception if it's not a String.
  ///
  String getString(String key) => _appEnv[key];

  ///
  /// Writes the appEnv from the json in using the [envName] to be used
  ///
  Future<void> _loadFromAsset(String envName) async {
    // final String content =
    //     await rootBundle.loadString('${_config.envFilePath}/$envName.json');
    // final String content =
    //     await rootBundle.loadString('lib/core/environments/$envName.json');
    // final Map<String, dynamic> envAsMap = json.decode(content);
    final Map<String, dynamic> envAsMap = {
      "BASE_URL": "https://apigateway-dev.nexxera.com",
      "SECRET_KEY": "34b443b8-20d1-4381-a069-77c282ab0d59",
      "REALM": "NixDev",
      "CLIENT_ID": "NIX",
      "APP_VERSION": "1.0.0",
      "APP_ENVIROMMENT": "dev"
    };
    _appEnv.addAll(envAsMap);
  }

  ///
  /// Writes the appEnv from the json in using the [envName] to be used
  ///
  Future<void> _loadFromPath(String dir) async {
    final String content = await rootBundle.loadString('$dir');
    final Map<String, dynamic> envAsMap = json.decode(content);
    _appEnv.addAll(envAsMap);
  }

  ///
  /// Writes the appEnv from the json in using the [envName] to be used
  ///
  Future<void> _loadFromMap(Map<String, String> envData) async {
    _appEnv.addAll(envData);
  }
}
