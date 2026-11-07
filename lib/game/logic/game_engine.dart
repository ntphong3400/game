import 'dart:math' as math;

import '../data/content.dart';
import '../data/expanded_events.dart' show eventEffectText;
import '../models/game_state.dart';
import 'personnel_rules.dart';
import 'food_pressure_rules.dart';
import 'finance_rules.dart';
import 'currency_rules.dart';
import 'harem_rules.dart';
import '../data/harem_quests.dart';
import 'reign_rules.dart';
import 'court_politics_rules.dart';
import 'petition_assignment_rules.dart';
import 'health_rules.dart';
import 'chain_settlement_rules.dart';
import 'population_rules.dart';
import 'warfare_rules.dart';
import 'frontier_rules.dart';
import 'dart:convert';
import 'court_rules.dart';
import 'management_rules.dart';
import 'investigation_rules.dart';
import 'court_personnel_rules.dart';
import '../data/court_personnel_petitions.dart';
import 'court_initialization.dart';
import '../data/reign_content.dart';
import '../data/story_petitions.dart';
part 'reign_engine.dart';
part 'harem_quest_engine.dart';
part 'petition_engine.dart';
part 'story_engine.dart';
part 'development_engine.dart';
part 'food_pressure_engine.dart';
part 'population_engine.dart';
part 'food_ledger_engine.dart';
part 'warfare_engine.dart';
part 'frontier_engine.dart';
part 'court_engine.dart';
part 'management_engine.dart';
part 'investigation_engine.dart';
part 'court_personnel_engine.dart';

/// No Flutter, storage, network or wall-clock dependencies. All gameplay random
/// consumes the persisted LCG (31-bit arithmetic is exact on Dart VM and JS).
class GameEngine {
  GameEngine({
    this.seasonal = true,
    this.populationEnabled = true,
    this.goldEnabled = true,
    this.challengeBalance = true,
    this.foodBalance = true,
  });
  final bool populationEnabled;
  final bool goldEnabled;
  final bool seasonal;
  final bool challengeBalance;
  final bool foodBalance;
  int _next(GameState s, int max) {
    s.rng = (s.rng * 48271) % 2147483647;
    return s.rng % max;
  }

  GameState start(String runId, String name, int seed) {
    final normalized = seed % 2147483646 + 1;
    final s = GameState(
      runId: runId,
      playerName: name.trim(),
      seed: normalized,
      rng: normalized,
      court: initialCourt(),
    );
    s.seasonal = seasonal;
    if (seasonal && populationEnabled && goldEnabled && challengeBalance) {
      s.balanceVersion = foodBalance ? 2 : 1;
      if (!foodBalance) s.scoreRules = 'mvp-0.27.0';
    }
    if (!challengeBalance) s.scoreRules = 'mvp-0.26.0';
    if (seasonal && populationEnabled && goldEnabled) {
      initializeCourt(s, (max) => _next(s, max));
    }
    if (seasonal && populationEnabled) {
      s.population = PopulationState();
      s.grain = initialFood;
      s.goldStandard = goldEnabled;
      if (goldEnabled) {
        s.treasury = 50000;
        s.warfare = WarfareState(seed: s.seed);
      }
    }
    s.points = s.actionsPerTurn;
    _financeWeek(s);
    _foodWeek(s);
    final factions = factionOpponents.keys.toList();
    s.hostileFaction = factions[_next(s, factions.length)];
    s.factions = {
      for (final faction in factions)
        faction:
            faction == s.hostileFaction
                ? 28
                : faction == factionOpponents[s.hostileFaction]
                ? 62
                : 48,
    };
    for (final c in s.court) {
      c.loyalty = (c.loyalty + _next(s, 13) - 6).clamp(0, 100);
      _initialAffection(s, c);
    }
    for (var i = 0; i < 12; i++) {
      s.officialsPool.add(_newOfficialCandidate(s));
    }
    initializeManagement(s, newReign: true);
    s.note(
      'Ngày đăng cơ',
      'Tiên đế băng hà. Ở tuổi mười tám, bạn nhận lấy ngọc tỷ và một đất nước đang chờ những quyết định đầu tiên.',
      'gold',
    );
    s.note(
      'Thế cục đầu triều',
      'Phe ${s.hostileFaction} còn dè chừng vị vua mới. Văn thần đối trọng Võ tướng; Hoàng tộc đối trọng Thế gia. Ưu ái một bên khiến bên kia bất mãn.',
      'warning',
    );
    s.nextMajorWeek =
        s.week + (seasonal ? 3 + s.seed % 3 : 4 + (s.seed * 17 % 21));
    s.nextChainWeek = s.week + (seasonal ? 1 : 3);
    s.note(
      'Chuẩn bị thế cục',
      'Đại biến cố đầu tiên dự kiến ${s.date(s.nextMajorWeek)}. ${reignStageHint(s)}',
    );
    if (seasonal) {
      s.note(
        'Thế cục sắp đổi',
        'Còn 1 mùa trước giai đoạn mới. ${reignStageHint(s)}',
        'warning',
      );
    }
    _addPetition(s, 'levee_warning');
    if (seasonal) _seasonPetitions(s);
    prepareHaremQuests(s);
    s.ensurePortraits();
    return s;
  }

  GameState execute(GameState original, GameCommand command) {
    if (original.runId != command.runId ||
        original.revision != command.expectedRevision) {
      throw const GameRuleException(
        'Tình hình đã thay đổi ở cửa sổ khác. Đã tải lại bản mới nhất; hãy chọn lại.',
      );
    }
    if (original.ended) {
      throw const GameRuleException('Lượt trị vì đã kết thúc.');
    }
    final s = original.copy();
    prepareHaremQuests(s);
    _financeWeek(s);
    _foodWeek(s);
    // A terminal state cannot be revived by issuing one more command.
    _finishIfCritical(s);
    if (!s.ended) {
      _warSync(s);
      prepareStoryPetitions(s);
      revealSeasonPetitions(s);
      switch (command.type) {
        case 'investigate':
          _startCovertInvestigation(s, command);
        case 'convict':
          _convict(s, command.target);
        case 'demote-court':
          _demoteCourtier(s, command.target, command.option);
        case 'appoint-manager':
          _appointManager(s, command.target, command.option);
        case 'promote':
          _promoteCourtier(s, command.target, command.option);
        case 'appoint-office':
          if (command.option.startsWith('{')) {
            Map<String, dynamic> data;
            try {
              data = Map<String, dynamic>.from(jsonDecode(command.option));
            } catch (_) {
              throw const GameRuleException('Lệnh bổ nhiệm không hợp lệ.');
            }
            if (data['candidate'] is! String || data['backfill'] is! String) {
              throw const GameRuleException(
                'Lệnh bổ nhiệm thiếu người tiếp nhận chức vụ.',
              );
            }
            _appointOffice(
              s,
              command.target,
              data['candidate'],
              backfillId: data['backfill'],
            );
          } else {
            _appointOffice(s, command.target, command.option);
          }
        case 'swap-office':
          _appointOffice(s, command.target, command.option, swap: true);
        case 'dismiss-office':
          _dismissOffice(s, command.target);
        case 'transfer':
          _transferTroops(s, command);
        case 'war':
          _warCommand(s, command);
        case 'action':
          _action(s, command.target, command.option);
        case 'petition':
          _resolve(s, command.target, command.option, command.assigneeId);
        case 'courtier':
          _courtier(s, command.target, command.option);
        case 'palace':
          throw const GameRuleException(
            'Học tập và cung vụ đã được thay bằng nhiệm vụ quan hệ.',
          );
        case 'harem-quest':
          _haremQuestOrder(s, command.target, command.option);
        case 'mission':
          _missionOrder(s, command.target, command.option);
        case 'chain':
          _chainChoice(s, command.target, command.option);
        case 'emergency':
          _emergency(s, command.target, command.option);
        case 'population':
          _populationCommand(s, command.target, command.option);
        case 'appoint':
          _appoint(s, command.target, command.option);
        case 'tax':
          final value = int.tryParse(command.option);
          if (value == null || value < 0 || value > 2 || value == s.tax) {
            throw const GameRuleException('Hãy chọn một mức thuế khác.');
          }
          _spend(s, money(s, 0), title: 'Điều chỉnh thuế');
          s.tax = value;
          s.workThisWeek++;
          s.affairsThisWeek++;
          s.note(
            'Điều chỉnh thuế',
            s.seasonal
                ? taxPolicyHint(s)
                : 'Thuế được đặt ở mức ${taxLabels[value]}.',
          );
        case 'priority':
          if (s.foodPressureEnabled) {
            throw const GameRuleException(
              'Cứu trợ được quyết định qua hành động hoặc tấu chương.',
            );
          }
          if (!['army', 'people'].contains(command.option) ||
              s.priority == command.option) {
            throw const GameRuleException('Hãy chọn ưu tiên chi trả khác.');
          }
          _spend(s, money(s, 0), title: 'Đổi ưu tiên ngân sách');
          s.priority = command.option;
          s.workThisWeek++;
          s.affairsThisWeek++;
          s.note(
            'Ưu tiên ngân sách',
            command.option == 'army'
                ? 'Ưu tiên trả lương quân đội khi thiếu tiền.'
                : 'Ưu tiên cứu tế khi thiếu tiền.',
          );
        case 'overtime':
          if (s.points != 0 || s.overtime >= 1) {
            throw GameRuleException(
              'Chỉ làm thêm một lần mỗi ${s.periodName}, sau khi đã dùng hết hành động.',
            );
          }
          s.overtime++;
          s.points += s.seasonal ? 2 : 1;
          s.fatigue += s.seasonal ? 10 : 5;
          s.stress += s.seasonal ? 8 : 4;
          s.note(
            'Làm việc quá giờ',
            'Bạn dành thêm thời gian cho việc nước. Long thể sẽ chịu thêm gánh nặng.',
            'warning',
          );
        case 'endWeek':
          _endWeek(s);
        default:
          throw const GameRuleException('Hành động không hợp lệ.');
      }
    }
    refreshCourtPersonnel(s);
    _warSync(s);
    _clamp(s);
    _finishIfCritical(s);
    if (s.ended) {
      _closeFinanceWeek(s);
      _closeFoodWeek(s);
    }
    s.revision++;
    s.history.add({
      ...command.toJson(),
      'week': original.week,
      'revision': s.revision,
    });
    prepareHaremQuests(s);
    s.ensurePortraits();
    return s;
  }

  FinanceWeek _financeWeek(GameState s) {
    if (s.financialWeeks.isEmpty || s.financialWeeks.last.week != s.week) {
      s.financialWeeks.add(
        FinanceWeek(
          week: s.week,
          openingBalance: s.treasury,
          openingDebt: s.debt,
          closingBalance: s.treasury,
          closingDebt: s.debt,
          partial:
              s.financialWeeks.isEmpty &&
              (s.revision > 0 || s.completedWeeks > 0),
        ),
      );
    }
    return s.financialWeeks.last;
  }

  void _postMoney(
    GameState s,
    int amount, {
    required String title,
    required String detail,
    String category = 'event',
    int requiredAmount = 0,
    int debtChange = 0,
  }) {
    final report = _financeWeek(s);
    s.treasury += amount;
    s.debt += debtChange;
    report.entries.add(
      FinanceEntry(
        title: title,
        detail: detail,
        category: category,
        amount: amount,
        requiredAmount: requiredAmount,
        debtChange: debtChange,
        balanceAfter: s.treasury,
        debtAfter: s.debt,
      ),
    );
    report.closingBalance = s.treasury;
    report.closingDebt = s.debt;
  }

  int _charge(
    GameState s,
    int required, {
    required String title,
    required String detail,
    String category = 'action',
  }) {
    final paid = math.min(s.treasury, required);
    if (required > 0) {
      _postMoney(
        s,
        -paid,
        title: title,
        detail: detail,
        category: category,
        requiredAmount: required,
        debtChange: required - paid,
      );
    }
    return paid;
  }

  void _closeFinanceWeek(GameState s) {
    final report = _financeWeek(s);
    report.closed = true;
    report.closingBalance = s.treasury;
    report.closingDebt = s.debt;
  }

  void _spend(
    GameState s,
    int money, {
    int points = 1,
    int grain = 0,
    required String title,
    String detail = '',
    String category = 'action',
  }) {
    if (s.points < points) {
      throw GameRuleException('Không còn đủ hành động trong ${s.periodName}.');
    }
    if (s.treasury < money) {
      throw const GameRuleException('Ngân khố không đủ cho lựa chọn này.');
    }
    if (s.grain < grain) {
      throw GameRuleException(
        'Cần $grain lương thực trong kho để thực hiện. Hãy bổ sung kho hoặc chờ mùa gặt.',
      );
    }
    s.points -= points;
    if (s.seasonal) s.seasonActionsSpent += points;
    _charge(
      s,
      money,
      title: title,
      detail:
          detail.isEmpty
              ? 'Kinh phí đã chi khi xác nhận; không hoàn lại nếu công việc thất bại.'
              : detail,
      category: category,
    );
    if (s.population == null) {
      s.grain -= grain;
    } else {
      _food(s, -grain, title, detail: detail, category: category);
    }
  }

  Courtier _person(GameState s, String id) => [
    ...s.court,
    if (s.hasCourtSystem) ...s.officialsPool,
  ].firstWhere(
    (c) => c.id == id && c.available,
    orElse:
        () => throw const GameRuleException('Nhân vật không còn ở vị trí này.'),
  );

