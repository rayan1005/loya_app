// Stub implementation for non-web platforms

void openUrlWeb(String url) {
  // No-op on non-web
}

Future<Map<String, double>?> getCurrentLocationWeb() async {
  return null;
}

void downloadFileWeb(String content, String fileName) {
  // No-op on non-web
}

void downloadBytesWeb(List<int> bytes, String fileName) {
  // No-op on non-web
}
