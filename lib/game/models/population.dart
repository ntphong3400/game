import 'dart:math' as math;

/// Only new seasonal reigns use this model. Historical saves keep their units.
class PopulationState {
  int population = 1000000;
  int soldiers = 50000;
  int serviceSoldiers = 50000;
  double _training = 60, _morale = 65, logistics = 100;
  final Map<String, double> frontierTraining = {
    for (final id in ['north', 'west', 'south']) id: 60,
  };
  final Map<String, double> frontierMorale = {
    for (final id in ['north', 'west', 'south']) id: 65,
  };
  static const frontierIds = ['north', 'west', 'south'];
  double trainingAt(String id) =>
      id == 'capital' ? _training : frontierTraining[id] ?? _training;
  double moraleAt(String id) =>
      id == 'capital' ? _morale : frontierMorale[id] ?? _morale;
  double _average(double Function(String) value) {
    final total = garrisons.values.fold<int>(0, (a, b) => a + b);
    if (total <= 0) return value('capital');
    return garrisons.entries.fold<double>(
          0,
          (sum, e) => sum + e.value * value(e.key),
        ) /
        total;
  }

  /// National summaries are weighted by stationed soldiers; direct assignments
  /// set a uniform baseline (also used for historical imports).
  double get training => _average(trainingAt);
  set training(double value) {
    _training = value;
    for (final id in frontierIds) {
      frontierTraining[id] = value;
    }
  }

  double get morale => _average(moraleAt);
  set morale(double value) {
    _morale = value;
    for (final id in frontierIds) {
      frontierMorale[id] = value;
    }
  }

  void setTrainingAt(String id, double value) {
    value = value.clamp(0, 100);
    if (id == 'capital') {
      _training = value;
    } else {
      frontierTraining[id] = value;
    }
  }

  void setMoraleAt(String id, double value) {
    value = value.clamp(0, 100);
    if (id == 'capital') {
      _morale = value;
    } else {
      frontierMorale[id] = value;
    }
  }

  void changeTraining(double amount, {String? at}) {
    for (final id in at == null ? ['capital', ...frontierIds] : [at]) {
      setTrainingAt(id, trainingAt(id) + amount);
    }
  }

  void changeMorale(double amount, {String? at}) {
    for (final id in at == null ? ['capital', ...frontierIds] : [at]) {
      setMoraleAt(id, moraleAt(id) + amount);
    }
  }

  void clampQualities() {
    for (final id in ['capital', ...frontierIds]) {
      setTrainingAt(id, trainingAt(id));
      setMoraleAt(id, moraleAt(id));
    }
  }

  double readinessAt(String id) =>
      .30 * trainingAt(id) +
      .25 * equipmentPercent +
      .20 * moraleAt(id) +
      .25 * logistics;
  int equipment = 30000;
  String policy = 'economy', nextPolicy = 'economy';
  int earlyWorkers = 0, earlyDebt = 0, earlyInstallment = 0;
  int earlyDue = 0, earlyAvailable = 0;
  int displaced = 0, diseaseLevel = 0;
  int openingPopulation = 1000000, productiveCivilians = 950000;
  double yearlyFarmLabor = 0, yearlyEconomicLabor = 0;
  int yearlyLaborSamples = 0;
  double growthRemainder = 0, agingRemainder = 0, diseaseRemainder = 0;
  int foodCredit = 0;
  double wageCoverage = 100;
  List<PopulationOrder> orders = [];
  List<ArmyDeployment> deployments = [];
  // Stationed totals include contingents away on missions from that garrison.
  Map<String, int> garrisons = {
    'capital': 20000,
    'north': 10000,
    'west': 10000,
    'south': 10000,
  };
  int stationed(String id) => garrisons[id] ?? 0;
  int away(String id) => deployments
      .where((d) => d.sourceGarrison == id)
      .fold(0, (n, d) => n + d.troops);
  int availableAt(String id) => math.max(0, stationed(id) - away(id));

  /// Allocate historical saves without changing totals, rolls or reservations.
  void reconcileGarrisons({bool migrate = false}) {
    const weights = {'capital': 2, 'north': 1, 'west': 1, 'south': 1};
    if (migrate) {
      final free = availableSoldiers;
      garrisons = {
        for (final e in weights.entries)
          e.key: away(e.key) + free * e.value ~/ 5,
      };
    }
    for (final id in weights.keys) {
      garrisons[id] = math.max(stationed(id), away(id));
    }
    final total = garrisons.values.fold(0, (a, b) => a + b);
    if (total < soldiers) {
      garrisons['capital'] = stationed('capital') + soldiers - total;
    }
    if (total > soldiers) removeGarrisonTroops(total - soldiers);
  }

