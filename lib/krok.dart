import 'dart:convert';
import 'dart:io';

import 'package:krok/src/api.dart';
import 'package:krok/src/log.dart';

krok() async {
  logLevel = LogLevel.verbose;

  final api = KrakenApi.fromFile("/home/dl/.config/clikraken/kraken.key");

  final ticker = await cached(
    key: "ticker",
    maxAge: 5.minutes,
    retrieve: () => api.retrieve(KrakenRequest.ticker()),
  );
  final ticks = ticker.where((key, value) => key.endsWith("USD"));
  for (var entry in ticks.entries) {
    final ask = ticks.dynamicMap(entry.key).list("a").first;
    print("${entry.key}: $ask");
  }
}

/// Somewhat horrific cache handling around retrieving data from the Kraken API.
///
/// The [key] is used to store the data in a file in the `cache` directory. If
/// the file is not older than [maxAge], the data is read from the file.
/// Otherwise, the [retrieve] function is called to get fresh data.
Future<Map<String, dynamic>> cached({
  required String key,
  required Duration maxAge,
  required Future<Map<String, dynamic>> Function() retrieve,
}) async {
  Map<String, dynamic>? result;
  var file = File("cache/$key.json");
  if (file.existsSync()) {
    var stat = file.statSync();
    if (stat.modified.isFresh(maxAge: maxAge)) {
      try {
        result = await file.readAsString().then((s) => jsonDecode(s));
        logVerbose("loaded cached $key");
      } on Exception catch (it) {
        logError("error reading cache - ignored: ${it.runtimeType}");
      }
    }
  }
  result ??= await retrieve();
  await file.writeAsString(jsonEncode(result));
  return result;
}
