const countryNames = {
  'north': 'Hàn Kỳ',
  'west': 'Xích Lĩnh',
  'south': 'Bích Trạch',
};

const countryPlaceNames = {
  'palace': 'Vương cung',
  'embassy': 'Sứ quán',
  'border': 'Biên thành',
};

String countryRoute(String country, [String? place]) =>
    'country-$country${place == null ? '' : '-$place'}';

String? countryFromRoute(String route) {
  final parts = route.split('-');
  return parts.length >= 2 &&
          parts[0] == 'country' &&
          countryNames.containsKey(parts[1]) &&
          (parts.length == 2 ||
              (parts.length == 3 && countryPlaceNames.containsKey(parts[2])))
      ? parts[1]
      : null;
}

String? countryPlace(String route) =>
    countryFromRoute(route) != null && route.split('-').length == 3
        ? route.split('-').last
        : null;
