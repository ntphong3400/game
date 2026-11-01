import 'number_format.dart';

String moneyNumber(num value) => formatWholeNumber(value);

String convertAuthoredMoneyText(String text) {
  final pattern = RegExp(
    r'(?<![\d.])([−+\-]?\d+(?:[–]\d+)?)\s+tiền|((?:[Nn]gân khố|[Nn]ợ)\s*[+:−\-]?\s*)(\d+)(?![\d.])(?:\s+tiền|(?!(?:\s+lượng)))',
  );
  String scale(String number) => number.replaceAllMapped(
    RegExp(r'\d+'),
    (m) => moneyNumber(int.parse(m[0]!) * 100),
  );
  return text
      .replaceAllMapped(
        pattern,
        (m) =>
            m[1] != null
                ? '${scale(m[1]!)} lượng vàng'
                : '${m[2]}${scale(m[3]!)} lượng vàng',
      )
      .replaceAll(RegExp(r'\btiền\b'), 'vàng');
}
