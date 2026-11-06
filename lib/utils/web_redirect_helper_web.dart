// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<bool> redirectToExternalUrl(String url) async {
  html.window.location.href = url;
  return true;
}

