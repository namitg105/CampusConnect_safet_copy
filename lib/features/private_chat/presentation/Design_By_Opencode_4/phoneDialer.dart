import 'package:url_launcher/url_launcher.dart';
import 'package:noteswap/features/auth/data/mobile_update.dart';

class PhoneDialer {
  final MobileUpdate _mobileUpdate = MobileUpdate();

  Future<void> dial(String targetUID) async {
    final phoneNumber = await _mobileUpdate.getMobileNumber(targetUID);
    if (phoneNumber == null || phoneNumber.isEmpty) {
      throw Exception('No phone number available for this user');
    }

    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch dialer');
    }
  }
}
