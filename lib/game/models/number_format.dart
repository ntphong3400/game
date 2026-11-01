/// Vietnamese grouping for whole-valued resources. Does not abbreviate or
/// change the value kept by the engine.
String formatWholeNumber(num value) =>
    value.round().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

final _largeInteger = RegExp(r'\d{4}');
final _numberToken = RegExp(
  r'(?<![\p{L}\p{N}_.])\d+(?:[.,]\d+)*(?![\p{L}\p{N}_])',
  unicode: true,
);
final _identifierPrefix = RegExp(
  r'(?:[\p{L}_][\p{L}\p{N}_]*-|(?:năm|year|seed|id|mã(?: hồ sơ)?|version|phiên bản)\s*[:#]?\s*)$',
  unicode: true,
  caseSensitive: false,
);
final _protectedText = RegExp(
  r'https?://\S+|\b\d{1,4}[-/]\d{1,2}[-/]\d{1,4}\b',
);

/// Formats display text from hints, saved journals, forecasts and reports at
/// the UI boundary. Existing grouping, small decimals, versions, IDs, dates,
/// URLs and zero-padded identifiers are preserved. Safe to apply repeatedly.
String formatGameNumbers(String text) {
  if (!_largeInteger.hasMatch(text)) return text;
  final protected = _protectedText.allMatches(text).toList();
  return text.replaceAllMapped(_numberToken, (match) {
    final token = match[0]!;
    if (protected.any((p) => match.start >= p.start && match.start < p.end)) {
      return token;
    }
    final prefix = text.substring(0, match.start);
    if (_identifierPrefix.hasMatch(prefix) || prefix.endsWith('^')) {
      return token;
    }
    final parts = token.split(RegExp(r'[.,]'));
    final integer = parts.first;
    if (integer.length < 4 || integer.startsWith('0')) return token;
    // Multiple separators denote an already grouped value or a version.
    if (parts.length > 2) return token;
    final grouped = integer.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return parts.length == 1 ? grouped : '$grouped,${parts.last}';
  });
}