  void _action(GameState s, String id, String officerId) {
    if (populationActionNames.containsKey(id)) {
      _populationCommand(s, id, officerId);
      return;
    }
    final definition = actions.where((a) => a.id == id).firstOrNull;
    if (definition == null) {
      throw const GameRuleException('Công việc không tồn tại.');
    }
    if (developmentTasks.contains(id)) {
      _startDevelopment(s, id, officerId);
      return;
    }
    if (id == 'maintain_levee') {
      if (s.levee >= 100) {
        throw const GameRuleException('Đê đang ở tình trạng tốt nhất.');
      }
      if ((s.actionCounts[id] ?? 0) > 0) {
        throw const GameRuleException('Chỉ bảo dưỡng đê một lần mỗi kỳ.');
      }
    }
    final securityBlock = id == 'security' ? securityBlocked(s) : null;
    if (securityBlock != null) throw GameRuleException(securityBlock);
    final revenueBlock = revenueTaskBlocked(s, id);
    if (revenueBlock != null) throw GameRuleException(revenueBlock);
    if (longTasks.contains(id) && s.projects.any((p) => p.kind == id)) {
      throw const GameRuleException('Công việc này đang được thực hiện.');
    }
    if (id == 'repair' && s.pending.any((p) => p.kind == 'petitionRepair')) {
      throw const GameRuleException('Đã có công trình sửa đê từ tấu chương.');
    }
    if (id == 'diplomacy' && s.pending.any((p) => p.kind == 'envoy')) {
      throw const GameRuleException('Sứ đoàn đang trên đường, hãy chờ hồi âm.');
    }
    if (id == 'mediate' && (s.actionCounts[id] ?? 0) > 0) {
      throw const GameRuleException(
        'Chỉ tổ chức hòa giải các phe một lần mỗi tuần.',
      );
    }
    if (id == 'buy_grain' && s.grain >= foodCapacity(s)) {
      throw const GameRuleException('Kho lương đã đầy.');
    }
    Courtier? officer;
    if (taskSpecialties.containsKey(id)) {
      if (officerId.isEmpty && longTasks.contains(id)) {
        throw const GameRuleException('Hãy chọn người phụ trách công việc.');
      }
      final defaultOfficer = taskOfficers(s, id).firstOrNull;
      if (officerId.isEmpty && defaultOfficer == null) {
        throw const GameRuleException('Không có quan đang rảnh để giao việc.');
      }
      officer = _person(s, officerId.isEmpty ? defaultOfficer!.id : officerId);
      if (officer.isConsort) {
        throw const GameRuleException(
          'Hãy giao việc này cho một quan trong triều.',
        );
      }
      if (officerBusy(s, officer.id)) {
        throw const GameRuleException(
          'Người này đang phụ trách công việc dài hạn. Hãy chọn người khác.',
        );
      }
    }
    final uses = s.actionCounts[id] ?? 0;
    final paidCost = actionCost(s, definition);
    final revenueBase =
        id == 'collect_arrears'
            ? arrearsBase(s)
            : id == 'sell_surplus' && s.population != null
            ? 25
            : revenueBaseReturns[id];
    _spend(
      s,
      paidCost,
      grain: actionGrainCost(s, definition),
      title: definition.title,
      detail:
          'Kinh phí ban đầu $paidCost ${moneyUnit(s)}${definition.grainCost > 0 ? ' và ${definition.grainCost} lương thực' : ''}.${officer == null ? '' : ' Giao ${officer.name} (${officer.role}) phụ trách.'} Không hoàn lại khi thất bại.',
    );
    s.actionCounts[id] = uses + 1;
    if (id == 'security' && s.seasonal) {
      s.cooldowns['task:security'] = s.week + securityCooldown;
    }
    if (id == 'collect_arrears') {
      s.cooldowns['task:collect_arrears'] =
          s.week + (s.seasonal ? 2 : s.cooldownTurns(4));
      s.arrearsUses++;
      s.people -= 2;
      s.fatigue += 4;
      s.stress += 3;
    }
    if (id == 'sell_surplus') s.fatigue += 2;
    String? result;
    if (!['rest', 'revel', 'treat'].contains(id)) s.workThisWeek++;
    if (!['rest', 'revel', 'treat'].contains(id)) s.affairsThisWeek++;
    if (id == 'govern') {
      s.fatigue += 6;
      s.stress += 4;
    }
    if (id == 'relief') s.stress += 2;
    if (id == 'security' && s.seasonal) s.stress += 3;
    if (id == 'mediate') {
      s.fatigue += 4;
      s.stress += 4;
    }
    final assessment = officer == null ? null : TaskAssessment(id, officer, s);
    if (officer != null &&
        ![...longTasks, 'diplomacy'].contains(id) &&
        !_taskSucceeds(s, id, officer)) {
      _assignOfficer(s, officer);
      return;
    }
    final delivery =
        officer == null || [...longTasks, 'diplomacy'].contains(id)
            ? 100
            : _deliveryPercent(s, officer, definition.title);
    int reward(int base) =>
        assessment == null
            ? base
            : (assessment.reward(base) * delivery / 100).round();
    int rewardMoney(int base) =>
        s.goldStandard
            ? money(
              s,
              base * (assessment?.rewardPercent ?? 100) / 100 * delivery / 100,
            )
            : reward(base);
    final meaningful =
        !s.hasCourtSystem ||
        switch (id) {
          'govern' => s.authority < 100 || (uses == 0 && s.stability < 100),
          'relief' => s.people < 100,
          'train' =>
            s.population == null ? s.army < 100 : s.population!.training < 100,
          'security' => s.court.any((c) => c.available && c.plot > 0),
          'mediate' =>
            s.stability < 100 ||
                s.factions.values.any((v) => v < 100) ||
                s.court.any((c) => c.available && c.discontent > 0),
          _ => true,
        };
    switch (id) {
      case 'maintain_levee':
        final gain = reward(12).clamp(0, 100 - s.levee);
        s.levee += gain;
        result = 'Tình trạng đê +$gain; cấp công trình giữ nguyên.';
      case 'collect_arrears':
      case 'sell_surplus':
        final gain = rewardMoney(revenueBase!);
        final paymentDetail =
            '${officer!.name}: cơ bản ${money(s, revenueBase)} ${moneyUnit(s)} × hiệu quả ${assessment!.rewardPercent}%, làm tròn = ${s.goldStandard ? money(s, revenueBase * assessment.rewardPercent / 100) : assessment.reward(revenueBase)}; kiểm đếm nhận $delivery% = $gain.${id == 'sell_surplus' ? ' Đã xuất ${whole(actionGrainCost(s, definition))} ${foodUnit(s)}.' : ' Thuế tồn thu được trong lần xử lý này.'}';
        if (s.seasonal) {
          final due = s.week + (id == 'collect_arrears' ? 1 : 0);
          s.pending.add(
            Consequence(
              kind: 'eventOutcome',
              dueWeek: due,
              title: definition.title,
              detail: '$paymentDetail Chuyển kho cuối ${s.date(due)}.',
              effects: {s.goldStandard ? 'gold' : 'treasury': gain},
            ),
          );
          result =
              'Đã chốt khoản thu $gain, chuyển kho cuối ${s.date(due)}. Chưa cộng vào ngân khố.';
        } else {
          _postMoney(
            s,
            gain,
            title: definition.title,
            category: 'action',
            detail: paymentDetail,
          );
        }
        result ??=
            'Ngân khố +$gain. ${id == 'collect_arrears' ? 'Lòng dân −2 · mệt +4 · căng thẳng +3. Có thể truy thu lại từ tuần ${s.cooldowns['task:collect_arrears']}.' : 'Đã xuất 40 lương thực · mệt +2. Chỉ bán một lần mỗi tuần.'}';
      case 'govern':
        final gain = reward(uses == 0 ? (s.authority >= 80 ? 2 : 3) : 1);
        s.authority += gain;
        if (uses == 0) s.stability++;
        result =
            'Uy quyền +$gain · Ổn định triều đình +${uses == 0 ? 1 : 0} · mệt mỏi +6 · căng thẳng +4. Lặp trong tuần giảm hiệu quả.';
      case 'relief':
        final base = s.people >= 75 ? 2 : 5;
        final gain = reward(math.max(1, base ~/ (uses + 1)));
        s.people += gain;
        _creditReliefFood(s, actionGrainCost(s, definition));
        result =
            'Chi ${moneyText(s, paidCost)} và xuất ${whole(actionGrainCost(s, definition))} ${foodUnit(s)}. Lòng dân +$gain. Cứu tế lặp lại hoặc khi lòng dân đã cao có hiệu quả thấp hơn.';
      case 'buy_grain':
        final amount = reward(s.population == null ? 30 : 200000);
        final received = _food(
          s,
          amount,
          definition.title,
          category: 'purchase',
          detail:
              'Cơ bản 200.000 tạ × hiệu quả ${assessment?.rewardPercent ?? 100}% × giao nhận $delivery%.',
        );
        result =
            'Lương thực +${whole(received)} ${foodUnit(s)} · chi ${moneyText(s, paidCost)}.';
      case 'mediate':
        for (final faction in s.factions.keys) {
          s.factions[faction] = s.factions[faction]! + reward(2);
        }
        for (final c in s.court.where((c) => c.available)) {
          c.discontent = math.max(0, c.discontent - reward(2));
        }
        s.authority -= 2;
        s.stability += reward(2);
        result =
            'Các phe +${reward(2)} · bất mãn mỗi người −${reward(2)} · Ổn định triều đình +${reward(2)} · uy quyền −2 · mệt +4 · căng thẳng +4.';
      case 'train':
        if (s.population == null) {
          s.army += reward(10);
          result = 'Quân lực +${reward(10)} · chi ${definition.cost}.';
        } else {
          final p = s.population!;
          final gain =
              reward(10) * math.min(1, 50000 / math.max(1, p.soldiers));
          p.changeTraining(gain.toDouble());
          result =
              'Huấn luyện +${gain.toStringAsFixed(1)} · chi ${definition.cost}.';
        }
        s.factions['Võ tướng'] = s.factions['Võ tướng']! + 2;
      case 'repair':
        s.projects.add(
          WorkOrder(
            id: 'p-${s.revision}',
            kind: id,
            officerId: officer!.id,
            startedWeek: s.week,
            duration: s.workTurns(4),
          ),
        );
      case 'farm':
      case 'commerce':
        s.projects.add(
          WorkOrder(
            id: 'p-${s.revision}',
            kind: id,
            officerId: officer!.id,
            startedWeek: s.week,
            duration: id == 'commerce' ? commerceDuration(s) : s.workTurns(5),
          ),
        );
      case 'rest':
        result = 'Đã dành thời gian dưỡng sức. ${careActionDescription(s, id)}';
        s.restThisWeek++;
      case 'revel':
        result =
            'Đã thu xếp thưởng nhạc, yến tiệc. ${careActionDescription(s, id)}';
        s.revelThisWeek++;
      case 'treat':
        final illnessReduction = math.min(
          s.illness,
          treatmentIllnessRecovery(s),
        );
        final fatigueReduction = math.min(s.fatigue, treatmentFatigueRecovery);
        final healthGain = math.min(100 - s.health, treatmentHealthRecovery);
        s.illness -= illnessReduction;
        s.fatigue -= fatigueReduction;
        s.health += healthGain;
        result =
            'Đã chi $paidCost ${moneyUnit(s)} · sức khỏe +$healthGain · mức bệnh −$illnessReduction · mệt mỏi −$fatigueReduction. Hiệu quả áp dụng ngay.'
            '${paidCost < money(s, definition.cost) ? ' Dược liệu hỗ trợ ${money(s, definition.cost) - paidCost} ${moneyUnit(s)}.' : ''}';
      case 'security':
        final reduction = reward(s.seasonal ? 7 : 18);
        for (final c in s.court.where(
          (c) => !s.seasonal || (c.available && (!c.isConsort || c.inHarem)),
        )) {
          c.plot = math.max(0, c.plot - reduction);
        }
        if (!s.seasonal) s.authority += 2;
        result =
            'Tiến độ âm mưu −$reduction · chi ${actionCost(s, definition)}.${s.seasonal ? ' Căng thẳng +3; huy động lại từ ${s.date(s.cooldowns['task:security']!)}. Cần xử lý trung thành và phe phái.' : ' Uy quyền +2.'}';
      case 'diplomacy':
        s.pending.add(
          Consequence(
            kind: 'envoy',
            dueWeek: s.week + s.workTurns(3) - 1,
            target: officer!.id,
          ),
        );
    }
    if (officer != null) {
      _assignOfficer(
        s,
        officer,
        success: meaningful && ![...longTasks, 'diplomacy'].contains(id),
        meritTitle: definition.title,
        meritEventId: 'action-${s.revision}',
      );
    }
    if (['relief', 'buy_grain'].contains(id)) _respond(s, 'hunger');
    if (id == 'train') _respond(s, 'border');
    if (id == 'security') _respond(s, 'plot');
    s.note(
      definition.title,
      officer == null
          ? result ?? definition.description
          : [...longTasks, 'diplomacy'].contains(id)
          ? 'Giao ${officer.name} (${officer.specialty}, năng lực ${officer.ability}) phụ trách. Kinh phí đã cấp; kết quả sẽ xét chuyên môn, năng lực, mệt mỏi, quan hệ và tính cách khi hoàn tất.'
          : '${officer.name} hoàn thành. ${fitLabel(assessment!.fit)} · mức hiệu quả ${assessment.rewardPercent}%. ${result ?? definition.description}',
    );
  }

