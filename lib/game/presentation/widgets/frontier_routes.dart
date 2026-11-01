String frontierRoute(String country, [String? place]) =>
    'frontier-$country${place == null ? '' : '-$place'}';
String? frontierCountry(String route) {
  final parts = route.split('-');
  return parts.length >= 2 &&
          parts[0] == 'frontier' &&
          ['north', 'west', 'south'].contains(parts[1]) &&
          (parts.length == 2 ||
              (parts.length == 3 && frontierPlaceNames.containsKey(parts[2])))
      ? parts[1]
      : null;
}

String? frontierPlace(String route) =>
    frontierCountry(route) != null && route.split('-').length == 3
        ? route.split('-').last
        : null;
const frontierPlaceNames = {
  'camp': 'Doanh Trại',
  'command': 'Phủ Trấn Thủ',
  'gate': 'Cửa Ải',
};
