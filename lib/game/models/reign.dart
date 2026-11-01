/// Persistent commitments; all dates are game weeks, never wall-clock time.
class Obligation {
  Obligation({
    required this.id,
    required this.kind,
    required this.title,
    required this.remaining,
    required this.nextWeek,
    this.amount = 0,
    this.income = 0,
    this.effects = const {},
  });
  String id, kind, title;
  int remaining, nextWeek, amount, income;
  Map<String, int> effects;
  factory Obligation.fromJson(Map<String, dynamic> j) => Obligation(
    id: j['id'],
    kind: j['kind'],
    title: j['title'],
    remaining: j['remaining'],
    nextWeek: j['nextWeek'],
    amount: j['amount'] ?? 0,
    income: j['income'] ?? 0,
    effects: Map<String, int>.from(j['effects'] ?? {}),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'title': title,
    'remaining': remaining,
    'nextWeek': nextWeek,
    'amount': amount,
    'income': income,
    'effects': effects,
  };
}

class StoryArc {
  StoryArc({
    required this.id,
    required this.kind,
    required this.dueWeek,
    this.stage = 0,
    this.decisions = const [],
    this.decisionLabels = const [],
    this.subjectId = '',
    this.facts = const {},
    this.settlementVersion = 1,
    this.completedSteps = 0,
    this.currencyScale = 1,
    this.investedValue = 0,
    this.cashSpent = 0,
    this.resourceCosts = const {},
    this.participantIds = const [],
    this.participantFactions = const [],
  });
  String id, kind;
  int stage, dueWeek;
  List<int> decisions;
  List<String> decisionLabels;
  String subjectId;
  Map<String, int> facts;
  int settlementVersion, completedSteps, investedValue, cashSpent;
  int currencyScale;
  Map<String, int> resourceCosts;
  List<String> participantIds, participantFactions;
  factory StoryArc.fromJson(Map<String, dynamic> j) => StoryArc(
    id: j['id'],
    kind: j['kind'],
    dueWeek: j['dueWeek'],
    stage: j['stage'],
    decisions: List<int>.from(j['decisions']),
    decisionLabels: List<String>.from(j['decisionLabels'] ?? []),
    subjectId: j['subjectId'] ?? '',
    facts: Map<String, int>.from(j['facts'] ?? {}),
    settlementVersion: j['settlementVersion'] ?? 0,
    completedSteps: j['completedSteps'] ?? 0,
    currencyScale: j['currencyScale'] ?? 1,
    investedValue: j['investedValue'] ?? 0,
    cashSpent: j['cashSpent'] ?? 0,
    resourceCosts: Map<String, int>.from(j['resourceCosts'] ?? {}),
    participantIds: List<String>.from(j['participantIds'] ?? []),
    participantFactions: List<String>.from(j['participantFactions'] ?? []),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'dueWeek': dueWeek,
    'stage': stage,
    'decisions': decisions,
    'decisionLabels': decisionLabels,
    'subjectId': subjectId,
    'facts': facts,
    'settlementVersion': settlementVersion,
    'completedSteps': completedSteps,
    'currencyScale': currencyScale,
    'investedValue': investedValue,
    'cashSpent': cashSpent,
    'resourceCosts': resourceCosts,
    'participantIds': participantIds,
    'participantFactions': participantFactions,
  };
}

class MissionObjective {
  MissionObjective({
    required this.key,
    this.done = false,
    this.officerId = '',
    this.finishWeek = 0,
    this.delivered = 0,
  });
  String key, officerId;
  bool done;
  int finishWeek;
  int delivered;
  bool get working => !done && officerId.isNotEmpty;
  factory MissionObjective.fromJson(Map<String, dynamic> j) => MissionObjective(
    key: j['key'],
    done: j['done'] == true,
    officerId: j['officerId'] ?? '',
    finishWeek: j['finishWeek'] ?? 0,
    delivered: ((j['delivered'] as num?)?.toInt() ?? 0).clamp(0, 100),
  );
  Map<String, dynamic> toJson() => {
    'key': key,
    'done': done,
    'officerId': officerId,
    'finishWeek': finishWeek,
    'delivered': delivered,
  };
}

class MajorMission {
  MajorMission({
    required this.id,
    required this.kind,
    required this.openedWeek,
    required this.deadline,
    required this.severity,
    required this.preparedness,
    required this.objectives,
    this.resolvedWeek = 0,
    this.result = '',
    this.subjectId = '',
    this.demanding = false,
    this.petitionDriven = false,
    this.stage = 0,
    this.dueWeek = 0,
    this.decisions = const [],
    this.decisionLabels = const [],
    this.damageTaken = const {},
  });
  final bool demanding;
  bool petitionDriven;
  int stage, dueWeek;
  List<int> decisions;
  List<String> decisionLabels;
  Map<String, int> damageTaken;
  String id, kind, result, subjectId;
  int openedWeek, deadline, severity, preparedness, resolvedWeek;
  List<MissionObjective> objectives;
  int get achieved => objectives.where((o) => o.done).length;
  int get responseScore =>
      petitionDriven
          ? objectives.fold<int>(
                0,
                (n, o) => n + (o.done ? 100 : o.delivered),
              ) ~/
              100
          : achieved;
  bool get resolved => resolvedWeek > 0;
  factory MajorMission.fromJson(Map<String, dynamic> j) => MajorMission(
    id: j['id'],
    kind: j['kind'],
    openedWeek: j['openedWeek'],
    deadline: j['deadline'],
    severity: j['severity'],
    preparedness: j['preparedness'],
    resolvedWeek: j['resolvedWeek'] ?? 0,
    result: j['result'] ?? '',
    subjectId: j['subjectId'] ?? '',
    demanding: j['demanding'] == true,
    petitionDriven: j['petitionDriven'] == true,
    stage: j['stage'] ?? 0,
    dueWeek: j['dueWeek'] ?? 0,
    decisions: List<int>.from(j['decisions'] ?? []),
    decisionLabels: List<String>.from(j['decisionLabels'] ?? []),
    damageTaken: Map<String, int>.from(j['damageTaken'] ?? {}),
    objectives:
        (j['objectives'] as List)
            .map((o) => MissionObjective.fromJson(Map<String, dynamic>.from(o)))
            .toList(),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'openedWeek': openedWeek,
    'deadline': deadline,
    'severity': severity,
    'preparedness': preparedness,
    'resolvedWeek': resolvedWeek,
    'result': result,
    'subjectId': subjectId,
    'demanding': demanding,
    'petitionDriven': petitionDriven,
    'stage': stage,
    'dueWeek': dueWeek,
    'decisions': decisions,
    'decisionLabels': decisionLabels,
    'damageTaken': damageTaken,
    'objectives': objectives.map((o) => o.toJson()).toList(),
  };
}
