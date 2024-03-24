part of 'cli.dart';

abstract mixin class _PublicCall {
  autoClose(KrakenApi api);

  run() async {
    final api = KrakenApi.fromFile(_keyFilePath);
    try {
      await autoClose(api);
    } finally {
      api.close();
    }
  }
}