  void removeGarrisonTroops(int count, {String? source}) {
    final ids =
        source == null
            ? ['capital', 'north', 'west', 'south']
            : [source, ...garrisons.keys.where((id) => id != source)];
    for (final id in ids) {
      final loss = math.min(count, availableAt(id));
      garrisons[id] = stationed(id) - loss;
      count -= loss;
      if (count == 0) break;
    }
  }

  Map<String, int> changes = {};
  List<Map<String, dynamic>> reports = [];

  int get civilians => math.max(0, population - soldiers);
  int get busySoldiers => deployments.fold(0, (n, d) => n + d.troops);
  int get availableSoldiers => math.max(0, soldiers - busySoldiers);
  int get recruitable => math.max(
    0,
    math.min(
          civilians - earlyWorkers - ((population - earlyWorkers) * .70).ceil(),
          ((population - earlyWorkers) * .12).floor() - soldiers,
        ) -
        orders
            .where((o) => o.kind == 'recruit')
            .fold<int>(0, (n, o) => n + o.count),
  );
  double get equipmentPercent =>
      soldiers <= 0 ? 0 : (equipment * 100 / soldiers).clamp(0, 100).toDouble();
  double get readiness =>
      .30 * training + .25 * equipmentPercent + .20 * morale + .25 * logistics;
  double get militaryAllocation => switch (policy) {
    'army' => .8,
    'balanced' => .5,
    _ => .2,
  };

  PopulationState();
  factory PopulationState.fromJson(Map<String, dynamic> j) {
    final p = PopulationState();
    int n(String k, int fallback) => (j[k] as num?)?.toInt() ?? fallback;
    double d(String k, double fallback) =>
        (j[k] as num?)?.toDouble() ?? fallback;
    p.population = n('population', 1000000);
    p.soldiers = n('soldiers', 50000);
    p.serviceSoldiers = n('serviceSoldiers', p.soldiers);
    p.training = d('training', 60);
    p.morale = d('morale', 65);
    p._training = d('capitalTraining', p._training);
    p._morale = d('capitalMorale', p._morale);
    for (final id in frontierIds) {
      p.frontierTraining[id] =
          ((j['frontierTraining'] as Map?)?[id] as num?)?.toDouble() ??
          p.trainingAt(id);
      p.frontierMorale[id] =
          ((j['frontierMorale'] as Map?)?[id] as num?)?.toDouble() ??
          p.moraleAt(id);
    }
    p.clampQualities();
    p.logistics = d('logistics', 100);
    p.equipment = n('equipment', 30000);
    p.policy = j['policy'] ?? 'economy';
    p.nextPolicy = j['nextPolicy'] ?? p.policy;
    p.earlyWorkers = n('earlyWorkers', 0);
    p.earlyDebt = n('earlyDebt', 0);
    p.earlyInstallment = n('earlyInstallment', 0);
    p.earlyDue = n('earlyDue', 0);
    p.earlyAvailable = n('earlyAvailable', 0);
    p.displaced = n('displaced', 0);
    p.diseaseLevel = n('diseaseLevel', 0);
    p.openingPopulation = n('openingPopulation', p.population);
    p.productiveCivilians = n('productiveCivilians', p.civilians);
    p.yearlyFarmLabor = d('yearlyFarmLabor', 0);
    p.yearlyEconomicLabor = d('yearlyEconomicLabor', 0);
    p.yearlyLaborSamples = n('yearlyLaborSamples', 0);
    p.growthRemainder = d('growthRemainder', 0);
    p.agingRemainder = d('agingRemainder', 0);
    p.diseaseRemainder = d('diseaseRemainder', 0);
    p.foodCredit = n('foodCredit', 0);
    p.wageCoverage = d('wageCoverage', 100);
    p.orders =
        (j['orders'] as List? ?? [])
            .map((x) => PopulationOrder.fromJson(Map<String, dynamic>.from(x)))
            .toList();
    p.deployments =
        (j['deployments'] as List? ?? [])
            .map((x) => ArmyDeployment.fromJson(Map<String, dynamic>.from(x)))
            .toList();
    if (j['garrisons'] is Map) {
      final raw = Map<String, dynamic>.from(j['garrisons']);
      p.garrisons = {
        for (final id in ['capital', 'north', 'west', 'south'])
          id: (raw[id] as num?)?.toInt() ?? 0,
      };
    }
    p.reconcileGarrisons(migrate: j['garrisons'] == null);
    p.changes = Map<String, int>.from(j['changes'] ?? {});
    p.reports =
        (j['reports'] as List? ?? [])
            .map((x) => Map<String, dynamic>.from(x))
            .toList();
    return p;
  }
  Map<String, dynamic> toJson() => {
    'population': population,
    'soldiers': soldiers,
    'serviceSoldiers': serviceSoldiers,
    'training': training,
    'morale': morale,
    'capitalTraining': _training,
    'capitalMorale': _morale,
    'frontierTraining': {for (final id in frontierIds) id: trainingAt(id)},
    'frontierMorale': {for (final id in frontierIds) id: moraleAt(id)},
    'logistics': logistics,
    'equipment': equipment,
    'policy': policy,
    'nextPolicy': nextPolicy,
    'earlyWorkers': earlyWorkers,
    'earlyDebt': earlyDebt,
    'earlyInstallment': earlyInstallment,
    'earlyDue': earlyDue,
    'earlyAvailable': earlyAvailable,
    'displaced': displaced,
    'diseaseLevel': diseaseLevel,
    'openingPopulation': openingPopulation,
    'productiveCivilians': productiveCivilians,
    'yearlyFarmLabor': yearlyFarmLabor,
    'yearlyEconomicLabor': yearlyEconomicLabor,
    'yearlyLaborSamples': yearlyLaborSamples,
    'growthRemainder': growthRemainder,
    'agingRemainder': agingRemainder,
    'diseaseRemainder': diseaseRemainder,
    'foodCredit': foodCredit,
    'wageCoverage': wageCoverage,
    'orders': orders.map((o) => o.toJson()).toList(),
    'deployments': deployments.map((d) => d.toJson()).toList(),
    'garrisons': Map<String, int>.of(garrisons),
    'changes': changes,
    'reports': reports,
  };
}

