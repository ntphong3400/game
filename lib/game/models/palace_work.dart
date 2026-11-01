/// Turn indexes follow the save's cadence; new palace work is seasonal only.
class PalaceWork {
  PalaceWork({
    required this.id,
    required this.kind,
    required this.personId,
    required this.startedTurn,
    required this.duration,
    this.progress = 0,
    this.faction = '',
  });
  final String id, kind, personId, faction;
  final int startedTurn, duration;
  int progress;
  int get dueTurn => startedTurn + duration - 1;
  factory PalaceWork.fromJson(Map<String, dynamic> j) => PalaceWork(
    id: j['id'],
    kind: j['kind'],
    personId: j['personId'],
    startedTurn: j['startedTurn'],
    duration: j['duration'],
    progress: j['progress'] ?? 0,
    faction: j['faction'] ?? '',
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'personId': personId,
    'startedTurn': startedTurn,
    'duration': duration,
    'progress': progress,
    'faction': faction,
  };
}

class PalaceEffect {
  PalaceEffect({
    required this.kind,
    required this.personId,
    required this.startsTurn,
    required this.endsTurn,
    required this.amount,
    this.uses = 0,
  });
  final String kind, personId;
  final int startsTurn, endsTurn, amount;
  int uses;
  bool active(int turn) => startsTurn <= turn && turn <= endsTurn;
  factory PalaceEffect.fromJson(Map<String, dynamic> j) => PalaceEffect(
    kind: j['kind'],
    personId: j['personId'],
    startsTurn: j['startsTurn'],
    endsTurn: j['endsTurn'],
    amount: j['amount'],
    uses: j['uses'] ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'kind': kind,
    'personId': personId,
    'startsTurn': startsTurn,
    'endsTurn': endsTurn,
    'amount': amount,
    'uses': uses,
  };
}
