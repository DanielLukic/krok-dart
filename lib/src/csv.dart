// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:krok/src/extensions.dart';

/// Somewhat generic function to dump a [dataMap] as tabular data, picking
/// the [columns] from [dataMap] and converting each column value to a
/// string via [toString]. The "dynamic" of the [dataMap] is assumed to be
/// List<dynamic>, representing the columns. The [dataMap] keys are used as the
/// first column, with [keyColumn] providing the column name.
dumpTable(
  String keyColumn,
  List<String> columns,
  Map<String, dynamic> dataMap,
  String Function(dynamic)? toString,
) {
  int toStringLength(String it) => it.length;

  final rows = asTableData(keyColumn, columns, dataMap, toString);

  final allColumns = rows.first; // pair + dataColumns
  final columnLengths = List.generate(
    allColumns.length,
    (column) => rows.extractColumn(column).map(toStringLength).toMax(),
  );

  String reformat(List<String> row, List<int> columnLengths) => [
        for (var i = 0; i < allColumns.length; i++)
          " ${row[i].padRight(columnLengths[i])} |"
      ].join("");

  final formatted = rows
      .map(
        (row) => "|${reformat(row, columnLengths)}",
      )
      .toList();

  formatted.insert(1, "".padLeft(formatted.first.length, "-"));
  formatted.forEach(print);
}

/// See [dumpTable]. Same logic, but unformatted CSV output.
dumpCsv(
  String keyColumn,
  List<String> columns,
  Map<String, dynamic> resultMap, [
  String Function(dynamic)? toString,
]) {
  csv(List row) => row.join(",");
  asTableData(keyColumn, columns, resultMap, toString).map(csv).forEach(print);
}

/// Convert the [resultMap] into a list of lists using the given [columns].
/// [toString] is used to convert the "dynamic" column values from the result.
/// The first column uses the keys from [resultMap] with [keyColumn] as name.
List<List<String>> asTableData(
  String keyColumn,
  List<String> columns,
  Map<String, dynamic> resultMap,
  String Function(dynamic)? toString,
) {
  toString ??= (it) => it.toString();
  return [
    [keyColumn, ...columns],
    for (var entry in resultMap.entries)
      [entry.key, ...entry.pick(columns).map(toString)]
  ].toList();
}

/// Dumb output of [resultMap] by printing each key plus the value in a line.
dumpByKey(Map<String, dynamic> resultMap) {
  for (var entry in resultMap.entries) {
    print("${entry.key}: ${resultMap[entry.key]}");
  }
}
