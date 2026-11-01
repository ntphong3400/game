/// Persisted diplomacy and campaigns. Troop reservations live in PopulationState.
class WarfareState {
  List<NeighborState> neighbors = [
    NeighborState('north', 'Hàn Kỳ', 'Phía Bắc'),
    NeighborState('west', 'Xích Lĩnh', 'Phía Tây'),
    NeighborState('south', 'Bích Trạch', 'Phía Nam'),
  ];
  List<WarMission> missions = [];
  List<Map<String, dynamic>> reports = [];
  int sequence = 0;
  int lastDefenseWeek = 0;
  NeighborState? get active =>
      neighbors.where((n) => n.status == 'war').firstOrNull;
  // Derive the opening draw from the saved run seed without consuming gameplay
  // RNG. Reloading and upgrading cannot reroll diplomacy or pending battles.
  WarfareState({required int seed}) {
    final neutral = (seed * 48271 % 2147483647) % neighbors.length;
    for (var i = 0; i < neighbors.length; i++) {
      neighbors[i].relation = i == neutral ? 0 : 10;
    }
  }
  factory WarfareState.fromJson(Map<String, dynamic> j, {required int seed}) {
    final w = WarfareState(seed: seed);
    final openingRelations = {for (final n in w.neighbors) n.id: n.relation};
    w.neighbors =
        (j['neighbors'] as List)
            .map((n) => NeighborState.fromJson(Map<String, dynamic>.from(n)))
            .toList();
    if (((j['initialSetupVersion'] as num?)?.toInt() ?? 1) < 2) {
      // Correct the old +10 advantage on north/west while retaining subsequent
      // diplomacy and combat changes, reservations, treaties and frozen rolls.
      for (final n in w.neighbors) {
        if (n.id == 'north' || n.id == 'west') {
          n.advantage = (n.advantage - 10).clamp(-100, 100);
        }
        n.relation = (n.relation + (openingRelations[n.id] ?? 0)).clamp(
          -100,
          100,
        );
      }
    }
    w.missions =
        (j['missions'] as List? ?? [])
            .map((m) => WarMission.fromJson(Map<String, dynamic>.from(m)))
            .toList();
    w.reports =
        (j['reports'] as List? ?? [])
            .map((r) => Map<String, dynamic>.from(r))
            .toList();
    w.sequence = j['sequence'] ?? 0;
    w.lastDefenseWeek = j['lastDefenseWeek'] ?? 0;
    if (j['frontierVersion'] == null) {
      for (final n in w.neighbors) {
        final reserved = w.missions
            .where(
              (m) =>
                  m.countryId == n.id &&
                  ['open', 'deployed', 'returning'].contains(m.status),
            )
            .fold<int>(0, (total, m) => total + m.enemyTroops);
        if (reserved > n.enemyTroops) n.enemyTroops = reserved;
      }
    }
    return w;
  }
  Map<String, dynamic> toJson() => {
    'initialSetupVersion': 2,
    'frontierVersion': 1,
    'lastDefenseWeek': lastDefenseWeek,
    'neighbors': neighbors.map((n) => n.toJson()).toList(),
    'missions': missions.map((m) => m.toJson()).toList(),
    'reports': reports,
    'sequence': sequence,
  };
}

class NeighborState {
  NeighborState(this.id, this.name, this.direction, {this.advantage = 0});
  final String id, name, direction;
  int relation = 0, advantage;
  String status = 'peace';
  int cooldownUntil = 0, warStarted = 0, nextMission = 0;
  int enemyQuality = 65, fortification = 65;
  int enemyTroops = 12500, lastReinforcementYear = 0;
  int lastReinforcement = 0, lastReinforcementRoll = 0;
  int defenseGraceThrough = 0;
  bool capitalWarned = false;
  int oldPayable = 0, oldReceivable = 0;
  TributeTreaty? treaty;
  factory NeighborState.fromJson(Map<String, dynamic> j) {
    final n = NeighborState(
      j['id'],
      j['name'],
      j['direction'],
      advantage: j['advantage'] ?? 0,
    );
    n.oldPayable = j['oldPayable'] ?? 0;
    n.oldReceivable = j['oldReceivable'] ?? 0;
    n.relation = j['relation'] ?? 0;
    n.status = j['status'] ?? 'peace';
    n.cooldownUntil = j['cooldownUntil'] ?? 0;
    n.warStarted = j['warStarted'] ?? 0;
    n.nextMission = j['nextMission'] ?? 0;
    n.enemyQuality = j['enemyQuality'] ?? 65;
    n.enemyTroops = j['enemyTroops'] ?? 12500;
    n.lastReinforcementYear = j['lastReinforcementYear'] ?? 0;
    n.lastReinforcement = j['lastReinforcement'] ?? 0;
    n.lastReinforcementRoll = j['lastReinforcementRoll'] ?? 0;
    n.defenseGraceThrough = j['defenseGraceThrough'] ?? n.cooldownUntil;
    n.fortification = j['fortification'] ?? 65;
    n.capitalWarned = j['capitalWarned'] == true;
    if (j['treaty'] != null) {
      n.treaty = TributeTreaty.fromJson(Map<String, dynamic>.from(j['treaty']));
    }
    return n;
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'direction': direction,
    'oldPayable': oldPayable,
    'oldReceivable': oldReceivable,
    'relation': relation,
    'advantage': advantage,
    'status': status,
    'cooldownUntil': cooldownUntil,
    'warStarted': warStarted,
    'nextMission': nextMission,
    'enemyQuality': enemyQuality,
    'enemyTroops': enemyTroops,
    'lastReinforcementYear': lastReinforcementYear,
    'lastReinforcement': lastReinforcement,
    'lastReinforcementRoll': lastReinforcementRoll,
    'defenseGraceThrough': defenseGraceThrough,
    'fortification': fortification,
    'capitalWarned': capitalWarned,
    'treaty': treaty?.toJson(),
  };
}

