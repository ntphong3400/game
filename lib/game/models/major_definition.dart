/// Authored, immutable content. Runtime progress lives in MajorMission.
class ObjectiveDefinition {
  const ObjectiveDefinition(
    this.key,
    this.title,
    this.specialty,
    this.cost,
    this.grain,
    this.duration,
    this.damage, {
    this.responses = const [],
    this.aftermath = const {},
  });
  final String key, title, specialty;
  final int cost, grain, duration;
  final Map<String, int> damage, aftermath;
  final List<String> responses;
}

/// A promise tied to a completed goal, or an economic benefit after 4/4.
class MajorAgreement {
  const MajorAgreement(
    this.title,
    this.amount,
    this.weeks, {
    this.goal = '',
    this.income = 0,
  });
  final String title, goal;
  final int amount, weeks, income;
}

class MajorDefinition {
  const MajorDefinition(
    this.id,
    this.title,
    this.body,
    this.objectives, {
    this.code = '',
    this.group = 'politics',
    this.condition = 'any',
    this.minWeek = 1,
    this.successText = '',
    this.failureText = '',
    this.rewards = const {'people': 4, 'authority': 5, 'stability': 3},
    this.agreement,
  });
  final String id,
      title,
      body,
      code,
      group,
      condition,
      successText,
      failureText;
  final int minWeek;
  final List<ObjectiveDefinition> objectives;
  final Map<String, int> rewards;
  final MajorAgreement? agreement;
}
