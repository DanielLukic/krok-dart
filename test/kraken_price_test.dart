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
}
