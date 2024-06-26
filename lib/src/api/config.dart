part of 'api.dart';

class KrakenConfig {
  String apiKey;
  String privateKey;
  Client? client;
  NonceGenerator? nonceGenerator;

  KrakenConfig(this.apiKey, this.privateKey, {this.client, this.nonceGenerator});

  factory KrakenConfig.from(String apiKey, String privateKey) {
    return KrakenConfig(apiKey, privateKey);
  }

  factory KrakenConfig.fromFile(String path) {
    path = expand(path);
    var file = File(path);
    var lines = file.readAsLinesSync();
    return KrakenConfig(lines[0], lines[1]);
  }
}

String expand(String path) {
  if (path.contains("~")) {
    path = path.replaceFirst(RegExp(r"[^~]*~"), "");
    path = Platform.environment["HOME"].toString() + path;
  }
  return path;
}
