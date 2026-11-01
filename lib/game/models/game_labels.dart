const stabilityLabel = 'Ổn định triều đình';
const stabilityDescription =
    'Mức hợp tác và trật tự trong triều đình, từ 0–100. '
    'Điểm thấp thể hiện chia rẽ và tranh quyền; về 0, vua bị phế truất.';

/// Display aliases keep saved reports readable without rewriting their data.
String gameStatLabel(String label) =>
    const ['Triều đình', 'triều đình', 'Ổn định', 'ổn định'].contains(label)
        ? stabilityLabel
        : label;

String gameStatText(String text) => text.replaceAll(
  RegExp(
    r'(?:[Ổổ]n định triều đình|[Tt]riều đình|[Ổổ]n định)(?=\s+[+−\-]|\s+\d)',
  ),
  stabilityLabel,
);
