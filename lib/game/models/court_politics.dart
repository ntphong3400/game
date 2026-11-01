/// Office ranks are shared by appointment costs and political eligibility.
const appointmentRanks = <String, int>{
  'Tể tướng': 4,
  'Đại tướng': 4,
  'Thái phó': 4,
  'Thân vương': 4,
  'Quốc công': 4,
  'Hộ bộ': 3,
  'Lại bộ': 3,
  'Lễ bộ': 3,
  'Công bộ': 3,
  'Hình bộ': 3,
  'Ngự sử': 3,
  'Phó tướng': 3,
  'Đô đốc': 3,
  'Quận vương': 3,
  'Tông chính': 3,
  'Tuần phủ': 3,
  'Tri phủ': 2,
  'Mật thám': 2,
  'Ngự y': 2,
  'Cấm vệ': 2,
  'Biên tướng': 2,
  'Trấn thủ': 2,
  'Tổng quản': 2,
  'Thương chính': 2,
  'Học sĩ': 1,
  'Võ quan': 1,
  'Ngự tiền': 1,
  'Quan điền': 1,
};

const discontentPlotThreshold = 60;

bool politicalAmbitionAllowed(String role, {bool queen = false}) =>
    queen || (appointmentRanks[role] ?? 0) >= 3;

/// Old plots retain their grievance through one ordinary calming tick;
/// otherwise seed from the existing relation.
/// This migration is deterministic and never consumes gameplay RNG.
int legacyDiscontent({required int affection, required int plot}) =>
    plot > 0 ? discontentPlotThreshold + 2 : (40 - affection).clamp(0, 100);
