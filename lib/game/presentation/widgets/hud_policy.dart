/// Screen-specific counters. Only the kingdom map shows the complete overview.
const allHudMetrics = [
  'treasury',
  'population',
  'food',
  'military',
  'people',
  'authority',
  'health',
  'stability',
];

List<String> hudMetricsFor(String section) => switch (section) {
  'citadel' => allHudMetrics,
  'capital' => const ['treasury', 'authority', 'stability'],
  'court' => const ['treasury', 'people', 'authority', 'stability'],
  'kingdom' => const ['treasury', 'food', 'people', 'stability'],
  'treasury' => const ['treasury', 'food'],
  'population' => const ['population', 'food', 'people'],
  'military' => const ['treasury', 'food', 'military'],
  'people' ||
  'people-government' => const ['treasury', 'authority', 'stability'],
  'harem' || 'harem-management' => const ['treasury', 'food', 'stability'],
  'health' => const ['treasury', 'health'],
  'locality' ||
  'local-administration' => const ['treasury', 'population', 'food', 'people'],
  'local-agriculture' => const ['treasury', 'food'],
  'local-irrigation' || 'local-granary' => const ['treasury', 'food', 'people'],
  'local-commerce' => const ['treasury', 'population', 'people'],
  'local-village' => const ['population', 'food', 'people'],
  _ when section.startsWith('frontier-') => const [
    'treasury',
    'food',
    'military',
  ],
  _ when section.startsWith('country-') => const [
    'treasury',
    'military',
    'authority',
  ],
  _ => const [],
};
