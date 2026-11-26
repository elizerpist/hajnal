import 'package:flutter/services.dart';
import '../../features/app_lock/application/device_guard.dart';

class DeviceGuardAdapter implements DeviceGuard {
  static const _channel = MethodChannel('hu.elizerpist.hajnal/lock_guard');
  @override
  Future<DeviceTime> time() async {
    final result = await _channel.invokeMapMethod<String, dynamic>('time');
    final uptime = result?['uptime'];
    final boot = result?['boot'];
    if (uptime is! int || uptime < 0 || boot is! String || boot.isEmpty) {
      throw StateError('Device uptime unavailable');
    }
    return DeviceTime(uptime, boot);
  }

  @override
  Future<void> revealAfterFrame() => _channel.invokeMethod<void>('reveal');
}
