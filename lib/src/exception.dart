part of 'api.dart';

class KrakenException implements Exception {
  final String message;

  KrakenException(this.message);

  @override
  String toString() => message;
}
