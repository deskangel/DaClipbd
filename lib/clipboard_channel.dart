import 'package:daclipbd/utils.dart';
import 'package:flutter/services.dart';

typedef Callback = void Function(dynamic result);

class ClipboardChannel {
  static const MethodChannel _channel = MethodChannel('clipboard');
  static const EventChannel _eventChannel = EventChannel('clipboard_event');

  Callback? _monitingCallback;

  ClipboardChannel() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (this._monitingCallback != null) {
        this._monitingCallback!(event);
      }
    });
  }

  Future<void> hideWindow() async {
    var result = await _channel.invokeMethod('hideWindow');

    return result;
  }

  Future<String> startMonitoring(Callback callback) async {
    this._monitingCallback = callback;

    var result = await _channel.invokeMethod('startMonitoring');

    return result;
  }

  Future<String> stopMonitoring() async {
    this._monitingCallback = null;

    var result = await _channel.invokeMethod('stopMonitoring');

    return result;
  }

  Future<String> setToClipboard({required Map<String, String> data}) async {
    var result = await _channel.invokeMethod('setToClipboard', data);
    logger.d('set to clipboard: $result');
    return result;
  }

  ///////////////////////////////////////
  ///settings

  Future<String> enableBlurWindow() async {
    var result = await _channel.invokeMethod('enableBlurWindow');

    return result;
  }

  Future<String> setWindowRectAccordingScreen() async {
    var result = await _channel.invokeMethod('setWindowRectAccordingScreen');

    return result;
  }

  Future<String> showIconOnDock(bool flag) async {
    var result = await _channel.invokeMethod('showDockIcon', flag);
    return result;
  }

  Future<void> setPositionValue(int pos) async {
    var result = await _channel.invokeMethod('setPositionValue', pos);
    return result;
  }

  Future<bool> setWindowSize(Rect rect) async {
    var result = await _channel.invokeMethod(
      'setWindowSize',
      {'width': rect.width, 'height': rect.height, 'x': rect.left, 'y': rect.top - rect.height},
    );
    return result;
  }

  Future<Rect> getScreenRect() async {
    final screen = await _channel.invokeMethod('getScreenRect');
    if (screen is List && screen.length == 4) {
      return Rect.fromLTWH(screen[0], screen[1] + screen[3], screen[2], screen[3]);
    }
    throw screen;
  }

  Future<bool> launchAtLogin(bool flag) async {
    var result = await _channel.invokeMethod('launchAtLogin', flag);
    return result == 'success';
  }

  Future<Uint8List?> getAppIcon(String bundleId) async {
    var result = await _channel.invokeMethod('getAppIcon', bundleId);
    return result;
  }

  Future<Uint8List?> getFileIcon(String path) async {
    var result = await _channel.invokeMethod('getFileIcon', path);
    return result;
  }

  Future<void> hidesOnDeactivate(bool flag) async {
    await _channel.invokeMethod('hidesOnDeactivate', flag);
  }

  Future<bool> setShowWindowHotkey(String key, int modifiers) async {
    return await _channel.invokeMethod('setShowWindowHotkey',{'key': key, 'modifiers': modifiers});
  }
}
