import 'dart:math';

// TODO revisit - pretty sure there are better - more dart-ish - ways than most of these

extension ResultPickColumn on MapEntry<String, dynamic> {
  /// Pick columns from the map entry value, based on the given [columns] as
  /// keys. The "dynamic" value is required to be a map, or at least respond to
  /// the [] operator with a String key.
  List pick(List<String> columns) =>
      List.generate(columns.length, (index) => value[columns[index]]);
}

extension ListExtractColumn<T> on List<List<T>> {
  /// Pick a column from a list of lists and return it as a list.
  List<T> extractColumn(int index) => map((e) => e[index]).toList();
}

extension IterableMax on Iterable<int> {
  int toMax() => reduce((value, element) => max(value, element));
}

extension DateTimeExtensions on DateTime {
  bool isFresh({DateTime? now, Duration maxAge = const Duration(hours: 8)}) {
    now ??= DateTime.now();
    return now.difference(this) < maxAge;
  }
}

extension IterablToMap<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap() => Map.fromEntries(this);
}

// TODO couldn't make this work for new key type R - revisit
extension MapKeys<K, V> on Map<K, V> {
  Map<K, V> mapKeys(K Function(K k) f) => map((k, v) => MapEntry(f(k), v));
}

extension MapPlusMap<K, V> on Map<K, V> {
  Map<K, V> operator +(Map<K, V> other) => this..addAll(other);
}

extension MapWhere<K, V> on Map<K, V> {
  Map<K, V> where(bool Function(K, V) test) =>
      entries.where((element) => test(element.key, element.value)).toMap();
}

extension MapEntries on Map<String, dynamic> {
  Map<String, String> mapValues(String Function(dynamic v) f) => map((k, v) => MapEntry(k, f(v)));
}

extension MapAccess on Map<String, dynamic> {
  Map<String, dynamic> dynamicMap(String key) => (this[key] as Map<String, dynamic>);

  List<dynamic> list(String key) => (this[key] as List<dynamic>);

  List<String> stringList(String key) => list(key).whereType<String>().toList();
}

extension IntExtensions on int {
  Duration get seconds => Duration(seconds: this);

  Duration get minutes => Duration(minutes: this);

  Duration get milliseconds => Duration(milliseconds: this);

  Duration get hours => Duration(hours: this);
}

extension StringExtensions on String {
  int? toInt() => int.tryParse(this);
}

extension ListNullOrEmpty on List<dynamic>? {
  bool get isNullOrEmpty => this?.isEmpty ?? true;

  bool get isNullOrNotEmpty => this?.isNotEmpty ?? true;
}

extension MapToTable on Map<String, dynamic> {
  List<List<String>> asTableData() => [
        keys.toList(),
        values.map((e) => e.toString()).toList(),
      ].toList();

  List<List<String>> asVerticalTableData(List<String> columns) {
    if (isEmpty) return [];
    final check = entries.first.value;
    if (check is List) {
      if (columns.length != check.length + 1 /*key column*/) {
        throw ArgumentError("columns must match key + value list length");
      }
      return [
        columns,
        ...entries.map((e) => [e.key, ...(e.value as List<dynamic>).map((e) => e.toString())]),
      ].toList();
    } else {
      return [
        columns,
        ...entries.map((e) => [e.key, e.value.toString()]),
      ].toList();
    }
  }
}

extension DoubleToKrakenDateTime on double {
  DateTime toKrakenDateTime() =>
      DateTime.fromMillisecondsSinceEpoch((this * 1000).toInt(), isUtc: true);
}

extension IntToKrakenDateTime on int {
  DateTime toKrakenDateTime() => DateTime.fromMillisecondsSinceEpoch(this * 1000, isUtc: true);
}

extension ModifyList on List<dynamic> {
  List<T> castEach<T>() => map((dynamic e) => e as T).toList();

  List<dynamic> modify<T>(int index, dynamic Function(T) modifier) {
    this[index] = modifier(this[index]);
    return this;
  }
}

extension MapList<T, R> on List<T> {
  /// In contrast to [map], this will return a [List] instead.
  List<R> map_(R Function(T) mapper) => map(mapper).toList();
}

extension ListOfT<T> on List<T> {
  List<T> reverse() => reversed.toList();

  List<int> indexWhere_(bool Function(T) select) =>
      indexed.where((it) => select(it.$2)).map((e) => e.$1).toList();
}

List<T> pickColumns<T>(List<T> row, List<int> columns) => [for (final c in columns) row[c]];

bool isNegative(int idx) => idx < 0;
