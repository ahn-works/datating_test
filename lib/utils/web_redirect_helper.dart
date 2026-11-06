import 'web_redirect_helper_stub.dart'
    if (dart.library.html) 'web_redirect_helper_web.dart' as impl;

Future<bool> redirectToExternalUrl(String url) => impl.redirectToExternalUrl(url);

