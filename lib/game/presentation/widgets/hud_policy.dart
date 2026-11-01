import '../../models/game_state.dart';
import '../../logic/frontier_rules.dart' show garrisonNames;
import 'country_routes.dart';
import 'frontier_routes.dart';
import 'locality_routes.dart';

/// Page names and parents shared by the top bar and its back link.
String hudTitleFor(GameState state, String section) {
  final locality = LocalityPlace.fromRoute(section);
  if (locality != null) return locality.landmark;
  final country = countryFromRoute(section);
  if (country != null) {
    final place = countryPlace(section);
    return place == null
        ? state.warfare?.neighbors
                .where((n) => n.id == country)
                .firstOrNull
                ?.name ??
            countryNames[country]!
        : countryPlaceNames[place]!;
  }
  final frontier = frontierCountry(section);
  if (frontier != null) {
    final place = frontierPlace(section);
    return place == null
        ? garrisonNames[frontier]!
        : frontierPlaceNames[place]!;
  }
  return switch (section) {
    'citadel' => 'Giang Sơn',
    'capital' => 'Kinh Thành',
    'locality' => 'Địa phương',
    'court' => 'Triều chính',
    'kingdom' => 'Quốc sự',
    'treasury' => 'Ngân khố',
    'people' => 'Triều thần',
    'people-government' => 'Bộ máy triều đình',
    'harem' => 'Hậu cung',
    'harem-management' => 'Học tập & cung vụ',
    'health' => 'Long thể',
    'journal' => 'Sử quán',
    'population' => 'Dân cư & Lao động',
    'military' => 'Quân sự',
    'scores' => 'Vọng Thiên Các',
    _ => 'Vạn Tuế',
  };
}

String? hudParentFor(String section) {
  if (LocalityPlace.fromRoute(section) != null) return 'locality';
  final country = countryFromRoute(section);
  if (country != null) {
    return countryPlace(section) == null ? 'citadel' : countryRoute(country);
  }
  final frontier = frontierCountry(section);
  if (frontier != null) {
    return frontierPlace(section) == null ? 'citadel' : frontierRoute(frontier);
  }
  return switch (section) {
    'citadel' => null,
    'capital' || 'locality' || 'population' || 'military' => 'citadel',
    'kingdom' => 'court',
    'people-government' => 'people',
    'harem-management' => 'harem',
    _ => 'capital',
  };
}
