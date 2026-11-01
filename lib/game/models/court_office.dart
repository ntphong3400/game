/// Grade 1 is the highest. Offices and their holders have separate identities.
const courtGradeNames = [
  '',
  'Nhất phẩm',
  'Nhị phẩm',
  'Tam phẩm',
  'Tứ phẩm',
  'Ngũ phẩm',
  'Lục phẩm',
  'Thất phẩm',
  'Bát phẩm',
  'Cửu phẩm',
];

String courtGradeName(int grade) =>
    grade >= 1 && grade <= 9 ? courtGradeNames[grade] : 'Chưa có phẩm';

class CourtOffice {
  CourtOffice({
    required this.id,
    required this.role,
    required this.group,
    required this.grade,
    this.holderId = '',
    this.appointedTurn = 0,
    this.royalOnly = false,
    this.passiveProgress = 0,
  });
  final String id, role, group;
  final int grade;
  final bool royalOnly;
  String holderId;
  int appointedTurn;
  int passiveProgress;
  factory CourtOffice.fromJson(Map<String, dynamic> j) => CourtOffice(
    id: j['id'],
    role: j['role'],
    group: j['group'],
    grade: j['grade'],
    holderId: j['holderId'] ?? '',
    appointedTurn: j['appointedTurn'] ?? 0,
    royalOnly: j['royalOnly'] == true,
    passiveProgress: j['passiveProgress'] ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'group': group,
    'grade': grade,
    'holderId': holderId,
    'appointedTurn': appointedTurn,
    'royalOnly': royalOnly,
    'passiveProgress': passiveProgress,
  };
}

class CourtMeritRecord {
  const CourtMeritRecord(
    this.id,
    this.turn,
    this.title,
    this.points,
    this.major,
  );
  final String id, title;
  final int turn, points;
  final bool major;
  factory CourtMeritRecord.fromJson(Map<String, dynamic> j) => CourtMeritRecord(
    j['id'],
    j['turn'],
    j['title'],
    j['points'],
    j['major'] == true,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'turn': turn,
    'title': title,
    'points': points,
    'major': major,
  };
}
