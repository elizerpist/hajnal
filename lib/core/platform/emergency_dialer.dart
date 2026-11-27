import 'package:url_launcher/url_launcher.dart';
import '../../features/panic/application/emergency_dialer.dart';

class PlatformEmergencyDialer implements EmergencyDialer {
  const PlatformEmergencyDialer();
  @override
  Future<bool> open112() => launchUrl(
    Uri(scheme: 'tel', path: '112'),
    mode: LaunchMode.externalApplication,
  );
}
