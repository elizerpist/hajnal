class DeviceTime {
  const DeviceTime(this.uptime, this.boot);
  final int uptime;
  final String boot;
}

abstract interface class DeviceGuard {
  Future<DeviceTime> time();
  Future<void> revealAfterFrame();
}