class PopulationOrder {
  PopulationOrder({
    required this.kind,
    required this.title,
    required this.count,
    required this.due,
    this.officerId = '',
  });
  final String kind, title, officerId;
  final int count, due;
  factory PopulationOrder.fromJson(Map<String, dynamic> j) => PopulationOrder(
    kind: j['kind'],
    title: j['title'],
    count: j['count'],
    due: j['due'],
    officerId: j['officerId'] ?? '',
  );
  Map<String, dynamic> toJson() => {
    'kind': kind,
    'title': title,
    'count': count,
    'due': due,
    'officerId': officerId,
  };
}

class ArmyDeployment {
  ArmyDeployment({
    required this.id,
    required this.title,
    required this.troops,
    required this.losses,
    required this.due,
    required this.officerId,
    required this.chance,
    required this.succeeded,
    this.countryId = '',
    this.sourceGarrison = 'capital',
    this.missionId = '',
    this.deputyId = '',
    this.retreated = false,
    this.baseCasualty = 0,
    this.reduction = 0,
    this.foodCredit = 0,
    this.majorId = '',
    this.objectiveKey = '',
    this.effects = const {},
    this.failureEffects = const {},
  });
  final String id, title, officerId;
  final String majorId, objectiveKey;
  final String countryId, missionId, deputyId;
  final String sourceGarrison;
  final bool retreated;
  final double baseCasualty;
  final int reduction;
  final int troops, losses;
  final int due, chance;
  final bool succeeded;
  final int foodCredit;
  final Map<String, int> effects, failureEffects;
  factory ArmyDeployment.fromJson(Map<String, dynamic> j) => ArmyDeployment(
    id: j['id'],
    title: j['title'],
    troops: j['troops'],
    losses: j['losses'],
    due: j['due'],
    officerId: j['officerId'],
    chance: j['chance'],
    succeeded: j['succeeded'] == true,
    countryId: j['countryId'] ?? '',
    sourceGarrison:
        j['sourceGarrison'] ??
        (['north', 'west', 'south'].contains(j['countryId'])
            ? j['countryId']
            : 'capital'),
    missionId: j['missionId'] ?? '',
    deputyId: j['deputyId'] ?? '',
    retreated: j['retreated'] == true,
    baseCasualty: (j['baseCasualty'] as num?)?.toDouble() ?? 0,
    reduction: j['reduction'] ?? 0,
    foodCredit: j['foodCredit'] ?? 0,
    majorId: j['majorId'] ?? '',
    objectiveKey: j['objectiveKey'] ?? '',
    effects: Map<String, int>.from(j['effects'] ?? {}),
    failureEffects: Map<String, int>.from(j['failureEffects'] ?? {}),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'troops': troops,
    'losses': losses,
    'due': due,
    'officerId': officerId,
    'chance': chance,
    'succeeded': succeeded,
    'countryId': countryId,
    'sourceGarrison': sourceGarrison,
    'missionId': missionId,
    'deputyId': deputyId,
    'retreated': retreated,
    'baseCasualty': baseCasualty,
    'reduction': reduction,
    'foodCredit': foodCredit,
    'majorId': majorId,
    'objectiveKey': objectiveKey,
    'effects': effects,
    'failureEffects': failureEffects,
  };
}
