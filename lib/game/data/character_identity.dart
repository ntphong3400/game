import 'dart:math';

import '../models/game_state.dart';

final _publicIdPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);
final _identityRandom = Random.secure();

bool isCharacterPublicId(String? value) =>
    value != null && _publicIdPattern.hasMatch(value);

String _newPublicId() {
  final bytes = List.generate(16, (_) => _identityRandom.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // UUID v4.
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

bool needsCharacterPublicIds(GameState state) {
  final byInternalId = <String, String>{};
  final byPublicId = <String, String>{};
  for (final person in [...state.court, ...state.officialsPool]) {
    final publicId = person.publicId;
    if (!isCharacterPublicId(publicId) ||
        (byInternalId.containsKey(person.id) &&
            byInternalId[person.id] != publicId) ||
        (byPublicId.containsKey(publicId) &&
            byPublicId[publicId] != person.id)) {
      return true;
    }
    byInternalId[person.id] = publicId!;
    byPublicId[publicId] = person.id;
  }
  return false;
}

/// Called inside the archive's write transaction. Allocate once per logical
/// person, including inactive people and copies shared by court/candidate pool.
/// The pure engine never generates random IDs or consumes gameplay RNG for them.
void ensureCharacterPublicIds(GameState state) {
  final groups = <String, List<Courtier>>{};
  for (final person in [...state.court, ...state.officialsPool]) {
    (groups[person.id] ??= []).add(person);
  }
  final used = <String>{};
  final reserved =
      groups.values
          .expand((people) => people)
          .map((p) => p.publicId)
          .whereType<String>()
          .where(isCharacterPublicId)
          .toSet();
  for (final people in groups.values) {
    var publicId =
        people
            .map((p) => p.publicId)
            .whereType<String>()
            .where((id) => isCharacterPublicId(id) && !used.contains(id))
            .firstOrNull;
    if (publicId == null) {
      do {
        publicId = _newPublicId();
      } while (reserved.contains(publicId) || used.contains(publicId));
    }
    used.add(publicId);
    for (final person in people) {
      person.publicId = publicId;
    }
  }
}
