import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:krok/src/common/extensions.dart';
import 'package:krok/src/common/log.dart';

part 'package:krok/src/api/config.dart';
part 'package:krok/src/api/exception.dart';
part 'package:krok/src/api/kraken_time.dart';
part 'package:krok/src/api/request.dart';
part 'package:krok/src/api/types.dart';

/// Main class for interacting with the Kraken API.
///
/// Implements the Kraken API public/private key and none-based authentication.
///
/// It is the callers responsibility to always only execute a single request.
class KrakenApi {
  List<String> _secret;

  final Client _client;

  final NonceGenerator _nonceGenerator;

  /// Create a new Kraken API instance based on the given [config].
  KrakenApi.fromConfig(KrakenConfig config)
      : _secret = [config.apiKey, config.privateKey],
        _client = config.client ?? Client(),
        _nonceGenerator = config.nonceGenerator ?? defaultNonceGenerator;

  /// Create a new Kraken API instance based on the given [apiKey] and [privateKey].
  factory KrakenApi.from(String apiKey, String privateKey) =>
      KrakenApi.fromConfig(KrakenConfig(apiKey, privateKey));

  /// Create a new Kraken API instance based on the given [path] to a file containing the API key
  /// and private key.
  factory KrakenApi.fromFile(String path) => KrakenApi.fromConfig(KrakenConfig.fromFile(path));

  /// Shut down the underlying client. Required to have the program terminate normally.
  close() => _client.close();

  /// High-level call to retrieve available assets. Can be restricted via optional [assets].
  Future<Result> assets({List<Pair>? assets}) => retrieve(KrakenRequest.assets(assets: assets));

  /// High-level call to retrieve asset pairs. Can be restricted via optional [pairs].
  Future<Result> assetPairs({List<Pair>? pairs}) =>
      retrieve(KrakenRequest.assetPairs(pairs: pairs));

  /// High-level call to retrieve ticker data. Can be restricted via optional [pairs].
  Future<Result> ticker([List<Pair>? pairs]) => retrieve(KrakenRequest.ticker(pairs: pairs));

  /// High-level call to retrieve open, high, low, close values for the given [pair].
  ///
  /// See the underlying request if you need to specify time range and interval.
  Future<Result> ohlc(Pair pair) => retrieve(KrakenRequest.ohlc(pair: pair));

  /// High-level call to retrieve trade volume data.
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
    logVerbose("sending request $url");
    var info = await _client.send(get);
    return await info.stream.bytesToString();
  }

  Future<String> _private(KrakenRequest request, {String? nonce}) async {
    assert(request.scope == Scope.private, "private request expected");

    var url = Uri.parse('https://api.kraken.com/0/private/${request.path}');
    var get = Request('POST', url);
    nonce ??= _nonceGenerator().toString();
    request._update(get, nonce);
    get.headers['API-Key'] = _secret[0];
    get.headers['API-Sign'] = _authenticate(url.path, get.body, nonce, _secret[1]);

    logVerbose("sending request $url: ${get.body}");
    var info = await _client.send(get);
    return await info.stream.bytesToString();
  }

  /// Creates the Kraken API signature ("API-Sign") for a private API call.
  String _authenticate(String path, String data, String nonce, String secret) {
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
  /// represented by [file].
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

extension on KrakenRequest {
  _update(Request get, String nonce) {
    if (body != null) {
      if (params.isNotEmpty) {
        throw ArgumentError("JSON body override requires empty params");
      }
      final data = {"nonce": nonce.toString(), ...body!};
      get.body = jsonEncode(data);
      get.headers['Content-Type'] = "application/json";
    } else {
      var map = params.mapValues((v) => v.toString());
      var data = {"nonce": nonce.toString(), ...map};
      get.bodyFields = data;
    }
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
