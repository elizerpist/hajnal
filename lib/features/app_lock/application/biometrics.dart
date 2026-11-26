enum BiometricResult {
  success,
  failed,
  cancelled,
  unavailable,
  notEnrolled,
  temporaryLockout,
  permanentLockout,
  platformError,
}

abstract interface class Biometrics {
  Future<BiometricResult> availability();
  Future<BiometricResult> authenticate();
  Future<void> cancel();
}
