import '../../app/game_controller.dart';
import 'widgets/country_routes.dart';
import 'widgets/frontier_routes.dart';
import 'widgets/locality_routes.dart';

/// The URL contract. Internal section keys remain independent of public paths.
class GameLocation {
  const GameLocation(this.section, {this.characterId, this.returnTo});

  final String section;
  final String? characterId;
  final String? returnTo;

  static final sectionPaths = <String, String>{
    'home': '/',
    'citadel': '/citadel',
    'capital': '/capital',
    'locality': '/locality',
    for (final place in LocalityPlace.values)
      place.route: '/locality/${place.name}',
    for (final country in countryNames.keys) ...{
      countryRoute(country): '/country/$country',
      for (final place in countryPlaceNames.keys)
        countryRoute(country, place): '/country/$country/$place',
      frontierRoute(country): '/frontier/$country',
      for (final place in frontierPlaceNames.keys)
        frontierRoute(country, place): '/frontier/$country/$place',
    },
    for (final section in [
      'court',
      'kingdom',
      'treasury',
      'population',
      'military',
      'people',
      'harem',
      'health',
      'journal',
      'scores',
    ])
      section: '/$section',
    'people-government': '/people/government',
    'harem-management': '/harem/management',
    'ending': '/ending',
    'ending-summary': '/ending/summary',
  };

  static String pathFor(String section) => sectionPaths[section]!;

  static String? sectionFor(String? path) {
    final uri = Uri.tryParse(path ?? '');
    if (uri == null || uri.hasScheme || uri.hasAuthority || uri.hasFragment) {
      return null;
    }
    return sectionPaths.entries
        .where((e) => e.value == uri.path)
        .firstOrNull
        ?.key;
  }

  static GameLocation? parse(Uri uri) {
    final path =
        uri.path.length > 1 && uri.path.endsWith('/')
            ? uri.path.substring(0, uri.path.length - 1)
            : uri.path;
    final section = sectionFor(path);
    final parts = [...uri.pathSegments];
    if (parts.lastOrNull == '') parts.removeLast();
    final meeting =
        parts.length == 3 &&
        ['people', 'harem'].contains(parts.first) &&
        parts[1] == 'meet' &&
        parts[2].isNotEmpty;
    if (section == null && !meeting) return null;
    final from = uri.queryParameters['from'];
    return GameLocation(
      section ?? parts.first,
      characterId: meeting ? parts[2] : null,
      returnTo: sectionFor(from) != null ? from : null,
    );
  }

  Uri get uri => Uri(
    path: characterId == null ? pathFor(section) : null,
    pathSegments:
        characterId == null ? null : ['', section, 'meet', characterId!],
    queryParameters: returnTo == null ? null : {'from': returnTo!},
  );

  String get backgroundSection =>
      characterId == null ? section : sectionFor(returnTo) ?? section;

  String get screen => switch (backgroundSection) {
    'people-government' => 'people',
    'harem-management' => 'harem',
    final value => value,
  };

  String get backPath => returnTo ?? pathFor(section);

  /// Never redirect on an empty archive until its asynchronous load completes.
  static String? redirect(GameController controller, Uri uri) {
    final location = parse(uri);
    if (location == null) return null; // The router renders the not-found page.
    if (controller.loading) return null;
    final state = controller.state;
    if (state == null) {
      if (['home', 'scores'].contains(location.section)) return null;
      return Uri(
        path: '/',
        queryParameters: {'continue': uri.toString()},
      ).toString();
    }
    if (state.ended &&
        ![
          'home',
          'scores',
          'ending',
          'ending-summary',
        ].contains(location.section)) {
      return '/ending';
    }
    if (!state.ended &&
        ['ending', 'ending-summary'].contains(location.section)) {
      return '/citadel';
    }
    if (location.section == 'people-government' && !state.hasCourtSystem) {
      return '/people';
    }
    if (location.section == 'harem-management' && !state.seasonal) {
      return '/harem';
    }
    if (frontierCountry(location.section) != null &&
        (state.warfare == null || state.population == null)) {
      return '/citadel';
    }
    if (location.characterId != null) {
      final person =
          [...state.court, ...state.officialsPool]
              .where((p) => p.publicId == location.characterId && p.available)
              .firstOrNull ??
          [...state.court, ...state.officialsPool]
              .where((p) => p.id == location.characterId && p.available)
              .firstOrNull;
      if (person == null) return location.backPath;
      final section = person.isConsort ? 'harem' : 'people';
      if (section != location.section ||
          person.publicId != location.characterId) {
        return GameLocation(
          section,
          characterId: person.publicId!,
          returnTo: location.returnTo,
        ).uri.toString();
      }
    }
    return null;
  }

  static String afterStart(Uri uri) {
    final target = Uri.tryParse(uri.queryParameters['continue'] ?? '');
    return target != null &&
            !target.hasScheme &&
            !target.hasAuthority &&
            parse(target) != null &&
            target.path != '/'
        ? target.toString()
        : '/citadel';
  }
}
