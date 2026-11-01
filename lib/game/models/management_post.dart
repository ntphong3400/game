/// Stable positions share their holder with the court's office ledger.
class ManagementPost {
  const ManagementPost(this.kind, this.area);
  final String kind, area;
  String get id => 'management-$kind-$area';
  bool get frontier => kind == 'camp' || kind == 'command';
  bool get senior => kind == 'command' || kind == 'prefect';
  String get role => switch (kind) {
    'camp' => 'Quản lý doanh trại',
    'command' => 'Trấn thủ',
    'prefect' => 'Tri phủ',
    _ => 'Phò tá',
  };
  String get areaName =>
      const {
        'north': 'Bắc Ải',
        'west': 'Tây Ải',
        'south': 'Nam Ải',
        'bac-son': 'Bắc Sơn',
        'dong-hai': 'Đông Hải',
        'tay-linh': 'Tây Lĩnh',
      }[area]!;
  String get group => frontier ? 'Võ ban' : 'Văn ban';
  int get abilityThreshold => senior ? 70 : 50;
  int get affectionThreshold => senior ? 60 : 50;
  int get growthCap => senior ? 70 : 60;
  String get growthLabel =>
      senior ? '+0,5 năng lực/mùa, tối đa 70' : '+1 năng lực/mùa, tối đa 60';
  String get benefit =>
      frontier
          ? (kind == 'camp' ? 'training' : 'morale')
          : switch (area) {
            'bac-son' => 'population',
            'dong-hai' => 'levee',
            _ => 'equipment',
          };
  String get benefitLabel => switch (benefit) {
    'training' => 'huấn luyện',
    'morale' => 'sĩ khí',
    'population' => 'dân số',
    'levee' => 'đê điều',
    _ => 'sản xuất quân khí',
  };
  int get amount =>
      benefit == 'population'
          ? (senior ? 200 : 100)
          : benefit == 'equipment'
          ? (senior ? 100 : 50)
          : 1;
  int get interval =>
      kind == 'camp'
          ? 2
          : benefit == 'levee'
          ? (senior ? 2 : 4)
          : 1;
  String effect({bool vacant = false}) =>
      '${vacant ? '−' : '+'}$amount $benefitLabel/${interval == 1 ? '' : '$interval '}mùa';
}

final managementPosts = [
  for (final area in ['north', 'west', 'south']) ...[
    ManagementPost('camp', area),
    ManagementPost('command', area),
  ],
  for (final area in ['bac-son', 'dong-hai', 'tay-linh']) ...[
    ManagementPost('prefect', area),
    ManagementPost('assistant', area),
  ],
];

ManagementPost? managementPost(String officeId) =>
    managementPosts.where((p) => p.id == officeId).firstOrNull;
