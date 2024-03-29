import 'package:krok/src/cli/cli.dart';
import 'package:test/test.dart';

class TabularTest with Tabular {}

void main() {
  late TabularTest subject;

  setUp(() {
    subject = TabularTest();
  });

  test('leaves raw data unchanged', () {
    // given
    final rows = [
      ["a", "b", "c"],
      ["0", "1", "2"],
    ];

    // when
    final actual = subject.modifyDateTimeColumns(rows);

    // then
    expect(rows, hasLength(2)); // bug: incoming data must not be changed
    expect(
      actual,
      containsAllInOrder([
        ["a", "b", "c"],
        ["0", "1", "2"],
      ]),
    );
  });

  test('transforms time column', () {
    // given
    final rows = [
      ["a", "time", "c"],
      ["0", "1700000000", "2"],
    ];

    // when
    final actual = subject.modifyDateTimeColumns(rows);

    // then
    expect(rows, hasLength(2)); // bug: incoming data must not be changed
    expect(
      actual,
      containsAllInOrder([
        ["a", "time", "c"],
        ["0", "2023-11-14 22:13:20.000Z", "2"],
      ]),
    );
  });
}
