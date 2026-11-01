import 'dart:convert';
import 'covert_mission.dart';
export 'covert_mission.dart';
import '../logic/management_rules.dart' show initializeManagement;
import 'population.dart';
import 'warfare.dart';
export 'warfare.dart';
import 'currency_migration.dart';
export 'population.dart';
import 'portraits.dart';
export 'portraits.dart';
import 'game_labels.dart';
export 'game_labels.dart';
import 'palace_work.dart';
export 'palace_work.dart';
import 'reign.dart';
import 'personality.dart';
import 'calendar.dart';
import 'court_politics.dart';
import 'court_office.dart';
import 'court_personnel_matter.dart';
export 'court_personnel_matter.dart';
export 'court_office.dart';
import 'petition_assignment.dart';
export 'petition_assignment.dart';
export 'court_politics.dart';
export 'calendar.dart';
export 'personality.dart';
export 'reign.dart';
import 'finance.dart';
import 'outcome_report.dart';
export 'finance.dart';
export 'outcome_report.dart';

const schemaVersion = 2;
const rulesVersion = 'mvp-0.27.0';
const contentVersion = 24;

String specialtyForRole(String role) => switch (role) {
  'Hộ bộ' || 'Thương chính' || 'Quan điền' => 'Kinh tế',
  'Công bộ' || 'Tri phủ' || 'Tuần phủ' => 'Công trình',
  'Đại tướng' ||
  'Phó tướng' ||
  'Đô đốc' ||
  'Biên tướng' ||
  'Đại tư mã' ||
  'Chinh tướng' ||
  'Hiệu úy' ||
  'Đội trưởng' ||
  'Võ quan' ||
  'Trấn thủ' => 'Quân sự',
  'Mật thám' || 'Cấm vệ' || 'Hình bộ' => 'An ninh',
  'Lễ bộ' => 'Ngoại giao',
  'Ngự y' => 'Y thuật',
  'Tiểu thư' ||
  'Tổng quản' ||
  'Ngự tiền' ||
  'Thượng thiện' ||
  'Thượng phục' => 'Cung đình',
  _ => 'Dân chính',
};

int number(Map<String, dynamic> json, String key, [int fallback = 0]) =>
    (json[key] as num?)?.toInt() ?? fallback;
Map<String, dynamic> object(dynamic value) =>
    Map<String, dynamic>.from(value as Map);

String reignTime(int weeks, {bool seasonal = false}) =>
    elapsedTime(weeks, seasonal: seasonal);

/// Intelligence captured at the start, published only after investigation ends.
class CharacterInvestigation {
  const CharacterInvestigation({
    required this.week,
    required this.plot,
    required this.discontent,
  });

  final int week, plot, discontent;

  factory CharacterInvestigation.fromJson(Map<String, dynamic> j) =>
      CharacterInvestigation(
        week: number(j, 'week', 1),
        plot: number(j, 'plot'),
        discontent: number(j, 'discontent').clamp(0, 100),
      );

  Map<String, dynamic> toJson() => {
    'week': week,
    'plot': plot,
    'discontent': discontent,
  };
}

class Courtier {
  Courtier({
    required this.id,
    this.publicId,
    required this.name,
    required this.role,
    required this.faction,
    required this.trait,
    required this.age,
    required this.ability,
    required this.loyalty,
    required this.ambition,
    required this.integrity,
    required this.influence,
    int affection = 50,
    this.baseAffection = 50,
    this.discontent = 0,
    this.investigated = false,
    this.lastInvestigation,
    this.available = true,
    this.inHarem = false,
    this.queen = false,
    this.plot = 0,
    this.strain = 0,
    this.merit = 0,
    this.grade = 0,
    this.meritSpent = 0,
    this.majorMerits = 0,
    this.courtGroup,
    this.royalEligible = false,
    this.retired = false,
    this.imprisoned = false,
    this.dead = false,
    this.evidenceTurn = 0,
    List<CourtMeritRecord>? meritHistory,
    this.assignments = 0,
    this.personalityContacts = 0,
    this.palaceExperience = 0,
    this.managementGrowthHalf = 0,
    this.palaceDutiesCompleted = 0,
    this.palaceCoursesCompleted = 0,
    this.portraitId,
    List<Personality>? personalities,
    String? specialty,
  }) : meritHistory = meritHistory ?? [],
       _affection = affection.clamp(0, 100),
       specialty = specialty ?? specialtyForRole(role),
       personalities = characterPersonalities(
         id: id,
         biography: trait,
         integrity: integrity,
         ambition: ambition,
         saved: personalities,
       );

  String id, name, role, faction, trait, specialty;

  /// Assigned and persisted by the gateway; independent of gameplay IDs/RNG.
  String? publicId;
  int grade, meritSpent, majorMerits;
  String? courtGroup;
  bool royalEligible, retired, imprisoned, dead;
  int evidenceTurn;
  final List<CourtMeritRecord> meritHistory;
  int get totalMerit => merit + meritSpent;
  String? portraitId;
  String get resolvedPortraitId {
    if (validCharacterPortrait(portraitId, harem: isConsort)) {
      return portraitId!;
    }
    final authored = initialPortraits[id];
    if (validCharacterPortrait(authored, harem: isConsort)) return authored!;
    final pool = isConsort ? haremPortraitIds : officialPortraitIds;
    return pool[portraitHash(id) % pool.length];
  }

  PortraitAge get portraitAge => portraitAgeFor(age);
  final List<Personality> personalities;
  int personalityContacts;
  int palaceExperience, palaceDutiesCompleted, palaceCoursesCompleted;
  int managementGrowthHalf;
  num get abilityScore => managementGrowthHalf == 0 ? ability : ability + .5;
  String get abilityLabel =>
      managementGrowthHalf == 0 || ability >= 100 ? '$ability' : '$ability,5';
  int get knownPersonalityCount =>
      (1 + personalityContacts ~/ 3).clamp(1, personalities.length);
  List<Personality> get knownPersonalities =>
      personalities.take(knownPersonalityCount).toList();
  bool get allPersonalitiesKnown =>
      knownPersonalityCount == personalities.length;
  String get knownPersonalityText =>
      knownPersonalities.map((p) => p.label).join(' · ');
  String get personalityProgress =>
      allPersonalitiesKnown
          ? 'Đã hiểu rõ các tính cách qua $personalityContacts lần tiếp xúc.'
          : 'Tính cách khác: chưa rõ · Tìm hiểu tiếp: ${personalityContacts % 3}/3 lần trò chuyện, lắng nghe.';
  int strain, merit, assignments;
  int _affection;
  int get affection => _affection;
  // Management replacement has an explicit relationship cost, including at 100.
  void changeManagementAffection(int delta) =>
      _affection = (_affection + delta).clamp(0, 100);
  // Reaching 100 is permanent, including within one action or season.
  // Persisting affection itself also preserves the lock in older save formats.
  set affection(int value) {
    if (_affection < 100) _affection = value.clamp(0, 100);
  }

