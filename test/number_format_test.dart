import 'package:flutter_test/flutter_test.dart';
import 'package:van_tue/game/models/number_format.dart';

void main() {
  test(
    'whole resource values use Vietnamese grouping without abbreviations',
    () {
      expect(formatWholeNumber(0), '0');
      expect(formatWholeNumber(999), '999');
      expect(formatWholeNumber(1000), '1.000');
      expect(formatWholeNumber(1000000), '1.000.000');
      expect(formatWholeNumber(-12500000), '-12.500.000');
    },
  );

  test(
    'mixed display text groups costs, reports, ranges and signed changes',
    () {
      const raw =
          'Chi 4500 lượng vàng; kho 4000000/8000000 tạ. '
          'Quân +12500, dân −1000000; nhận 2500–17000. Ngân khố:50000.';
      const expected =
          'Chi 4.500 lượng vàng; kho 4.000.000/8.000.000 tạ. '
          'Quân +12.500, dân −1.000.000; nhận 2.500–17.000. Ngân khố:50.000.';
      expect(formatGameNumbers(raw), expected);
      expect(formatGameNumbers(expected), expected);
      expect(
        formatGameNumbers('999999999999999999999'),
        '999.999.999.999.999.999.999',
      );
    },
  );

  test(
    'already formatted values, small decimals, versions and IDs stay intact',
    () {
      const text =
          '1.000.000 tạ; 2.323,12 vàng; 1.25% / 0,5; '
          'mvp-0.27.0; DB-1000; ID:123456; mã hồ sơ 123456; 000123; '
          'Xuân · năm 1000; 01/11/2026; 2026-11-01; '
          'https://example.com/123456/50000. Cấp 2/5; 80/100/125%.';
      expect(formatGameNumbers(text), text);
      expect(formatGameNumbers('1.000.000 + 4500'), '1.000.000 + 4.500');
      expect(formatGameNumbers('4500.75 vàng'), '4.500,75 vàng');
      expect(formatGameNumbers('4.500,75 vàng'), '4.500,75 vàng');
    },
  );
}