  bool _taskSucceeds(GameState s, String task, Courtier officer) {
    final chance = TaskAssessment(task, officer, s).successChance;
    final roll = _next(s, 100);
    if (roll < chance) return true;
    final severe =
        roll >=
        chance + TaskAssessment(task, officer, s).personality.severeMargin;
    final n = severe ? 2 : 1;
    final effects = switch (task) {
      'maintain_levee' => {'levee': -2},
      'collect_arrears' => {
        'authority': -2 * n,
        'people': -n,
        if (severe) 'stability': -2,
        if (severe) 'treasury': -10,
      },
      'sell_surplus' => {
        'authority': -n,
        'people': -n,
        if (severe) 'treasury': -8,
      },
      'commerce' => {
        'treasury': -10 * n,
        'authority': -n,
        if (severe) 'people': -2,
      },
      'train' => {'army': -3 * n, 'authority': -n, if (severe) 'treasury': -15},
      'repair' => {
        'levee': -4 * n,
        'people': -2 * n,
        if (severe) 'authority': -3,
        if (severe) 'treasury': -15,
      },
      'farm' || 'relief' => {
        'people': -2 * n,
        'grain': -3 * n,
        if (severe) 'authority': -2,
        if (severe) 'treasury': -10,
      },
      'buy_grain' => {'authority': -n, if (severe) 'treasury': -15},
      'security' => {
        'authority': -2 * n,
        'stability': -n,
        'plotReduce': -4 * n,
      },
      'diplomacy' => {
        'war': n,
        'authority': -2 * n,
        if (severe) 'treasury': -20,
      },
      _ => {'authority': -2 * n, 'stability': -n, if (severe) 'people': -2},
    };
    _apply(
      s,
      effects,
      title:
          '${severe ? 'Thất bại nặng' : 'Thất bại'}: ${actions.firstWhere((a) => a.id == task).title}',
      detail:
          '${officer.name}, năng lực ${officer.ability}; thiệt hại phát sinh ngoài kinh phí đã chi.',
      category: longTasks.contains(task) ? 'project' : 'action',
    );
    final details = effects.entries
        .map(
          (e) =>
              '${switch (e.key) {
                'army' => 'quân lực',
                'authority' => 'uy quyền',
                'stability' => stabilityLabel,
                'people' => 'lòng dân',
                'treasury' => 'ngân khố',
                'grain' => 'lương thực',
                'levee' => 'đê điều',
                'war' => 'áp lực chiến tranh',
                _ => 'tiến độ âm mưu',
              }} ${e.key == 'plotReduce'
                  ? '+${-e.value}'
                  : e.value > 0
                  ? '+${e.value}'
                  : e.value}',
        )
        .join(' · ');
    s.note(
      severe ? 'Công việc thất bại nặng' : 'Công việc thất bại',
      '${actions.firstWhere((a) => a.id == task).title}: ${officer.name}, năng lực ${officer.ability}, ${fitLabel(TaskAssessment(task, officer, s).fit).toLowerCase()}. $details. Kinh phí đã cấp không được hoàn lại.',
      severe ? 'danger' : 'warning',
    );
    return false;
  }

  int _deliveryPercent(GameState s, Courtier c, String title) {
    final assessment = PersonalityAssessment(c, s);
    if (assessment.corruptionChance == 0 ||
        _next(s, 100) >= assessment.corruptionChance) {
      return 100;
    }
    final loss = assessment.lossPercent;
    // Report an observed shortfall, never reveal a hidden trait or accuse a
    // particular official without investigation. No second treasury debit.
    s.note(
      'Thành quả bị thất thoát',
      '$title do ${c.name} phụ trách: kiểm đếm chỉ nhận ${100 - loss}% thành quả, thiếu $loss%. '
          '${c.investigated ? 'Liêm chính đã xác minh: ${c.integrity}/100.' : 'Chưa rõ nguyên nhân; phẩm chất người phụ trách chưa được xác minh.'}',
      'warning',
    );
    return 100 - loss;
  }

  void _learnPersonality(GameState s, Courtier c) {
    final before = c.knownPersonalityCount;
    c.personalityContacts++;
    if (c.knownPersonalityCount <= before) return;
    final discovered = c.knownPersonalities.last;
    s.note(
      'Hiểu thêm về ${c.name}',
      'Qua ${c.personalityContacts} lần trò chuyện, lắng nghe, bệ hạ nhận ra: ${discovered.label}. ${discovered.description}',
      'gold',
    );
  }

  Courtier _newOfficialCandidate(GameState s) {
    final serial = s.nextOfficialCandidate++;
    const specialties = [
      'Dân chính',
      'Kinh tế',
      'Công trình',
      'Quân sự',
      'An ninh',
      'Ngoại giao',
      'Y thuật',
      'Cung đình',
    ];
    const surnames = ['Đỗ', 'Bùi', 'Phan', 'Tạ', 'Trần', 'Nguyễn', 'Lê', 'Vũ'];
    const names = [
      'Minh Khang',
      'Quang Hòa',
      'Thành Đạt',
      'Bảo An',
      'Đức Hải',
      'Văn Khôi',
      'Trọng Tín',
      'Công Bình',
      'Thanh Tùng',
      'Quốc Phong',
      'Gia Huy',
      'Nhật Nam',
    ];
    var name = '';
    for (var attempt = 0; attempt < 96; attempt++) {
      name =
          '${surnames[(serial + attempt ~/ names.length) % surnames.length]} ${names[(serial ~/ surnames.length + attempt) % names.length]}';
      if (![
        ...s.court,
        ...s.officialsPool,
      ].any((c) => c.available && c.name == name)) {
        break;
      }
    }
    final candidate = Courtier(
      id: 'official-candidate-$serial',
      name: name,
      role: 'Ứng viên',
      faction: factionOpponents.keys.elementAt(serial % 4),
      trait: 'Được tiến cử từ địa phương; cần điều tra thêm về phẩm chất.',
      age: 24 + _next(s, 22),
      ability: [32, 55, 80][serial % 3] + _next(s, 15),
      loyalty: 45 + _next(s, 41),
      ambition: 25 + _next(s, 56),
      integrity: 35 + _next(s, 56),
      influence: 25 + _next(s, 26),
      specialty: specialties[serial % specialties.length],
    );
    _initialAffection(s, candidate);
    if (s.hasCourtSystem) {
      candidate.role = 'Chờ bổ nhiệm';
      candidate.grade = serial == 0 ? 1 : 3 + _next(s, 7);
      if (serial == 0) {
        candidate.ability = 90;
        candidate.specialty = 'Dân chính';
      }
    }
    return candidate;
  }

  void _appoint(GameState s, String outgoingId, String candidateId) {
    if (s.hasCourtSystem) {
      final office = courtOfficeFor(s, outgoingId);
      if (office == null) {
        throw const GameRuleException('Quan không còn giữ chức vụ.');
      }
      _appointOffice(s, office.id, candidateId);
      return;
    }
    final old = _person(s, outgoingId);
    if (old.isConsort) {
      throw const GameRuleException('Chỉ thay thế chức vụ của triều thần.');
    }
    final candidate =
        s.officialsPool
            .where(
              (c) =>
                  c.id == candidateId &&
                  c.available &&
                  !c.isConsort &&
                  c.age >= 18,
            )
            .firstOrNull;
    if (candidate == null) {
      throw const GameRuleException(
        'Ứng viên không còn trong danh sách tiến cử.',
      );
    }
    final price = appointmentCost(candidate, old.role, s);
    _spend(
      s,
      price,
      title: 'Bổ nhiệm ${candidate.name}',
      category: 'character',
      detail:
          'Thay ${old.name} giữ chức ${old.role}, bậc ${appointmentRank(old.role)}/4. Năng lực ${candidate.ability}, địa vị (ảnh hưởng) ${candidate.influence}/100 → phí $price ${moneyUnit(s)}.',
    );
    s.workThisWeek++;
    s.affairsThisWeek++;
    old.available = false;
    if (old.id == s.heirId) {
      s.heirCondition = 'withdrawn';
      s.successionCertified = false;
    }
    candidate.role = old.role;
    s.officialsPool.remove(candidate);
    s.court.add(candidate);
    for (final p in s.projects.where((p) => p.officerId == old.id)) {
      // Development has strict specialist/ability gates and a frozen chance.
      // A replacement officeholder must be explicitly reassigned and checked.
      if (developmentTasks.contains(p.kind)) {
        p.paused = true;
      } else {
        p.officerId = candidate.id;
      }
    }
    for (final p in s.pending.where(
      (p) => p.kind == 'envoy' && p.target == old.id,
    )) {
      p.target = candidate.id;
    }
    for (final o in s.major?.objectives ?? <MissionObjective>[]) {
      if (o.working && o.officerId == old.id) o.officerId = candidate.id;
    }
    if (old.influence >= 60) {
      s.obligations.add(
        Obligation(
          id: 'dismiss-${s.revision}',
          kind: 'resentment',
          title: 'Phe ${old.faction} phản ứng việc bãi ${old.name}',
          remaining: s.seasonal ? 1 : 3,
          nextWeek: s.week + 1,
          effects: {'faction:${old.faction}': -1},
        ),
      );
    }
    s.stability -= replacementDisruption(old);
    s.authority++;
    if (old.faction != candidate.faction) {
      s.factions[old.faction] = s.factions[old.faction]! - 4;
    }
    _favorFaction(s, candidate.faction, 5, 2);
    s.officialsPool.add(_newOfficialCandidate(s));
    s.note(
      'Bổ nhiệm ${candidate.name}',
      'Thay ${old.name} giữ chức ${old.role} (bậc ${appointmentRank(old.role)}/4). Chi $price; phí dựa trên năng lực ${candidate.ability}, địa vị (ảnh hưởng) ${candidate.influence}/100 và chức vụ tiếp nhận · Ổn định triều đình −${replacementDisruption(old)} · uy quyền +1. Phe ${candidate.faction} +5, phe ${factionOpponents[candidate.faction]} −6; phe người bị bãi chức −4 nếu khác phe người mới. Công việc đang giao được chuyển cho người mới, giữ tiến độ; chuyên môn vẫn là ${candidate.specialty}. Tấu chương đã giao riêng cho người cũ sẽ gián đoạn, không tự chuyển phân công.',
      'warning',
    );
  }

  void _initialAffection(GameState s, Courtier c) {
    final hostile = c.faction == s.hostileFaction;
    final base =
        hostile
            ? 26
            : c.faction == factionOpponents[s.hostileFaction]
            ? 62
            : 47;
    c.affection = (base + _next(s, 19) - 9 + (c.loyalty - 60) ~/ 8).clamp(
      hostile ? 12 : 36,
      hostile ? 35 : 78,
    );
    c.baseAffection = c.affection;
    c.discontent = math.max(0, 40 - c.affection);
  }

  int _favor(
    GameState s,
    Courtier c,
    int maximum, {
    required int mood,
    required int rivalLoss,
  }) {
    final repeats = s.favorsThisWeek[c.id] ?? 0;
    final base =
        c.affection >= 85
            ? 1
            : c.affection >= 65
            ? math.min(3, maximum)
            : maximum;
    final grateful = c.personalities.contains(Personality.grateful);
    final bonus = repeats == 0 ? (grateful ? 2 : 0) : 0;
    final gain = ((base + bonus) ~/ (repeats + 1)).clamp(0, 100 - c.affection);
    _grantFavor(s, c, gain, mood: mood, rivalLoss: rivalLoss);
    return gain;
  }

  void _grantFavor(
    GameState s,
    Courtier c,
    int gain, {
    required int mood,
    required int rivalLoss,
  }) {
    final repeats = s.favorsThisWeek[c.id] ?? 0;
    c.affection += gain;
    c.discontent = math.max(0, c.discontent - gain);
    s.favorsThisWeek[c.id] = repeats + 1;
    s.stress += repeats * 2;
    _favorFaction(s, c.faction, mood, rivalLoss);
  }

  void _favorFaction(GameState s, String faction, int gain, int rivalLoss) {
    final opponent = factionOpponents[faction]!;
    s.factions[faction] = s.factions[faction]! + gain;
    s.factions[opponent] = s.factions[opponent]! - gain - 1;
    for (final person in s.court.where(
      (c) => c.available && c.faction == opponent,
    )) {
      person.affection -= rivalLoss;
      person.discontent = math.min(100, person.discontent + rivalLoss);
    }
  }

  void _admit(GameState s, Courtier c) {
    final admission = haremAdmissionBlocked(s);
    if (admission != null) throw GameRuleException(admission);
    c.inHarem = true;
    c.affection += 8;
    c.discontent = math.max(0, c.discontent - 8);
    _favorFaction(s, c.faction, 5, 2);
    s.stability -= 1;
    s.note(
      'Tuyển phi: ${c.name}',
      'Gia tộc được ưu ái; mỗi nhân vật phe ${factionOpponents[c.faction]} giảm 2 thiện cảm, gồm tú nữ/phi tần. Chi sinh hoạt tăng ${money(s, s.seasonal ? 6 : 2)} ${moneyUnit(s)}/${s.periodName}.',
      'gold',
    );
  }

  Courtier _newCandidate(GameState s) {
    const surnames = [
      'Đỗ',
      'Bùi',
      'Phan',
      'Tạ',
      'Trần',
      'Nguyễn',
      'Lê',
      'Hoàng',
    ];
    const middles = ['Ngọc', 'Thanh', 'Nhã', 'Bích', 'Tú', 'Ánh'];
    const names = [
      'Dung',
      'Hà',
      'Uyên',
      'Thư',
      'Quỳnh',
      'Hương',
      'Nhiên',
      'Anh',
    ];
    var name = '';
    for (var attempt = 0; attempt < 64; attempt++) {
      name =
          '${surnames[_next(s, surnames.length)]} ${middles[_next(s, middles.length)]} ${names[_next(s, names.length)]}';
      if (!s.court.any((c) => c.available && c.name == name)) break;
    }
    final c = Courtier(
      id: 'candidate-${s.week}-${s.court.length}',
      name: name,
      role: 'Tiểu thư',
      faction: factionOpponents.keys.elementAt(_next(s, 4)),
      trait:
          [
            'Giỏi thư họa, coi trọng sự chân thành',
            'Quen lễ nghi, luôn nhớ tới gia tộc',
            'Thẳng thắn, muốn góp sức cho dân sinh',
            'Kín đáo, có tài thu xếp việc cung đình',
          ][_next(s, 4)],
      age: 18 + _next(s, 11),
      ability: 0,
      loyalty: 50 + _next(s, 31),
      ambition: 30 + _next(s, 36),
      integrity: 50 + _next(s, 36),
      influence: 30 + _next(s, 26),
    );
    _initialAffection(s, c);
    s.court.add(c);
    return c;
  }

  void _courtier(GameState s, String id, String option) {
    final c = _person(s, id);
    switch (option) {
      case 'audience':
        _spend(
          s,
          money(s, 0),
          title: 'Tiếp kiến ${c.name}',
          category: 'character',
        );
        s.workThisWeek++;
        if (!c.isConsort) s.affairsThisWeek++;
        final gain = _favor(s, c, 6, mood: 2, rivalLoss: 2);
        if (gain > 0 &&
            c.loyalty > 45 &&
            c.affection >= 55 &&
            s.favorsThisWeek[c.id] == 1) {
          c.loyalty++;
        }
        s.stress += 2;
        s.note(
          'Tiếp kiến ${c.name}',
          'Thiện cảm +$gain; bất mãn giảm tối đa $gain. Phe ${factionOpponents[c.faction]} giảm thái độ 3, mỗi nhân vật đang hiện diện của phe đó (gồm tú nữ và phi tần) giảm 2 thiện cảm và tăng 2 bất mãn. Tiếp kiến lặp lại và quan hệ đã cao có hiệu quả thấp hơn.',
        );
        _learnPersonality(s, c);
      case 'reward': // Older commands use the smallest reward.
      case 'reward:20':
      case 'reward:40':
      case 'reward:80':
        final tier = CharacterReward.values.firstWhere(
          (tier) => tier.option == option,
          orElse: () => CharacterReward.small,
        );
        final cost = tier.cost(s);
        final gain = tier.affectionGain(c.affection);
        _spend(
          s,
          cost,
          title: 'Ban thưởng ${c.name}',
          detail:
              '${moneyText(s, cost)} quà ban thưởng cho ${c.displayRole}, phe ${c.faction}; thiện cảm +$gain.',
          category: 'character',
        );
        s.workThisWeek++;
        if (!c.isConsort) s.affairsThisWeek++;
        _grantFavor(s, c, gain, mood: 3, rivalLoss: 3);
        if (gain > 0 && s.favorsThisWeek[c.id] == 1) c.loyalty += 2;
        c.influence += 2;
        s.note(
          'Ban thưởng ${c.name}',
          'Ngân khố −${moneyText(s, cost)} · thiện cảm +$gain; bất mãn giảm tối đa $gain. Phe ${factionOpponents[c.faction]} giảm thiện cảm 3 (người đạt 100 được giữ nguyên) và tăng 3 bất mãn; quyền lực người được thưởng tăng.',
        );
      case 'investigate':
        if (s.hasCourtSystem) {
          throw const GameRuleException(
            'Hãy chọn mật thám và kinh phí điều tra.',
          );
        }
        if (s.pending.any((p) => p.kind == 'investigate' && p.target == id)) {
          throw const GameRuleException('Cuộc điều tra đang được tiến hành.');
        }
        _spend(
          s,
          investigationCost(s),
          title: 'Điều tra ${c.name}',
          detail:
              '${investigationCost(s)} ${moneyUnit(s)}; kết quả âm mưu, bất mãn và xác minh phẩm chất về cuối ${s.date(s.week + investigationDuration(s) - 1)}.',
          category: 'character',
        );
        s.workThisWeek++;
        s.affairsThisWeek++;
        final intelligence = CharacterInvestigation(
          week: s.week,
          plot: c.plot,
          discontent: c.discontent,
        );
        s.pending.add(
          Consequence(
            kind: 'investigate',
            dueWeek: s.week + investigationDuration(s) - 1,
            target: id,
            investigation: intelligence,
          ),
        );
        s.note(
          'Điều tra kín',
          'Bắt đầu điều tra ${c.name}. Kết quả sẽ hiển thị cuối ${s.date(s.week + investigationDuration(s) - 1)}, theo số liệu tại thời điểm bắt đầu. Trong lúc chờ, hai thanh giữ kết quả lần trước hoặc Chưa rõ. Âm mưu lớn khó lấy chứng cứ hơn.',
        );
      case 'dismiss':
        throw const GameRuleException(
          'Hãy chọn ứng viên và xác nhận chi phí để thay thế.',
        );
      case 'expel':
        final reason = haremDisciplineBlocked(c, expel: true);
        if (reason != null) throw GameRuleException(reason);
        _spend(s, 0, title: 'Trục xuất ${c.name}', category: 'character');
        s.workThisWeek++;
        c.available = false;
        s.factions[c.faction] =
            s.factions[c.faction]! - haremExpulsionFactionLoss;
        s.stability -= haremExpulsionStabilityLoss;
        s.petitions.removeWhere(
          (p) => p.definitionId == 'consort_recommendation' && p.targetId == id,
        );
        s.note(
          'Trục xuất ${c.name}',
          'Tú nữ rời danh sách, không thể tuyển lại. Thái độ phe ${c.faction} −$haremExpulsionFactionLoss; ${haremStabilityEffectText(haremExpulsionStabilityLoss)}. Chi 1 hành động, không chi ngân khố.',
          'warning',
        );
      case 'demote':
        final reason = haremDisciplineBlocked(c, expel: false);
        if (reason != null) throw GameRuleException(reason);
        final wasQueen = c.queen;
        final from = c.displayRole;
        final losses = haremDemotionLosses(c);
        final affectionEffect = haremDemotionAffectionText(c);
        _spend(s, 0, title: 'Giáng chức ${c.name}', category: 'character');
        s.workThisWeek++;
        if (wasQueen) {
          c.queen = false;
        } else {
          c.inHarem = false;
        }
        c.affection -= losses.affection;
        c.discontent += losses.discontent;
        s.factions[c.faction] = s.factions[c.faction]! - losses.faction;
        s.stability -= losses.stability;
        s.cooldowns['harem-demotion:${c.id}'] = s.week + 1;
        s.note(
          'Giáng chức ${c.name}',
          '$from → ${c.displayRole}. $affectionEffect, bất mãn +${losses.discontent}; thái độ phe ${c.faction} −${losses.faction}; ${haremStabilityEffectText(losses.stability)}. '
              '${wasQueen ? 'Ngôi Hoàng hậu để trống, mất lợi ích bổ sung của Hoàng hậu; chi sinh hoạt giữ nguyên.' : 'Ngừng đóng góp hậu cung, giảm chi sinh hoạt ${money(s, s.seasonal ? 6 : 2)} ${moneyUnit(s)}/${s.periodName} từ kỳ thu chi tiếp theo; không hoàn phí nhập cung.'} '
              'Chỉ tuyển hoặc sắc phong lại từ ${s.date(s.week + 1)}. Chi 1 hành động, không chi ngân khố.',
          'warning',
        );
      case 'invite':
        if (!c.isConsort || c.inHarem || c.age < 18) {
          throw const GameRuleException(
            'Không thể tuyển nhân vật này vào cung.',
          );
        }
        final reason = haremPromotionBlocked(s, c);
        if (reason != null) throw GameRuleException(reason);
        _spend(
          s,
          money(s, 35),
          title: 'Tuyển ${c.name} vào hậu cung',
          detail:
              '${money(s, 35)} ${moneyUnit(s)} cho việc nhập cung; sinh hoạt hậu cung còn phát sinh ${money(s, s.seasonal ? 6 : 2)} ${moneyUnit(s)} mỗi ${s.periodName} từ kỳ thu chi sau.',
          category: 'character',
        );
        s.workThisWeek++;
        _admit(s, c);
        s.petitions.removeWhere(
          (p) => p.definitionId == 'consort_recommendation' && p.targetId == id,
        );
      case 'queen':
        if (!c.inHarem || c.queen) {
          throw const GameRuleException(
            'Chỉ phong hậu cho một phi tần chưa giữ ngôi hậu.',
          );
        }
        final reason = haremPromotionBlocked(s, c);
        if (reason != null) throw GameRuleException(reason);
        _spend(
          s,
          money(s, 60),
          title: 'Sắc phong Hoàng hậu: ${c.name}',
          detail:
              '${money(s, 60)} ${moneyUnit(s)} tổ chức lễ sắc phong; không phải khoản chi hàng tuần.',
          category: 'character',
        );
        s.workThisWeek++;
        for (final other in s.court.where((x) => x.queen)) {
          other.queen = false;
          other.affection -= 25;
          other.discontent = math.min(100, other.discontent + 25);
          s.stability -= 10;
        }
        c.queen = true;
        c.affection += 18;
        c.discontent = math.max(0, c.discontent - 18);
        c.influence += 12;
        _favorFaction(s, c.faction, 8, 4);
        s.stability += 3;
        s.note(
          'Sắc phong Hoàng hậu',
          '${c.name} nhận kim sách. Vị thế các gia tộc trong triều thay đổi.',
          'gold',
        );
      case 'visit':
        if (!c.inHarem) {
          throw const GameRuleException('Nhân vật chưa ở trong hậu cung.');
        }
        _spend(
          s,
          money(s, 10),
          title: 'Dạo Ngự uyển cùng ${c.name}',
          detail: '${money(s, 10)} ${moneyUnit(s)} cho buổi dạo vườn.',
          category: 'character',
        );
        final gain = _favor(s, c, 7, mood: 1, rivalLoss: 2);
        s.revelThisWeek++;
        for (final other in s.court.where((x) => x.inHarem && x.id != id)) {
          other.affection -= 2;
          other.discontent = math.min(100, other.discontent + 2);
        }
        s.note(
          'Dạo Ngự uyển cùng ${c.name}',
          'Thiện cảm +$gain; phe đối lập bất mãn. Hoạt động được tính vào mức hưởng lạc trong tuần.',
        );
      default:
        throw const GameRuleException('Lệnh nhân vật không hợp lệ.');
    }
  }

  void _resolve(
    GameState s,
    String petitionId,
    String option,
    String assigneeId,
  ) {
    final p = s.petitions.where((p) => p.id == petitionId).firstOrNull;
    if (p == null) {
      throw const GameRuleException('Tấu chương đã được xử lý hoặc hết hạn.');
    }
    if (isFoodRecoveryEvent(p.definitionId)) {
      _resolveFoodRecovery(s, p, option, assigneeId: assigneeId);
      return;
    }
    if (isCourtPersonnelEvent(p.definitionId)) {
      _resolveCourtPersonnel(s, p, option, assigneeId);
      return;
    }
    if (p.isStory) {
      _resolveStoryPetition(s, p, option, assigneeId: assigneeId);
      return;
    }
    final e = eventForState(s, p.definitionId);
    final index = int.tryParse(option);
    if (index == null || index < 0 || index >= e.choices.length) {
      throw const GameRuleException('Lựa chọn không hợp lệ.');
    }
    final choice = e.choices[index];
    if (s.warfare != null && choice.effects.containsKey('warMission')) {
      _warPetition(s, p, e, choice);
      return;
    }
    if (s.population != null &&
        choice.troops > s.population!.availableSoldiers) {
      throw GameRuleException('Cần ${whole(choice.troops)} quân rảnh.');
    }
    final managed = petitionCanAssign(s, choice) && choice.troops == 0;
    Courtier? person;
    if (assigneeId.isNotEmpty) {
      if (!managed && choice.troops == 0) {
        throw const GameRuleException(
          'Phương án này không có công việc để giao.',
        );
      }
      person = _person(s, assigneeId);
      final blocked = petitionAssigneeBlocked(
        s,
        person,
        specialty: petitionSpecialty(e, choice),
      );
      if (blocked != null) throw GameRuleException(blocked);
    }
    final chance = managed ? petitionChance(s, e, choice, person) : 0;
    final appliedHint = petitionChoiceHint(s, e, choice, person: person);
    if (choice.effects.containsKey('repair') &&
        (s.projects.any((p) => p.kind == 'repair') ||
            s.pending.any((p) => p.kind == 'petitionRepair'))) {
      throw const GameRuleException(
        'Đã có công trình sửa đê. Hãy chọn phương án khác.',
      );
    }
    Courtier? recruit;
    if (choice.effects.containsKey('recruitConsort')) {
      recruit = _person(s, p.targetId);
      if (!recruit.isConsort || recruit.inHarem || recruit.age < 18) {
        throw const GameRuleException(
          'Ứng viên không còn đủ điều kiện nhận làm tú nữ.',
        );
      }
    }
    _spend(
      s,
      choice.cost,
      points: petitionPoints(s, choice),
      grain: choice.grainCost,
      title: e.title,
      detail:
          '${choice.label}.${choice.grainCost > 0 ? ' Xuất thêm ${choice.grainCost} lương thực.' : ''}',
      category: 'event',
    );
    if (s.foodPressureEnabled && ['flood', 'hunger'].contains(e.id)) {
      _creditReliefFood(s, (choice.grainCost * 4) ~/ 5);
    }
    s.workThisWeek += petitionPoints(s, choice);
    final deployment = s.population != null && choice.troops > 0;
    if (deployment) _deployChoice(s, e, choice, assigneeId);
    final assignment =
        managed ? _startPetitionAssignment(s, e, choice, person, chance) : null;
    if (!['Cung đình', 'Hậu cung', 'Sức khỏe'].contains(e.category)) {
      s.affairsThisWeek++;
    }
    _apply(
      s,
      {
        for (final entry in choice.effects.entries)
          if (assignment == null || entry.key != 'repair')
            entry.key: entry.value,
      },
      title: e.title,
      detail: choice.label,
      targetId: p.targetId,
    );
    if ((choice.effects['grain'] ?? 0) > 0 ||
        (eventTrigger(e) == 'hunger' && (choice.effects['people'] ?? 0) > 0)) {
      _respond(s, 'hunger');
    }
    if ((choice.effects['army'] ?? 0) > 0 ||
        choice.effects.containsKey('peace')) {
      _respond(s, 'border');
    }
    if ((choice.effects['plotReduce'] ?? 0) > 0) _respond(s, 'plot');
    if (!deployment) _queuePetitionResult(s, e, choice, assignment);
    _recordOrdinaryDisaster(s, e, index);
    s.petitions.remove(p);
    s.note(
      e.title,
      '${choice.label}. $appliedHint'
      '${assignment == null ? '' : ' ${assignment.personLabel} · tỷ lệ đã chốt ${assignment.chance}%.'}',
    );
  }

  void _scheduleEventOutcome(
    GameState s,
    EventDefinition event,
    EventChoice choice, {
    PetitionAssignment? assignment,
  }) {
    if (choice.laterEffects.isEmpty) return;
    final success =
        assignment?.succeeded ??
        (choice.successChance == 100 || _next(s, 100) < choice.successChance);
    final effects = success ? choice.laterEffects : choice.laterFailureEffects;
    s.pending.add(
      Consequence(
        kind: 'eventOutcome',
        dueWeek: s.week + petitionDelay(s, choice) - 1,
        title: event.title,
        detail:
            assignment == null
                ? '${choice.label}: ${success ? 'thành công' : 'thất bại'}.'
                : choice.label,
        effects: Map<String, int>.from(effects),
        assignment: assignment,
      ),
    );
  }

  void _apply(
    GameState s,
    Map<String, int> effects, {
    required String title,
    String detail = '',
    String category = 'event',
    String targetId = '',
  }) {
    final resolved = currencyEffects(
      s,
      s.population == null
          ? effects
          : populationEffects(
            effects,
            context: title,
            challenging: s.challengingEconomy,
          ),
    );
    for (final entry in resolved.entries) {
      final value = entry.value;
      if (_populationEffect(
        s,
        entry.key,
        value,
        title,
        detail: detail,
        category: category,
      )) {
        continue;
      }
      switch (entry.key) {
        case 'treasury':
        case 'gold':
          if (value < 0) {
            _charge(
              s,
              -value,
              title: title,
              detail: detail,
              category: category,
            );
          } else if (value > 0) {
            _postMoney(
              s,
              value,
              title: title,
              detail: detail,
              category: category,
            );
          }
        case 'people':
          s.people += value;
        case 'authority':
          s.authority += value;
        case 'army':
          s.army += value;
        case 'health':
          s.health += value;
        case 'stability':
          s.stability += value;
        case 'grain':
          s.grain += value;
        case 'levee':
          s.levee += value;
        case 'stress':
          s.stress += value;
        case 'fatigue':
          s.fatigue += value;
        case 'illness':
          s.illness += value;
        case 'war':
          s.war += value;
        case 'debt':
        case 'goldDebt':
          final actual = math.max(0, s.debt + value) - s.debt;
          if (actual != 0) {
            _postMoney(
              s,
              money(s, 0),
              title: title,
              detail:
                  '$detail Thay đổi nghĩa vụ nợ, không phải dòng tiền ngân khố.',
              category: category,
              debtChange: actual,
            );
          }
        case 'revel':
          s.revelThisWeek += value;
        case 'rest':
          s.restThisWeek += value;
        case 'work':
          s.workThisWeek += value;
        case 'peace':
          if (s.warfare?.active != null) {
            final n = s.warfare!.active!;
            _warSignTreaty(
              s,
              n,
              n.advantage < -29 ? 'medium' : 'light',
              receiving: false,
            );
          }
          s.war = 0;
          s.siege = 0;
        case 'taxNormal':
          s.tax = 1;
        case 'plotReduce':
          for (final c in s.court) {
            c.plot = math.max(0, c.plot - value);
          }
        case 'repair':
          final officer = taskOfficers(s, 'repair').first;
          s.projects.add(
            WorkOrder(
              id: 'p-${s.revision}',
              kind: 'repair',
              officerId: officer.id,
              startedWeek: s.week,
              duration: s.workTurns(4),
            ),
          );
        case 'revealCandidates':
          for (var i = 0; i < value; i++) {
            _newCandidate(s);
          }
          s.note(
            'Danh sách tiến cử mới',
            'Có $value ứng viên trưởng thành vừa tới kinh. Xem Hậu cung → Tú nữ.',
            'gold',
          );
        case 'recruitConsort':
        case 'rejectConsort':
          final candidate = _person(s, targetId);
          // The petition accepts a tú nữ; only the separate invite action
          // admits her into the palace as a consort.
          final accept = entry.key == 'recruitConsort';
          final faction = candidate.faction;
          final opponent = factionOpponents[faction]!;
          s.factions[faction] = s.factions[faction]! + (accept ? 3 : -5);
          s.factions[opponent] = s.factions[opponent]! + (accept ? -5 : 3);
        default:
          if (entry.key.startsWith('faction:')) {
            final faction = entry.key.substring(8);
            if (!s.factions.containsKey(faction)) {
              throw StateError('Unknown faction $faction');
            }
            s.factions[faction] = s.factions[faction]! + value;
          } else if (entry.key.startsWith('affection:')) {
            final faction = entry.key.substring(10);
            if (!s.factions.containsKey(faction)) {
              throw StateError('Unknown faction $faction');
            }
            for (final c in s.court.where(
              (c) =>
                  c.available &&
                  (!c.isConsort || c.inHarem) &&
                  c.faction == faction,
            )) {
              c.affection += value;
            }
          } else {
            throw StateError('Unknown effect ${entry.key}');
          }
      }
    }
  }

  Map<String, int> _stats(GameState s) => {
    'treasury': s.treasury,
    'people': s.people,
    'authority': s.authority,
    'army': militaryStrength(s),
    'health': s.health,
    'stability': s.stability,
  };

  void _endWeek(GameState s) {
    final before = _stats(s);
    // Use the same visible snapshot as the forecast; returning armies and
    // seasonal production cannot retroactively defend the season just closed.
    final defenseForecasts = {
      for (final n in s.warfare?.neighbors ?? <NeighborState>[])
        n.id: FrontierDefense(s, n),
    };
    refreshCourtPersonnel(s);
    var ignoredCrises = 0;
    for (final p in s.petitions.where((p) => p.deadline <= s.week).toList()) {
      if (isCourtPersonnelEvent(p.definitionId)) {
        final m = courtMatterForEvent(s, p.definitionId);
        if (m != null) {
          final sponsor = courtPerson(s, m.sponsorId);
          if (sponsor != null) {
            s.factions[sponsor.faction] = s.factions[sponsor.faction]! - 1;
          }
          m.status = 'expired';
          s.note(
            'Tấu nhân sự quá hạn',
            '${courtPersonnelEvent(s, m).title}: bác đề nghị, giữ nguyên nhân sự; không thu hành động hoặc phí nhân sự.',
            'warning',
          );
        }
        s.petitions.remove(p);
        continue;
      }
      if (p.isStory) {
        _resolveStoryPetition(s, p, '2', expired: true);
        _clamp(s);
        _finishIfCritical(s);
        if (s.ended) return;
        continue;
      }
      if (isFoodRecoveryEvent(p.definitionId)) {
        _resolveFoodRecovery(s, p, '2', expired: true);
        continue;
      }
      final definition = eventForState(s, p.definitionId);
      if (['Khủng hoảng', 'Âm mưu'].contains(definition.category)) {
        ignoredCrises++;
      }
      final fallback = definition.choices.last;
      final assignment =
          petitionCanAssign(s, fallback)
              ? _startPetitionAssignment(
                s,
                definition,
                fallback,
                null,
                petitionBaseChance(fallback),
              )
              : null;
      _apply(
        s,
        {
          for (final entry in fallback.effects.entries)
            if (assignment == null || entry.key != 'repair')
              entry.key: entry.value,
        },
        title: 'Quá hạn: ${definition.title}',
        detail: fallback.label,
        targetId: p.targetId,
      );
      _queuePetitionResult(s, definition, fallback, assignment);
      _recordOrdinaryDisaster(s, definition, definition.choices.length - 1);
      s.petitions.remove(p);
      s.note(
        'Tấu chương quá hạn',
        '${definition.title}: ${fallback.label}. ${fallback.hint}',
        'warning',
      );
    }
    _neglect(s, ignoredCrises);
    if (!s.ended) _settleCourtPersonnel(s);
    if (!s.ended) _settleCourtPassives(s);
    if (!s.ended) _settleManagementPassives(s);
    _economy(s);
    _projects(s);
    _consequences(s);
    _health(s);
    _finishIfCritical(s);
    if (!s.ended) _settleHaremQuests(s);
    _finishIfCritical(s);
    if (!s.ended) _reignWeek(s);
    _finishIfCritical(s);
    if (!s.ended) _politics(s);
    if (!s.ended) _military(s);
    if (!s.ended && s.population != null) _populationSeason(s);
    if (!s.ended) _frontierDefense(s, defenseForecasts);
    if (!s.ended) _warSeason(s);
    if (!s.ended) _growManagers(s);
    _clamp(s);
    _finishIfCritical(s);
    if (!s.ended &&
        s.people < 12 &&
        armyCondition(s) < 24 &&
        _next(s, 100) < 35) {
      _finish(
        s,
        'Lòng dân xuống quá thấp, dân chúng nổi dậy chống triều đình. Quân đội suy yếu không còn giữ được kinh thành; nhà vua bị phế truất.',
        kind: 'rebellion',
      );
    }
    // Natural mortality is an age-dependent hazard, never a fixed expiry date.
    if (!s.ended &&
        s.age > 55 &&
        _next(s, 10000) < (s.age - 55) * (s.seasonal ? 26 : 2)) {
      _finish(
        s,
        'Ở tuổi ${s.age}, nhà vua qua đời sau một thời gian sức lực suy giảm vì tuổi tác.',
        kind: 'oldAge',
      );
    }
    final after = _stats(s);
    s.deltas = {for (final key in before.keys) key: after[key]! - before[key]!};
    s.note(
      'Khép lại tuần ${s.week}',
      'Sổ tiền tuần ${s.week}: thu ${_financeWeek(s).income} · thực chi ${_financeWeek(s).expense}; ngân khố ${s.treasury}. ${s.healthReport}',
    );
    _closeFinanceWeek(s);
    _closeFoodWeek(s);
    if (s.ended) return;
    s.completedWeeks++;
    _frontierNewYear(s);
    s.points = s.actionsPerTurn;
    s.seasonActionsSpent = 0;
    s.seasonPetitionTarget = 0;
    s.midSeasonDelivered = false;
    s.overtime = 0;
    s.workThisWeek = 0;
    s.affairsThisWeek = 0;
    s.restThisWeek = 0;
    s.revelThisWeek = 0;
    s.actionCounts.clear();
    s.favorsThisWeek.clear();
    s.responsesThisWeek.clear();
    if (s.population != null) _populationNewSeason(s);
    _foodWeek(s);
    if (s.completedWeeks % (s.seasonal ? 4 : 52) == 0) _ageCourt(s);
    // Continuations reserve their place before the ordinary random draw.
    if (s.seasonal) _reignGenerate(s);
    _generate(s);
    if (!s.seasonal) _reignGenerate(s);
    _clamp(s);
  }

  void _neglect(GameState s, int ignoredCrises) {
    s.neglectedWeeks = s.affairsThisWeek == 0 ? s.neglectedWeeks + 1 : 0;
    if (s.neglectedWeeks > 0) {
      final authorityLoss = math.min(12, 2 + s.neglectedWeeks * 2);
      final stabilityLoss = math.min(7, 1 + s.neglectedWeeks);
      final peopleLoss = math.min(4, (s.neglectedWeeks + 1) ~/ 2);
      s.authority -= authorityLoss;
      s.stability -= stabilityLoss;
      s.people -= peopleLoss;
      for (final c in s.court.where((c) => c.available && !c.isConsort)) {
        c.loyalty -= s.neglectedWeeks >= 3 ? 2 : 1;
      }
      s.note(
        'Bỏ bê triều chính',
        'Đã ${s.neglectedWeeks} tuần liên tiếp không xử lý việc nước. Ngoài hao mòn thường lệ: uy quyền −$authorityLoss · Ổn định triều đình −$stabilityLoss · lòng dân −$peopleLoss; quan lại mất lòng tin. Chỉ nghỉ ngơi, chữa bệnh hoặc lo hậu cung không giải quyết việc nước.',
        'warning',
      );
    }
    if (ignoredCrises > 0) {
      final count = math.min(2, ignoredCrises);
      s.authority -= count * 4;
      s.stability -= count * 3;
      s.note(
        'Khủng hoảng bị bỏ mặc',
        '$ignoredCrises tấu chương khủng hoảng/âm mưu quá hạn. Ngoài hậu quả riêng: uy quyền −${count * 4}, Ổn định triều đình −${count * 3}.',
        'danger',
      );
    }
  }

  void _economy(GameState s) {
    _warPrepareBudget(s);
    if (s.population != null) _populationLaborSample(s);
    if (s.seasonal) {
      _settleLeveeSeason(s);
      if (s.season == 'Thu') _harvest(s);
    }
    final harem = HaremBenefits(s);
    final settleTax = s.autumnTaxDue;
    final collectedTax = settleTax ? annualTaxRevenue(s) : 0;
    final taxSupport = settleTax ? annualTaxSupportChange(s) : 0;
    s.lastIncome = 0;
    for (final item in budgetIncome(s)) {
      _postMoney(
        s,
        item.amount,
        title: item.title,
        detail: item.detail,
        category: 'budget',
      );
      s.lastIncome += item.amount;
    }
    if (settleTax) {
      s.lastTaxYear = s.year;
      s.lastTaxRate = s.tax;
      s.lastTaxRevenue = collectedTax;
      s.people += taxSupport;
      s.taxCredit = s.taxSupportCredit = 0;
      s.taxCreditYear = 0;
      s.note(
        'Chốt thuế vụ Thu năm ${s.year}',
        'Sau thu hoạch, áp dụng mức ${taxLabels[s.lastTaxRate]} cho năm ${s.year}: '
            'ngân khố +$collectedTax; lòng dân ${taxSupport >= 0 ? '+' : ''}$taxSupport. '
            'Mức này đã chốt; thay đổi tiếp theo dành cho vụ Thu năm sau.',
        'gold',
      );
    }
    s.lastExpense = 0;
    final costs = budgetExpenses(s);
    var spent = 0;
    for (final key in budgetPaymentOrder(s)) {
      if (key.startsWith('tribute:')) continue;
      final item = costs[key]!;
      final required = item.amount;
      final paid = _charge(
        s,
        required,
        title: item.title,
        detail: item.detail,
        category: 'budget',
      );
      spent += paid;
      if (key == 'army' && s.population != null) {
        s.population!.wageCoverage =
            required == 0 ? 100 : paid * 100 / required;
      }
      if (paid < required) {
        if (key == 'army' && s.population == null) s.army -= 4;
        if (key == 'people') s.people -= 3;
        if (key == 'court') s.stability -= 3;
        if (key.startsWith('obligation:')) {
          final obligation = s.obligations.firstWhere(
            (o) => 'obligation:${o.id}' == key,
          );
          if (obligation.kind == 'demand') {
            _apply(
              s,
              obligation.effects,
              title: obligation.title,
              category: 'commitment',
            );
          } else {
            s.stability--;
          }
        }
      }
    }
    _warSettleTribute(s);
    spent += s.lastExpense;
    final payment = debtPayment(s.debt, s.treasury, scale: moneyScale(s));
    if (payment > 0) {
      final beforeDebt = s.debt;
      final available = s.treasury;
      _postMoney(
        s,
        -payment,
        title: 'Trả nợ chi trả',
        category: 'debt',
        requiredAmount: payment,
        debtChange: -payment,
        detail:
            'Nợ $beforeDebt; ngân khố sau chi thường lệ $available. Trả tối đa ${money(s, 10)} ${moneyUnit(s)}/tuần, giữ lại ít nhất 20 → trả $payment.',
      );
      spent += payment;
    }
    s.lastExpense = spent;
    if (!s.seasonal) {
      s.people +=
          s.tax == 0
              ? 1
              : s.tax == 2
              ? -2
              : 0;
    }
    if (s.population == null) {
      s.grain -= grainConsumption(s);
    } else {
      _populationFoodSeason(s);
    }
    if (!s.seasonal) s.levee -= s.season == 'Hạ' ? 2 : 1;
    if (!s.seasonal && s.completedWeeks % 52 == 26) _harvest(s);
    if (s.population == null ? s.grain < 15 : foodDays(s) < 30) s.people -= 3;
    if (s.population == null) {
      s.army -= s.seasonal ? (s.war > 0 ? 6 : 2) : (s.war > 0 ? 2 : 1);
    }
    s.authority -= s.seasonal ? 2 + reignStage(s) ~/ 2 : 1;
    if (s.workThisWeek == 0) s.stability -= 2;
    if (s.week % (s.seasonal ? 1 : 4) == 0) {
      final moods = s.factions.values.toList()..sort();
      if (moods.last - moods.first > 35) {
        s.stability -= moods.last - moods.first > 60 ? 2 : 1;
        s.note(
          'Các phe mất cân bằng',
          'Chênh lệch ưu ái làm triều đình kém ổn định. Có thể hòa giải các phe hoặc đổi cách tiếp kiến.',
          'warning',
        );
      }
    }
    if (s.seasonal) {
      s.authority += harem.total(HaremBenefit.authority);
      s.people += harem.total(HaremBenefit.people);
      s.stability += harem.total(HaremBenefit.stability);
      if (harem.contributions.isNotEmpty) {
        s.note(
          'Đóng góp hậu cung',
          '${authoredMoneyText(s, harem.summary)}.\n${harem.contributions.map((c) => authoredMoneyText(s, c.description)).join('\n')}\n'
              'Chốt theo thiện cảm, dấu mốc quan hệ và cam kết nhân sự cuối mùa; '
              'tối đa +5 mỗi chỉ số, +50 ngân khố. Tiền đã ghi vào sổ thu chi, chưa trừ chi hậu cung.',
          'gold',
        );
      }
    } else {
      final queen = s.court.where((c) => c.available && c.queen).firstOrNull;
      if (queen != null &&
          queen.affection > 70 &&
          queen.affection > 40 &&
          s.week % (s.seasonal ? 1 : 3) == 0) {
        s.stability++;
      }
    }
  }

  void _harvest(GameState s) {
    if (s.seasonal) {
      if (s.lastHarvestYear >= s.year) return;
      final weather = 90 + _next(s, 21);
      final factor = harvestLeveePercent(s);
      final base = agricultureBaseYield(s);
      final harvest =
          s.population == null
              ? (base * factor * weather / 10000).round()
              : foodAmount(
                base * factor * weather / 10000 * annualFarmLaborFactor(s),
              );
      _food(
        s,
        harvest,
        'Thu hoạch',
        category: 'harvest',
        detail:
            'Nền ${whole(base)} × đê ${factor.toStringAsFixed(1)}% × thời tiết $weather% × lao động ${(annualFarmLaborFactor(s) * 100).toStringAsFixed(1)}%.',
      );
      s.lastHarvestYear = s.year;
      s.lastHarvestAmount = harvest;
      s.lastHarvestWeather = weather;
      s.lastHarvestLeveePercent = factor;
      s.note(
        'Mùa gặt',
        'Nông nghiệp cấp ${s.agricultureLevel}: nền $base × đê cả vụ '
            '${factor.toStringAsFixed(1)}% × thời tiết $weather%'
            '${s.population == null ? '' : ' × lao động ${(annualFarmLaborFactor(s) * 100).toStringAsFixed(1)}%'} = ${whole(harvest)} ${foodUnit(s)}. '
            'Xuân 20% · Hạ 50% · Thu 30%; chưa trừ tiêu hao ${whole(grainConsumption(s))} ${foodUnit(s)} mùa này.',
        'gold',
      );
      return;
    }
    final harvest = (s.seasonal ? 45 : 35) + _next(s, 26);
    s.grain += harvest;
    s.note('Mùa gặt', 'Kho triều đình nhận thêm $harvest lương thực.', 'gold');
  }

  void _projects(GameState s) {
    for (final p in s.projects.toList()) {
      if (developmentTasks.contains(p.kind)) {
        _advanceDevelopment(s, p);
        continue;
      }
      final before = _outcomeStats(s);
      final officer =
          s.court.where((c) => c.available && c.id == p.officerId).firstOrNull;
      if (officer == null) {
        s.projects.remove(p);
        s.note(
          'Công việc gián đoạn',
          'Người phụ trách đã rời chức. Cần ban lệnh mới.',
          'warning',
        );
        _recordOutcome(
          s,
          before,
          '${projectTitle(p.kind)} — gián đoạn',
          'interrupted',
          detail:
              'Người phụ trách đã rời chức. Công việc dừng lại, kinh phí đã cấp không được hoàn. Cần ban lệnh mới.',
        );
        continue;
      }
      p.progress++;
      if (p.progress < p.duration) continue;
      s.projects.remove(p);
      if (!_taskSucceeds(s, p.kind, officer)) {
        _recordOutcome(s, before, projectTitle(p.kind), 'failure');
        continue;
      }
      final assessment = TaskAssessment(p.kind, officer, s);
      final delivery = _deliveryPercent(s, officer, projectTitle(p.kind));
      final quality =
          p.kind == 'commerce' && s.goldStandard
              ? money(
                s,
                revenueBaseReturns['commerce']! *
                    assessment.rewardPercent /
                    100 *
                    delivery /
                    100,
              )
              : (assessment.reward(
                        p.kind == 'repair'
                            ? 30
                            : p.kind == 'commerce'
                            ? revenueBaseReturns['commerce']!
                            : 35,
                      ) *
                      delivery /
                      100)
                  .round();
      _merit(
        s,
        officer,
        points: 2,
        title: projectTitle(p.kind),
        eventId: 'project-${p.id}',
      );
      if (p.kind == 'farm') _respond(s, 'hunger');
      if (p.kind == 'repair') s.levee += quality;
      if (p.kind == 'commerce') {
        final adjusted =
            s.goldStandard
                ? money(
                  s,
                  revenueBaseReturns['commerce']! *
                      assessment.rewardPercent /
                      100,
                )
                : assessment.reward(revenueBaseReturns['commerce']!);
        _postMoney(
          s,
          quality,
          title: 'Đoàn thương mại trở về',
          category: 'project',
          detail:
              '${officer.name}: nền ${money(s, 110)} ${moneyUnit(s)} × hiệu quả ${assessment.rewardPercent}%, làm tròn = $adjusted; chất lượng thực hiện điều chỉnh thành $quality. Đã nhận $delivery% thành quả sau kiểm đếm. ${money(s, 40)} ${moneyUnit(s)} vốn đã chi ở tuần ${p.startedWeek}, không trừ lại.',
        );
      }
      final farmFood =
          s.population == null
              ? quality
              : authoredFood(
                quality,
                context: 'farm',
                challenging: s.challengingEconomy,
              );
      if (p.kind == 'farm') {
        _food(
          s,
          farmFood,
          'Canh tác bổ sung',
          category: 'project',
          detail: '${officer.name} hoàn thành canh tác.',
        );
        s.people += 4;
      }
      s.note(
        p.kind == 'repair'
            ? 'Đê điều được tu bổ'
            : p.kind == 'commerce'
            ? 'Đoàn thương mại trở về'
            : 'Ruộng mới đã khai khẩn',
        '${officer.name} báo hoàn tất. ${fitLabel(TaskAssessment(p.kind, officer, s).fit)} · năng lực ${officer.ability}; ${p.kind == 'repair'
            ? 'đê điều'
            : p.kind == 'commerce'
            ? 'ngân khố'
            : 'lương thực'} +${p.kind == 'farm' ? '$farmFood ${foodUnit(s)}' : quality}${p.kind == 'farm' ? ' · lòng dân +4' : ''}.${p.kind == 'commerce' ? ' Doanh thu chưa trừ 40 vốn đã chi.' : ''} Chất lượng còn phụ thuộc liêm chính.',
        'gold',
      );
      _recordOutcome(s, before, projectTitle(p.kind), 'success');
    }
  }

  // Snapshot only the effects of this result, separate from weekly upkeep,
  // health and other results. Values retain the engine's pre-clamp arithmetic.
  Map<String, int> _outcomeStats(GameState s) => {
    'Ngân khố': s.treasury,
    'Nợ chi trả': s.debt,
    'Lương thực': s.grain,
    'Lòng dân': s.people,
    'Uy quyền': s.authority,
    stabilityLabel: s.stability,
    'Quân lực': militaryStrength(s),
    if (s.population != null) ...{
      'Dân số lao động': s.population!.population,
      'Quân số': s.population!.soldiers,
      'Huấn luyện': s.population!.training.round(),
      'Quân khí (bộ)': s.population!.equipment,
      'Sĩ khí': s.population!.morale.round(),
    },
    'Sức khỏe': s.health,
    'Đê điều': s.levee,
    'Cấp kinh tế': s.economyLevel,
    'Cấp nông nghiệp': s.agricultureLevel,
    'Cấp đê': s.leveeLevel,
    'Mệt mỏi': s.fatigue,
    'Căng thẳng': s.stress,
    'Bệnh tật': s.illness,
    'Áp lực chiến tranh': s.war,
    'Bao vây': s.siege,
    (s.seasonal ? 'Thuế kỳ thu hoạch tới' : 'Mức thuế'): s.tax,
    for (final e in s.factions.entries) 'Phe ${e.key}': e.value,
    for (final c in s.court) 'Thiện cảm ${c.name}': c.affection,
    for (final c in s.court) 'Bất mãn ${c.name}': c.discontent,
  };

  void _recordOutcome(
    GameState s,
    Map<String, int> before,
    String title,
    String status, {
    String? detail,
  }) {
    // New quantitative reports must describe the committed, bounded metrics;
    // e.g. morale at 100 cannot report an extra gain beyond its cap.
    if (s.population != null) _clamp(s);
    final after = _outcomeStats(s);
    s.outcomes.add(
      OutcomeReport(
        id: '${s.runId}-${s.revision}-${s.outcomes.length}',
        week: s.week,
        title: title,
        status: status,
        detail: detail ?? s.journal.first.text,
        changes: {
          for (final e in before.entries)
            if (after[e.key] != null && after[e.key] != e.value)
              e.key: after[e.key]! - e.value,
        },
      ),
    );
  }

  void _consequences(GameState s) {
    for (final p in s.pending.where((p) => p.dueWeek <= s.week).toList()) {
      s.pending.remove(p);
      final before = _outcomeStats(s);
      if (p.assignment != null) {
        final status = _resolveAssignedPetition(s, p);
        _recordOutcome(
          s,
          before,
          p.title,
          status,
          detail: s.journal.first.text,
        );
        continue;
      }
      var status = 'success';
      switch (p.kind) {
        case 'eventOutcome':
          status = p.detail.contains('thất bại') ? 'failure' : 'success';
          _apply(
            s,
            p.effects,
            title: 'Kết quả: ${p.title}',
            detail: p.detail,
            category: 'outcome',
          );
          s.note(
            'Kết quả: ${p.title}',
            '${p.detail} ${eventEffectText(p.effects)}.',
            p.detail.contains('thất bại') ? 'warning' : 'gold',
          );
        case 'school':
          s.people += s.seasonal ? 4 : 8;
          s.authority += s.seasonal ? 1 : 3;
          s.note(
            'Lớp học đầu tiên',
            'Trẻ trong huyện đã có thầy. Lòng dân +${s.seasonal ? 4 : 8}, uy quyền +${s.seasonal ? 1 : 3}.',
            'gold',
          );
        case 'trade':
          final revenue = money(
            s,
            (s.seasonal ? 70 : 65) + _next(s, s.seasonal ? 26 : 31),
          );
          _postMoney(
            s,
            revenue,
            title: 'Thương lộ sinh lợi',
            category: 'outcome',
            detail:
                'Đoàn buôn hoàn thành theo sự kiện: ${money(s, s.seasonal ? 70 : 65)} ${moneyUnit(s)} nền + ${revenue - money(s, s.seasonal ? 70 : 65)} từ kết quả chuyến đi = $revenue. Vốn đã chi khi chọn sự kiện.',
          );
          s.note(
            'Thương lộ sinh lợi',
            'Đoàn buôn nộp $revenue vào ngân khố.',
            'gold',
          );
        case 'weapons':
          if (s.population == null) {
            s.army += s.seasonal ? 8 : 15;
          } else {
            s.population!.equipment += 8000;
          }
          s.note(
            'Quân khí đã tới',
            'Trang bị mới được bàn giao. Quân lực +${s.seasonal ? 8 : 15}.',
            'gold',
          );
        case 'envoy':
          final minister =
              s.court
                  .where((c) => c.available && c.id == p.target)
                  .firstOrNull ??
              (p.target.isEmpty
                  ? taskOfficers(s, 'diplomacy').firstOrNull
                  : null);
          if (minister == null) {
            status = 'interrupted';
            s.authority -= 2;
            s.note(
              'Hòa đàm gián đoạn',
              'Người phụ trách không còn tại chức. Sứ đoàn trở về, uy quyền −2; kinh phí không được hoàn lại.',
              'warning',
            );
            break;
          }
          if (_taskSucceeds(s, 'diplomacy', minister)) {
            final delivery = _deliveryPercent(s, minister, 'Hòa đàm');
            final gain =
                (TaskAssessment('diplomacy', minister, s).reward(3) *
                        delivery /
                        100)
                    .round();
            _merit(s, minister);
            _respond(s, 'border');
            s.war = math.max(0, s.war - gain);
            s.siege = 0;
            s.authority +=
                (TaskAssessment('diplomacy', minister, s).reward(2) *
                        delivery /
                        100)
                    .round();
            s.note(
              'Hồi âm từ sứ đoàn',
              '${minister.name} đàm phán thành công. Áp lực chiến tranh −$gain, uy quyền được củng cố. Kết quả phụ thuộc chuyên môn, quan hệ và tính cách.',
              'gold',
            );
          } else {
            status = 'failure';
          }
        case 'audit':
          final auditor =
              s.court
                  .where((c) => c.available && c.role == 'Ngự sử')
                  .firstOrNull;
          if (_next(s, 100) <
              (auditor == null
                  ? 40
                  : roleEffect(auditor, 'Dân chính', auditor.ability))) {
            final recovered = money(
              s,
              (s.seasonal ? 25 : 35) + _next(s, s.seasonal ? 21 : 36),
            );
            _postMoney(
              s,
              recovered,
              title: 'Thu hồi tiền thất thoát',
              category: 'outcome',
              detail:
                  '${auditor?.name ?? 'Đoàn kiểm toán'} xác minh sổ sách: ${money(s, s.seasonal ? 25 : 35)} ${moneyUnit(s)} nền + ${recovered - money(s, s.seasonal ? 25 : 35)} thu hồi thêm = $recovered.',
            );
            s.authority += s.seasonal ? 2 : 4;
            s.note(
              'Sổ sách được làm rõ',
              'Thu hồi $recovered ${moneyUnit(s)} thất thoát. Uy quyền +${s.seasonal ? 2 : 4}.',
              'gold',
            );
          } else {
            status = 'inconclusive';
            s.note(
              'Chưa đủ chứng cứ',
              'Cuộc kiểm toán chưa xác minh được khoản thất thoát.',
            );
          }
        case 'security':
          final spy = s.officerForRole('Mật thám');
          final suspects =
              s.court
                  .where(
                    (c) =>
                        !s.seasonal ||
                        (c.available && (!c.isConsort || c.inHarem)),
                  )
                  .toList()
                ..sort((a, b) => b.plot.compareTo(a.plot));
          if (s.seasonal &&
              (suspects.isEmpty ||
                  _next(s, 100) >=
                      investigationChance(s, spy, suspects.first))) {
            status = 'inconclusive';
            s.note(
              'Báo cáo mật',
              'Chưa đủ chứng cứ để phá mạng lưới liên lạc; âm mưu vẫn tiếp tục.',
              'warning',
            );
            break;
          }
          final reduction = s.seasonal ? 6 : 22;
          for (final c in suspects) {
            c.plot = math.max(0, c.plot - reduction);
          }
          if (s.seasonal) _respond(s, 'plot');
          s.note(
            'Báo cáo mật',
            'Một số liên lạc đáng ngờ đã bị gián đoạn. Tiến độ mỗi âm mưu giảm tối đa $reduction, không thấp hơn 0. Cần tiếp tục xử lý lòng trung thành và phe phái.',
          );
        case 'investigate':
          if (p.covertMission != null) {
            status = _settleCovertInvestigation(s, p);
            break;
          }
          final c =
              [
                ...s.court,
                if (s.hasCourtSystem) ...s.officialsPool,
              ].where((c) => c.id == p.target && c.available).firstOrNull;
          if (c == null) {
            status = 'interrupted';
            s.note(
              'Điều tra khép lại',
              'Người bị điều tra không còn giữ vị trí cũ.',
            );
            break;
          }
          // Publish the captured figures only when the investigation completes.
          // Legacy pending reports have no captured data; do not invent it.
          final intelligence = p.investigation;
          if (intelligence != null) c.lastInvestigation = intelligence;
          final intelligenceText =
              intelligence == null
                  ? ''
                  : 'Âm mưu ${intelligence.plot}/100, bất mãn ${intelligence.discontent}/100, ghi nhận ${s.date(intelligence.week)}. Hai thanh chỉ cập nhật khi điều tra tiếp theo hoàn tất. ';
          final spy = s.officerForRole('Mật thám');
          if (_next(s, 100) < investigationChance(s, spy, c)) {
            c.investigated = true;
            c.plot = math.max(0, c.plot - (s.seasonal ? 6 : 8));
            _respond(s, 'plot');
            s.note(
              'Hồ sơ ${c.name}',
              '$intelligenceText${c.qualitiesText}. Xem tại Triều thần.',
              'gold',
            );
          } else {
            status = 'inconclusive';
            s.note(
              'Điều tra chưa rõ',
              '${intelligenceText}Chưa đủ bằng chứng xác minh phẩm chất của ${c.name}. Có thể điều tra lại.',
            );
          }
        default:
          throw StateError('Unknown consequence ${p.kind}');
      }
      _recordOutcome(
        s,
        before,
        p.title.isNotEmpty ? p.title : s.journal.first.title,
        status,
        detail:
            p.kind != 'eventOutcome' && p.detail.isNotEmpty
                ? '${p.detail}. ${s.journal.first.text}'
                : null,
      );
    }
  }

  void _health(GameState s) {
    final revel = s.revelThisWeek, rest = s.restThisWeek, work = s.workThisWeek;
    s.indulgence = math.max(0, s.indulgence - 1) + revel * 2;
    s.fatigue = (s.fatigue +
            work * (s.seasonal ? 2 : 5) +
            s.overtime * 10 +
            (s.seasonal ? 0 : math.max(0, revel - 1) * excessRevelFatigue) -
            revelFatigueRecovery(s, revel) -
            rest * restFatigueRecovery(s) -
            (s.seasonal ? 12 : 6))
        .clamp(0, 100);
    s.stress = (s.stress +
            work * (s.seasonal ? 1 : 3) +
            s.war * (s.seasonal ? 4 : 2) -
            rest * restStressRecovery -
            revelStressRecovery(s, revel) -
            2)
        .clamp(0, 100);
    s.exhaustedWeeks =
        s.fatigue > 55
            ? s.exhaustedWeeks + 1
            : math.max(0, s.exhaustedWeeks - 1);
    final changes = <String, int>{};
    if (rest > 0) {
      changes['nghỉ ngơi'] = math.max(1, rest * (s.age >= 60 ? 2 : 3));
    }
    if (revel == 1 && s.indulgence <= 4) changes['giải trí vừa phải'] = 2;
    if (revel >= 2 || s.indulgence > 5) {
      changes['hưởng lạc quá mức'] =
          -math.max(2, revel * 2 + (s.indulgence - 4) ~/ 3);
    }
    if (work >= (s.seasonal ? 7 : 3) || s.overtime > 0) {
      changes['làm việc quá độ'] =
          -(math.max(0, work - (s.seasonal ? 6 : 2)) + s.overtime * 2);
    }
    if (s.fatigue > 55) {
      changes['mệt mỏi tích lũy'] = -math.max(1, (s.fatigue - 45) ~/ 10);
    }
    if (s.stress > 65) {
      changes['căng thẳng'] = -math.max(1, (s.stress - 55) ~/ 12);
    }
    if (s.illness > 0) changes['bệnh'] = -math.max(1, s.illness ~/ 8);
    if (s.age > 60) changes['tuổi tác'] = -math.max(1, (s.age - 55) ~/ 15);
    final delta = changes.values.fold(0, (a, b) => a + b);
    s.health += delta;
    s.healthReport =
        changes.isEmpty
            ? 'Sức khỏe không đổi.'
            : 'Sức khỏe ${delta >= 0 ? '+' : ''}$delta: ${changes.entries.map((e) => '${e.key} ${e.value > 0 ? '+' : ''}${e.value}').join(', ')}.';
    if (s.health > 0 &&
        (s.fatigue > 75 || s.indulgence > 10 || s.age > 50) &&
        _next(s, 100) < 9) {
      s.illness = math.min(40, s.illness + 8);
      s.note(
        'Ngự y báo bệnh',
        'Sinh hoạt và thể trạng làm nguy cơ bệnh tăng. Cần chữa trị và điều chỉnh nhịp sống.',
        'warning',
      );
    }
  }

  void _politics(GameState s) {
    if (s.week % (s.seasonal ? 1 : 4) == 0) {
      for (final c in s.court.where((c) => c.available)) {
        final before = c.discontent;
        c.discontent = (before + discontentChange(s, c)).clamp(0, 100);
        if (before < discontentPlotThreshold &&
            c.discontent >= discontentPlotThreshold) {
          s.note(
            'Bất mãn gia tăng',
            '${c.name} bất mãn ${c.discontent}/100. Nếu lòng trung thành thấp, sự chống đối có thể phát triển thành âm mưu. Hãy lắng nghe, ban thưởng hoặc hòa giải phe phái.',
            'warning',
          );
        }
      }
    }
    var activePlots =
        s.court
            .where(
              (c) => c.available && (!c.isConsort || c.inHarem) && c.plot > 0,
            )
            .length;
    for (final c in s.court.where(
      (c) => c.available && (!c.isConsort || c.inHarem),
    )) {
      if (s.week % (s.seasonal ? 1 : 4) == 0) {
        if (c.affection > c.baseAffection &&
            (!c.personalities.contains(Personality.grateful) ||
                s.week % (s.seasonal ? 2 : 8) == 0)) {
          c.affection--;
        }
        if (c.affection < c.baseAffection &&
            s.factions[c.faction]! >= 40 &&
            (!c.personalities.contains(Personality.resentful) ||
                s.week % (s.seasonal ? 2 : 8) == 0)) {
          c.affection++;
        }
        if (s.factions[c.faction]! < 30 || s.debt > money(s, 30)) {
          c.loyalty -= 2;
        }
        if (c.affection < 25) c.loyalty--;
        if (s.authority > 80 &&
            c.loyalty > 45 &&
            c.affection >= 50 &&
            s.factions[c.faction]! >= 45) {
          c.loyalty++;
        }
      }
      final motivated = hasPlotMotive(c);
      if (motivated) {
        if (c.plot > 0 || activePlots < 3) {
          if (c.plot == 0) activePlots++;
          c.plot += plotProgressPerTurn(s, c);
        }
      } else {
        final decay = s.seasonal ? 1 : 2;
        if (c.plot > 0 && c.plot <= decay) activePlots--;
        c.plot = math.max(0, c.plot - decay);
      }
      if (c.plot >= 30 && c.plot < 70) _addTriggered(s, 'plot_warning');
      if (!motivated || c.plot < 70) continue;
      if (_next(s, 100) <
          (c.influence ~/ 2 + (100 - s.authority) ~/ 3).clamp(10, 85)) {
        if (isCoupPlot(c)) {
          _finish(
            s,
            '${c.name} (phe ${c.faction}) lôi kéo lực lượng làm đảo chính. Âm mưu giành ngôi thành công, nhà vua bị phế truất.',
            kind: 'coup',
          );
        } else {
          s.health -= 35;
          s.illness += 12;
          s.illnessSource = '${c.name} (phe ${c.faction})';
          s.note(
            'Một vụ đầu độc',
            '${s.illnessSource} đứng sau vụ bỏ độc. Cấm vệ phát hiện quá muộn; sức khỏe −35.',
            'danger',
          );
          if (s.health <= 0) {
            _finish(
              s,
              '${s.illnessSource} đã bỏ độc nhà vua. Cấm vệ không ngăn kịp, ngự y không cứu được; nhà vua băng hà vì bị mưu sát.',
              kind: 'poisoning',
            );
          }
        }
      } else {
        s.authority += s.seasonal ? 1 : 4;
        s.note(
          'Âm mưu bị chặn',
          'Cấm vệ chặn một kế hoạch nguy hiểm. ${c.name} bị lộ liên hệ đáng ngờ.',
          'warning',
        );
      }
      c.investigated = true;
      c.plot = s.seasonal ? 35 : 15;
      if (s.ended) return;
    }
  }

  void _military(GameState s) {
    if (s.warfare != null) return;
    if (s.war <= 0 || s.ended) return;
    final general =
        s.court.where((c) => c.available && c.role == 'Đại tướng').firstOrNull;
    final strength =
        (s.population == null
            ? s.army
            : (militaryStrength(s, troops: s.population!.availableSoldiers) /
                    500)
                .round()) +
        (general == null
            ? 10
            : roleEffect(general, 'Quân sự', general.ability ~/ 3)) -
        s.war * 9;
    final ratio =
        s.population == null
            ? 1.0
            : militaryStrength(s, troops: s.population!.availableSoldiers) /
                (30000 + s.war * 5000);
    if (s.population == null ? strength < 30 : ratio < .8) {
      s.siege++;
      if (s.population != null) {
        _losePopulation(
          s,
          (s.population!.civilians * (s.siege >= 3 ? .01 : .002)).floor(),
          'Lưu tán vì biên giới bị đẩy lùi',
          civiliansOnly: true,
          displaced: true,
        );
      }
      s.note(
        'Biên giới bị đẩy lùi',
        'Quân địch tiến gần kinh thành (${s.siege}/4 bước). Cần tăng viện hoặc cầu hòa.',
        'danger',
      );
    } else if (_next(s, 100) <
        (s.population != null && ratio >= 1.2 ? 50 : 30)) {
      s.war--;
      s.siege = math.max(0, s.siege - 1);
      s.note(
        'Giữ vững cửa ải',
        'Quân ta đẩy lui một đợt tiến công. Áp lực chiến tranh giảm.',
        'gold',
      );
    }
    if (s.siege >= 4) {
      _finish(
        s,
        'Quân ngoại xâm liên tục đẩy lùi lực lượng phòng thủ. Kinh thành thất thủ sau nhiều tuần bị dồn ép; nhà vua mất quyền cai trị và đất nước rơi vào tay quân địch.',
        kind: 'invasion',
      );
    }
  }

  bool eligible(GameState s, EventDefinition e) {
    if (e.condition == 'storyOnly') return false;
    if (s.week < (s.seasonal ? s.cooldownTurns(e.minWeek) : e.minWeek) ||
        (s.cooldowns[e.id] ?? 0) > s.week ||
        s.petitions.any((p) => p.definitionId == e.id)) {
      return false;
    }
    final trigger = eventTrigger(e);
    if (trigger.isNotEmpty &&
        ((s.cooldowns[trigger] ?? 0) > s.week ||
            s.petitions.any(
              (p) => eventTrigger(eventForState(s, p.definitionId)) == trigger,
            ))) {
      return false;
    }
    return switch (e.condition) {
      'any' => true,
      'weakLevee' => s.levee < 50,
      'hasConsort' => s.court.any((c) => c.inHarem && c.available),
      'factionSplit' =>
        s.factions.values.reduce(math.max) -
                s.factions.values.reduce(math.min) >
            35,
      'spring' => s.season == 'Xuân',
      'rain' => s.season == 'Hạ',
      'winter' => s.season == 'Đông',
      'flood' => s.season == 'Hạ' && s.levee < 40,
      'hungry' => s.population == null ? s.grain < 25 : foodDays(s) < 90,
      'poor' => s.treasury < money(s, 120),
      'rich' => s.treasury > money(s, 450),
      'court' => s.stability < 55,
      'ill' => s.health < 65 || s.illness > 0 || s.fatigue > 60,
      'peace' => s.war == 0,
      'war' => s.war > 0,
      'debt' => s.debt > 0,
      'harem' => s.court.where((c) => c.inHarem && c.available).length >= 2,
      'stressed' => s.stress > 45 || s.fatigue > 45,
      'weakArmy' => armyCondition(s) < 50,
      'population' => s.population != null,
      'populationReturn' => s.population != null && s.population!.displaced > 0,
      'tax' => s.effectiveTax == 2,
      'plot' => s.court.any((c) => c.available && c.plot >= 30),
      'lowPeople' => s.people < 30,
      'weakAuthority' => s.authority < 35,
      'recruitment' => s.seasonal ? s.week >= 2 : (s.week - 4) % 13 == 0,
      _ => false,
    };
  }

  void _addPetition(GameState s, String definitionId) {
    final e = eventById(definitionId);
    if (!eligible(s, e)) {
      return;
    }
    final targetId =
        definitionId == 'consort_recommendation' ? _newCandidate(s).id : '';
    s.petitions.add(
      Petition(
        id: '$definitionId-${s.week}',
        definitionId: definitionId,
        openedWeek: s.week,
        deadline: s.week + (s.seasonal && eventTrigger(e).isNotEmpty ? 0 : 1),
        targetId: targetId,
      ),
    );
    s.cooldowns[definitionId] = s.week + s.cooldownTurns(e.cooldown);
    final trigger = eventTrigger(e);
    if (trigger.isNotEmpty) {
      s.cooldowns[trigger] =
          s.week + s.cooldownTurns(eventById(trigger).cooldown);
    }
    s.eventSeen.update(e.id, (count) => count + 1, ifAbsent: () => 1);
    s.eventFamilyWeeks[eventFamily(e)] = s.week;
    s.recentEventCategories.add(e.category);
    if (s.recentEventCategories.length > 3) s.recentEventCategories.removeAt(0);
  }

  EventDefinition _pickEvent(
    GameState s,
    List<EventDefinition> pool, {
    bool urgent = false,
  }) {
    final leastSeen = pool.map((e) => s.eventSeen[e.id] ?? 0).reduce(math.min);
    var choices =
        pool.where((e) => (s.eventSeen[e.id] ?? 0) == leastSeen).toList();
    if (!urgent) {
      final spaced =
          choices
              .where(
                (e) =>
                    s.week - (s.eventFamilyWeeks[eventFamily(e)] ?? -100) >= 3,
              )
              .toList();
      if (spaced.isNotEmpty) choices = spaced;
      final recent = s.recentEventCategories.reversed.take(2);
      final varied =
          choices.where((e) => !recent.contains(e.category)).toList();
      if (varied.isNotEmpty) choices = varied;
    }
    return choices[_next(s, choices.length)];
  }

  bool _addTriggered(GameState s, String trigger) {
    final pool =
        eventsForState(
          s,
        ).where((e) => eventTrigger(e) == trigger && eligible(s, e)).toList();
    if (pool.isEmpty) return false;
    _addPetition(s, _pickEvent(s, pool, urgent: true).id);
    return true;
  }

  void _generate(GameState s) {
    if (eligible(s, eventById('consort_recommendation'))) {
      _addPetition(s, 'consort_recommendation');
    }
    for (final id in ['hunger', 'rebellion_warning', 'succession_rumor']) {
      _addTriggered(s, id);
    }
    if (s.season == 'Hạ' && s.levee < 40 && _next(s, 100) < 40 - s.levee ~/ 2) {
      if (_addTriggered(s, 'flood')) {
        if (s.population == null) {
          s.grain = math.max(0, s.grain - 12);
        } else {
          _food(
            s,
            -authoredFood(12, context: 'flood'),
            'Lũ tràn qua ruộng',
            category: 'disaster',
          );
        }
        s.people = math.max(0, s.people - 5);
        s.note(
          'Đê đã vỡ',
          'Nước tràn qua vùng đê yếu. Cần xử lý cứu tế.',
          'danger',
        );
      }
    }
    if (s.seasonal) {
      _seasonPetitions(s);
      return;
    }
    final count = _next(s, 3);
    for (var i = 0; i < count; i++) {
      final pool =
          eventsForState(s)
              .where(
                (e) =>
                    eventTrigger(e).isEmpty &&
                    e.id != 'consort_recommendation' &&
                    eligible(s, e),
              )
              .toList();
      if (pool.isEmpty || s.petitions.length >= 5) break;
      _addPetition(s, _pickEvent(s, pool).id);
    }
    if (s.age > 55 && s.week % 13 == 0) {
      s.note(
        'Ngự y nhắc về tuổi tác',
        'Sức hồi phục giảm theo tuổi. Long thể cần được theo dõi ngay cả khi chưa có bệnh.',
        'warning',
      );
    }
  }

  /// Reveal only the deferred half of a save made under the old two-batch
  /// schedule, even if some of its initial petitions have already been resolved.
  /// The gateway commits this with the RNG before presenting the loaded game.
  bool revealSeasonPetitions(GameState s) {
    if (!s.seasonal || s.ended || s.midSeasonDelivered) return false;
    final deferred =
        s.seasonPetitionTarget > 0 ? s.seasonPetitionTarget ~/ 2 : null;
    _seasonPetitions(s, deferredCount: deferred);
    return true;
  }

  void _seasonPetitions(GameState s, {int? deferredCount}) {
    if (s.midSeasonDelivered) return;
    _generateCourtPersonnel(s);
    if (s.seasonPetitionTarget == 0) s.seasonPetitionTarget = 4 + _next(s, 3);
    final count =
        deferredCount ??
        math.max(
          0,
          s.seasonPetitionTarget -
              s.petitions.where((p) => p.openedWeek == s.week).length,
        );
    s.midSeasonDelivered = true;
    for (var i = 0; i < count; i++) {
      final pool =
          eventsForState(s)
              .where(
                (e) =>
                    eventTrigger(e).isEmpty &&
                    e.id != 'consort_recommendation' &&
                    eligible(s, e),
              )
              .toList();
      if (pool.isEmpty) break;
      final populationPool =
          s.population != null && i == 0 && s.week % 4 == 1
              ? pool.where((e) => e.category == 'Dân cư').toList()
              : <EventDefinition>[];
      _addPetition(
        s,
        _pickEvent(s, populationPool.isEmpty ? pool : populationPool).id,
      );
    }
    s.note(
      deferredCount == null ? 'Tấu chương đầu mùa' : 'Trình đủ tấu chương',
      deferredCount == null
          ? 'Đã trình đầy đủ ${s.seasonPetitionTarget} tấu chương ngay đầu mùa.'
          : 'Trình thêm $count tấu chương còn lại của mùa; không cần dùng hành động để chờ tin.',
    );
  }

  void _replace(GameState s, Courtier old) {
    if (s.hasCourtSystem) {
      final office = courtOfficeFor(s, old.id);
      if (office != null) {
        office.holderId = '';
        office.appointedTurn = s.week;
      }
      return;
    }
    final serial = s.court.length;
    s.court.add(
      Courtier(
        id: 'successor-$serial',
        name:
            '${['Trần', 'Lê', 'Vũ', 'Phạm'][_next(s, 4)]} ${['Minh Đức', 'Quang Bình', 'Thanh Sơn', 'Bảo Chính'][_next(s, 4)]}',
        role: old.role,
        faction: old.faction,
        trait: 'Mới nhận chức, cần thời gian quan sát',
        age: 25 + _next(s, 16),
        ability: 50 + _next(s, 36),
        loyalty: 50 + _next(s, 31),
        ambition: 25 + _next(s, 51),
        integrity: 40 + _next(s, 46),
        influence: 30 + _next(s, 21),
      ),
    );
    _initialAffection(s, s.court.last);
  }

  void _ageCourt(GameState s) {
    for (final c
        in [
          ...s.court,
          if (s.hasCourtSystem) ...s.officialsPool,
        ].where((c) => c.available).toList()) {
      c.age++;
      if (c.age > 65 && _next(s, 100) < (c.age - 60).clamp(0, 70)) {
        c.available = false;
        if (c.id == s.heirId) {
          s.heirCondition = 'deceased';
          s.successionCertified = false;
        }
        c.queen = false;
        if (!c.isConsort) _replace(s, c);
        s.note(
          'Nhân sự đổi thay',
          '${c.name} qua đời. ${c.isConsort ? 'Hậu cung để tang.' : 'Người mới được tiến cử thay thế.'}',
          'warning',
        );
      }
    }
    // Adult candidates replenish over long reigns.
    if (s.court.where((c) => c.available && c.isConsort && !c.inHarem).length <
        2) {
      _newCandidate(s);
    }
  }

  void _finishHealth(GameState s) {
    if (s.illness > 0 && s.illnessSource != null) {
      _finish(
        s,
        'Nhà vua băng hà sau vụ đầu độc do ${s.illnessSource} thực hiện. Di chứng chưa được chữa khỏi khiến long thể suy kiệt.',
        kind: 'poisoning',
      );
      return;
    }
    final causes = [
      if (s.illness > 0) 'bệnh tật',
      if (s.workThisWeek >= 3 || s.overtime > 0) 'làm việc quá độ',
      if (s.fatigue > 55) 'mệt mỏi tích lũy',
      if (s.stress > 65) 'căng thẳng kéo dài',
      if (s.revelThisWeek >= 2 || s.indulgence > 5) 'lạm dụng tửu sắc',
      if (s.age > 60) 'tuổi tác',
    ];
    _finish(
      s,
      causes.isEmpty
          ? 'Sức khỏe cạn kiệt, nhà vua băng hà.'
          : 'Long thể suy kiệt do ${causes.join(', ')}. Sức khỏe cạn kiệt, nhà vua băng hà.',
      kind: s.illness > 0 ? 'illness' : 'exhaustion',
    );
  }

  void _finishIfCritical(GameState s) {
    if (s.ended) return;
    if (s.health <= 0) {
      _finishHealth(s);
    } else if (s.stability <= 0) {
      _finish(
        s,
        'Ổn định triều đình đã giảm về 0. Các phe công khai tranh quyền, quan lại không còn tuân lệnh và bộ máy cai trị tan rã. Các đại thần ép nhà vua thoái vị; uy quyền hay quân lực còn lại không thể giữ được ngai vàng.',
        kind: 'courtCollapse',
      );
    } else if (s.authority <= 0) {
      _finish(
        s,
        'Uy quyền đã giảm về 0. Mọi quyết định đều do các thế lực trong triều chi phối, mệnh lệnh của nhà vua không còn được thi hành. Nhà vua chỉ còn giữ danh vị, trở thành bù nhìn và mất quyền tự quyết; lượt trị vì kết thúc.',
        kind: 'puppet',
      );
    } else if (s.people <= 0) {
      _finish(
        s,
        'Lòng dân đã giảm về 0. Dân chúng khắp nơi nổi dậy, không còn chấp nhận sự cai trị của nhà vua. Triều đình mất hoàn toàn sự ủng hộ và bị lật đổ; nhà vua bị phế truất.',
        kind: 'rebellion',
      );
    } else if (s.population == null
        ? s.army <= 0
        : (s.warfare == null && s.population!.soldiers <= 0) ||
            s.population!.population <= 0) {
      _finish(
        s,
        s.war > 0
            ? 'Quân lực đã giảm về 0 giữa lúc có chiến tranh. Quân đội tan rã, biên giới và kinh thành không còn lực lượng phòng thủ. Quân ngoại xâm tràn vào; đất nước rơi vào tay quân địch và nhà vua mất quyền cai trị.'
            : 'Quân lực đã giảm về 0. Quân đội tan rã, cấm vệ bỏ vị trí và nhà vua không còn lực lượng bảo vệ. Các thế lực tranh quyền chiếm hoàng cung, ép nhà vua thoái vị.',
        kind: s.war > 0 ? 'invasion' : 'armyCollapse',
      );
    }
  }

  void _finish(GameState s, String reason, {String? kind}) {
    if (s.ended) return;
    s.endReason = reason;
    s.endKind = kind;
    s.note('Triều đại khép lại', reason, 'danger');
  }

  void _clamp(GameState s) {
    s.treasury = math.max(0, s.treasury);
    s.debt = math.max(0, s.debt);
    s.people = s.people.clamp(0, 100);
    s.authority = s.authority.clamp(0, 100);
    s.army = s.army.clamp(0, 100);
    s.health = s.health.clamp(0, 100);
    s.stability = s.stability.clamp(0, 100);
    final food = s.grain.clamp(0, foodCapacity(s));
    if (s.population != null && food != s.grain) {
      _food(
        s,
        food - s.grain,
        'Điều chỉnh giới hạn kho',
        category: 'adjustment',
        detail: 'Đối chiếu tồn kho với giới hạn hiện tại.',
      );
    } else {
      s.grain = food;
    }
    final p = s.population;
    if (p != null) {
      p.population = math.max(0, p.population);
      p.soldiers = p.soldiers.clamp(0, p.population);
      p.clampQualities();
      p.logistics = p.logistics.clamp(0, 100);
      p.equipment = math.max(0, p.equipment);
      p.earlyWorkers = p.earlyWorkers.clamp(0, p.civilians);
      p.productiveCivilians = math.min(p.productiveCivilians, p.civilians);
    }
    s.levee = s.levee.clamp(0, 100);
    s.fatigue = s.fatigue.clamp(0, 100);
    s.stress = s.stress.clamp(0, 100);
    s.indulgence = s.indulgence.clamp(0, 40);
    s.illness = s.illness.clamp(0, 100);
    if (s.illness == 0) s.illnessSource = null;
    s.war = s.war.clamp(0, 8);
    for (final key in s.factions.keys) {
      s.factions[key] = s.factions[key]!.clamp(0, 100);
    }
    for (final c in [...s.court, if (s.hasCourtSystem) ...s.officialsPool]) {
      if (c.ability >= 100) c.managementGrowthHalf = 0;
      c.loyalty = c.loyalty.clamp(0, 100);
      c.discontent = c.discontent.clamp(0, 100);
      c.affection = c.affection.clamp(0, 100);
      c.influence = c.influence.clamp(0, 100);
    }
  }
}
