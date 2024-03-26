import 'package:krok/api/api.dart';
import 'package:test/test.dart';

void main() {
  group("handles basic absolute values", () {
    check(String input, String expected) {
      test("$input == $expected", () {
        expect(KrakenPrice.fromString(input, trailingStop: false).it, expected);
      });
    }

    check("0", "0");
    check("1", "1");
    check("0.1", "0.1");
    check(".1", ".1");
    check("+1", "+1");
    check("-1", "-1");
    check("#1", "#1");
    check("1%", "1%");
    check("+1%", "+1%");
    check("-1%", "-1%");
    check("#1%", "#1%");
  });

  group("handles trailing stop values", () {
    check(String input, String expected) {
      test("$input == $expected", () {
        expect(KrakenPrice.fromString(input, trailingStop: true).it, expected);
      });
    }

    check("+1", "+1");
    check("-1", "-1");
    check("+1%", "+1%");
    check("-1%", "-1%");
  });

  group("fails invalid trailing stop values", () {
    fails(String input, Matcher expected) {
      test("$input fails", () {
        expect(() => KrakenPrice.fromString(input, trailingStop: true), expected);
      });
    }

    fails("0", throwsA(isA<ArgumentError>()));
    fails("1", throwsA(isA<ArgumentError>()));
    fails("0.1", throwsA(isA<ArgumentError>()));
    fails(".1", throwsA(isA<ArgumentError>()));
    fails("#1", throwsA(isA<ArgumentError>()));
    fails("1%", throwsA(isA<ArgumentError>()));
    fails("#1%", throwsA(isA<ArgumentError>()));
  });
}
