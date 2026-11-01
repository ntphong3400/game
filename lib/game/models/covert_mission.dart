/// Costs, risks and outcomes are frozen when a covert mission is dispatched.
class CovertMission {
  const CovertMission({
    required this.spyId,
    required this.funding,
    required this.chance,
    required this.deathRisk,
    required this.succeeded,
    required this.fatal,
  });
  final String spyId;
  final int funding, chance, deathRisk;
  final bool succeeded, fatal;
  factory CovertMission.fromJson(Map<String, dynamic> j) => CovertMission(
    spyId: j['spyId'],
    funding: j['funding'],
    chance: j['chance'],
    deathRisk: j['deathRisk'],
    succeeded: j['succeeded'] == true,
    fatal: j['fatal'] == true,
  );
  Map<String, dynamic> toJson() => {
    'spyId': spyId,
    'funding': funding,
    'chance': chance,
    'deathRisk': deathRisk,
    'succeeded': succeeded,
    'fatal': fatal,
  };
}