  int age,
      ability,
      loyalty,
      ambition,
      integrity,
      influence,
      baseAffection,
      discontent,
      plot;
  bool investigated, available, inHarem, queen;
  CharacterInvestigation? lastInvestigation;
  bool get isConsort => role == 'Tiểu thư';
  String get displayRole =>
      imprisoned
          ? 'Đang bị giam'
          : dead
          ? 'Đã tử nạn'
          : isConsort
          ? category
          : role;
  bool get canHaveAmbition =>
      (grade > 0 && grade <= 3) || politicalAmbitionAllowed(role, queen: queen);
  // Preserve a candidate's potential through promotion without rerolling it.
  // Only politicalAmbition participates in political rules or public profiles.
  int? get politicalAmbition => canHaveAmbition ? ambition : null;
  String get qualitiesText =>
      investigated
          ? 'Đã xác minh: trung thành $loyalty'
              '${canHaveAmbition ? ' · tham vọng $politicalAmbition' : ''}'
              ' · liêm chính $integrity'
          : 'Trung thành${canHaveAmbition ? ', tham vọng' : ''} & liêm chính: chưa xác minh';
  String get category =>
      isConsort
          ? (queen
              ? 'Hoàng hậu'
              : inHarem
              ? 'Phi tần'
              : 'Tú nữ')
          : courtGroup ??
              switch (role) {
                'Đại tướng' ||
                'Phó tướng' ||
                'Đô đốc' ||
                'Cấm vệ' ||
                'Biên tướng' ||
                'Võ quan' ||
                'Trấn thủ' => 'Võ ban',
                'Tri phủ' || 'Tuần phủ' || 'Quan điền' => 'Địa phương',
                'Thân vương' ||
                'Quận vương' ||
                'Tông chính' ||
                'Quốc công' => 'Hoàng thất',
                'Ngự y' ||
                'Mật thám' ||
                'Tổng quản' ||
                'Ngự tiền' => 'Nội đình',
                _ => 'Văn ban',
              };

