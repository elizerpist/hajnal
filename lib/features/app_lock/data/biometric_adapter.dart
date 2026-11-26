import 'package:local_auth/local_auth.dart';
import '../application/biometrics.dart';

class BiometricAdapter implements Biometrics {
  BiometricAdapter() : _auth = LocalAuthentication();
  final LocalAuthentication _auth;

  BiometricResult _error(LocalAuthException error) => switch (error.code) {
    LocalAuthExceptionCode.noBiometricHardware ||
    LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
      BiometricResult.unavailable,
    LocalAuthExceptionCode.noCredentialsSet ||
    LocalAuthExceptionCode.noBiometricsEnrolled => BiometricResult.notEnrolled,
    LocalAuthExceptionCode.temporaryLockout => BiometricResult.temporaryLockout,
    LocalAuthExceptionCode.biometricLockout => BiometricResult.permanentLockout,
    LocalAuthExceptionCode.userCanceled ||
    LocalAuthExceptionCode.systemCanceled ||
    LocalAuthExceptionCode.userRequestedFallback ||
    LocalAuthExceptionCode.timeout => BiometricResult.cancelled,
    _ => BiometricResult.platformError,
  };

  @override
  Future<BiometricResult> availability() async {
    try {
      if (!await _auth.canCheckBiometrics) return BiometricResult.unavailable;
      if ((await _auth.getAvailableBiometrics()).isEmpty) {
        return BiometricResult.notEnrolled;
      }
      return BiometricResult.success;
    } on LocalAuthException catch (e) {
      return _error(e);
    } catch (_) {
      return BiometricResult.platformError;
    }
  }

  @override
  Future<BiometricResult> authenticate() async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Oldd fel a Hajnalt.',
        biometricOnly: true,
        persistAcrossBackgrounding: false,
      );
      return ok ? BiometricResult.success : BiometricResult.failed;
    } on LocalAuthException catch (e) {
      return _error(e);
    } catch (_) {
      return BiometricResult.platformError;
    }
  }

  @override
  Future<void> cancel() async {
    await _auth.stopAuthentication();
  }
}
