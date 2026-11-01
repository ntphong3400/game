/// Stable save identifiers. Descriptive biography is never used by the rules.
enum Personality {
  honest('Liêm khiết', 'Giảm nguy cơ thất thoát thành quả công việc.'),
  greedy(
    'Tham lợi',
    'Dễ ăn chặn kinh phí, thóc và thành quả; thích được thưởng tiền.',
  ),
  dutiful(
    'Tận tâm',
    'Giữ khả năng hoàn thành khi mệt và tăng thành quả công việc.',
  ),
  negligent('Tắc trách', 'Dễ làm thiếu và thất bại khi thực hiện công việc.'),
  cautious(
    'Thận trọng',
    'Ít thất bại nghiêm trọng, đổi lại thành quả thận trọng hơn.',
  ),
  decisive('Quyết đoán', 'Giỏi xử lý quân sự, an ninh và cứu nguy.'),
  reckless(
    'Liều lĩnh',
    'Có thể đạt thành quả cao nhưng dễ chịu thiệt hại nặng.',
  ),
  disciplined('Kỷ luật', 'Giúp khả năng hoàn thành công việc ổn định hơn.'),
  flexible(
    'Linh hoạt',
    'Giảm bất lợi khi làm trái chuyên môn và khi thiếu nguồn lực.',
  ),
  conservative(
    'Bảo thủ',
    'Làm tốt việc đúng chuyên môn, khó thích ứng việc khác.',
  ),
  upright('Cương trực', 'Hợp việc an ninh; phản đối thuế nặng và truy thu.'),
  diplomatic('Khéo léo', 'Giỏi hòa giải, ngoại giao và giữ hòa khí.'),
  hotTempered(
    'Nóng nảy',
    'Mạnh khi luyện quân, dễ gây hỏng việc hòa giải, ngoại giao.',
  ),
  resentful(
    'Thù dai',
    'Thiện cảm thấp ảnh hưởng hợp tác mạnh; khó quên hiềm khích.',
  ),
  grateful('Biết ơn', 'Ghi nhớ ân tình, thiện cảm tốt được giữ lâu hơn.'),
  compassionate(
    'Gần dân',
    'Làm tốt cứu tế, nông nghiệp; không thích truy thu và thuế nặng.',
  ),
  impartial(
    'Công tâm',
    'Ít bị thiện cảm phe chi phối, giảm thất thoát vì thiên vị.',
  ),
  familyFirst(
    'Vị gia tộc',
    'Có thể huy động quan hệ, nhưng dễ ưu ái lợi ích gia tộc.',
  ),
  partisan('Trọng phe', 'Thiện cảm phe ảnh hưởng mạnh đến mức hợp tác.'),
  fameSeeking('Háo danh', 'Tích cực làm việc lớn; coi trọng danh tiếng.');

  const Personality(this.label, this.description);
  final String label, description;
}

bool personalitiesConflict(Personality a, Personality b) => const [
  {Personality.honest, Personality.greedy},
  {Personality.dutiful, Personality.negligent},
  {Personality.cautious, Personality.reckless},
  {Personality.flexible, Personality.conservative},
  {Personality.impartial, Personality.familyFirst},
  {Personality.grateful, Personality.resentful},
].any((pair) => pair.contains(a) && pair.contains(b));

/// Stable across VM/web, reloads and upgrades; consumes no gameplay RNG.
int personalitySeed(String id) =>
    id.codeUnits.fold(17, (hash, unit) => (hash * 31 + unit) % 2147483647);

List<Personality> characterPersonalities({
  required String id,
  required String biography,
  required int integrity,
  required int ambition,
  List<Personality>? saved,
}) {
  final result = <Personality>[];
  void add(Personality p) {
    if (!result.contains(p) &&
        !result.any((other) => personalitiesConflict(p, other)) &&
        !(saved == null && p == Personality.honest && integrity < 80) &&
        !(saved == null && p == Personality.greedy && integrity > 40)) {
      result.add(p);
    }
  }

  if (saved != null) {
    for (final p in saved) {
      add(p);
    }
  } else {
    // One-time authored migration. Engine/UI subsequently use the stable IDs.
    final hints = <String, Personality>{
      'thận trọng': Personality.cautious,
      'cẩn trọng': Personality.cautious,
      'quyết đoán': Personality.decisive,
      'tận tâm': Personality.dutiful,
      'chăm chỉ': Personality.dutiful,
      'thẳng': Personality.upright,
      'cương trực': Personality.upright,
      'gia tộc': Personality.familyFirst,
      'tông thất': Personality.familyFirst,
      'nóng tính': Personality.hotTempered,
      'kỷ luật': Personality.disciplined,
      'phép nước': Personality.disciplined,
      'gần dân': Personality.compassionate,
      'cứu tế': Personality.compassionate,
      'lắng nghe dân': Personality.compassionate,
      'hòa khí': Personality.diplomatic,
      'thu xếp': Personality.diplomatic,
      'thương lượng': Personality.diplomatic,
      'lễ chế': Personality.conservative,
      'hiềm khích': Personality.resentful,
    };
    final lower = biography.toLowerCase();
    for (final e in hints.entries) {
      if (lower.contains(e.key)) add(e.value);
    }
    if (integrity >= 80) add(Personality.honest);
    if (integrity <= 40) add(Personality.greedy);
    if (ambition >= 75) add(Personality.fameSeeking);
  }
  final seed = personalitySeed(id);
  final wanted = saved == null ? 2 + seed % 2 : 2;
  for (
    var i = 0;
    result.length < wanted && i < Personality.values.length;
    i++
  ) {
    add(Personality.values[(seed + i * 7) % Personality.values.length]);
  }
  return result.take(saved == null ? 3 : Personality.values.length).toList();
}