  factory Courtier.fromJson(Map<String, dynamic> j) => Courtier(
    id: j['id'],
    publicId: j['publicId'] is String ? j['publicId'] as String : null,
    name: j['name'],
    role: j['role'],
    faction: j['faction'],
    trait: j['trait'],
    personalities:
        j['personalities'] is List
            ? (j['personalities'] as List)
                .map(
                  (id) =>
                      Personality.values.where((p) => p.name == id).firstOrNull,
                )
                .whereType<Personality>()
                .toList()
            : null,
    personalityContacts: number(j, 'personalityContacts').clamp(0, 1000000),
    palaceExperience: number(j, 'palaceExperience'),
    palaceDutiesCompleted: number(j, 'palaceDutiesCompleted'),
    palaceCoursesCompleted: number(j, 'palaceCoursesCompleted'),
    portraitId: j['portraitId'] is String ? j['portraitId'] as String : null,
    age: number(j, 'age'),
    ability: number(j, 'ability'),
    managementGrowthHalf: number(j, 'managementGrowthHalf'),
    loyalty: number(j, 'loyalty'),
    ambition: number(j, 'ambition'),
    integrity: number(j, 'integrity'),
    influence: number(j, 'influence'),
    affection: number(j, 'affection'),
    baseAffection: number(j, 'baseAffection', number(j, 'affection')),
    discontent: number(
      j,
      'discontent',
      legacyDiscontent(
        affection: number(j, 'affection', 50),
        plot: number(j, 'plot'),
      ),
    ).clamp(0, 100),
    plot: number(j, 'plot'),
    strain: number(j, 'strain'),
    merit: number(j, 'merit'),
    grade: number(j, 'grade'),
    meritSpent: number(j, 'meritSpent'),
    majorMerits: number(j, 'majorMerits'),
    courtGroup: j['courtGroup'],
    royalEligible: j['royalEligible'] == true,
    retired: j['retired'] == true,
    imprisoned: j['imprisoned'] == true,
    dead: j['dead'] == true,
    evidenceTurn: number(j, 'evidenceTurn'),
    meritHistory:
        (j['meritHistory'] as List? ?? [])
            .map((x) => CourtMeritRecord.fromJson(object(x)))
            .toList(),
    assignments: number(j, 'assignments'),
    specialty: j['specialty'],
    investigated: j['investigated'] == true,
    lastInvestigation:
        j['lastInvestigation'] is Map
            ? CharacterInvestigation.fromJson(object(j['lastInvestigation']))
            : null,
    available: j['available'] != false,
    inHarem: j['inHarem'] == true,
    queen: j['queen'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    if (publicId != null) 'publicId': publicId,
    'name': name,
    'role': role,
    'faction': faction,
    'trait': trait,
    'personalities': personalities.map((p) => p.name).toList(),
    'personalityContacts': personalityContacts,
    'palaceExperience': palaceExperience,
    'palaceDutiesCompleted': palaceDutiesCompleted,
    'palaceCoursesCompleted': palaceCoursesCompleted,
    'portraitId': portraitId,
    'age': age,
    'ability': ability,
    'managementGrowthHalf': managementGrowthHalf,
    'loyalty': loyalty,
    'ambition': ambition,
    'integrity': integrity,
    'influence': influence,
    'affection': affection,
    'baseAffection': baseAffection,
    'discontent': discontent,
    'plot': plot,
    'strain': strain,
    'merit': merit,
    'grade': grade,
    'meritSpent': meritSpent,
    'majorMerits': majorMerits,
    'courtGroup': courtGroup,
    'royalEligible': royalEligible,
    'retired': retired,
    'imprisoned': imprisoned,
    'dead': dead,
    'evidenceTurn': evidenceTurn,
    'meritHistory': meritHistory.map((m) => m.toJson()).toList(),
    'assignments': assignments,
    'specialty': specialty,
    'investigated': investigated,
    if (lastInvestigation != null)
      'lastInvestigation': lastInvestigation!.toJson(),
    'available': available,
    'inHarem': inHarem,
    'queen': queen,
  };
}

class WorkOrder {
  WorkOrder({
    required this.id,
    required this.kind,
    required this.officerId,
    required this.startedWeek,
    required this.duration,
    this.progress = 0,
    this.targetLevel = 0,
    this.successChance = 0,
    this.estimatedChance = 0,
    this.paused = false,
  });
  String id, kind, officerId;
  int startedWeek, duration, progress;
  int targetLevel, successChance, estimatedChance;
  bool paused;
  factory WorkOrder.fromJson(Map<String, dynamic> j) => WorkOrder(
    id: j['id'],
    kind: j['kind'],
    officerId: j['officerId'],
    startedWeek: number(j, 'startedWeek'),
    duration: number(j, 'duration'),
    progress: number(j, 'progress'),
    targetLevel: number(j, 'targetLevel'),
    successChance: number(j, 'successChance'),
    estimatedChance: number(j, 'estimatedChance'),
    paused: j['paused'] == true,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'officerId': officerId,
    'startedWeek': startedWeek,
    'duration': duration,
    'progress': progress,
    'targetLevel': targetLevel,
    'successChance': successChance,
    'estimatedChance': estimatedChance,
    'paused': paused,
  };
}

class Petition {
  Petition({
    required this.id,
    required this.definitionId,
    required this.openedWeek,
    required this.deadline,
    this.targetId = '',
    this.storyId = '',
    this.storyKind = '',
    this.storyStage = 0,
  });
  String id, definitionId, targetId;
  int openedWeek, deadline;
  String storyId, storyKind;
  int storyStage;
  bool get isStory => storyId.isNotEmpty;
  factory Petition.fromJson(Map<String, dynamic> j) => Petition(
    id: j['id'],
    definitionId: j['definitionId'],
    openedWeek: number(j, 'openedWeek'),
    deadline: number(j, 'deadline'),
    targetId: j['targetId'] ?? '',
    storyId: j['storyId'] ?? '',
    storyKind: j['storyKind'] ?? '',
    storyStage: number(j, 'storyStage'),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'definitionId': definitionId,
    'openedWeek': openedWeek,
    'deadline': deadline,
    'targetId': targetId,
    'storyId': storyId,
    'storyKind': storyKind,
    'storyStage': storyStage,
  };
}

class Consequence {
  Consequence({
    required this.kind,
    required this.dueWeek,
    this.target = '',
    this.amount = 0,
    this.effects = const {},
    this.title = '',
    this.detail = '',
    this.assignment,
    this.investigation,
    this.covertMission,
  });
  String kind, target;
  final PetitionAssignment? assignment;
  final CharacterInvestigation? investigation;
  final CovertMission? covertMission;
  String title, detail;
  Map<String, int> effects;
  int dueWeek, amount;
  factory Consequence.fromJson(Map<String, dynamic> j) => Consequence(
    covertMission:
        j['covertMission'] is Map
            ? CovertMission.fromJson(object(j['covertMission']))
            : null,
    kind: j['kind'],
    dueWeek: number(j, 'dueWeek'),
    target: j['target'] ?? '',
    amount: number(j, 'amount'),
    effects: (j['effects'] as Map? ?? {}).map(
      (k, v) => MapEntry(k as String, (v as num).toInt()),
    ),
    title: j['title'] ?? '',
    detail: j['detail'] ?? '',
    assignment:
        j['assignment'] == null
            ? null
            : PetitionAssignment.fromJson(object(j['assignment'])),
    investigation:
        j['investigation'] is Map
            ? CharacterInvestigation.fromJson(object(j['investigation']))
            : null,
  );
  Map<String, dynamic> toJson() => {
    'kind': kind,
    'dueWeek': dueWeek,
    'target': target,
    'amount': amount,
    'effects': effects,
    'title': title,
    'detail': detail,
    if (assignment != null) 'assignment': assignment!.toJson(),
    if (investigation != null) 'investigation': investigation!.toJson(),
    if (covertMission != null) 'covertMission': covertMission!.toJson(),
  };
}

class Chronicle {
  Chronicle(this.week, this.title, this.text, [this.tone = 'neutral']);
  int week;
  String title, text, tone;
  factory Chronicle.fromJson(Map<String, dynamic> j) => Chronicle(
    number(j, 'week'),
    j['title'],
    j['text'],
    j['tone'] ?? 'neutral',
  );
  Map<String, dynamic> toJson() => {
    'week': week,
    'title': title,
    'text': text,
    'tone': tone,
  };
}

class GameState {
  GameState({
    required this.runId,
    required this.playerName,
    required this.seed,
    required this.rng,
    required this.court,
  });
  String runId, playerName;
  // Existing *Week JSON keys are turn indexes. Explicit cadence prevents a
  // historical weekly save ever being interpreted as hundreds of seasons.
  bool seasonal = false;
  String scoreRules = rulesVersion;
  int seasonActionsSpent = 0, seasonPetitionTarget = 0;
  // Legacy JSON name: now records whether all petitions for this season arrived.
  bool midSeasonDelivered = false;
  int storySystemVersion = 1;
  String get periodName => seasonal ? 'mùa' : 'tuần';
  String get periodTitle => seasonal ? 'Mùa' : 'Tuần';
  int get actionsPerTurn => seasonal ? seasonalActions : 3;
  String date(int turn) => seasonal ? seasonDate(turn) : 'tuần $turn';
  String calendarText(String text) =>
      !seasonal
          ? gameStatText(text)
          : gameStatText(text)
              .replaceAll(RegExp(r'\btuần\b(?! phủ)'), 'mùa')
              .replaceAll(RegExp(r'\bTuần\b(?! phủ)'), 'Mùa')
              .replaceAll('TUẦN', 'MÙA');
  String authoredText(String text) =>
      !seasonal
          ? gameStatText(text)
          : calendarText(
            text.replaceAllMapped(
              RegExp(r'(\d+) tuần(?! phủ)'),
              (m) => '${workTurns(int.parse(m[1]!))} mùa',
            ),
          );
  int workTurns(int weeks) => seasonal ? ((weeks + 3) ~/ 4).clamp(1, 2) : weeks;
  int cooldownTurns(int weeks) =>
      seasonal ? ((weeks + 12) ~/ 13).clamp(1, 100) : weeks;
  int seed, rng;
  int revision = 0, completedWeeks = 0, points = 3, overtime = 0;
  PopulationState? population;
  WarfareState? warfare;
  bool goldStandard = false;
  // New reigns opt into the calibrated economy. Missing on historical saves:
  // never reprice an ongoing reign or rewrite already committed outcomes.
  int balanceVersion = 0;
  bool get challengingEconomy => balanceVersion >= 1;
  int treasury = 520, people = 65, authority = 62, army = 60;
  int health = 88, stability = 64, grain = 100, levee = 65;
  int economyLevel = 1, agricultureLevel = 1, leveeLevel = 1;
  // Carry fractional wear in hundredths instead of rounding small wear away.
  int leveeWearRemainder = 0;
  int cropYear = 1, cropBaselineLevee = 65;
  double? springLeveePercent, summerLeveePercent;
  int lastHarvestYear = 0, lastHarvestAmount = 0, lastHarvestWeather = 100;
  double lastHarvestLeveePercent = 100;
  int fatigue = 10, stress = 15, indulgence = 0, illness = 0;
  int workThisWeek = 0, restThisWeek = 0, revelThisWeek = 0;
  int affairsThisWeek = 0, neglectedWeeks = 0;
  int exhaustedWeeks = 0, tax = 1, debt = 0;
  // tax is the selected rate for the next harvest; the applied rate changes
  // only when the autumn levy is settled, never when a chip is selected.
  int lastTaxYear = 0, lastTaxRate = 1, lastTaxRevenue = 0;
  int taxCreditYear = 0, taxCredit = 0, taxSupportCredit = 0;
  int get effectiveTax => seasonal ? lastTaxRate : tax;
  bool get autumnTaxDue => seasonal && season == 'Thu' && lastTaxYear < year;
  int get nextTaxYear =>
      completedWeeks % 4 <= 2 && lastTaxYear < year ? year : year + 1;
  int get nextTaxTurn => (nextTaxYear - 1) * 4 + 3;
  int war = 0, siege = 0, tribute = 0;
  String priority = 'army';
  String hostileFaction = '';
  String? endReason;
  String? endKind, illnessSource;
  List<Courtier> court;
  List<Courtier> officialsPool = [];
  int courtSystemVersion = 0, lastCourtPassiveTurn = 0;
  int managementVersion = 0, lastManagementTurn = 0;
  List<CourtPersonnelMatter> courtPersonnelMatters = [];
  Set<String> courtPersonnelRewarded = {};
  int nextCourtPersonnelTurn = 2, lastCourtRecruitYear = 0;
  bool get hasCourtSystem => courtSystemVersion > 0;
  Courtier? officerForRole(String role) {
    if (hasCourtSystem) {
      final offices =
          courtOffices.where((o) => o.role == role).toList()
            ..sort((a, b) => a.grade.compareTo(b.grade));
      for (final office in offices) {
        final holder =
            court
                .where((c) => c.available && c.id == office.holderId)
                .firstOrNull;
        if (holder != null) return holder;
      }
      return null;
    }
    return court.where((c) => c.available && c.role == role).firstOrNull;
  }