class TributeTreaty {
  TributeTreaty({
    required this.tier,
    required this.receiving,
    required this.annualGold,
    required this.signed,
    required this.installments,
  });
  final String tier;
  final bool receiving;
  final int annualGold, signed, installments;
  int paidInstallments = 0, arrears = 0, graceUntil = 0, extensions = 0;
  bool broken = false, incomingWithheld = false;
  int get nextDue => signed + (paidInstallments + 1) * 4;
  bool get completed => paidInstallments >= installments && arrears == 0;
  factory TributeTreaty.fromJson(Map<String, dynamic> j) {
    final t = TributeTreaty(
      tier: j['tier'],
      receiving: j['receiving'],
      annualGold: j['annualGold'],
      signed: j['signed'],
      installments: j['installments'],
    );
    t.paidInstallments = j['paidInstallments'] ?? 0;
    t.arrears = j['arrears'] ?? 0;
    t.graceUntil = j['graceUntil'] ?? 0;
    t.extensions = j['extensions'] ?? 0;
    t.broken = j['broken'] == true;
    t.incomingWithheld = j['incomingWithheld'] == true;
    return t;
  }
  Map<String, dynamic> toJson() => {
    'tier': tier,
    'receiving': receiving,
    'annualGold': annualGold,
    'signed': signed,
    'installments': installments,
    'paidInstallments': paidInstallments,
    'arrears': arrears,
    'graceUntil': graceUntil,
    'extensions': extensions,
    'broken': broken,
    'incomingWithheld': incomingWithheld,
  };
}

class WarMission {
  WarMission({
    required this.id,
    required this.countryId,
    required this.kind,
    required this.title,
    required this.enemyTroops,
    required this.opened,
    required this.deadline,
    this.naval = false,
  });
  final String id, countryId, kind, title;
  final int enemyTroops, opened, deadline;
  final bool naval;
  String status = 'open', officerId = '', deputyId = '', tactic = 'balanced';
  int troops = 0, due = 0, relief = 0;
  bool intervention = false;
  String majorId = '', objectiveKey = '';
  Map<String, int> successEffects = {}, failureEffects = {};
  int get duration => ['siege', 'battle', 'capital'].contains(kind) ? 2 : 1;
  int get advantageValue => switch (kind) {
    'scout' => 6,
    'supply' => 8,
    'raid' => 12,
    'relieve' => 12,
    'defend' => 15,
    'siege' => 20,
    'capital' => 25,
    _ => 20,
  };
  factory WarMission.fromJson(Map<String, dynamic> j) {
    final m = WarMission(
      id: j['id'],
      countryId: j['countryId'],
      kind: j['kind'],
      title: j['title'],
      enemyTroops: j['enemyTroops'],
      opened: j['opened'],
      deadline: j['deadline'],
      naval: j['naval'] == true,
    );
    m.status = j['status'] ?? 'open';
    m.officerId = j['officerId'] ?? '';
    m.deputyId = j['deputyId'] ?? '';
    m.tactic = j['tactic'] ?? 'balanced';
    m.troops = j['troops'] ?? 0;
    m.due = j['due'] ?? 0;
    m.relief = j['relief'] ?? 0;
    m.intervention = j['intervention'] == true;
    m.majorId = j['majorId'] ?? '';
    m.objectiveKey = j['objectiveKey'] ?? '';
    m.successEffects = Map<String, int>.from(j['successEffects'] ?? {});
    m.failureEffects = Map<String, int>.from(j['failureEffects'] ?? {});
    return m;
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'countryId': countryId,
    'kind': kind,
    'title': title,
    'enemyTroops': enemyTroops,
    'opened': opened,
    'deadline': deadline,
    'naval': naval,
    'status': status,
    'officerId': officerId,
    'deputyId': deputyId,
    'tactic': tactic,
    'troops': troops,
    'due': due,
    'relief': relief,
    'intervention': intervention,
    'majorId': majorId,
    'objectiveKey': objectiveKey,
    'successEffects': successEffects,
    'failureEffects': failureEffects,
  };
}
