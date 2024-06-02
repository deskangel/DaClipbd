import 'dart:convert';

import 'package:daclipbd/model/keybinding.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ParkPosition { LEFT, TOP, RIGHT, BOTTOM, WITH_CURSOR }

class Settings {
  factory Settings() => _getInstance();
  static Settings get instance => _getInstance();
  static Settings? _instance;

  Settings._internal();

  static Settings _getInstance() {
    _instance ??= Settings._internal();

    return _instance!;
  }

  bool get isDebug => kDebugMode;

  late SharedPreferences prefs;
  Future<void> init() async {
    this.prefs = await SharedPreferences.getInstance();

    _enableBlur = this.prefs.getBool('enableBlur') ?? false;
    _showIconOnDock = this.prefs.getBool('showIconOnDock') ?? false;
    _launchAtLogin = this.prefs.getBool('launchAtLogin') ?? false;
    _position = ParkPosition.values[this.prefs.getInt('position') ?? ParkPosition.BOTTOM.index];

    _historyCount = this.prefs.getInt('historyCount') ?? 10;
    _keepDuplicates = this.prefs.getBool('keepDuplicates') ?? true;

    _keybinding = Keybinding.fromJsonString(this.prefs.getString('keybinding') ?? '{}');

    themeMode = this.prefs.getInt('themeMode') ?? _themeMode;
  }

  ////////////////////////////////////////////////////////////////////
  /// window and ui settings
  ///
  bool? _enableBlur;
  bool get enableBlur => _enableBlur ?? false;
  set enableBlur(bool enableBlur) {
    _enableBlur = enableBlur;

    this.prefs.setBool('enableBlur', enableBlur);
  }

  bool? _showIconOnDock;
  bool get showIconOnDock => _showIconOnDock ?? false;
  set showIconOnDock(bool showIconOnDock) {
    _showIconOnDock = showIconOnDock;

    this.prefs.setBool('showIconOnDock', showIconOnDock);
  }

  bool? _launchAtLogin;
  bool get launchAtLogin => _launchAtLogin ?? false;
  set launchAtLogin(bool launchAtLogin) {
    _launchAtLogin = launchAtLogin;
    this.prefs.setBool('launchAtLogin', launchAtLogin);
  }

  ParkPosition? _position;
  ParkPosition get position => _position ?? ParkPosition.BOTTOM;
  set position(ParkPosition position) {
    _position = position;
    this.prefs.setInt('position', position.index);
  }

  int _themeMode = 0;
  int get themeMode => _themeMode;
  set themeMode(int value) {
    _themeMode = value;
    this.prefs.setInt('themeMode', value);
  }

  ////////////////////////////////////////////////////////////////////
  /// clipboard related settings

  // the last one means infinity
  static const HISTORY_COUNTS = [10, 100, 200, 300, 400];

  static const int COPYRIGHT_DATE = 2024;

  ///
  /// 0: infinite
  ///
  int? _historyCount;
  int get historyCount => (_historyCount == null || _historyCount! < 10) ? 10 : _historyCount!;
  set historyCount(int historyCount) {
    _historyCount = historyCount;
    this.prefs.setInt('historyCount', historyCount);
  }

  bool get isInfinity => historyCount >= HISTORY_COUNTS.last;

  /// keep duplicated items or not
  bool? _keepDuplicates;
  bool get keepDuplicates => _keepDuplicates ?? true;
  set keepDuplicates(bool value) {
    _keepDuplicates = value;
    this.prefs.setBool('keepDuplicates', value);
  }

  Keybinding? _keybinding;
  Keybinding get keybinding => _keybinding ?? Keybinding();
  set keybinding(Keybinding value) {
    _keybinding = value;
    this.prefs.setString('keybinding', jsonEncode(value));
  }
}

