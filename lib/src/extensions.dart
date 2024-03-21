part of 'api.dart';

extension DateTimeExtensions on DateTime {
  bool isFresh({DateTime? now, Duration maxAge = const Duration(hours: 8)}) {
    now ??= DateTime.now();
    return now.difference(this) < maxAge;
  }
}

extension<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap() => Map.fromEntries(this);
}

extension MapWhere<K, V> on Map<K, V> {
  Map<K, V> where(bool Function(K, V) test) =>
      entries.where((element) => test(element.key, element.value)).toMap();
}

extension MapValues on Map<String, dynamic> {
  Map<String, String> mapValues(String Function(dynamic v) f) =>
      map((k, v) => MapEntry(k, f(v)));
}

extension MapAccess on Map<String, dynamic> {
  Map<String, dynamic> dynamicMap(String key) =>
      (this[key] as Map<String, dynamic>);

  List<dynamic> list(String key) => (this[key] as List<dynamic>);

  List<String> stringList(String key) => list(key).whereType<String>().toList();
}

extension IntExtensions on int {
  get seconds => Duration(seconds: this);

  get minutes => Duration(minutes: this);

  get milliseconds => Duration(milliseconds: this);

  get hours => Duration(hours: this);
}
