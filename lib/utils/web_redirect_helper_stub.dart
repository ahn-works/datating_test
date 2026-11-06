import 'package:url_launcher/url_launcher.dart';

Future<bool> redirectToExternalUrl(String url) async {
  return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

