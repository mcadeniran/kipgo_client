import 'package:url_launcher/url_launcher.dart';

class ContactLauncher {
  ContactLauncher._();

  static Future<void> call(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);

    if (!await launchUrl(uri)) {
      throw Exception('Could not make phone call.');
    }
  }

  static Future<void> whatsapp(String phoneNumber) async {
    final uri = Uri.parse('https://wa.me/$phoneNumber');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open WhatsApp.');
    }
  }

  static Future<void> email({
    required String email,
    String? subject,
    String? body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );

    if (!await launchUrl(uri)) {
      throw Exception('Could not open email.');
    }
  }
}
