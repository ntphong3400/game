/// Snapshot committed with the decision: retries/reloads never reroll it.
class PetitionAssignment {
  const PetitionAssignment({
    required this.eventId,
    required this.assigneeId,
    required this.assigneeName,
    required this.specialty,
    required this.chance,
    required this.succeeded,
    required this.failureEffects,
    this.auditRecoveryMinimum = 25,
    this.auditRecoveryMaximum = 45,
    this.meritId = '',
  });
  final String eventId, assigneeId, assigneeName, specialty;
  final String meritId;
  final int chance;
  final int auditRecoveryMinimum, auditRecoveryMaximum;
  final bool succeeded;
  final Map<String, int> failureEffects;
  String get personLabel =>
      assigneeId.isEmpty ? 'Không giao ai xử lý' : assigneeName;
  factory PetitionAssignment.fromJson(
    Map<String, dynamic> j,
  ) => PetitionAssignment(
    eventId: j['eventId'] as String,
    meritId: j['meritId'] as String? ?? '',
    assigneeId: j['assigneeId'] as String,
    assigneeName: j['assigneeName'] as String,
    specialty: j['specialty'] as String,
    chance: (j['chance'] as num).toInt(),
    succeeded: j['succeeded'] == true,
    auditRecoveryMinimum: (j['auditRecoveryMinimum'] as num?)?.toInt() ?? 25,
    auditRecoveryMaximum: (j['auditRecoveryMaximum'] as num?)?.toInt() ?? 45,
    failureEffects: (j['failureEffects'] as Map).map(
      (k, v) => MapEntry(k as String, (v as num).toInt()),
    ),
  );
  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'meritId': meritId,
    'assigneeId': assigneeId,
    'assigneeName': assigneeName,
    'specialty': specialty,
    'chance': chance,
    'succeeded': succeeded,
    'failureEffects': failureEffects,
    'auditRecoveryMinimum': auditRecoveryMinimum,
    'auditRecoveryMaximum': auditRecoveryMaximum,
  };
}
