import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

// Conditional imports
import 'platform_utils_stub.dart'
    if (dart.library.html) 'platform_utils_web.dart' as platform;

/// Opens a URL in a new browser tab/window
Future<void> openUrl(String url) async {
  if (kIsWeb) {
    platform.openUrlWeb(url);
  } else {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Gets current geolocation (web only, returns null on mobile)
Future<Map<String, double>?> getCurrentLocationWeb() async {
  if (kIsWeb) {
    return platform.getCurrentLocationWeb();
  }
  return null;
}

/// Downloads a file with the given content (web only)
void downloadFile(String content, String fileName) {
  if (kIsWeb) {
    platform.downloadFileWeb(content, fileName);
  }
}

/// Downloads bytes as a file (web only)
void downloadBytes(List<int> bytes, String fileName) {
  if (kIsWeb) {
    platform.downloadBytesWeb(bytes, fileName);
  }
}