  List<CourtOffice> courtOffices = [];
  Map<String, int> courtTaxSeasons = {};

  /// Upgrade old saves and assign new arrivals without rerolling existing faces.
  /// Prefer never-used identities, then departed people's faces. Only when all
  /// faces are occupied do we reuse the least-shared identity in that group.
  void ensurePortraits() {
    final people = [...court, ...officialsPool];
    final occupied = <String, int>{};
    final used = <String>{};
    for (final c in people) {
      if (!validCharacterPortrait(c.portraitId, harem: c.isConsort)) {
        c.portraitId = null;
      }
      final id = c.portraitId;
      if (id != null) {
        used.add(id);
        if (c.available) occupied.update(id, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    void assign(Courtier c, String id) {
      c.portraitId = id;
      used.add(id);
      if (c.available) occupied.update(id, (n) => n + 1, ifAbsent: () => 1);
    }

    // Reserve the complete authored roster before assigning generated people.
    for (final c in people.where((c) => c.portraitId == null)) {
      final id = initialPortraits[c.id];
      if (validCharacterPortrait(id, harem: c.isConsort) &&
          (!c.available || !occupied.containsKey(id))) {
        assign(c, id!);
      }
    }
    // Living people get first choice when migrating a long historical save.
    final missing =
        people.where((c) => c.portraitId == null).toList()..sort((a, b) {
          if (a.available != b.available) return a.available ? -1 : 1;
          return a.id.compareTo(b.id);
        });
    for (final c in missing) {
      final all = c.isConsort ? haremPortraitIds : officialPortraitIds;
      final offset = portraitHash(c.id) % all.length;
      final rotated = [...all.skip(offset), ...all.take(offset)];
      final preferred =
          c.isConsort
              ? rotated
              : preferredOfficialPortraits(c.category, c.specialty);
      final choices = {...preferred, ...rotated}.toList();
      final fresh = choices.where((id) => !used.contains(id)).firstOrNull;
      final free = choices.where((id) => !occupied.containsKey(id)).firstOrNull;
      final selected =
          fresh ??
          free ??
          (choices.toList()..sort((a, b) {
                final counts = occupied[a]!.compareTo(occupied[b]!);
                return counts != 0
                    ? counts
                    : choices.indexOf(a).compareTo(choices.indexOf(b));
              }))
              .first;
      assign(c, selected);
    }
  }

  int nextOfficialCandidate = 0;
  List<WorkOrder> projects = [];
  List<PalaceWork> palaceWorks = [];
  List<PalaceEffect> palaceEffects = [];
  List<Petition> petitions = [];
  List<Consequence> pending = [];
  List<OutcomeReport> outcomes = [];
  List<Chronicle> journal = [];
  List<Map<String, dynamic>> history = [];
  Map<String, int> cooldowns = {};
  Map<String, int> eventSeen = {}, eventFamilyWeeks = {};
  List<String> recentEventCategories = [];
  Map<String, int> actionCounts = {};
  Map<String, int> favorsThisWeek = {};
  Map<String, int> factions = {
    'Văn thần': 55,
    'Võ tướng': 55,
    'Hoàng tộc': 55,
    'Thế gia': 55,
  };
  Map<String, int> deltas = {};
  String healthReport =
      'Long thể an khang. Giữ cân bằng việc nước và nghỉ ngơi.';
  int lastIncome = 0, lastExpense = 0;
  List<FinanceWeek> financialWeeks = [];
  Map<String, int> crisisWeeks = {}, responsesThisWeek = {};
  int arrearsUses = 0, nextMajorWeek = 0, nextChainWeek = 0;
  int lastMajorGap = 0;
  String lastMajorKind = '';
  MajorMission? major;
  List<MajorMission> majorHistory = [];
  List<Obligation> obligations = [];
  List<StoryArc> chains = [];
  List<String> completedChains = [];
  Map<String, int> realmMilestones = {};
  String heirId = '', heirCondition = '';
  bool successionCertified = false;

  bool get ended => endReason != null;
  int get week => completedWeeks + 1;
  int get age => 18 + completedWeeks ~/ (seasonal ? 4 : 52);
  String get season =>
      seasonNames[seasonal ? completedWeeks % 4 : (completedWeeks % 52) ~/ 13];
  int get year => completedWeeks ~/ (seasonal ? 4 : 52) + 1;
  String get duration => reignTime(completedWeeks, seasonal: seasonal);

  GameState copy() =>
      GameState.fromJson(object(jsonDecode(jsonEncode(toJson()))));

  void note(String title, String text, [String tone = 'neutral']) {
    if (goldStandard) text = text.replaceAll(RegExp(r'\btiền\b'), 'lượng vàng');
    journal.insert(
      0,
      Chronicle(week, calendarText(title), calendarText(text), tone),
    );
  }

  factory GameState.fromJson(Map<String, dynamic> j) {
    j = migrateGoldSave(j);
    if (![
          'mvp-0.8.0',
          'mvp-0.9.0',
          'mvp-0.10.0',
          'mvp-0.10.1',
          'mvp-0.11.0',
          'mvp-0.11.1',
          'mvp-0.12.0',
          'mvp-0.12.1',
          'mvp-0.13.0',
          'mvp-0.14.0',
          'mvp-0.14.1',
          'mvp-0.15.0',
          'mvp-0.15.1',
          'mvp-0.15.2',
          'mvp-0.16.0',
          'mvp-0.17.0',
          'mvp-0.17.1',
          'mvp-0.17.2',
          'mvp-0.17.3',
          'mvp-0.18.0',
          'mvp-0.19.0',
          'mvp-0.20.0',
          'mvp-0.21.0',
          'mvp-0.21.1',
          'mvp-0.22.0',
          'mvp-0.23.0',
          'mvp-0.23.1',
          'mvp-0.24.0',
          'mvp-0.25.0',
          'mvp-0.26.0',
          rulesVersion,
        ].contains(j['rulesVersion']) ||
        ![
          7,
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          17,
          18,
          19,
          20,
          21,
          22,
          23,
          contentVersion,
        ].contains(j['contentVersion'])) {
      throw const FormatException(
        'Bản lưu dùng bộ luật khác. Cần bản game tương thích; dữ liệu chưa bị xóa.',
      );
    }
    final s = GameState(
      runId: j['runId'],
      playerName: j['playerName'],
      seed: number(j, 'seed'),
      rng: number(j, 'rng'),
      court:
          (j['court'] as List)
              .map((x) => Courtier.fromJson(object(x)))
              .toList(),
    );
    s.revision = number(j, 'revision');
    s.courtSystemVersion = number(j, 'courtSystemVersion');
    s.managementVersion = number(j, 'managementVersion');
    s.balanceVersion = number(j, 'balanceVersion');
    s.lastManagementTurn = number(j, 'lastManagementTurn');
    s.lastCourtPassiveTurn = number(j, 'lastCourtPassiveTurn');
    s.courtPersonnelMatters =
        (j['courtPersonnelMatters'] as List? ?? [])
            .map((x) => CourtPersonnelMatter.fromJson(object(x)))
            .toList();
    s.courtPersonnelRewarded = Set<String>.from(
      j['courtPersonnelRewarded'] ?? [],
    );
    s.nextCourtPersonnelTurn = number(j, 'nextCourtPersonnelTurn', 2);
    s.lastCourtRecruitYear = number(j, 'lastCourtRecruitYear');
    s.courtOffices =
        (j['courtOffices'] as List? ?? [])
            .map((x) => CourtOffice.fromJson(object(x)))
            .toList();
    s.courtTaxSeasons = Map<String, int>.from(j['courtTaxSeasons'] ?? {});
    s.goldStandard = j['goldStandard'] == true;
    s.seasonal = j['timeUnit'] == 'season';
    s.population =
        j['population'] == null
            ? null
            : PopulationState.fromJson(object(j['population']));
    s.scoreRules = j['scoreRules'] ?? j['rulesVersion'];
    s.seasonActionsSpent = number(j, 'seasonActionsSpent');
    s.seasonPetitionTarget = number(j, 'seasonPetitionTarget');
    s.midSeasonDelivered = j['midSeasonDelivered'] == true;
    s.storySystemVersion = number(j, 'storySystemVersion');
    s.crisisWeeks = Map<String, int>.from(j['crisisWeeks'] ?? {});
    s.responsesThisWeek = Map<String, int>.from(j['responsesThisWeek'] ?? {});
    s.arrearsUses = number(j, 'arrearsUses');
    s.nextMajorWeek = number(j, 'nextMajorWeek');
    s.nextChainWeek = number(j, 'nextChainWeek');
    s.lastMajorGap = number(j, 'lastMajorGap');
    s.lastMajorKind = j['lastMajorKind'] ?? '';
    s.realmMilestones = Map<String, int>.from(j['realmMilestones'] ?? {});
    s.heirId = j['heirId'] ?? '';
    s.heirCondition = j['heirCondition'] ?? '';
    s.successionCertified = j['successionCertified'] == true;
    s.major =
        j['major'] == null ? null : MajorMission.fromJson(object(j['major']));
    s.majorHistory =
        (j['majorHistory'] as List? ?? [])
            .map((x) => MajorMission.fromJson(object(x)))
            .toList();
    s.obligations =
        (j['obligations'] as List? ?? [])
            .map((x) => Obligation.fromJson(object(x)))
            .toList();
    s.chains =
        (j['chains'] as List? ?? [])
            .map((x) => StoryArc.fromJson(object(x)))
            .toList();
    s.completedChains = List<String>.from(j['completedChains'] ?? []);
    s.officialsPool =
        (j['officialsPool'] as List? ?? [])
            .map((x) => Courtier.fromJson(object(x)))
            .toList();
    s.nextOfficialCandidate = number(j, 'nextOfficialCandidate');
    s.completedWeeks = number(j, 'completedWeeks');
    s.points = number(j, 'points');
    // Preserve spent actions and the already-drawn petition batch. The larger
    // budget applies once; serializing writes the current rules version.
    if (s.seasonal &&
        [
          'mvp-0.10.0',
          'mvp-0.10.1',
          'mvp-0.11.0',
          'mvp-0.11.1',
        ].contains(j['rulesVersion']) &&
        j['endReason'] == null) {
      s.points +=
          ['mvp-0.10.0', 'mvp-0.10.1'].contains(j['rulesVersion']) ? 2 : 4;
    }
    s.overtime = number(j, 'overtime');
    s.treasury = number(j, 'treasury');
    s.people = number(j, 'people');
    s.authority = number(j, 'authority');
    s.army = number(j, 'army');
    s.health = number(j, 'health');
    s.stability = number(j, 'stability');
    s.grain = number(j, 'grain');
    s.levee = number(j, 'levee');
    s.economyLevel = number(j, 'economyLevel', 1).clamp(1, 5);
    s.agricultureLevel = number(j, 'agricultureLevel', 1).clamp(1, 5);
    s.leveeLevel = number(j, 'leveeLevel', 1).clamp(1, 5);
    s.leveeWearRemainder = number(j, 'leveeWearRemainder').clamp(0, 99);
    // Old saves have no historic crop samples. Use their current condition as
    // the baseline, without inventing past harvests or consuming RNG on load.
    s.cropYear = number(j, 'cropYear', s.year);
    s.cropBaselineLevee = number(j, 'cropBaselineLevee', s.levee).clamp(0, 100);
    s.springLeveePercent = (j['springLeveePercent'] as num?)?.toDouble();
    s.summerLeveePercent = (j['summerLeveePercent'] as num?)?.toDouble();
    s.lastHarvestYear = number(j, 'lastHarvestYear');
    s.lastHarvestAmount = number(j, 'lastHarvestAmount');
    s.lastHarvestWeather = number(j, 'lastHarvestWeather', 100);
    s.lastHarvestLeveePercent =
        (j['lastHarvestLeveePercent'] as num?)?.toDouble() ?? 100;
    s.fatigue = number(j, 'fatigue');
    s.stress = number(j, 'stress');
    s.indulgence = number(j, 'indulgence');
    s.illness = number(j, 'illness');
    s.workThisWeek = number(j, 'workThisWeek');
    s.affairsThisWeek = number(j, 'affairsThisWeek');
    s.neglectedWeeks = number(j, 'neglectedWeeks');
    s.restThisWeek = number(j, 'restThisWeek');
    s.revelThisWeek = number(j, 'revelThisWeek');
    s.exhaustedWeeks = number(j, 'exhaustedWeeks');
    s.tax = number(j, 'tax');
    s.lastTaxYear = number(j, 'lastTaxYear');
    s.lastTaxRate = number(j, 'lastTaxRate', 1);
    s.lastTaxRevenue = number(j, 'lastTaxRevenue');
    s.taxCreditYear = number(j, 'taxCreditYear');
    s.taxCredit = number(j, 'taxCredit');
    s.taxSupportCredit = number(j, 'taxSupportCredit');
    s.debt = number(j, 'debt');
    s.war = number(j, 'war');
    s.siege = number(j, 'siege');
    s.warfare =
        j['warfare'] != null
            ? WarfareState.fromJson(object(j['warfare']), seed: s.seed)
            : !j.containsKey('warfare') && s.goldStandard
            ? WarfareState(seed: s.seed)
            : null;
    if (s.warfare != null && !j.containsKey('warfare') && s.war > 0) {
      final n = s.warfare!.neighbors.first;
      n.status = 'war';
      n.warStarted = s.week;
      n.advantage = (-s.siege * 20).clamp(-100, 100);
    }
    s.tribute = number(j, 'tribute');
    s.priority = j['priority'] ?? 'army';
    s.hostileFaction = j['hostileFaction'] ?? '';
    s.endReason = j['endReason'];
    s.endKind = j['endKind'];
    s.illnessSource = j['illnessSource'];
    s.healthReport = j['healthReport'];
    s.lastIncome = number(j, 'lastIncome');
    s.lastExpense = number(j, 'lastExpense');
    s.financialWeeks =
        (j['financialWeeks'] as List? ?? [])
            .map((x) => FinanceWeek.fromJson(object(x)))
            .toList();
    if (s.seasonal && !j.containsKey('lastTaxYear')) {
      // Keep the old cash/ledger intact. Credit taxes already paid this year
      // against the new annual levy; never manufacture a retroactive payment.
      s.lastTaxRate = s.tax;
      s.lastTaxYear = s.season == 'Đông' ? s.year : s.year - 1;
      s.taxCreditYear = s.year;
      for (final report in s.financialWeeks.where((w) => w.closed)) {
        final reportYear = (report.week - 1) ~/ 4 + 1;
        for (final entry in report.entries.where(
          (e) => e.category == 'budget',
        )) {
          final rate = const [
            'Thuế nhẹ',
            'Thuế vừa',
            'Thuế cao',
          ].indexOf(entry.title);
          if (reportYear == s.year && rate >= 0) {
            s.taxSupportCredit +=
                rate == 0
                    ? 1
                    : rate == 2
                    ? -2
                    : 0;
          }
          if (rate >= 0 || entry.title == 'Thu thêm theo lòng dân') {
            if (reportYear == s.year) s.taxCredit += entry.amount;
            if (reportYear == s.lastTaxYear) s.lastTaxRevenue += entry.amount;
          }
        }
      }
    }
    s.projects =
        (j['projects'] as List)
            .map((x) => WorkOrder.fromJson(object(x)))
            .toList();
    s.palaceWorks =
        (j['palaceWorks'] as List? ?? [])
            .map((x) => PalaceWork.fromJson(object(x)))
            .toList();
    s.palaceEffects =
        (j['palaceEffects'] as List? ?? [])
            .map((x) => PalaceEffect.fromJson(object(x)))
            .toList();
    s.petitions =
        (j['petitions'] as List)
            .map((x) => Petition.fromJson(object(x)))
            .toList();
    s.pending =
        (j['pending'] as List).map((x) {
          final raw = object(x);
          if (raw['kind'] == 'investigate' && raw['investigation'] == null) {
            final person =
                s.court.where((c) => c.id == raw['target']).firstOrNull;
            final snapshot = person?.lastInvestigation;
            // The previous implementation published two-period reports at
            // the start. Move that exact snapshot back into the pending
            // report; earlier completed results remain valid.
            if (snapshot != null &&
                snapshot.week == number(raw, 'dueWeek') - 1) {
              raw['investigation'] = snapshot.toJson();
              person!.lastInvestigation = null;
            }
          }
          return Consequence.fromJson(raw);
        }).toList();
    s.outcomes =
        (j['outcomes'] as List? ?? [])
            .map((x) => OutcomeReport.fromJson(object(x)))
            .toList();
    s.journal =
        (j['journal'] as List)
            .map((x) => Chronicle.fromJson(object(x)))
            .toList();
    s.history = (j['history'] as List).map(object).toList();
    s.cooldowns = Map<String, int>.from(j['cooldowns']);
    s.eventSeen = Map<String, int>.from(j['eventSeen'] ?? {});
    s.eventFamilyWeeks = Map<String, int>.from(j['eventFamilyWeeks'] ?? {});
    s.recentEventCategories = List<String>.from(
      j['recentEventCategories'] ?? [],
    );
    s.actionCounts = Map<String, int>.from(j['actionCounts'] ?? {});
    // Old saves already record the turn of each command. Preserve the actual
    // last deployment when introducing a cooldown; never restart it on load.
    if (s.seasonal && !s.cooldowns.containsKey('task:security')) {
      final deployment =
          s.history.reversed
              .where((h) => h['type'] == 'action' && h['target'] == 'security')
              .firstOrNull;
      final lastTurn =
          deployment == null
              ? ((s.actionCounts['security'] ?? 0) > 0 ? s.week : 0)
              : number(deployment, 'week');
      if (lastTurn > 0) {
        s.cooldowns['task:security'] = lastTurn + securityCooldown;
      }
    }
    s.favorsThisWeek = Map<String, int>.from(j['favorsThisWeek'] ?? {});
    s.factions = Map<String, int>.from(j['factions']);
    s.deltas = Map<String, int>.from(j['deltas']);
    initializeManagement(s);
    s.ensurePortraits();
    return s;
  }

  Map<String, dynamic> toJson() => {
    'storySystemVersion': storySystemVersion,
    'courtSystemVersion': courtSystemVersion,
    'managementVersion': managementVersion,
    'balanceVersion': balanceVersion,
    'lastManagementTurn': lastManagementTurn,
    'lastCourtPassiveTurn': lastCourtPassiveTurn,
    'courtPersonnelMatters':
        courtPersonnelMatters.map((m) => m.toJson()).toList(),
    'courtPersonnelRewarded': courtPersonnelRewarded.toList(),
    'nextCourtPersonnelTurn': nextCourtPersonnelTurn,
    'lastCourtRecruitYear': lastCourtRecruitYear,
    'courtOffices': courtOffices.map((o) => o.toJson()).toList(),
    'courtTaxSeasons': courtTaxSeasons,
    'rulesVersion': rulesVersion,
    'contentVersion': contentVersion,
    'timeUnit': seasonal ? 'season' : 'week',
    'scoreRules': scoreRules,
    'seasonActionsSpent': seasonActionsSpent,
    'seasonPetitionTarget': seasonPetitionTarget,
    'midSeasonDelivered': midSeasonDelivered,
    'runId': runId,
    'playerName': playerName,
    'seed': seed,
    'rng': rng,
    'revision': revision,
    'completedWeeks': completedWeeks,
    'points': points,
    'overtime': overtime,
    'treasury': treasury,
    'people': people,
    'authority': authority,
    'army': army,
    'population': population?.toJson(),
    'warfare': warfare?.toJson(),
    'goldStandard': goldStandard,
    'health': health,
    'stability': stability,
    'grain': grain,
    'levee': levee,
    'economyLevel': economyLevel,
    'agricultureLevel': agricultureLevel,
    'leveeLevel': leveeLevel,
    'leveeWearRemainder': leveeWearRemainder,
    'cropYear': cropYear,
    'cropBaselineLevee': cropBaselineLevee,
    'springLeveePercent': springLeveePercent,
    'summerLeveePercent': summerLeveePercent,
    'lastHarvestYear': lastHarvestYear,
    'lastHarvestAmount': lastHarvestAmount,
    'lastHarvestWeather': lastHarvestWeather,
    'lastHarvestLeveePercent': lastHarvestLeveePercent,
    'fatigue': fatigue,
    'stress': stress,
    'indulgence': indulgence,
    'illness': illness,
    'workThisWeek': workThisWeek,
    'affairsThisWeek': affairsThisWeek,
    'neglectedWeeks': neglectedWeeks,
    'restThisWeek': restThisWeek,
    'revelThisWeek': revelThisWeek,
    'exhaustedWeeks': exhaustedWeeks,
    'tax': tax,
    'lastTaxYear': lastTaxYear,
    'lastTaxRate': lastTaxRate,
    'lastTaxRevenue': lastTaxRevenue,
    'taxCreditYear': taxCreditYear,
    'taxCredit': taxCredit,
    'taxSupportCredit': taxSupportCredit,
    'debt': debt,
    'war': war,
    'siege': siege,
    'tribute': tribute,
    'priority': priority,
    'hostileFaction': hostileFaction,
    'endReason': endReason,
    'endKind': endKind,
    'illnessSource': illnessSource,
    'healthReport': healthReport,
    'lastIncome': lastIncome,
    'lastExpense': lastExpense,
    'financialWeeks': financialWeeks.map((x) => x.toJson()).toList(),
    'crisisWeeks': crisisWeeks,
    'responsesThisWeek': responsesThisWeek,
    'arrearsUses': arrearsUses,
    'nextMajorWeek': nextMajorWeek,
    'nextChainWeek': nextChainWeek,
    'lastMajorGap': lastMajorGap,
    'lastMajorKind': lastMajorKind,
    'realmMilestones': realmMilestones,
    'heirId': heirId,
    'heirCondition': heirCondition,
    'successionCertified': successionCertified,
    'major': major?.toJson(),
    'majorHistory': majorHistory.map((x) => x.toJson()).toList(),
    'obligations': obligations.map((x) => x.toJson()).toList(),
    'chains': chains.map((x) => x.toJson()).toList(),
    'completedChains': completedChains,
    'court': court.map((x) => x.toJson()).toList(),
    'officialsPool': officialsPool.map((x) => x.toJson()).toList(),
    'nextOfficialCandidate': nextOfficialCandidate,
    'projects': projects.map((x) => x.toJson()).toList(),
    'palaceWorks': palaceWorks.map((x) => x.toJson()).toList(),
    'palaceEffects': palaceEffects.map((x) => x.toJson()).toList(),
    'petitions': petitions.map((x) => x.toJson()).toList(),
    'pending': pending.map((x) => x.toJson()).toList(),
    'outcomes': outcomes.map((x) => x.toJson()).toList(),
    'journal': journal.map((x) => x.toJson()).toList(),
    'history': history,
    'cooldowns': cooldowns,
    'eventSeen': eventSeen,
    'eventFamilyWeeks': eventFamilyWeeks,
    'recentEventCategories': recentEventCategories,
    'actionCounts': actionCounts,
    'favorsThisWeek': favorsThisWeek,
    'factions': factions,
    'deltas': deltas,
  };
}

class GameCommand {
  const GameCommand({
    required this.id,
    required this.runId,
    required this.expectedRevision,
    required this.type,
    this.target = '',
    this.option = '',
    this.assigneeId = '',
  });
  final String id, runId, type, target, option, assigneeId;
  final int expectedRevision;
  Map<String, dynamic> toJson() => {
    'id': id,
    'runId': runId,
    'expectedRevision': expectedRevision,
    'type': type,
    'target': target,
    'option': option,
    if (assigneeId.isNotEmpty) 'assigneeId': assigneeId,
  };
  String get signature => jsonEncode(toJson());
}

class ScoreEntry {
  ScoreEntry(
    this.runId,
    this.playerName,
    this.weeks, {
    this.rules = rulesVersion,
    this.seasonal = false,
  });
  final String runId, playerName, rules;
  final int weeks;
  final bool seasonal;
  int get calendarWeeks => seasonal ? weeks * 13 : weeks;
  factory ScoreEntry.fromJson(Map<String, dynamic> j) => ScoreEntry(
    j['runId'],
    j['playerName'],
    number(j, 'weeks'),
    rules: j['rules'],
    seasonal: j['timeUnit'] == 'season',
  );
  Map<String, dynamic> toJson() => {
    'runId': runId,
    'playerName': playerName,
    'weeks': weeks,
    'rules': rules,
    'timeUnit': seasonal ? 'season' : 'week',
  };
}

List<({int rank, ScoreEntry score})> rankedScores(
  List<ScoreEntry> entries, {
  String rules = rulesVersion,
}) {
  final best = <String, ScoreEntry>{};
  for (final score in entries.where((s) => s.rules == rules)) {
    final key = score.playerName.trim().toLowerCase();
    if (!best.containsKey(key) ||
        score.calendarWeeks > best[key]!.calendarWeeks) {
      best[key] = score;
    }
  }
  final sorted =
      best.values.toList()
        ..sort((a, b) => b.calendarWeeks.compareTo(a.calendarWeeks));
  var rank = 0;
  return [
    for (var i = 0; i < sorted.length; i++)
      (
        rank:
            (i == 0 || sorted[i].calendarWeeks != sorted[i - 1].calendarWeeks)
                ? (rank = i + 1)
                : rank,
        score: sorted[i],
      ),
  ];
}

class GameArchive {
  GameState? active;
  List<Map<String, dynamic>> archivedRuns = [];
  List<ScoreEntry> scores = [];
  Map<String, String> receipts = {};
  Map<String, String> starts = {};
  GameArchive();
  factory GameArchive.fromJson(Map<String, dynamic> j) {
    if (j['schemaVersion'] != schemaVersion && j['schemaVersion'] != 1) {
      throw const FormatException(
        'Cấu trúc bản lưu không tương thích. Dữ liệu chưa bị xóa.',
      );
    }
    final archive = GameArchive();
    archive.archivedRuns =
        (j['archivedRuns'] as List? ?? []).map(object).toList();
    if (j['active'] != null) {
      final active = object(j['active']);
      if (([
                'mvp-0.7.0',
                'mvp-0.7.1',
                'mvp-0.7.2',
                'mvp-0.7.3',
                'mvp-0.7.4',
              ].contains(active['rulesVersion']) &&
              active['contentVersion'] == 6) ||
          (active['rulesVersion'] == 'mvp-0.2.0' &&
              active['contentVersion'] == 1) ||
          (active['rulesVersion'] == 'mvp-0.3.0' &&
              active['contentVersion'] == 2) ||
          (active['rulesVersion'] == 'mvp-0.4.0' &&
              active['contentVersion'] == 3) ||
          (active['rulesVersion'] == 'mvp-0.5.0' &&
              active['contentVersion'] == 4) ||
          (active['rulesVersion'] == 'mvp-0.6.0' &&
              active['contentVersion'] == 5)) {
        // Never silently apply new balance to an existing reign. Preserve the
        // complete legacy snapshot; the player starts a new ruleset explicitly.
        if (!archive.archivedRuns.any((r) => r['runId'] == active['runId'])) {
          archive.archivedRuns.add(active);
        }
      } else {
        archive.active = GameState.fromJson(active);
      }
    }
    archive.scores =
        (j['scores'] as List)
            .map((x) => ScoreEntry.fromJson(object(x)))
            .toList();
    archive.receipts = Map<String, String>.from(j['receipts']);
    archive.starts = Map<String, String>.from(j['starts'] ?? {});
    return archive;
  }
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'active': active?.toJson(),
    'archivedRuns': archivedRuns,
    'scores': scores.map((x) => x.toJson()).toList(),
    'receipts': receipts,
    'starts': starts,
  };
}

class GameRuleException implements Exception {
  const GameRuleException(this.message);
  final String message;
  @override
  String toString() => message;
}
