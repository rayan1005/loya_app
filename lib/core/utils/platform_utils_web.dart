import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';

void openUrlWeb(String url) {
  html.window.open(url, '_blank');
}

Future<Map<String, double>?> getCurrentLocationWeb() async {
  final completer = Completer<Map<String, double>?>();

  try {
    html.window.navigator.geolocation.getCurrentPosition().then((position) {
      completer.complete({
        'latitude': position.coords!.latitude!.toDouble(),
        'longitude': position.coords!.longitude!.toDouble(),
      });
    }).catchError((error) {
      print('Geolocation error: $error');
      completer.complete(null);
    });

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
  } catch (e) {
    return null;
  }
}

void downloadFileWeb(String content, String fileName) {
  final bytes = utf8.encode(content);
  downloadBytesWeb(bytes, fileName);
}

void downloadBytesWeb(List<int> bytes, String fileName) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement()
    ..href = url
    ..style.display = 'none'
    ..download = fileName;

  html.document.body!.children.add(anchor);
  anchor.click();
  html.document.body!.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
