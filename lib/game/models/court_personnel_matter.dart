/// A petition keeps its people and office IDs through reloads and court changes.
class CourtPersonnelMatter {
  CourtPersonnelMatter({
    required this.id,
    required this.kind,
    required this.personId,
    required this.sponsorId,
    required this.openedTurn,
    this.officeId = '',
    this.holderId = '',
    this.targetGrade = 0,
    this.status = 'open',
    this.verified = false,
    this.acceptedTurn = 0,
  });
  final String id, kind, sponsorId, officeId, holderId;
  String personId, status;
  final int targetGrade, openedTurn;
  int acceptedTurn;
  bool verified;
  String get eventId => 'court-personnel:$id';
  String get rewardKey => '$personId:$officeId';
  factory CourtPersonnelMatter.fromJson(Map<String, dynamic> j) =>
      CourtPersonnelMatter(
        id: j['id'],
        kind: j['kind'],
        personId: j['personId'],
        sponsorId: j['sponsorId'],
        openedTurn: j['openedTurn'] ?? 1,
        officeId: j['officeId'] ?? '',
        holderId: j['holderId'] ?? '',
        targetGrade: j['targetGrade'] ?? 0,
        status: j['status'] ?? 'open',
        verified: j['verified'] == true,
        acceptedTurn: j['acceptedTurn'] ?? 0,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'personId': personId,
    'sponsorId': sponsorId,
    'officeId': officeId,
    'holderId': holderId,
    'targetGrade': targetGrade,
    'openedTurn': openedTurn,
    'status': status,
    'verified': verified,
    'acceptedTurn': acceptedTurn,
  };
}
