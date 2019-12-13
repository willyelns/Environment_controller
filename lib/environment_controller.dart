library environment_controller;

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:meta/meta.dart';

const String DEFAULT_FLAG = 'ENV';
const String DEFAULT_ENV_VALUE = 'dev';
const String DEFAULT_ENV_PATH = 'lib/core/environments';

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

  Future<void> loadEnv(String env) async {
    print('chamou aqui $env');
    // TODO(loadEnv): Find a way to get the flag value from here instead the main
    env ??= String.fromEnvironment(_config.runFlag,
        defaultValue: _config.envFilePath);
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
    final String content =
        await rootBundle.loadString('${_config.envFilePath}/$envName.json');
    final Map<String, dynamic> envAsMap = json.decode(content);
    _appEnv.addAll(envAsMap);
  }
}
