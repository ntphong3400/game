import '../models/game_state.dart';
import '../models/event_definition.dart';
import '../logic/court_rules.dart';
import '../logic/management_rules.dart';
import '../logic/court_personnel_rules.dart';
import '../logic/currency_rules.dart';
import '../logic/personnel_rules.dart' show specialtyFit;

EventDefinition courtPersonnelEvent(
  GameState s,
  CourtPersonnelMatter m, {
  String nomineeId = '',
}) {
  final c = courtPerson(s, m.personId);
  final sponsor = courtPerson(s, m.sponsorId);
  final office = courtMatterOffice(s, m);
  final title = switch (m.kind) {
    'nominate' => 'Tiến cử người tài bổ khuyết ${office?.role ?? 'chức trống'}',
    'recruit' => 'Chiêu mộ hiền tài cho ${office?.role ?? 'triều đình'}',
    'retire' => 'Đề nghị cho ${c?.name ?? 'quan cũ'} hồi hương',
    'promote' => 'Xin ghi nhận công lao của ${c?.name ?? 'quan cũ'}',
    'patronage' => 'Xin đặc cách thăng phẩm cho ${c?.name ?? 'quan cũ'}',
    _ => 'Kiện toàn chức ${office?.role ?? 'quan'}',
  };
  final target =
      office == null
          ? 'Đề nghị lên ${courtGradeName(m.targetGrade)}.'
          : 'Chức vụ: ${office.role} · ${courtGradeName(office.grade)} · ${office.group}.';
  final incumbent = office == null ? null : courtOfficeHolder(s, office);
  final intent = switch (m.kind) {
    'retire' =>
      'Người dâng tấu thuộc phe đối lập, muốn quan này thôi chức. Lời đề nghị có động cơ phe phái; bệ hạ có thể đối chiếu công việc trước khi quyết định.',
    'patronage' =>
      'Người được nâng đỡ chưa đạt năng lực của phẩm đích. Đặc cách chỉ miễn yêu cầu năng lực; vẫn cần công trạng, thành tích lớn và đủ ngân khố. Passive vẫn xét theo điều kiện thực tế.',
    'promote' =>
      'Xin sắc phong theo công trạng đã tích lũy. Không cấp thêm công trạng chỉ vì được thăng phẩm.',
    'reform' =>
      'Người đương nhiệm chưa đạt năng lực hoặc thiện cảm để phát huy passive. Đề nghị bổ nhiệm người khác đủ năng lực, thiện cảm và chuyên môn thay thế. Người mới phát huy passive sau một mùa giữ chức đầy đủ.',
    _ =>
      'Xin bổ khuyết vị trí đang trống. Người tiến cử chỉ được ghi công sau khi người được chọn giữ chức trọn một mùa, đủ năng lực, đúng chuyên môn và điều kiện của chức vụ.',
  };
  final assessment =
      m.verified && c != null && office != null
          ? '\nKết quả khảo hạch/đối chiếu: phù hợp chuyên môn ${specialtyFit(c.specialty, specialtyForRole(office.role))}%; ${courtNomineeQualified(c, office) ? 'đạt' : 'chưa đạt'} các điều kiện công khai của chức vụ. Đây không phải kết luận về phẩm chất ẩn hay bằng chứng sai phạm.'
          : '';
  final body =
      'Người dâng tấu: ${sponsor?.name ?? 'Quan đã rời triều'} · phe ${sponsor?.faction ?? 'không còn hiện diện'}.\n'
      '${c == null ? 'Người liên quan không còn hiện diện.' : 'Người được đề nghị: ${c.name} · ${courtGradeName(c.grade)} · ${c.specialty} · phe ${c.faction}. Năng lực ${c.abilityLabel}, thiện cảm ${c.affection}, công trạng ${c.merit}, thành tích lớn ${c.majorMerits}.'}\n'
      '$target${incumbent == null ? '' : '\nNgười đang giữ chức: ${incumbent.name}; năng lực ${incumbent.abilityLabel}, thiện cảm ${incumbent.affection}.'}\n$intent$assessment'
      '${courtMatterInvalid(s, m) == null ? '' : '\n${courtMatterInvalid(s, m)}'}';
  EventChoice choice(
    String label,
    String hint, {
    int cost = 0,
    Map<String, int> effects = const {},
  }) => EventChoice(
    label,
    hint,
    effects,
    cost: cost,
    points: 1,
    nativeResources: true,
    currencyNative: true,
  );
  EventChoice appointment(int index, String label) {
    final candidate = courtMatterCandidate(s, m, index, nomineeId);
    final price =
        candidate == null || office == null
            ? 0
            : courtAppointmentCost(s, candidate, office);
    final source = candidate == null ? null : courtOfficeFor(s, candidate.id);
    if (office != null && courtMatterFillsVacancy(s, m, index)) {
      final quote =
          candidate == null ? null : vacancyPromotion(s, candidate, office);
      return choice(
        label,
        candidate == null
            ? 'Chọn người được tiến cử để xem phí thăng phẩm.'
            : '${candidate.name} nhận chức ${office.role}. '
                '${candidate.grade > office.grade ? '${courtGradeName(candidate.grade)} → ${courtGradeName(office.grade)}.' : 'Đã đủ phẩm; giữ phẩm hiện tại.'} '
                'Chi ${moneyText(s, quote!.cost)} và 1 hành động; dùng ${quote.merit} công trạng. '
                'Miễn yêu cầu năng lực và thiện cảm; vẫn cần công trạng, thành tích lớn và thân phận hợp lệ. '
                'Passive vẫn theo điều kiện thông thường.${source == null ? '' : ' Chức ${source.role} sẽ bỏ trống.'}',
        cost: quote?.cost ?? 0,
      );
    }
    final post = office == null ? null : managementPost(office.id);
    if (post != null) {
      return choice(
        label,
        candidate == null
            ? 'Chọn ứng viên để xem đủ chi phí và điều kiện.'
            : '${candidate.name} quản lý ${post.areaName}; ${post.senior ? 'Lục phẩm trở lên' : 'không yêu cầu phẩm vị'}. '
                'Chi 1.000 ngân lượng và 1 hành động; người mới +5 thiện cảm.'
                '${incumbent == null ? '' : ' ${incumbent.name} −10 thiện cảm, chờ bổ nhiệm và giữ nguyên phẩm.'}'
                '${source == null ? '' : ' Chức ${source.role} sẽ bỏ trống.'}'
                ' ${post.effect()}; cần năng lực >${post.abilityThreshold}, thiện cảm >${post.affectionThreshold}.',
        cost: price,
      );
    }
    final loss =
        candidate == null || office == null
            ? 0
            : courtAppointmentDisruption(s, candidate, office);
    return choice(
      label,
      candidate == null
          ? 'Chọn ứng viên để xem đủ chi phí và điều kiện.'
          : '${candidate.name} nhận chức ${office!.role}; ${courtGradeName(office.grade)} trở lên. ${candidate.retired ? 'Triệu hồi người đã hồi hương. ' : ''}'
              'Phe người mới +5, phe đối lập −6; chuyển từ chức khác để lại ghế trống. Phí dùng luật bổ nhiệm thông thường. '
              '${incumbent == null ? '' : '${incumbent.name} về danh sách chờ; ${incumbent.faction == candidate.faction ? 'cùng phe nên không mất thêm thái độ vì thay người' : 'phe ${incumbent.faction} giảm thêm 4 thái độ'}.${incumbent.influence >= 60 ? ' Phe người cũ còn phản ứng mùa sau.' : ''} '}${source == null ? '' : '${source.role} sẽ bỏ trống. ${courtVacancyEffects(source).isEmpty ? '' : 'Mỗi mùa bỏ trống: ${courtVacancyEffects(source)}.'} '}'
              'Passive cần đủ năng lực, thiện cảm và giữ chức trọn mùa. Nếu thôi giữ chức trước khi được đánh giá thì không ghi công tiến cử.',
      cost: price,
      effects: {'authority': 1, if (loss > 0) 'stability': -loss},
    );
  }

  final sponsorFaction = sponsor?.faction;
  final choices = <EventChoice>[];
  if (['nominate', 'recruit', 'reform'].contains(m.kind)) {
    choices.add(appointment(0, 'Bổ nhiệm ${c?.name ?? 'người được tiến cử'}'));
    choices.add(
      m.kind == 'recruit' && !m.verified
          ? choice(
            'Khảo hạch trước khi bổ nhiệm',
            'Chi 1 hành động; giữ tấu tới cuối mùa sau. Khảo hạch không tự bổ nhiệm hoặc cấp công trạng.',
            cost: money(s, 5),
          )
          : appointment(1, 'Chọn người khác để bổ nhiệm'),
    );
  } else if (m.kind == 'retire') {
    choices.add(
      choice(
        'Cho ${c?.name ?? 'quan cũ'} thôi chức, hồi hương',
        'Chi 1 hành động, không chi vàng. ${office == null ? '' : 'Cần uy quyền trên ${courtOfficeAuthority(office)} nếu chức từ Tứ phẩm trở lên. ${courtVacancyEffects(office).isEmpty ? '' : 'Mỗi mùa ghế trống: ${courtVacancyEffects(office)}.'}'} '
            'Người hồi hương giữ phẩm và công trạng; phe người cũ −4, phe dâng tấu +3; người ảnh hưởng cao còn phản ứng mùa sau.',
        effects: {
          if (office != null) 'stability': -courtOfficeDisruption(office),
          if (sponsorFaction != null) 'faction:$sponsorFaction': 3,
          if (c != null) 'faction:${c.faction}': -4,
        },
      ),
    );
    choices.add(
      choice(
        'Đối chiếu công việc trước khi quyết định',
        'Chi 1 hành động; gia hạn tới cuối mùa sau, không tự cho hồi hương hoặc miễn yêu cầu uy quyền.',
      ),
    );
  } else {
    final quote = c == null ? null : CourtPromotion(s, c, m.targetGrade);
    choices.add(
      choice(
        m.kind == 'patronage'
            ? 'Đặc cách lên ${courtGradeName(m.targetGrade)}'
            : 'Thăng lên ${courtGradeName(m.targetGrade)}',
        'Dùng ${quote?.merit ?? 0} công trạng; giữ nguyên yêu cầu thành tích lớn. Thiện cảm +${quote?.actualAffection(c!) ?? 0}, bất mãn −${quote?.actualDiscontent(c!) ?? 0}. '
        '${m.kind == 'patronage' ? 'Miễn điều kiện năng lực; uy quyền −2, ổn định −1, phe tiến cử +5. Không kích hoạt passive nếu chưa đủ năng lực.' : 'Uy quyền +1, phe tiến cử +2. Không cộng công trạng cho việc thăng phẩm.'}',
        cost: quote?.cost ?? 0,
        effects: {
          'authority': m.kind == 'patronage' ? -2 : 1,
          if (m.kind == 'patronage') 'stability': -1,
          if (sponsorFaction != null)
            'faction:$sponsorFaction': m.kind == 'patronage' ? 5 : 2,
        },
      ),
    );
    choices.add(
      choice(
        m.kind == 'patronage'
            ? 'Yêu cầu lập công và rèn năng lực trước'
            : 'Xét sắc phong vào dịp khác',
        'Khép đề nghị; không thăng phẩm, không cấp công trạng hay miễn điều kiện cho lần sau.',
      ),
    );
  }
  choices.add(
    choice(
      'Bác đề nghị',
      'Giữ nguyên nhân sự; phe dâng tấu −1. Quá hạn cũng áp dụng phương án này.',
      effects: {if (sponsorFaction != null) 'faction:$sponsorFaction': -1},
    ),
  );
  return EventDefinition(
    m.eventId,
    title,
    body,
    'Nhân sự',
    choices,
    condition: 'storyOnly',
  );
}
