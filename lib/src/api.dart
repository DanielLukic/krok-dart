import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:krok/src/extensions.dart';
import 'package:krok/src/log.dart';

part 'package:krok/src/config.dart';
part 'package:krok/src/exception.dart';
part 'package:krok/src/request.dart';
part 'package:krok/src/types.dart';

class KrakenApi {
  List<String> secret;

  final Client client;

  final NonceGenerator nonceGenerator;

  KrakenApi.fromConfig(KrakenConfig config)
      : secret = [config.apiKey, config.privateKey],
        client = config.client ?? Client(),
        nonceGenerator = config.nonceGenerator ?? defaultNonceGenerator;

  factory KrakenApi.from(String apiKey, String privateKey) =>
      KrakenApi.fromConfig(KrakenConfig(apiKey, privateKey));

  factory KrakenApi.fromFile(String path) =>
      KrakenApi.fromConfig(KrakenConfig.fromFile(path));

  close() => client.close();

  Future<Result> assets({List<Pair>? assets}) =>
      retrieve(KrakenRequest.assets(assets: assets));

  Future<Result> assetPairs({List<Pair>? pairs}) =>
      retrieve(KrakenRequest.assetPairs(pairs: pairs));

  Future<Result> ticker([List<Pair>? pairs]) =>
      retrieve(KrakenRequest.ticker(pairs: pairs));

  Future<Result> ohlc(List<Pair> pairs) => retrieve(KrakenRequest.ohlc(pairs));

  Future<Result> tradeVolume() => retrieve(KrakenRequest.tradeVolume());

  /// Retrieves decoded json data from the Kraken API. Takes care of signing for
  /// private requests.
  Future<Result> retrieve(KrakenRequest request) async {
    final data = switch (request.scope) {
      Scope.public => _public(request),
      Scope.private => _private(request)
    };
    final Result envelope = json.decode(await data);
    final errors = envelope.stringList("error");
    for (var element in errors) {
      if (element.startsWith("E")) {
        throw KrakenException(element);
      } else {
        logWarn(element);
      }
    }
    return envelope["result"] as Result;
  }

  Future<String> _public(KrakenRequest request) async {
    assert(request.scope == Scope.public, "public request expected");
    var params = request.params.mapValues((v) => v.toString());
    var url = Uri.parse('https://api.kraken.com/0/public/${request.path}')
        .replace(queryParameters: params);
    var get = Request('GET', url);
    logVerbose("sending request $url: ${get.body}");
    var info = await client.send(get);
    return await info.stream.bytesToString();
  }

  Future<String> _private(KrakenRequest request, {String? nonce}) async {
    assert(request.scope == Scope.private, "private request expected");
    var url = Uri.parse('https://api.kraken.com/0/private/${request.path}');
    var get = Request('POST', url);
    nonce ??= nonceGenerator().toString();

    var map = request.params.mapValues((v) => v.toString());
    var params = {"nonce": nonce.toString(), ...map};
    get.bodyFields = params;
    get.headers['API-Key'] = secret[0];
    get.headers['API-Sign'] =
        createApiSign(url.path, get.body, nonce, secret[1]);

    logVerbose("sending request $url: ${get.body}");
    var info = await client.send(get);
    return await info.stream.bytesToString();
  }

  /// Creates the Kraken API signature ("API-Sign") for a private API call.
  String createApiSign(String path, String data, String nonce, String secret) {
    var innerBytes = utf8.encode(nonce.toString() + data);
    var innerDigest = sha256.convert(innerBytes);
    var pathBytes = utf8.encode(path);
    var secretBytes = base64.decode(secret);
    Hmac hmac = Hmac(sha512, secretBytes);
    Digest digest = hmac.convert(pathBytes + innerDigest.bytes);
    return base64.encode(digest.bytes);
  }

  /// Loads data for a parameterless, public Kraken API call from cache if
  /// available and fresh, otherwise fetches fresh data and caches it.
  Future<Result> load(String path, {Duration? maxAge}) async {
    String? data;

    var file = File("cache/$path.json");
    if (await file.exists()) {
      var age = await file.lastModified();
      if (age.isFresh(maxAge: maxAge ?? 8.hours)) {
        logVerbose("load cached $path");
        data = await cached(file);
      }
    }

    if (data == null) {
      logVerbose("fetch fresh $path");
      data = await fresh(path);
      await file.writeAsString(data);
    }

    return json.decode(data);
  }

  /// Loads cached json for the parameterless, public Kraken API call
  /// represented by [path].
  Future<String?> cached(File file) async {
    try {
      return await file.readAsString();
    } catch (e) {
      return null;
    }
  }

  /// Fetches parameterless, public data from the Kraken API. Only HTTP caching
  /// potentially applies.
  Future<String> fresh(String path) async {
    var url = Uri.parse('https://api.kraken.com/0/public/$path');
    var request = Request('GET', url);
    var info = await request.send();
    return await info.stream.bytesToString();
  }
}

/// Somewhat horrific cache handling around retrieving data from the Kraken API.
///
/// The [key] is used to store the data in a file in the `cache` directory. If
/// the file is not older than [maxAge], the data is read from the file.
/// Otherwise, the [retrieve] function is called to get fresh data.
Future<Result> cached({
  required String key,
  required Duration maxAge,
  required Future<Result> Function() retrieve,
}) async {
  Result? result;
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
