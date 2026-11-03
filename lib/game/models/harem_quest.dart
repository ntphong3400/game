import 'game_labels.dart';
import 'personality.dart';

enum HaremBenefit {
  authority('Uy quyền'),
  people('Lòng dân'),
  stability(stabilityLabel),
  treasury('Ngân khố');

  const HaremBenefit(this.label);
  final String label;
  int get cap => this == treasury ? 50 : 5;
}

enum HaremObjective {
  removeOfficial,
  removeConsort,
  familyOffice,
  removePower,
  factionOffice,
}

class HaremChapter {
  const HaremChapter(this.title, this.body, this.choiceA, this.choiceB);
  final String title, body, choiceA, choiceB;
}

class HaremQuestDefinition {
  const HaremQuestDefinition({
    required this.id,
    required this.title,
    required this.traits,
    required this.chapters,
    required this.cost,
    this.benefit,
    this.foundation = false,
    this.queen = false,
    this.objective,
    this.factionLoss = 0,
    this.stat = 'stability',
    this.statLoss = 2,
    this.minGrade = 0,
    this.maxGrade = 0,
    this.factionContext = 'affected',
  });
  final String id, title, stat, factionContext;
  final List<Personality> traits;
  final List<HaremChapter> chapters;
  final HaremBenefit? benefit;
  final bool foundation, queen;
  final HaremObjective? objective;

  /// Authored denomination; multiply by the save's currency scale once.
  final int cost, factionLoss, statLoss, minGrade, maxGrade;
  bool get conflict => objective != null;
  int get requiredSeasons => queen ? 3 : 2;
}

/// One persistent allocation per person and role. Assignment and choices never
/// depend on view rendering, wall clock, or a later personality reveal.
class HaremQuest {
  HaremQuest({
    required this.personId,
    required this.definitionId,
    required this.assignedTurn,
    required this.faction,
    this.queen = false,
    this.targetId = '',
    this.officeId = '',
    List<String>? familyIds,
    List<String>? choices,
    this.stage = 0,
    this.lastChapterTurn = 0,
    this.refusedUntil = 0,
    this.commitmentSince = 0,
    this.verifiedSeasons = 0,
    this.completedTurn = 0,
  }) : familyIds = familyIds ?? [],
       choices = choices ?? [];

  final String personId, definitionId, faction, targetId, officeId;
  final bool queen;
  final int assignedTurn;
  final List<String> familyIds, choices;
  int stage,
      lastChapterTurn,
      refusedUntil,
      commitmentSince,
      verifiedSeasons,
      completedTurn;
  bool get completed => stage == 3;
  String get key => '$personId:${queen ? 'queen' : 'personal'}';

  factory HaremQuest.fromJson(Map<String, dynamic> j) => HaremQuest(
    personId: j['personId'] as String,
    definitionId: j['definitionId'] as String,
    assignedTurn: (j['assignedTurn'] as num?)?.toInt() ?? 1,
    faction: j['faction'] as String,
    queen: j['queen'] == true,
    targetId: j['targetId'] as String? ?? '',
    officeId: j['officeId'] as String? ?? '',
    familyIds: List<String>.from(j['familyIds'] ?? []),
    choices: List<String>.from(j['choices'] ?? []),
    stage: ((j['stage'] as num?)?.toInt() ?? 0).clamp(0, 3),
    lastChapterTurn: (j['lastChapterTurn'] as num?)?.toInt() ?? 0,
    refusedUntil: (j['refusedUntil'] as num?)?.toInt() ?? 0,
    commitmentSince: (j['commitmentSince'] as num?)?.toInt() ?? 0,
    verifiedSeasons: (j['verifiedSeasons'] as num?)?.toInt() ?? 0,
    completedTurn: (j['completedTurn'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'personId': personId,
    'definitionId': definitionId,
    'assignedTurn': assignedTurn,
    'faction': faction,
    'queen': queen,
    'targetId': targetId,
    'officeId': officeId,
    'familyIds': familyIds,
    'choices': choices,
    'stage': stage,
    'lastChapterTurn': lastChapterTurn,
    'refusedUntil': refusedUntil,
    'commitmentSince': commitmentSince,
    'verifiedSeasons': verifiedSeasons,
    'completedTurn': completedTurn,
  };
}
