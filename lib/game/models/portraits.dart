/// One three-cell atlas per identity: young, middle-aged, elder.
/// These visual choices never consume the gameplay random stream.
enum PortraitAge {
  young('Trẻ'),
  middle('Trung niên'),
  elder('Lão niên');

  const PortraitAge(this.label);
  final String label;
}

PortraitAge portraitAgeFor(int age) =>
    age < 35
        ? PortraitAge.young
        : age < 55
        ? PortraitAge.middle
        : PortraitAge.elder;

const officialPortraitCount = 60;
const haremPortraitCount = 30;
const emperorPortraitId = 'emperor';

String officialPortraitId(int index) =>
    'official-${index.toString().padLeft(3, '0')}';
String haremPortraitId(int index) =>
    'harem-${index.toString().padLeft(3, '0')}';

final officialPortraitIds = List<String>.unmodifiable([
  for (var i = 1; i <= officialPortraitCount; i++) officialPortraitId(i),
]);
final haremPortraitIds = List<String>.unmodifiable([
  for (var i = 1; i <= haremPortraitCount; i++) haremPortraitId(i),
]);

bool validCharacterPortrait(String? id, {required bool harem}) =>
    (harem ? haremPortraitIds : officialPortraitIds).contains(id);

String portraitAsset(String id) => 'assets/images/portraits/$id.webp';

int portraitHash(String id) =>
    id.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff);

// Stable faces for the authored roster, independent of list order or seed.
const initialPortraits = <String, String>{
  'chancellor': 'official-001',
  'treasurer': 'official-002',
  'scholar': 'official-003',
  'academician': 'official-004',
  'rites': 'official-005',
  'works': 'official-006',
  'royal_tutor': 'official-007',
  'personnel': 'official-008',
  'justice': 'official-009',
  'trade_officer': 'official-010',
  'general': 'official-017',
  'deputy_general': 'official-018',
  'admiral': 'official-019',
  'guard': 'official-020',
  'border_general': 'official-021',
  'marshal': 'official-022',
  'garrison': 'official-023',
  'governor': 'official-029',
  'provincial': 'official-030',
  'land_officer': 'official-031',
  'regional-north-prefect': 'official-032',
  'regional-east-prefect': 'official-033',
  'regional-west-prefect': 'official-034',
  'regional-south-governor': 'official-035',
  'regional-highland-governor': 'official-036',
  'regional-coast-land': 'official-037',
  'regional-delta-land': 'official-038',
  'prince': 'official-043',
  'duke': 'official-044',
  'royal_cousin': 'official-045',
  'royal_clan': 'official-046',
  'spy': 'official-049',
  'doctor': 'official-050',
  'steward': 'official-051',
  'chamberlain': 'official-052',
  'consort_lan': 'harem-001',
  'consort_mai': 'harem-002',
  'consort_yen': 'harem-003',
  'consort_truc': 'harem-004',
  'consort_dao': 'harem-005',
  'consort_khue': 'harem-006',
  'consort_nguyet': 'harem-007',
  'consort_lien': 'harem-008',
  'consort_van': 'harem-009',
  'consort_chau': 'harem-010',
};

/// Prefer clothing suited to the person's original office or specialty.
/// Once assigned, a face is retained even if that person is promoted.
List<String> preferredOfficialPortraits(String category, String specialty) {
  final (start, end) = switch (category) {
    'Võ ban' => (17, 28),
    'Địa phương' => (29, 42),
    'Hoàng thất' => (43, 48),
    'Nội đình' => (49, 54),
    _ => switch (specialty) {
      'Quân sự' || 'An ninh' => (17, 28),
      'Công trình' || 'Kinh tế' => (29, 42),
      'Cung đình' || 'Y thuật' => (49, 54),
      _ => (1, 16),
    },
  };
  return [for (var i = start; i <= end; i++) officialPortraitId(i)];
}
