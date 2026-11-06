import '../models/number_format.dart';
import '../logic/currency_rules.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'game_routes.dart';
import 'music/background_music.dart';
import 'music/music_scope.dart';
import 'widgets/imperial_dialog.dart';
import '../../app/game_controller.dart';
import '../data/content.dart';
import '../data/reign_content.dart' show majorDefinition;
import '../models/game_state.dart';
import '../logic/personnel_rules.dart';
import 'widgets/palace_art.dart';
import 'widgets/treasury_panel.dart';
import 'widgets/outcome_panel.dart';
import 'widgets/kingdom_panel.dart';
import 'widgets/population_panel.dart';
import '../logic/population_rules.dart';
import '../logic/reign_rules.dart';
import '../logic/harem_rules.dart';
import '../logic/petition_assignment_rules.dart';
import '../logic/health_rules.dart';
import '../logic/chain_settlement_rules.dart';
import 'widgets/harem_quest_panel.dart';
import 'widgets/citadel_hub.dart';
import 'widgets/capital_hub.dart';
import 'widgets/locality_hub.dart';
import 'widgets/locality_panel.dart';
import 'widgets/investigation_dialog.dart';
import '../logic/investigation_rules.dart';
import 'widgets/locality_routes.dart';
import 'widgets/frontier_routes.dart';
import 'widgets/frontier_hub.dart';
import 'widgets/frontier_panel.dart';
import 'widgets/country_routes.dart';
import 'widgets/country_hub.dart';
import 'widgets/country_panel.dart';
import '../logic/frontier_rules.dart';
import 'widgets/web_game_hud.dart';
import 'widgets/hud_policy.dart';
import 'widgets/imperial_widgets.dart';
import 'widgets/imperial_assets.dart';
import 'widgets/imperial_room.dart';
import 'widgets/imperial_theme.dart';
import 'widgets/petition_decision.dart';
import 'widgets/petition_document.dart';
import 'widgets/petition_art.dart';
import 'widgets/memorial_paper.dart';
import 'outcome_read_store.dart';
import 'meeting_scenes.dart';
import 'widgets/character_meeting_page.dart';
import '../logic/court_rules.dart';
import 'widgets/court_roster_panel.dart';
import 'widgets/court_overview.dart';
import 'widgets/court_government_panel.dart';
import 'widgets/court_personnel_dialogs.dart';
import 'widgets/personnel_passives.dart';
import 'widgets/equal_height_grid.dart';
import 'widgets/roster_card_body.dart';
import 'widgets/harem_rank_badge.dart';
export 'widgets/imperial_theme.dart';

class GameApp extends StatefulWidget {
  const GameApp({
    super.key,
    required this.controller,
    this.initialRoute,
    this.outcomeReadStore,
    this.musicController,
  });
  final GameController controller;
  final OutcomeReadStore? outcomeReadStore;
  final BackgroundMusicController? musicController;

  /// Starting section; existing section tests can open their subject directly.
  final String? initialRoute;
  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> with WidgetsBindingObserver {
  late final _ownsMusic = widget.musicController == null;
  late final _music =
      _ownsMusic ? BackgroundMusicController() : widget.musicController!;
  void _syncMusic() => _music.selectLocation(
    GameLocation.parse(router.routeInformationProvider.value.uri),
  );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _music.setSuspended(state != AppLifecycleState.resumed);
  }

  final routingRefresh = ValueNotifier(0);
  void refreshRouting() {
    final uri = router.routeInformationProvider.value.uri;
    final destination = GameLocation.redirect(widget.controller, uri);
    final routeContext = router.routerDelegate.navigatorKey.currentContext;
    final source = GameLocation.parse(uri);
    final target =
        destination == null ? null : GameLocation.parse(Uri.parse(destination));
    if (routeContext != null &&
        source?.characterId != null &&
        target?.characterId != null) {
      // The alias may already have been reported while the archive loaded.
      // Replace that entry when its persisted public UUID becomes available.
      Router.neglect(routeContext, () => routingRefresh.value++);
    } else {
      routingRefresh.value++;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(refreshRouting);
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _music.setSuspended(
      lifecycle != null && lifecycle != AppLifecycleState.resumed,
    );
    router.routeInformationProvider.addListener(_syncMusic);
    _syncMusic();
  }

  @override
  void didUpdateWidget(covariant GameApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(refreshRouting);
      widget.controller.addListener(refreshRouting);
      router.refresh();
    }
  }

  late final router = GoRouter(
    initialLocation:
        widget.initialRoute == null
            ? null
            : GameLocation.pathFor(widget.initialRoute!),
    refreshListenable: routingRefresh,
    redirect: (_, state) => GameLocation.redirect(widget.controller, state.uri),
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Không tìm thấy trang này.'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Về trang giới thiệu'),
                ),
              ],
            ),
          ),
        ),
    routes: [
      ShellRoute(
        builder:
            (context, state, child) => GameShell(
              controller: widget.controller,
              location: GameLocation.parse(state.uri)!,
              outcomeReadStore: widget.outcomeReadStore,
              child: child,
            ),
        routes: [
          for (final entry in GameLocation.sectionPaths.entries)
            GoRoute(
              path: entry.value,
              pageBuilder:
                  (_, state) => const NoTransitionPage<void>(
                    key: ValueKey('game-section'),
                    child: _GameSectionPage(),
                  ),
              routes: [
                if (['people', 'harem'].contains(entry.key))
                  GoRoute(
                    path: 'meet/:publicId',
                    pageBuilder:
                        (_, state) => NoTransitionPage<void>(
                          key: state.pageKey,
                          child: _GameCharacterPage(
                            publicId: state.pathParameters['publicId']!,
                          ),
                        ),
                  ),
              ],
            ),
        ],
      ),
    ],
  );

  @override
  void dispose() {
    widget.controller.removeListener(refreshRouting);
    WidgetsBinding.instance.removeObserver(this);
    router.routeInformationProvider.removeListener(_syncMusic);
    if (_ownsMusic) _music.dispose();
    router.dispose();
    routingRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    routerConfig: router,
    builder: (context, child) => MusicScope(controller: _music, child: child!),
    title: 'Vạn Tuế — Một đời đế vương',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'BeVietnam',
      scaffoldBackgroundColor: parchment,
      colorScheme: ColorScheme.fromSeed(
        seedColor: forest,
        primary: forest,
        surface: paper,
        onSurface: ink,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 13, height: 1.65, color: ink),
        bodySmall: TextStyle(fontSize: 11, height: 1.65, color: muted),
      ),
      dividerColor: line,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: forest,
          foregroundColor: paper,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forest,
          side: const BorderSide(color: line),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paper,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}

/// Keep filters, scroll positions and gameplay callbacks alive across URLs.
class _GameShellScope extends InheritedWidget {
  const _GameShellScope({required this.shell, required super.child});
  final _GameShellState shell;
  static _GameShellState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GameShellScope>()!.shell;
  @override
  bool updateShouldNotify(_GameShellScope oldWidget) => true;
}

class _GameSectionPage extends StatelessWidget {
  const _GameSectionPage();
  @override
  Widget build(BuildContext context) {
    final shell = _GameShellScope.of(context);
    return AnimatedBuilder(
      animation: shell.controller,
      builder: (context, _) => shell._sectionPage(context),
    );
  }
}

class _GameCharacterPage extends StatelessWidget {
  const _GameCharacterPage({required this.publicId});
  final String publicId;
  @override
  Widget build(BuildContext context) {
    final shell = _GameShellScope.of(context);
    return AnimatedBuilder(
      animation: shell.controller,
      builder: (context, _) {
        final state = shell.controller.state;
        final person =
            state == null
                ? null
                : [...state.court, ...state.officialsPool]
                    .where((p) => p.publicId == publicId && p.available)
                    .firstOrNull;
        // Guards resolve this destination once the archive finishes loading.
        if (shell.controller.loading || person == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return shell._characterMeeting(person);
      },
    );
  }
}

class GameShell extends StatefulWidget {
  const GameShell({
    super.key,
    required this.controller,
    required this.location,
    required this.child,
    this.outcomeReadStore,
  });
  final GameController controller;
  final OutcomeReadStore? outcomeReadStore;
  final GameLocation location;
  final Widget child;
  @override
  State<GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<GameShell> {
  String get route => widget.location.screen;
  GameController get controller => widget.controller;
  GameState get s => controller.state!;
  bool get busy => controller.busy;
  final scrollController = ScrollController();
  final courtReadingController = ScrollController();
  final courtSearch = TextEditingController();
  String courtCategory = 'Tất cả', haremCategory = 'Tất cả';
  String courtFaction = 'Tất cả', haremFaction = 'Tất cả';
  String scoreRules = rulesVersion;
  String? selectedPetitionId, approvedPetitionTitle;
  bool petitionDialogOpen = false;
  bool personDialogOpen = false;
  bool get palaceManagementOpen =>
      widget.location.backgroundSection == 'harem-management';
  bool get courtGovernmentOpen =>
      widget.location.backgroundSection == 'people-government';
  String? selectedOfficialId, selectedConsortId;
  String courtAvailability = 'Tất cả', haremAvailability = 'Tất cả';
  bool courtListView = false;
  String? selectedCareId;
  int treasurySection = 0;
  String? get localityPersonnelReturn {
    final section = GameLocation.sectionFor(widget.location.returnTo);
    return section != null && LocalityPlace.fromRoute(section) != null
        ? section
        : null;
  }

  int selectedChronicleIndex = 0;
  late final _outcomeReadStore = widget.outcomeReadStore ?? OutcomeReadStore();
  String? _outcomeReadRun;
  bool _outcomeReadReady = false;
  final _readOutcomeIds = <String>{};

  @override
  void initState() {
    super.initState();
    controller.addListener(_loadOutcomeReadState);
    _loadOutcomeReadState();
  }

  @override
  void didUpdateWidget(covariant GameShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location.screen != route) treasurySection = 0;
    if (oldWidget.location.uri != widget.location.uri &&
        !['ending', 'ending-summary'].contains(widget.location.section)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // A turn may open its result report while redirecting to the ending;
        // keep that report visible. Other page changes dismiss transient UI.
        Navigator.of(
          context,
          rootNavigator: true,
        ).popUntil((route) => route.settings is Page);
      });
    }
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_loadOutcomeReadState);
      controller.addListener(_loadOutcomeReadState);
      _outcomeReadRun = null;
      _loadOutcomeReadState();
    }
  }

  void _loadOutcomeReadState() {
    final run = controller.state?.runId;
    if (run == _outcomeReadRun) return;
    _outcomeReadRun = run;
    _outcomeReadReady = false;
    _readOutcomeIds.clear();
    if (run == null) return;
    _outcomeReadStore.read(run).then((ids) {
      if (!mounted || _outcomeReadRun != run) return;
      setState(() {
        _readOutcomeIds.addAll(ids);
        _outcomeReadReady = true;
      });
    });
  }

  Future<void> _viewOutcomeReports(List<OutcomeReport> reports) async {
    final run = s.runId;
    await showOutcomeReports(context, reports, seasonal: s.seasonal);
    if (!mounted || controller.state?.runId != run) return;
    final ids = reports.map((r) => r.id).toSet();
    setState(() => _readOutcomeIds.addAll(ids));
    await _outcomeReadStore.markRead(run, ids);
  }

  @override
  void dispose() {
    controller.removeListener(_loadOutcomeReadState);
    scrollController.dispose();
    courtReadingController.dispose();
    courtSearch.dispose();
    super.dispose();
  }

  void navigate(String value) {
    final from =
        LocalityPlace.fromRoute(route) != null && value == 'people'
            ? GameLocation.pathFor(route)
            : null;
    context.go(GameLocation(value, returnTo: from).uri.toString());
    if (scrollController.hasClients) scrollController.jumpTo(0);
  }

  Future<bool> act(
    String type, {
    String target = '',
    String option = '',
    String assigneeId = '',
    bool showSnackBar = true,
  }) async {
    final previousOutcomes = controller.state?.outcomes.length ?? 0;
    final ok = await controller.act(
      type,
      target: target,
      option: option,
      assigneeId: assigneeId,
    );
    if (!mounted) return ok;
    if (showSnackBar) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      if (!ok) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              formatGameNumbers(
                s.calendarText(controller.error ?? 'Chưa thực hiện được.'),
              ),
            ),
          ),
        );
      } else if (type != 'endWeek' && !s.ended) {
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(formatGameNumbers(s.journal.first.title))),
              ],
            ),
          ),
        );
      }
    }
    if (ok && s.outcomes.length > previousOutcomes) {
      await _viewOutcomeReports(s.outcomes.skip(previousOutcomes).toList());
    }
    return ok;
  }

  Future<void> startDialog() async {
    final name = TextEditingController(
      text: controller.state?.playerName ?? '',
    );
    final form = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => ImperialAlertDialog(
            title: const Text(
              'Một triều đại mới',
              style: TextStyle(fontFamily: 'Lora'),
            ),
            content: SizedBox(
              width: 380,
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mười tám tuổi, bạn nhận ngọc tỷ. Từ hôm nay, vận mệnh giang sơn nằm trong từng quyết định.',
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: name,
                      autofocus: true,
                      maxLength: 32,
                      decoration: const InputDecoration(
                        labelText: 'Tên người chơi',
                        hintText: 'Bạn muốn được ghi tên thế nào?',
                      ),
                      validator:
                          (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Vui lòng nhập tên người chơi.'
                                  : null,
                      onFieldSubmitted: (_) {
                        if (form.currentState!.validate()) {
                          Navigator.pop(context, name.text.trim());
                        }
                      },
                    ),
                    if (controller.state != null && !s.ended)
                      const Text(
                        'Bắt đầu lại sẽ thay lượt đang chơi. Lượt bị bỏ không được ghi thành tích.',
                        style: TextStyle(color: terracotta, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Để sau'),
              ),
              FilledButton(
                onPressed: () {
                  if (form.currentState!.validate()) {
                    Navigator.pop(context, name.text.trim());
                  }
                },
                child: const Text('Nhận ngọc tỷ'),
              ),
            ],
          ),
    );
    // A dialog can still be unmounting during its reverse animation.
    Future<void>.delayed(const Duration(milliseconds: 500), name.dispose);
    if (result == null || !mounted) return;
    final ok = await controller.start(result);
    if (!mounted) return;
    if (ok) {
      context.go(GameLocation.afterStart(GoRouterState.of(context).uri));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatGameNumbers(
              controller.error ?? 'Không thể bắt đầu lượt mới.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) =>
      _GameShellScope(shell: this, child: widget.child);

  Widget _sectionPage(BuildContext context) {
    if (controller.loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Crest(size: 56),
              SizedBox(height: 24),
              CircularProgressIndicator(strokeWidth: 2),
            ],
          ),
        ),
      );
    }
    if (route == 'home' || (controller.state == null && route != 'scores')) {
      return _landing();
    }
    if (controller.state?.ended == true && route != 'scores') {
      return route == 'ending-summary' ? _ending() : _endingReason();
    }
    final neighborCountry = countryFromRoute(route);
    if (neighborCountry != null) {
      final place = countryPlace(route);
      if (place != null) return _countryDetailShell(neighborCountry, place);
      return CountryHub(
        key: ValueKey(neighborCountry),
        state: s,
        countryId: neighborCountry,
        busy: busy,
        onNavigate: navigate,
        onEndTurn: _nextWeek,
        onOvertime: _overtimeDialog,
      );
    }
    final frontCountry = frontierCountry(route);
    if (frontCountry != null && s.warfare != null && s.population != null) {
      final place = frontierPlace(route);
      if (place != null) return _frontierDetailShell(frontCountry, place);
      return FrontierHub(
        key: ValueKey(frontCountry),
        state: s,
        countryId: frontCountry,
        busy: busy,
        onNavigate: navigate,
        onEndTurn: _nextWeek,
        onOvertime: _overtimeDialog,
      );
    }
    if (route == 'capital') {
      return CapitalHub(
        state: s,
        busy: busy,
        onNavigate: navigate,
        onEndTurn: _nextWeek,
        onOvertime: _overtimeDialog,
      );
    }
    if (route == 'locality') {
      return LocalityHub(
        state: s,
        busy: busy,
        onNavigate: navigate,
        onEndTurn: _nextWeek,
        onOvertime: _overtimeDialog,
      );
    }
    final localPlace = LocalityPlace.fromRoute(route);
    if (localPlace != null) return _localityDetailShell(localPlace);
    if (route == 'citadel') {
      return CitadelHub(
        state: s,
        busy: busy,
        onNavigate: navigate,
        onEndTurn: _nextWeek,
        onOvertime: _overtimeDialog,
      );
    }
    return _roomShell();
  }

  String get _roomBackDestination {
    if (route == 'treasury' && treasurySection != 0) return 'treasury';
    return localityPersonnelReturn ??
        hudParentFor(widget.location.backgroundSection) ??
        'capital';
  }

  void _roomBack() {
    if (route == 'treasury' && treasurySection != 0) {
      setState(() => treasurySection = 0);
    } else {
      navigate(_roomBackDestination);
    }
  }

  String? get _hudTitle =>
      route == 'treasury' && treasurySection != 0
          ? [
            'Ngân khố',
            'Thuế & ngân sách',
            'Việc tăng thu',
            'Kho lương & đê điều',
            'Đang thực hiện',
          ][treasurySection]
          : null;

  Widget _roomShell() => ImperialRoomScope(
    child: Theme(
      data: roomTheme(context),
      child: LayoutBuilder(
        builder: (context, bounds) {
          final desktop = bounds.maxWidth >= 1050;
          final title = switch (route) {
            'court' => 'Triều chính',
            'treasury' => desktop ? 'Hộ bộ · Sổ tiền và kho lương' : 'Hộ bộ',
            'people' =>
              courtGovernmentOpen
                  ? 'Bộ máy triều đình'
                  : 'Những người bên ngai vàng',
            'kingdom' => 'Điện nghị sự',
            'population' => 'Dân cư & Lao động',
            'military' => 'Quân sự',
            'journal' => 'Sử quán',
            'scores' => 'Điện lưu danh',
            'harem' =>
              palaceManagementOpen ? 'Câu chuyện hậu cung' : 'Sau rèm châu',
            _ => 'Long thể & nhịp sống',
          };
          return Scaffold(
            backgroundColor: imperialDeep,
            body: SafeArea(
              child: Column(
                children: [
                  if (route == 'scores')
                    _archiveHud()
                  else
                    RoomHud(
                      state: s,
                      section: widget.location.backgroundSection,
                      title: _hudTitle,
                      onBack: _roomBack,
                      backLabel: hudTitleFor(s, _roomBackDestination),
                      onNavigate: navigate,
                    ),
                  if (busy)
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: imperialGold,
                      backgroundColor: imperialDeep,
                    ),
                  Expanded(
                    child: RoomStage(
                      scene: route,
                      title: title,
                      showHeader: route != 'court',
                      child: _page(),
                    ),
                  ),
                  if (controller.state != null && !s.ended && route != 'scores')
                    _weekbar(desktop),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _frontierDetailShell(
    String country,
    String place,
  ) => ImperialRoomScope(
    child: Theme(
      data: roomTheme(context),
      child: LayoutBuilder(
        builder:
            (context, bounds) => Scaffold(
              backgroundColor: paper,
              body: SafeArea(
                child: Column(
                  children: [
                    WebGameHud(state: s, section: route, onNavigate: navigate),
                    if (busy) const LinearProgressIndicator(minHeight: 2),
                    Expanded(
                      child: RoomStage(
                        scene: route,
                        title:
                            '${frontierPlaceNames[place]} · ${garrisonNames[country]}',
                        child: FrontierPanel(
                          key: ValueKey(route),
                          state: s,
                          controller: controller,
                          countryId: country,
                          place: place,
                          onNavigate: navigate,
                        ),
                      ),
                    ),
                    _weekbar(bounds.maxWidth >= 1050),
                  ],
                ),
              ),
            ),
      ),
    ),
  );

  Widget _countryDetailShell(String country, String place) => ImperialRoomScope(
    child: Theme(
      data: roomTheme(context),
      child: LayoutBuilder(
        builder:
            (context, bounds) => Scaffold(
              backgroundColor: paper,
              body: SafeArea(
                child: Column(
                  children: [
                    WebGameHud(state: s, section: route, onNavigate: navigate),
                    if (busy) const LinearProgressIndicator(minHeight: 2),
                    Expanded(
                      child: RoomStage(
                        scene: route,
                        title:
                            '${countryPlaceNames[place]} · ${s.warfare?.neighbors.where((n) => n.id == country).firstOrNull?.name ?? countryNames[country]}',
                        child: CountryPanel(
                          key: ValueKey(route),
                          state: s,
                          controller: controller,
                          countryId: country,
                          place: place,
                          onNavigate: navigate,
                        ),
                      ),
                    ),
                    _weekbar(bounds.maxWidth >= 1050),
                  ],
                ),
              ),
            ),
      ),
    ),
  );

  Widget _localityDetailShell(LocalityPlace place) => ImperialRoomScope(
    child: Theme(
      data: roomTheme(context),
      child: LayoutBuilder(
        builder:
            (context, bounds) => Scaffold(
              backgroundColor: paper,
              body: SafeArea(
                child: Column(
                  children: [
                    WebGameHud(state: s, section: route, onNavigate: navigate),
                    if (busy) const LinearProgressIndicator(minHeight: 2),
                    Expanded(
                      child: RoomStage(
                        scene: place.route,
                        title:
                            place == LocalityPlace.administration
                                ? 'Phủ nha'
                                : '${place.landmark} · ${place.title}',
                        child: LocalityPanel(
                          send:
                              (type, target, option) => controller.act(
                                type,
                                target: target,
                                option: option,
                              ),
                          place: place,
                          state: s,
                          busy: busy,
                          onNavigate: navigate,
                          onAction: _performAction,
                          blockedReason: _actionBlocked,
                          actionDescription: _actionDescription,
                          onPolicy: _localityPolicy,
                          onPetition: _petitionDialog,
                          onPerson: _openCharacterMeeting,
                          onOutcomes: () => _viewOutcomeReports(s.outcomes),
                        ),
                      ),
                    ),
                    _weekbar(bounds.maxWidth >= 1050),
                  ],
                ),
              ),
            ),
      ),
    ),
  );

  Future<void> _localityPolicy(String type, String option) async {
    if (type == 'production') {
      await act('population', target: 'production', option: option);
    } else {
      await act(type, option: option);
    }
  }

  Widget _archiveHud() {
    final active = controller.state;
    if (active != null && !active.ended) {
      return WebGameHud(state: active, section: 'scores', onNavigate: navigate);
    }
    return GameTopBar(
      title: 'Vọng Thiên Các',
      backLabel: 'Trang chủ',
      onBack: () => navigate('home'),
    );
  }

  Widget _page() => switch (route) {
    'scores' => _scores(),
    'kingdom' => _kingdom(),
    'treasury' => _treasury(),
    'population' => PopulationPanel(state: s),
    'military' => PopulationPanel(
      state: s,
      military: true,
      controller: widget.controller,
    ),
    'people' => _people(false),
    'harem' => _people(true),
    'health' => _health(),
    'journal' => _journal(),
    _ => _dashboard(),
  };

  Widget _heading(String title, String subtitle, {Widget? trailing}) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatGameNumbers(title),
                style: TextStyle(fontFamily: 'Lora', fontSize: 30, height: 1.3),
              ),
              const SizedBox(height: 8),
              Text(
                formatGameNumbers(subtitle),
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );

  Widget _dashboard() => Theme(data: Theme.of(context), child: _courtDesk());

  Widget _courtAlert(String key, String message, String destination) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextButton.icon(
      onPressed: () => navigate(destination),
      style: TextButton.styleFrom(
        foregroundColor: terracotta,
        alignment: Alignment.centerLeft,
      ),
      icon: const Icon(Icons.warning_amber_outlined, size: 18),
      label: Text(
        formatGameNumbers(message),
        key: ValueKey(key),
        style: const TextStyle(fontSize: 12, height: 1.6),
      ),
    ),
  );

  Widget _courtNotices() {
    final unread =
        s.outcomes.where((r) => !_readOutcomeIds.contains(r.id)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_outcomeReadReady && unread.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey('open-outcomes'),
              onPressed: () => _viewOutcomeReports(unread),
              icon: const Icon(Icons.assignment_turned_in_outlined, size: 18),
              label: Text(formatGameNumbers('Kết quả mới (${unread.length})')),
            ),
          ),
        if (s.stability <= 20)
          _courtAlert(
            'court-collapse-warning',
            'Ổn định triều đình ${s.stability}/100. Về 0 sẽ bị phế truất. Đến Quốc sự để ứng phó.',
            'kingdom',
          ),
        if (s.authority <= 20)
          _courtAlert(
            'authority-zero-warning',
            'Uy quyền ${s.authority}/100. Về 0 sẽ trở thành bù nhìn. Đến Quốc sự để ứng phó.',
            'kingdom',
          ),
        if (s.people <= 20)
          _courtAlert(
            'people-zero-warning',
            'Lòng dân ${s.people}/100. Về 0 sẽ bị lật đổ. Đến Quốc sự để ứng phó.',
            'kingdom',
          ),
        if (armyCondition(s) <= 20)
          _courtAlert(
            'army-zero-warning',
            s.population == null
                ? 'Quân lực ${s.army}/100. Về 0 sẽ mất ngôi hoặc mất nước. Đến Quốc sự để ứng phó.'
                : 'Quân đội có mức sẵn sàng thấp. Xem Quân sự để kiểm tra huấn luyện, trang bị và hậu cần.',
            'kingdom',
          ),
        if (s.health <= 20)
          _courtAlert(
            'health-zero-warning',
            'Sức khỏe ${s.health}/100. Về 0 sẽ băng hà. Đến Long thể để chăm sóc.',
            'health',
          )
        else if (s.fatigue > 55 || s.stress > 55 || s.indulgence > 5)
          _courtAlert(
            'court-health-warning',
            'Cần chăm sóc long thể. Đến Long thể để xem tình trạng và dưỡng sức.',
            'health',
          ),
        if (s.major != null)
          _courtAlert(
            'court-major-warning',
            'Đang ứng phó ${majorDefinition(s.major!.kind).title}. '
                '${s.major!.petitionDriven ? 'Ngự phê phương án tại Tấu chương.' : 'Đến Quốc sự để củng cố nguồn lực.'}',
            s.major!.petitionDriven ? 'court' : 'kingdom',
          ),
      ],
    );
  }

  Widget _courtDone() => Padding(
    key: const ValueKey('court-complete'),
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, color: forest, size: 32),
        const SizedBox(height: 14),
        Text(
          formatGameNumbers('Đã xử lý hết tấu chương ${s.periodName} này.'),
          style: const TextStyle(fontFamily: 'Lora', fontSize: 22),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            FilledButton(
              key: const ValueKey('court-to-kingdom'),
              onPressed: () => navigate('kingdom'),
              child: const Text('Đến Quốc sự'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _petitionHeading() => KeyedSubtree(
    key: const ValueKey('court-petition-header'),
    child: _section(
      s.seasonal ? 'Tấu chương mùa ${s.season}' : 'Tấu chương trong tuần',
      trailing: Tag(
        '${s.petitions.length} CHỜ',
        key: const ValueKey('court-petition-count'),
      ),
    ),
  );

  Widget _courtDesk() => LayoutBuilder(
    builder: (context, bounds) {
      final inline = bounds.maxWidth >= 700 && bounds.maxHeight >= 300;
      final petition =
          s.petitions.where((p) => p.id == selectedPetitionId).firstOrNull ??
          (approvedPetitionTitle == null ? s.petitions.firstOrNull : null);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CourtOverview(state: s, dense: bounds.maxHeight < 300),
          const SizedBox(height: 12),
          if (!inline) _petitionHeading(),
          Expanded(
            child:
                inline
                    ? Row(
                      key: const ValueKey('petition-desk'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: (bounds.maxWidth * .31).clamp(250.0, 350.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _petitionHeading(),
                              Expanded(
                                child: RoomPane(
                                  key: const ValueKey('court-petition-scroll'),
                                  padding: 0,
                                  child: _petitions(compact: true),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: paper,
                              border: Border.all(color: line),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: RoomPane(
                              padding: 22,
                              controller: courtReadingController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _courtNotices(),
                                  _courtReading(petition),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : RoomPane(
                      key: const ValueKey('court-petition-scroll'),
                      padding: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _courtNotices(),
                          if (s.petitions.isEmpty)
                            _courtDone()
                          else
                            _petitions(),
                        ],
                      ),
                    ),
          ),
        ],
      );
    },
  );

  Widget _courtReading(Petition? petition) => Column(
    key: const ValueKey('court-reading'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (s.petitions.isEmpty)
        _courtDone()
      else if (petition != null) ...[
        LayoutBuilder(
          builder:
              (context, bounds) => SizedBox(
                height: (bounds.maxWidth / 4.8).clamp(120.0, 130.0),
                width: double.infinity,
                child: PetitionPainting(
                  category: eventForState(s, petition.definitionId).category,
                ),
              ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(
              petitionCategoryIcon(
                eventForState(s, petition.definitionId).category,
              ),
              color: forest,
              size: 22,
            ),
            Text(
              formatGameNumbers(
                eventForState(s, petition.definitionId).category.toUpperCase(),
              ),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                color: forest,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              formatGameNumbers(
                petition.deadline <= s.week
                    ? 'Hạn: cuối ${s.periodName} này'
                    : 'Còn ${petition.deadline - s.week + 1} ${s.periodName}',
              ),
              style: const TextStyle(color: terracotta, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          formatGameNumbers(eventForState(s, petition.definitionId).title),
          style: const TextStyle(
            fontFamily: 'Lora',
            fontSize: 26,
            height: 1.35,
            color: forest,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          formatGameNumbers(s.authoredText(petitionText(petition, s))),
          style: const TextStyle(fontSize: 14, height: 1.7),
        ),
        if (!petitionDialogOpen) ...[
          const SizedBox(height: 10),
          const PetitionRule(),
          const SizedBox(height: 6),
          PetitionDecision(
            key: ValueKey('desk-decision-${petition.id}'),
            state: s,
            petition: petition,
            busy: busy,
            pickAssignee: _choosePetitionAssignee,
            onReadLater:
                () => setState(() {
                  selectedPetitionId = null;
                  approvedPetitionTitle = '';
                }),
            onConfirm:
                (index, assignee) =>
                    _approvePetition(petition, index, assignee),
          ),
        ],
      ] else if (approvedPetitionTitle?.isNotEmpty == true) ...[
        const SizedBox(height: 30),
        Center(
          child: const ApprovedMemorialSeal(key: ValueKey('approval-seal')),
        ),
        const SizedBox(height: 20),
        Text(
          formatGameNumbers(approvedPetitionTitle!),
          style: const TextStyle(fontFamily: 'Lora', fontSize: 20),
        ),
      ] else
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'Chọn một bản tấu để ngự lãm.',
            style: TextStyle(color: muted, fontSize: 15),
          ),
        ),
    ],
  );

  Widget _section(String title, {Widget? trailing}) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      children: [
        Expanded(
          child: Text(
            formatGameNumbers(title),
            style: const TextStyle(fontFamily: 'Lora', fontSize: 18),
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );

  Widget _outcomeSummary() {
    final latestWeek = s.outcomes.last.week;
    final latest = s.outcomes.where((r) => r.week == latestWeek).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatGameNumbers(
                'Cuối ${s.periodName} $latestWeek: ${latest.length} kết quả đã nhận',
              ),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              formatGameNumbers(
                latest
                    .map((r) => '${r.title}: ${r.statusLabel.toLowerCase()}')
                    .join(' · '),
              ),
              style: const TextStyle(fontSize: 11, color: muted),
            ),
            TextButton.icon(
              key: const ValueKey('open-outcomes'),
              onPressed: () => _viewOutcomeReports(latest),
              icon: const Icon(Icons.assignment_turned_in_outlined, size: 16),
              label: const Text('Xem kết quả'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _petitions({bool compact = false}) {
    final petitions = [...s.petitions]..sort((a, b) {
      int priority(Petition p) =>
          p.storyKind == 'major'
              ? 0
              : p.isStory
              ? 1
              : 2;
      final order = priority(a).compareTo(priority(b));
      return order != 0 ? order : a.deadline.compareTo(b.deadline);
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (petitions.isEmpty)
          const Text(
            'Không còn tấu chờ xử lý.',
            style: TextStyle(color: muted),
          ),
        for (final p in petitions)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PetitionDocument(
              key: ValueKey('petition-card-${p.id}'),
              readKey: ValueKey('read-petition-${p.id}'),
              title: eventForState(s, p.definitionId).title,
              category: eventForState(s, p.definitionId).category,
              deadline:
                  p.deadline <= s.week
                      ? 'Hạn: cuối ${s.periodName} này'
                      : 'Còn ${p.deadline - s.week + 1} ${s.periodName}',
              urgent:
                  p.deadline <= s.week ||
                  p.storyKind == 'major' ||
                  [
                    'Khủng hoảng',
                    'Âm mưu',
                  ].contains(eventForState(s, p.definitionId).category),
              selected:
                  compact &&
                  (selectedPetitionId == p.id ||
                      (selectedPetitionId == null &&
                          approvedPetitionTitle == null &&
                          s.petitions.firstOrNull?.id == p.id)),
              onOpen:
                  busy
                      ? null
                      : () {
                        if (compact) {
                          setState(() {
                            selectedPetitionId = p.id;
                            approvedPetitionTitle = null;
                          });
                          if (courtReadingController.hasClients) {
                            courtReadingController.jumpTo(0);
                          }
                        } else {
                          _petitionDialog(p);
                        }
                      },
            ),
          ),
      ],
    );
  }

  String _petitionExpiryText(Petition p) {
    final e = eventForState(s, p.definitionId);
    final arc = s.chains.where((a) => a.id == p.storyId).firstOrNull;
    if (arc != null && usesChainSettlement(arc)) {
      return '${e.title}\nDừng ở ${arc.completedSteps}/4 và quyết toán: ${chainSettlementRewardText(s, arc)}';
    }
    return '${e.title}\n${e.choices.last.label}: ${e.choices.last.hint}';
  }

  Future<void> _petitionDialog(Petition petition) async {
    setState(() => petitionDialogOpen = true);
    // Router refreshes may rebuild a closing dialog after its petition has
    // already settled. Keep the decision's original event until it unmounts.
    final decisionState = s;
    final choice = await showDialog<(int, String)>(
      context: context,
      builder:
          (dialogContext) => PetitionDecision(
            state: decisionState,
            petition: petition,
            inDialog: true,
            busy: busy,
            pickAssignee: _choosePetitionAssignee,
            onReadLater: () => Navigator.pop(dialogContext),
            onConfirm: (index, assignee) async {
              Navigator.pop(dialogContext, (index, assignee));
              return true;
            },
          ),
    );
    if (!mounted) return;
    setState(() => petitionDialogOpen = false);
    if (choice != null) await _approvePetition(petition, choice.$1, choice.$2);
  }

  Future<bool> _approvePetition(
    Petition petition,
    int index,
    String assignee,
  ) async {
    final title = eventForState(s, petition.definitionId).title;
    final ok = await act(
      'petition',
      target: petition.id,
      option: index < 0 ? 'abandon' : '$index',
      assigneeId: assignee,
    );
    if (ok && mounted) {
      setState(() {
        selectedPetitionId = null;
        approvedPetitionTitle = title;
      });
    }
    return ok;
  }

  Future<String?> _choosePetitionAssignee(
    EventDefinition e,
    EventChoice c,
  ) => showDialog<String>(
    context: context,
    builder:
        (context) => ImperialSimpleDialog(
          title: const Text('Chọn người xử lý tấu chương'),
          children: [
            ImperialDialogOption(
              key: const ValueKey('petition-unassigned'),
              onPressed: () => Navigator.pop(context, ''),
              child: Text(
                formatGameNumbers(
                  'Không giao ai xử lý · ${petitionBaseChance(c)}%',
                ),
              ),
            ),
            if (petitionAssignees(s, e, c).isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chưa có triều thần hoặc người trong hậu cung đủ điều kiện và đang rảnh.',
                ),
              ),
            for (final p in petitionAssignees(s, e, c))
              ImperialDialogOption(
                key: ValueKey('petition-person-${p.id}'),
                leading: CharacterPortrait(person: p, width: 42, height: 56),
                onPressed: () => Navigator.pop(context, p.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatGameNumbers('${p.name} · ${p.displayRole}')),
                      Text(
                        formatGameNumbers(
                          '${p.specialty} · ${p.isConsort ? 'thiện cảm ${p.affection}' : 'năng lực ${p.abilityLabel}'} · mệt ${p.strain} · bất mãn ${p.discontent}\n${petitionChance(s, e, c, p)}% thành công',
                        ),
                        style: const TextStyle(fontSize: 11, color: muted),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
  );

  IconData _actionIcon(String key) => switch (key) {
    'court' => Icons.account_balance_outlined,
    'people' => Icons.volunteer_activism_outlined,
    'army' => Icons.shield_outlined,
    'levee' => Icons.water_outlined,
    'grain' => Icons.grass_outlined,
    'health' => Icons.spa_outlined,
    'revel' => Icons.music_note_outlined,
    'security' => Icons.security_outlined,
    'treasury' => Icons.savings_outlined,
    _ => Icons.public_outlined,
  };

  String _actionDescription(ActionDefinition a) => s.authoredText(
    authoredMoneyText(
      s,
      populationActionDescription(s, a.id) ??
          (a.id == 'treat'
              ? treatmentActionDescription(
                s,
                baseCost: money(s, a.cost),
                cost: actionCost(s, a),
              )
              : null) ??
          revenueTaskBlocked(s, a.id) ??
          (a.id == 'security' ? securityBlocked(s) : null) ??
          careActionDescription(s, a.id) ??
          seasonalActionDescription(s, a.id) ??
          a.description,
    ),
  );

  String? _actionBlocked(ActionDefinition a) {
    if (busy) return 'Đang xử lý lệnh trước.';
    if (populationActionNames.containsKey(a.id)) {
      return populationActionBlocked(s, a.id);
    }
    if (s.points < 1) return 'Cần 1 hành động.';
    if (s.treasury < actionCost(s, a)) return 'Không đủ ngân khố.';
    if (s.grain < actionGrainCost(s, a)) return 'Không đủ lương thực.';
    if (a.id == 'buy_grain' && s.grain >= foodCapacity(s)) {
      return 'Kho lương đã đầy.';
    }
    if (developmentTasks.contains(a.id)) {
      final reason = developmentBlocked(s, a.id);
      if (reason != null) return reason;
      if (taskOfficers(s, a.id).isEmpty) {
        return 'Cần quan rảnh chuyên môn ${developmentSpecialties[a.id]}, '
            'năng lực ≥${developmentRequiredAbility(developmentTarget(s, a.id))}.';
      }
    }
    if (a.id == 'maintain_levee') {
      if (s.levee >= 100) return 'Đê đang ở tình trạng tốt nhất.';
      if ((s.actionCounts[a.id] ?? 0) > 0) {
        return 'Đã bảo dưỡng đê trong kỳ này.';
      }
    }
    final reason =
        revenueTaskBlocked(s, a.id) ??
        (a.id == 'security' ? securityBlocked(s) : null);
    if (reason != null) return reason;
    if (a.id == 'mediate' && (s.actionCounts[a.id] ?? 0) > 0) {
      return 'Đã hòa giải các phe trong ${s.periodName} này.';
    }
    return null;
  }

  Widget _actionRow(ActionDefinition a) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: parchment,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_actionIcon(a.icon), size: 19, color: forest),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatGameNumbers(a.title),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              Text(
                formatGameNumbers(_actionDescription(a)),
                style: const TextStyle(fontSize: 11, color: muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          key: ValueKey('action-${a.id}'),
          tooltip: formatGameNumbers(a.title),
          onPressed: _actionBlocked(a) == null ? () => _performAction(a) : null,
          icon: const Icon(Icons.arrow_outward, size: 18),
          color: forest,
        ),
      ],
    ),
  );

  EdgeInsets _personnelDialogInsets(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return EdgeInsets.symmetric(
      horizontal: width > 760 ? (width - 680) / 2 : 24,
      vertical: 24,
    );
  }

  Future<void> _performAction(ActionDefinition a) async {
    if (populationActionNames.containsKey(a.id)) {
      final yes = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => ImperialAlertDialog(
              title: Text(formatGameNumbers(a.title)),
              content: Text(formatGameNumbers(populationActionHint(s, a.id))),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Ban lệnh'),
                ),
              ],
            ),
      );
      if (yes == true) await act('population', target: a.id);
      return;
    }
    String officer = '';
    if (taskSpecialties.containsKey(a.id)) {
      final result = await showDialog<String>(
        context: context,
        builder:
            (context) => ImperialSimpleDialog(
              insetPadding: _personnelDialogInsets(context),
              title: Text(
                formatGameNumbers(
                  'Giao ai phụ trách ${a.title.toLowerCase()}?',
                ),
                style: TextStyle(fontFamily: 'Lora'),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Surface(
                    padding: 14,
                    child: Text(
                      formatGameNumbers(
                        '${_actionDescription(a)}\n\nCần chuyên môn ${taskSpecialties[a.id]}. Ước tính dựa trên năng lực, chuyên môn, mệt mỏi, quan hệ và tính cách đã biết. Phẩm chất chưa rõ có thể đổi kết quả; thành công không được bảo đảm. Người đang làm công việc dài hạn không có trong danh sách. ${taskFailureHint(a.id, s)}',
                      ),
                      style: const TextStyle(fontSize: 12, height: 1.7),
                    ),
                  ),
                ),
                ...taskOfficers(s, a.id).map(
                  (c) => ImperialDialogOption(
                    key: ValueKey('assign-${a.id}-${c.id}'),
                    leading: CharacterPortrait(
                      person: c,
                      width: 42,
                      height: 56,
                    ),
                    onPressed: () => Navigator.pop(context, c.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatGameNumbers('${c.name} · ${c.displayRole}'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            formatGameNumbers(
                              'Năng lực ${c.abilityLabel} · ${c.specialty} · mệt ${c.strain}/100\n${personalityWorkHint(s, c)}',
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            formatGameNumbers(
                              '${fitLabel(TaskAssessment.preview(a.id, c, s).fit)} · ước tính thành công ${actionSuccessChance(s, a.id, c)}% · ${actionRewardDescription(s, a.id, c)}',
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  TaskAssessment.preview(a.id, c, s).fit == 20
                                      ? terracotta
                                      : forest,
                            ),
                          ),
                          if (revenueTasks.contains(a.id)) ...[
                            const SizedBox(height: 5),
                            Text(
                              formatGameNumbers(
                                revenueRewardPreview(a.id, c, s),
                              ),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (taskOfficers(s, a.id).isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Chưa có quan rảnh đáp ứng chuyên môn và năng lực yêu cầu.',
                    ),
                  ),
              ],
            ),
      );
      if (result == null || !mounted) return;
      officer = result;
      final person = s.court.firstWhere((c) => c.id == result);
      final yes = await showDialog<bool>(
        context: context,
        builder:
            (context) => ImperialAlertDialog(
              insetPadding: _personnelDialogInsets(context),
              title: Text(
                formatGameNumbers('Giao việc cho ${person.name}'),
                style: const TextStyle(fontFamily: 'Lora'),
              ),
              content: SingleChildScrollView(
                child: Text(
                  formatGameNumbers(
                    developmentTasks.contains(a.id)
                        ? '${a.title}\n${_actionDescription(a)}\n\n'
                            'Chuyên môn ${person.specialty} · năng lực ${person.abilityLabel}\n'
                            'Đúng chuyên môn · ước tính thành công ${actionSuccessChance(s, a.id, person)}%\n\n'
                            'Tốn 1 hành động. Thành công tăng đúng 1 cấp.\n'
                            '${personalityWorkHint(s, person)}'
                        : '${a.title}\nChuyên môn ${person.specialty} · năng lực ${person.abilityLabel}\n${fitLabel(TaskAssessment.preview(a.id, person, s).fit)} · ước tính thành công ${actionSuccessChance(s, a.id, person)}%\n\nChi ${actionCost(s, a)} ${moneyUnit(s)}${actionGrainCost(s, a) > 0 ? ' và ${whole(actionGrainCost(s, a))} ${foodUnit(s)}' : ''}, 1 hành động. ${actionRewardDescription(s, a.id, person)}\n${personalityWorkHint(s, person)}\n\n${revenueTasks.contains(a.id) ? '${revenueRewardPreview(a.id, person, s)}\n\n' : ''}${taskFailureHint(a.id, s)} Kinh phí không hoàn lại khi thất bại.',
                  ),
                  style: const TextStyle(height: 1.8),
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: forest),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cân nhắc lại'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Xác nhận giao việc'),
                ),
              ],
            ),
      );
      if (yes != true) return;
    }
    await act('action', target: a.id, option: officer);
  }

  Widget _kingdom() => KingdomPanel(
    state: s,
    busy: busy,
    readState: () => s,
    isBusy: () => busy,
    actions:
        actions
            .where(
              (a) =>
                  (s.population != null || a.icon != 'population') &&
                  ![
                    'rest',
                    'revel',
                    'treat',
                    'buy_grain',
                    'repair',
                    'maintain_levee',
                    ...developmentTasks,
                    ...revenueTasks,
                  ].contains(a.id),
            )
            .toList(),
    onAction: _performAction,
    blockedReason: _actionBlocked,
    send: (type, target, option) async {
      await act(type, target: target, option: option);
    },
  );

  Widget _treasury() => TreasuryPanel(
    state: s,
    section: treasurySection,
    onSectionChanged: (value) => setState(() => treasurySection = value),
    busy: busy,
    onAction: _performAction,
    blockedReason: _actionBlocked,
    onPolicy: (type, option) async {
      if (type == 'production') {
        await act('population', target: 'production', option: option);
      } else {
        await act(type, option: option);
      }
    },
  );

  Widget _people(bool harem) {
    if (!harem && s.hasCourtSystem) {
      if (courtGovernmentOpen) {
        return CourtGovernmentPanel(
          state: s,
          busy: busy,
          onPerson: _openCharacterMeeting,
          onAppoint:
              (office) => chooseCourtAppointment(
                context,
                s,
                office,
                (type, target, option) =>
                    act(type, target: target, option: option),
              ),
          onDismiss:
              (office) => confirmCourtDismissal(
                context,
                s,
                office,
                (type, target, option) =>
                    act(type, target: target, option: option),
              ),
        );
      }
      return CourtRosterPanel(
        state: s,
        busy: busy,
        onPerson: _openCharacterMeeting,
        onOffice:
            (office) => chooseCourtAppointment(
              context,
              s,
              office,
              (type, target, option) =>
                  act(type, target: target, option: option),
            ),
        onGovernment: () => navigate('people-government'),
      );
    }
    if (harem && s.seasonal && palaceManagementOpen) {
      return HaremQuestPanel(
        state: s,
        busy: busy,
        personId: selectedConsortId,
        onPerson: _openCharacterMeeting,
        onOffice:
            (office) => chooseCourtAppointment(
              context,
              s,
              office,
              (type, target, option) =>
                  act(type, target: target, option: option),
            ),
        onSend:
            (personId, option) =>
                act('harem-quest', target: personId, option: option),
      );
    }

    final all =
        s.court.where((c) => c.available && c.isConsort == harem).toList();
    final category = harem ? haremCategory : courtCategory;
    final faction = harem ? haremFaction : courtFaction;
    final availability = harem ? haremAvailability : courtAvailability;
    final query = harem ? '' : courtSearch.text.trim().toLowerCase();
    final listView = !harem && courtListView;
    final categories = [
      'Tất cả',
      if (harem) ...[
        'Hoàng hậu',
        'Phi tần',
        'Tú nữ',
      ] else
        ...officialCategories,
    ];
    final people =
        all
            .where(
              (c) =>
                  (category == 'Tất cả' || c.category == category) &&
                  (faction == 'Tất cả' || c.faction == faction) &&
                  (availability == 'Tất cả' ||
                      officerBusy(s, c.id) == (availability == 'Đang bận')) &&
                  '${c.name} ${c.displayRole} ${c.faction}'
                      .toLowerCase()
                      .contains(query),
            )
            .toList();
    final chosenId = harem ? selectedConsortId : selectedOfficialId;
    final chosen =
        chosenId == null
            ? people.firstOrNull
            : people.where((c) => c.id == chosenId).firstOrNull;
    final filters = Surface(
      padding: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in categories)
                      ChoiceChip(
                        key: ValueKey('catalog-$harem-$item'),
                        label: Text(
                          formatGameNumbers(
                            '$item (${item == 'Tất cả' ? all.length : all.where((c) => c.category == item).length})',
                          ),
                          style: const TextStyle(fontSize: 11),
                        ),
                        selected: category == item,
                        onSelected:
                            (_) => setState(() {
                              if (harem) {
                                haremCategory = item;
                              } else {
                                courtCategory = item;
                              }
                            }),
                      ),
                  ],
                ),
              ),
              if (!harem) ...[
                IconButton(
                  key: ValueKey('roster-cards-$harem'),
                  tooltip: 'Xem thẻ chân dung',
                  onPressed: () => setState(() => courtListView = false),
                  icon: Icon(
                    Icons.grid_view_outlined,
                    color: listView ? muted : forest,
                  ),
                ),
                IconButton(
                  key: ValueKey('roster-list-$harem'),
                  tooltip: 'Xem danh sách so sánh',
                  onPressed: () => setState(() => courtListView = true),
                  icon: Icon(
                    Icons.view_list_outlined,
                    color: listView ? forest : muted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder:
                (context, box) => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (!harem)
                      SizedBox(
                        width:
                            box.maxWidth > 620
                                ? box.maxWidth - 340
                                : box.maxWidth,
                        child: TextField(
                          key: ValueKey('people-search-$harem'),
                          controller: courtSearch,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            isDense: true,
                            prefixIcon: Icon(Icons.search, size: 20),
                            hintText: 'Tìm tên, chức vụ hoặc phe…',
                          ),
                        ),
                      ),
                    SizedBox(
                      width: box.maxWidth > 620 ? 166 : (box.maxWidth - 10) / 2,
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('faction-filter-$harem'),
                        value: faction,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Phe phái',
                        ),
                        items:
                            ['Tất cả', ...factionOpponents.keys]
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(
                                      formatGameNumbers(
                                        f == 'Tất cả' ? 'Tất cả các phe' : f,
                                      ),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() {
                              if (harem) {
                                haremFaction = value!;
                              } else {
                                courtFaction = value!;
                              }
                            }),
                      ),
                    ),
                    SizedBox(
                      width: box.maxWidth > 620 ? 154 : (box.maxWidth - 10) / 2,
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('availability-filter-$harem'),
                        value: availability,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Công việc',
                        ),
                        items:
                            ['Tất cả', 'Đang rảnh', 'Đang bận']
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(
                                      formatGameNumbers(f),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() {
                              if (harem) {
                                haremAvailability = value!;
                              } else {
                                courtAvailability = value!;
                              }
                            }),
                      ),
                    ),
                  ],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            formatGameNumbers('Đang xem ${people.length}/${all.length} người'),
            style: const TextStyle(fontSize: 11, color: muted),
          ),
        ],
      ),
    );
    final roster = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        filters,
        const SizedBox(height: 8),
        if (people.isEmpty)
          Surface(
            child: Text(
              formatGameNumbers(
                harem
                    ? 'Không có nhân vật phù hợp. Hãy đổi phân loại, phe hoặc công việc.'
                    : 'Không có nhân vật phù hợp. Hãy đổi phân loại, phe hoặc từ tìm kiếm.',
              ),
              style: TextStyle(color: muted),
            ),
          ),
        if (listView)
          ...people.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _characterListRow(c, harem),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, box) {
              final columns =
                  harem
                      ? (box.maxWidth / 260).floor().clamp(1, 5)
                      : box.maxWidth > 540
                      ? 3
                      : box.maxWidth > 420
                      ? 2
                      : 1;
              return EqualHeightGrid(
                columns: columns,
                children: [
                  for (final c in people)
                    SizedBox(
                      width: (box.maxWidth - (columns - 1) * 14) / columns,
                      child: _characterCard(c, harem),
                    ),
                ],
              );
            },
          ),
      ],
    );
    final details = harem ? null : _characterProfile(chosen, false);
    return LayoutBuilder(
      builder: (context, box) {
        final heading = Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                formatGameNumbers(
                  harem
                      ? 'Hậu cung ${haremResidentCount(s)}/$haremLimit'
                      : 'Triều thần',
                ),
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 27,
                  color: ink,
                ),
              ),
              if (harem && s.seasonal)
                OutlinedButton.icon(
                  key: const ValueKey('open-palace-management'),
                  onPressed: () => _showPalaceManagement(true),
                  icon: const Icon(Icons.auto_stories_outlined, size: 17),
                  label: const Text('Câu chuyện & passive'),
                ),
            ],
          ),
        );
        if (harem) {
          return RoomPane(child: Column(children: [heading, roster]));
        }
        if (box.maxWidth < 760) {
          return RoomPane(child: Column(children: [heading, roster, details!]));
        }
        return Column(
          children: [
            heading,
            const Divider(height: 1, color: gold),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 7,
                    child: RoomPane(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!harem) ...[
                            Wrap(
                              spacing: 7,
                              runSpacing: 6,
                              children: [
                                for (final entry in s.factions.entries)
                                  Tag(
                                    '${entry.key.toUpperCase()}  ${entry.value}',
                                    color:
                                        entry.value < 35 ? terracotta : forest,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          roster,
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: gold),
                  Expanded(flex: 5, child: RoomPane(child: details!)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _characterListRow(Courtier c, bool harem) => Surface(
    padding: 14,
    selected: (harem ? selectedConsortId : selectedOfficialId) == c.id,
    child: Row(
      children: [
        CharacterPortrait(person: c, width: 56, height: 56),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatGameNumbers(c.name),
                style: const TextStyle(fontFamily: 'Lora', fontSize: 17),
              ),
              Text(
                formatGameNumbers('${c.displayRole} · ${c.faction}'),
                style: const TextStyle(fontSize: 11, color: gold),
              ),
              Text(
                formatGameNumbers(
                  '${c.specialty} · ${c.isConsort ? 'thiện cảm ${c.affection}' : 'năng lực ${c.abilityLabel} · thiện cảm ${c.affection}'}',
                ),
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                formatGameNumbers(
                  officerBusy(s, c.id)
                      ? 'Đang bận'
                      : c.isConsort && !c.inHarem
                      ? 'Chưa nhập cung'
                      : 'Đang rảnh',
                ),
                style: const TextStyle(fontSize: 10, color: muted),
              ),
            ],
          ),
        ),
        IconButton(
          key: ValueKey('list-profile-${c.id}'),
          tooltip: formatGameNumbers('Xem hồ sơ ${c.name}'),
          icon: const Icon(Icons.chevron_right),
          onPressed:
              () => setState(() {
                if (harem) {
                  selectedConsortId = c.id;
                } else {
                  selectedOfficialId = c.id;
                }
              }),
        ),
      ],
    ),
  );

  void _showPalaceManagement(bool open) {
    navigate(open ? 'harem-management' : 'harem');
  }

  Widget _characterProfile(Courtier? c, bool harem) {
    if (c == null || personDialogOpen) {
      return Surface(
        key: ValueKey('character-profile-$harem'),
        padding: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Text(
                'Chọn một chân dung để xem hồ sơ và các hành động.',
                style: TextStyle(fontFamily: 'Lora', fontSize: 21),
              ),
            ),
          ],
        ),
      );
    }
    final information = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatGameNumbers('${c.name} · ${c.displayRole}'),
          style: const TextStyle(fontFamily: 'Lora', fontSize: 25, height: 1.3),
        ),
        const SizedBox(height: 8),
        Text(
          formatGameNumbers('${c.faction} · ${c.age} tuổi'),
          style: const TextStyle(fontSize: 12, color: gold),
        ),
        const Divider(height: 24, color: gold),
        LayoutBuilder(
          builder:
              (context, bounds) => Row(
                children: [
                  CharacterPortrait(
                    person: c,
                    width: bounds.maxWidth >= 420 ? 112 : 76,
                    height: bounds.maxWidth >= 420 ? 144 : 98,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!c.isConsort)
                          Text(
                            formatGameNumbers('Năng lực ${c.abilityLabel}'),
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 20,
                            ),
                          ),
                        Text(
                          formatGameNumbers('Chuyên môn: ${c.specialty}'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          formatGameNumbers(
                            officerBusy(s, c.id)
                                ? 'Đang bận'
                                : c.isConsort && !c.inHarem
                                ? 'Chưa nhập cung'
                                : 'Đang rảnh',
                          ),
                          style: const TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        ),
        const SizedBox(height: 16),
        _smallMeter('Thiện cảm', c.affection),
        const SizedBox(height: 12),
        if (!c.isConsort) _smallMeter('Năng lực', c.ability),
        const SizedBox(height: 12),
        KeyedSubtree(
          key: ValueKey('plot-${c.id}'),
          child: _smallMeter(
            'Âm mưu',
            c.lastInvestigation?.plot,
            inverse: true,
          ),
        ),
        const SizedBox(height: 12),
        KeyedSubtree(
          key: ValueKey('discontent-${c.id}'),
          child: _smallMeter(
            'Bất mãn',
            c.lastInvestigation?.discontent,
            inverse: true,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          formatGameNumbers(
            c.lastInvestigation == null
                ? 'Chưa điều tra · Điều tra kín để biết âm mưu và bất mãn.'
                : 'Ghi nhận ${s.date(c.lastInvestigation!.week)} · Chỉ cập nhật khi điều tra tiếp theo hoàn tất.',
          ),
          style: const TextStyle(fontSize: 10, color: muted),
        ),
        const SizedBox(height: 12),
        Text(
          formatGameNumbers(c.qualitiesText),
          key: ValueKey('qualities-${c.id}'),
          style: TextStyle(
            fontSize: 11,
            color: c.investigated ? forest : muted,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          formatGameNumbers(
            'Đã biết: ${c.knownPersonalityText}\n${c.personalityProgress}',
          ),
          style: const TextStyle(fontSize: 11, color: muted),
        ),
        if (harem && s.seasonal) ...[
          const SizedBox(height: 10),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text(
              'Đóng góp & điều kiện',
              style: TextStyle(fontSize: 11),
            ),
            children: [
              Text(
                formatGameNumbers(
                  authoredMoneyText(s, haremPassivePreview(c, state: s)),
                ),
                key: ValueKey('harem-passive-${c.id}'),
                style: const TextStyle(fontSize: 11, color: forest),
              ),
            ],
          ),
        ],
      ],
    );
    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Hành động',
          style: TextStyle(fontFamily: 'Lora', fontSize: 20),
        ),
        const SizedBox(height: 12),
        for (final option in _personOptions(c))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              key: ValueKey('profile-action-${c.id}-${option.$1}'),
              onPressed:
                  busy ||
                          s.points < 1 ||
                          s.treasury < option.$4 ||
                          _courtOptionBlocked(c, option.$1) != null
                      ? null
                      : () => _handlePersonOption(c, option.$1),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatGameNumbers(option.$2),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatGameNumbers(option.$3),
                    style: const TextStyle(fontSize: 10, color: muted),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
    return Surface(
      key: ValueKey('character-profile-$harem'),
      padding: 10,
      child: LayoutBuilder(
        builder: (context, bounds) {
          if (bounds.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                information,
                const Divider(height: 24, color: gold),
                actions,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: information),
              const SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: gold)),
                  ),
                  child: actions,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _characterCard(Courtier c, bool harem) {
    final selected = !harem && selectedOfficialId == c.id;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: ValueKey('select-person-${c.id}'),
        borderRadius: BorderRadius.circular(12),
        onTap:
            busy
                ? null
                : () {
                  if (!harem) setState(() => selectedOfficialId = c.id);
                  _openCharacterMeeting(c);
                },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:
                    selected
                        ? const Color(0x80D8A13F)
                        : const Color(0x283E210B),
                blurRadius: selected ? 14 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ImperialSkin(
            edge: 24,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: RosterCardBody(
                action: OutlinedButton(
                  key: ValueKey('meet-person-${c.id}'),
                  onPressed: busy ? null : () => _openCharacterMeeting(c),
                  child: Text(
                    formatGameNumbers(harem ? 'Gặp gỡ' : 'Triệu kiến'),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                children: [
                  LayoutBuilder(
                    builder:
                        (context, bounds) => CharacterPortrait(
                          person: c,
                          width: bounds.maxWidth,
                          height: bounds.maxWidth,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Tag(
                    key: ValueKey('roster-status-${c.id}'),
                    c.isConsort && !c.inHarem
                        ? 'CHƯA NHẬP CUNG'
                        : officerBusy(s, c.id)
                        ? 'ĐANG BẬN'
                        : 'ĐANG RẢNH',
                    color: officerBusy(s, c.id) ? terracotta : forest,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formatGameNumbers(c.name),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (harem) ...[
                    Center(
                      child: HaremRankBadge(
                        c.category,
                        key: ValueKey('harem-rank-${c.id}'),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    formatGameNumbers(
                      harem
                          ? '${c.age} tuổi'
                          : '${c.displayRole} · ${c.age} tuổi',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: gold),
                  ),
                  const SizedBox(height: 8),
                  if (harem) ...[
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          formatGameNumbers('Thiện cảm ${c.affection}'),
                          key: ValueKey('harem-affection-${c.id}'),
                          style: const TextStyle(fontSize: 11, color: forest),
                        ),
                        if (!c.isConsort)
                          Text(
                            formatGameNumbers('Năng lực ${c.abilityLabel}'),
                            key: ValueKey('harem-ability-${c.id}'),
                            style: const TextStyle(fontSize: 11, color: forest),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (harem && s.seasonal) ...[
                    PersonnelPassives(person: c, state: s),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCharacterMeeting(Courtier person) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final section = person.isConsort ? 'harem' : 'people';
    final from = widget.location.uri.toString();
    context.go(
      GameLocation(
        section,
        characterId: person.publicId!,
        returnTo: from == GameLocation.pathFor(section) ? null : from,
      ).uri.toString(),
    );
  }

  void _closeCharacterMeeting() {
    final location = widget.location;
    if (location.characterId == null) return;
    final router = GoRouter.of(context);
    if (location.returnTo == null && router.canPop()) {
      router.pop();
    } else {
      router.go(location.backPath);
    }
  }

  Widget _characterMeeting(Courtier current) {
    void closeIfDeparted() {
      if (mounted &&
          ![
            ...s.court,
            ...s.officialsPool,
          ].any((c) => c.id == current.id && c.available)) {
        _closeCharacterMeeting();
      }
    }

    final backLabel = hudTitleFor(
      s,
      GameLocation.sectionFor(widget.location.backPath) ??
          widget.location.section,
    );
    return CharacterMeetingPage(
      backLabel: backLabel,
      scene: meetingSceneFor(current, state: s),
      onBack: _closeCharacterMeeting,
      header: WebGameHud(
        state: s,
        section: current.isConsort ? 'harem' : 'people',
        title: 'Tiếp kiến',
        onNavigate: navigate,
        onBack: _closeCharacterMeeting,
        backKey: const ValueKey('meeting-back'),
        backLabel: backLabel,
      ),
      actions: _meetingActions(current),
      profileLabel: s.hasCourtSystem ? 'Thăng phẩm' : 'Hồ sơ & chức vụ',
      profileDescription:
          s.hasCourtSystem ? 'Chọn phẩm vị để xem điều kiện và chi phí.' : null,
      profileButtonKey: ValueKey(
        !current.isConsort && s.hasCourtSystem
            ? 'meeting-promotion'
            : 'meeting-profile',
      ),
      profileIcon:
          !current.isConsort && s.hasCourtSystem
              ? Icons.upgrade
              : Icons.badge_outlined,
      onProfile:
          current.isConsort
              ? null
              : () async {
                if (!current.isConsort && s.hasCourtSystem) {
                  await chooseCourtPromotion(
                    context,
                    s,
                    current,
                    (type, target, option) =>
                        act(type, target: target, option: option),
                    changes: controller,
                    currentState: () => s,
                  );
                } else {
                  await _personDialog(current);
                  closeIfDeparted();
                }
              },
      busy: busy,
      onAction: (option) async {
        if (option == 'investigate' && s.hasCourtSystem) {
          final result = await chooseCovertInvestigation(
            context,
            targetId: current.id,
            changes: controller,
            currentState: () => s,
            send:
                (type, target, option) => act(
                  type,
                  target: target,
                  option: option,
                  showSnackBar: false,
                ),
          );
          return result == null
              ? null
              : result
              ? s.journal.first.title
              : controller.error;
        }
        if (option == 'convict' || option.startsWith('demote-court:')) {
          final convicted = option == 'convict';
          final ok = await act(
            convicted ? 'convict' : 'demote-court',
            target: current.id,
            option: convicted ? '' : option.split(':').last,
            showSnackBar: false,
          );
          if (ok && convicted) {
            closeIfDeparted();
            return null;
          }
          return ok ? s.journal.first.title : controller.error;
        }
        if (option == 'harem-quest') {
          selectedConsortId = current.id;
          navigate('harem-management');
          return null;
        }
        if (option == 'cut-office') {
          final office = courtOfficeFor(s, current.id);
          if (office == null) {
            return 'Nhân vật không còn giữ chức vụ.';
          }
          final ok = await act(
            'dismiss-office',
            target: office.id,
            showSnackBar: false,
          );
          return ok
              ? s.journal.first.title
              : controller.error ?? 'Chưa thực hiện được.';
        }
        final ok = await act(
          'courtier',
          target: current.id,
          option: option,
          showSnackBar: false,
        );
        if (ok && option == 'expel') {
          closeIfDeparted();
          return null;
        }
        return ok
            ? s.journal.first.title
            : s.calendarText(controller.error ?? 'Chưa thực hiện được.');
      },
    );
  }

  List<MeetingAction> _meetingActions(Courtier person) {
    final options = {
      for (final option in _personOptions(person)) option.$1: option,
      'expel': ('expel', 'Trục xuất', '', 0),
      'demote': ('demote', 'Giáng chức', '', 0),
    };
    return [
      'audience',
      'reward',
      'investigate',
      if (person.isConsort) ...[
        'invite',
        'expel',
        'demote',
        if (person.inHarem && !person.queen) 'queen',
        if (person.inHarem && s.seasonal) 'harem-quest',
        if (person.inHarem) 'visit',
      ],
      if (!person.isConsort && s.hasCourtSystem) ...[
        'demote-court',
        'cut-office',
      ],
      if (s.hasCourtSystem) 'convict',
    ].map((id) {
      if (id == 'reward') return _rewardMeetingAction(person);
      if (id == 'investigate' && s.hasCourtSystem) {
        return _covertMeetingAction(person);
      }
      if (id == 'demote-court') return _demotionMeetingAction(person);
      if (id == 'convict') return _convictionMeetingAction(person);
      if (id == 'cut-office') return _courtRetirementAction(person);
      if (id == 'harem-quest') {
        return const MeetingAction(
          id: 'harem-quest',
          label: 'Câu chuyện & passive',
          description:
              'Xem tuyến nhiệm vụ, chi phí, mục tiêu và đóng góp thực nhận.',
          costLabel: 'Xem không tốn hành động',
          requiresConfirmation: false,
        );
      }
      final option =
          options[id] ??
          (
            'invite',
            'Tuyển vào hậu cung',
            'Nhân vật đã nhập cung.',
            money(s, 35),
          );
      final disabledReason =
          !person.available
              ? 'Nhân vật không còn hiện diện.'
              : s.ended
              ? 'Triều đại đã kết thúc.'
              : id == 'invite' && haremAdmissionBlocked(s) != null
              ? haremAdmissionBlocked(s)
              : id == 'invite' && person.inHarem
              ? 'Đã nhập cung'
              : ['invite', 'queen'].contains(id) &&
                  haremPromotionBlocked(s, person) != null
              ? haremPromotionBlocked(s, person)
              : ['expel', 'demote'].contains(id) &&
                  haremDisciplineBlocked(person, expel: id == 'expel') != null
              ? haremDisciplineBlocked(person, expel: id == 'expel')
              : id == 'investigate' &&
                  s.pending.any(
                    (p) => p.kind == 'investigate' && p.target == person.id,
                  )
              ? 'Đang điều tra'
              : s.points < 1
              ? 'Hết hành động'
              : s.treasury < option.$4
              ? 'Không đủ ngân khố'
              : null;
      final losses = haremDemotionLosses(person);
      final (description, benefit, consequence) = switch (id) {
        'expel' => (
          'Trục xuất Tú nữ ${person.name} khỏi danh sách.',
          'Nhân vật rời danh sách đang hiện diện; lịch sử và Sử ký vẫn giữ.',
          'Không thể tuyển lại nhân vật này. Thái độ phe ${person.faction} −$haremExpulsionFactionLoss; ${haremStabilityEffectText(haremExpulsionStabilityLoss)}. Không giảm chi sinh hoạt vì Tú nữ chưa phát sinh khoản này.',
        ),
        'demote' => (
          'Giáng ${person.name} từ ${person.displayRole} xuống ${person.queen ? 'Phi tần' : 'Tú nữ'}.',
          person.queen
              ? 'Bãi ngôi Hoàng hậu; nhân vật vẫn ở hậu cung với chức Phi tần.'
              : 'Ngừng đóng góp hậu cung; giảm chi sinh hoạt ${money(s, s.seasonal ? 6 : 2)} ${moneyUnit(s)}/${s.periodName} từ kỳ thu chi tiếp theo.',
          '${haremDemotionAffectionText(person)}, bất mãn +${losses.discontent}; thái độ phe ${person.faction} −${losses.faction}; ${haremStabilityEffectText(losses.stability)}. '
              '${person.queen ? 'Mất lợi ích bổ sung của Hoàng hậu; ngôi hậu để trống, chi sinh hoạt giữ nguyên.' : 'Không hoàn phí nhập cung.'} '
              'Chỉ tuyển hoặc sắc phong lại từ ${s.date(s.week + 1)}.',
        ),
        'queen' => (
          'Sắc phong ${person.name} làm Hoàng hậu.',
          'Thiện cảm tăng tối đa 18, bất mãn giảm tối đa 18, ảnh hưởng +12; ổn định +3.${s.seasonal ? '\n${authoredMoneyText(s, haremPassivePreview(person, asQueen: true, state: s))}' : ''}',
          'Phe ${person.faction} +8, phe đối lập −9; người phe đối lập giảm 4 thiện cảm và tăng 4 bất mãn. '
              '${s.court.any((c) => c.queen && c.available && c.id != person.id) ? 'Hoàng hậu hiện tại trở thành Phi tần: thiện cảm −25 (người đã đạt 100 vẫn giữ 100), bất mãn +25; ổn định −10.' : 'Ngôi hậu hiện đang trống.'}',
        ),
        'visit' => (
          'Cùng ${person.name} dạo Ngự uyển.',
          'Thiện cảm cơ bản +7 và giảm bất mãn theo mức thực nhận; tùy tính cách, thiện cảm hiện tại và số lần lặp trong mùa.',
          'Phe ${person.faction} +1, phe đối lập −2; người phe đối lập giảm 2 thiện cảm, tăng 2 bất mãn. Những người khác đã nhập cung giảm thêm 2 thiện cảm và tăng 2 bất mãn. Tính thêm 1 lần hưởng lạc trong ${s.periodName}.',
        ),
        'audience' => (
          'Dành thời gian trò chuyện và lắng nghe ${person.name}.',
          'Thiện cảm cơ bản +6, giảm bất mãn theo mức tăng thực tế. Mỗi 3 lần tiếp kiến mở thêm 1 tính cách.',
          'Hiệu quả tùy tính cách, giảm khi lặp lại hoặc quan hệ đã cao. Phe đối lập giảm 3 thái độ; mỗi người trong phe giảm 2 thiện cảm, tăng 2 bất mãn. Căng thẳng +2.',
        ),
        'investigate' => (
          'Cử mật thám âm thầm điều tra ${person.name}.',
          'Nhận tiến độ âm mưu và mức bất mãn khi điều tra kết thúc; số liệu được chốt tại thời điểm bắt đầu.',
          'Hai chỉ số giữ kết quả lần trước trong lúc chờ, chỉ cập nhật khi điều tra hoàn tất. Báo cáo xác minh phẩm chất về cuối ${s.date(s.week + investigationDuration(s) - 1)}; không bảo đảm thành công${s.seasonal ? ', thành công giảm 6 tiến độ âm mưu' : ''}.',
        ),
        _ => (
          'Đón ${person.name} vào hậu cung.',
          'Thiện cảm +8, bất mãn −8.${s.seasonal ? '\n\nĐóng góp hậu cung sau khi trở thành Phi tần:\n${haremPassivePreview(person, state: s)}' : ''}',
          'Tăng chi sinh hoạt ${money(s, s.seasonal ? 6 : 2)} ${moneyUnit(s)}/${s.periodName} từ kỳ thu chi sau. Mỗi người phe đối lập giảm 2 thiện cảm; $stabilityLabel −1.',
        ),
      };
      return MeetingAction(
        id: id,
        label: option.$2,
        description: s.calendarText(description),
        benefit: s.calendarText(benefit),
        consequence: s.calendarText(consequence),
        costLabel:
            '1 hành động${option.$4 > 0 ? ' · ${option.$4} ${moneyUnit(s)}' : ''}',
        disabledReason: disabledReason,
      );
    }).toList();
  }

  MeetingAction _covertMeetingAction(Courtier person) => MeetingAction(
    id: 'investigate',
    label: 'Điều tra kín',
    description: 'Chọn mật thám và kinh phí điều tra ${person.name}.',
    costLabel: '1 hành động · 2.000 / 4.000 / 8.000 ngân lượng',
    requiresConfirmation: false,
    disabledReason:
        !person.available
            ? 'Nhân vật không còn hiện diện.'
            : s.pending.any(
              (p) => p.kind == 'investigate' && p.target == person.id,
            )
            ? 'Đang điều tra'
            : s.ended
            ? 'Triều đại đã kết thúc.'
            : s.points < 1
            ? 'Hết hành động'
            : s.treasury < covertCost(s, 20)
            ? 'Không đủ ngân khố'
            : covertSpies(s, person).isEmpty
            ? 'Không có mật thám rảnh phù hợp.'
            : null,
  );

  String _evidenceDescription(Courtier person) =>
      person.evidenceTurn == 0
          ? 'Cần điều tra kín thành công để có bằng chứng.'
          : 'Âm mưu đã xác minh ${person.lastInvestigation?.plot ?? 0}%. Bằng chứng hiệu lực từ ${s.date(person.evidenceTurn)} tới trước ${s.date(evidenceExpires(s, person))}.';

  MeetingAction _demotionMeetingAction(Courtier person) => MeetingAction(
    id: 'demote-court',
    label: 'Giáng chức',
    choiceLabel: 'Chọn mức giáng phẩm',
    choiceKeyPrefix: 'demotion-choice',
    costLabel: '1 hành động · Phe ${person.faction} −2',
    description: 'Giáng phẩm ${person.name} theo bằng chứng điều tra.',
    benefit: _evidenceDescription(person),
    consequence:
        'Thôi chức, các vị trí quản lý để trống. Giữ công trạng và nhiệm vụ; không đổi uy quyền hoặc ổn định triều đình.',
    disabledReason: courtDemotionBlocked(s, person, 1),
    choices: [
      for (final steps in [1, 2])
        MeetingActionChoice(
          id: 'demote-court:$steps',
          label: 'Giáng $steps phẩm',
          summary:
              '${courtGradeName(person.grade)} → ${courtGradeName(person.grade + steps)}',
          benefit:
              'Cần âm mưu đã xác minh >${steps == 1 ? 50 : 60}%, bằng chứng chưa quá một năm.',
          costLabel: '1 hành động · Phe ${person.faction} −2',
          disabledReason: courtDemotionBlocked(s, person, steps),
        ),
    ],
  );

  MeetingAction _convictionMeetingAction(Courtier person) => MeetingAction(
    id: 'convict',
    label: 'Kết tội',
    costLabel: '1 hành động · Phe ${person.faction} −5',
    description: 'Bỏ tù ${person.name}, tước toàn bộ phẩm vị và chức vụ.',
    benefit: _evidenceDescription(person),
    consequence:
        'Ngừng đóng góp, các vị trí đang giữ để trống; công vụ gián đoạn, quân được thu hồi. Không đổi uy quyền hoặc ổn định triều đình.',
    disabledReason: evidenceBlocked(s, person, 75),
  );

  MeetingAction _courtRetirementAction(Courtier person) {
    final office = courtOfficeFor(s, person.id);
    final loss = office == null ? 0 : courtOfficeDisruption(office);
    final authority = office == null ? 0 : courtOfficeAuthority(office);
    final vacancy = office == null ? '' : courtVacancyEffects(office);
    return MeetingAction(
      id: 'cut-office',
      label: 'Cho hồi hương',
      description:
          'Cho ${person.name} thôi chức${office == null ? '' : ' ${office.role} (${courtGradeName(office.grade)})'} và hồi hương.',
      benefit:
          'Giữ nguyên phẩm cá nhân, công trạng, diện mạo và quan hệ; có thể triệu hồi, bổ nhiệm lại về sau.',
      costLabel: '1 hành động · Ổn định −$loss · Không chi vàng',
      consequence:
          'Vị trí để trống tới khi vua bổ nhiệm. Phe ${person.faction} −4.${person.influence >= 60 ? ' Phe người cũ còn phản ứng mùa sau.' : ''} '
          '${authority == 0 ? 'Chức này không yêu cầu uy quyền.' : 'Cần uy quyền trên $authority; hiện tại ${s.authority}.'}'
          '${vacancy.isEmpty ? '' : '\nMỗi mùa ghế trống: $vacancy.'}'
          '${loss >= s.stability ? '\nCẢNH BÁO: ổn định về 0 sẽ kết thúc lượt chơi.' : ''}',
      disabledReason:
          !person.available
              ? 'Nhân vật không còn hiện diện.'
              : office == null
              ? person.retired
                  ? 'Đã hồi hương'
                  : 'Nhân vật chưa giữ chức vụ'
              : courtDismissalBlocked(s, office),
    );
  }

  MeetingAction _rewardMeetingAction(Courtier person) => MeetingAction(
    id: 'reward',
    label: 'Ban thưởng',
    description:
        'Ban thưởng cho ${person.name}. Thiện cảm hiện tại ${person.affection}.',
    benefit: 'Giảm bất mãn theo thiện cảm thực nhận; quyền lực +2.',
    consequence:
        'Mức tăng thiện cảm theo đúng mức thưởng và thiện cảm hiện tại, không đổi theo tính cách hoặc số lần ban thưởng. '
        'Mỗi người phe đối lập giảm 3 thiện cảm, tăng 3 bất mãn. '
        'Thiện cảm đã đạt 100 sẽ luôn giữ ở 100, kể cả khi giáng chức.',
    costLabel:
        '1 hành động · từ ${moneyText(s, CharacterReward.small.cost(s))}',
    disabledReason:
        !person.available
            ? 'Nhân vật không còn hiện diện.'
            : s.ended
            ? 'Triều đại đã kết thúc.'
            : s.points < 1
            ? 'Hết hành động'
            : s.treasury < CharacterReward.small.cost(s)
            ? 'Không đủ ngân khố'
            : null,
    choices: [
      for (final tier in CharacterReward.values)
        MeetingActionChoice(
          id: tier.option,
          label: moneyText(s, tier.cost(s)),
          summary: 'Thiện cảm +${tier.affectionGain(person.affection)}',
          benefit:
              'Thiện cảm +${tier.affectionGain(person.affection)}, bất mãn giảm tối đa ${tier.affectionGain(person.affection)}; quyền lực +2.',
          costLabel: '1 hành động · ${moneyText(s, tier.cost(s))}',
          disabledReason:
              s.treasury < tier.cost(s) ? 'Không đủ ngân khố' : null,
        ),
    ],
  );

  String? _courtOptionBlocked(Courtier c, String option) {
    if (!s.hasCourtSystem || c.isConsort) return null;
    final office = courtOfficeFor(s, c.id);
    if (office == null) return null;
    if (option == 'cut-office') return courtDismissalBlocked(s, office);
    if (option == 'dismiss') return courtRemovalBlocked(s, office);
    return null;
  }

  List<(String, String, String, int)> _personOptions(
    Courtier c,
  ) => <(String, String, String, int)>[
    (
      'audience',
      'Trò chuyện, lắng nghe',
      '1 hành động · thiện cảm cơ bản +6 và giảm bất mãn theo mức thực nhận; tùy tính cách, lặp/quan hệ cao giảm hiệu quả · thái độ phe đối lập −3; mỗi nhân vật phe đó −2 thiện cảm, gồm tú nữ/phi tần; đồng thời +2 bất mãn · mỗi 3 lần mở thêm 1 tính cách',
      0,
    ),
    (
      'reward',
      'Ban thưởng',
      'Chọn mức thưởng ${CharacterReward.values.map((tier) => moneyText(s, tier.cost(s))).join(' / ')} · 1 hành động · thiện cảm tăng theo mức thưởng và thiện cảm hiện tại · phe đối lập −3 thiện cảm (trừ người đạt 100), +3 bất mãn',
      CharacterReward.small.cost(s),
    ),
    (
      'investigate',
      'Điều tra kín',
      '1 hành động · chi ${investigationCost(s)} ${moneyUnit(s)} · âm mưu và bất mãn chỉ hiển thị khi điều tra hoàn tất, theo số liệu lúc bắt đầu · báo cáo xác minh phẩm chất về cuối ${s.date(s.week + investigationDuration(s) - 1)}${s.seasonal ? ', thành công giảm 6 tiến độ âm mưu' : ''}',
      investigationCost(s),
    ),
    if (!c.isConsort && (!s.hasCourtSystem || courtOfficeFor(s, c.id) != null))
      (
        'dismiss',
        'Điều chỉnh nhân sự',
        'Chọn ứng viên · 1 hành động · phí theo năng lực, địa vị và chức vụ · ảnh hưởng các phe',
        0,
      ),
    if (!c.isConsort && s.hasCourtSystem && courtOfficeFor(s, c.id) != null)
      (
        'cut-office',
        'Cho hồi hương',
        '1 hành động · ổn định −${courtOfficeDisruption(courtOfficeFor(s, c.id)!)} · ${courtOfficeAuthority(courtOfficeFor(s, c.id)!) == 0 ? 'không yêu cầu uy quyền' : 'cần uy quyền trên ${courtOfficeAuthority(courtOfficeFor(s, c.id)!)}'}. Người hồi hương giữ phẩm và công trạng. Chức cao bỏ trống chịu tác động ngược passive mỗi mùa.',
        0,
      ),
    if (!c.isConsort && s.hasCourtSystem && c.grade > 1)
      (
        'promote',
        'Thăng phẩm',
        'Chọn phẩm đích; cộng dồn công trạng, phí và tác động quan hệ. Không có thời gian chờ giữa các lần thăng.',
        0,
      ),
    if (!c.isConsort && s.hasCourtSystem)
      (
        'choose-office',
        courtOfficeFor(s, c.id) == null
            ? 'Bổ nhiệm chức vụ'
            : 'Điều chuyển chức vụ',
        'Chọn chức vụ phù hợp với phẩm hàm và chuyên môn.',
        0,
      ),
    if (c.isConsort && !c.inHarem)
      (
        'invite',
        'Tuyển vào hậu cung',
        '1 hành động · chi ${money(s, 35)} ${moneyUnit(s)} · sinh hoạt +${money(s, s.seasonal ? 6 : 2)} ${moneyUnit(s)}/${s.periodName} · mỗi nhân vật phe đối lập −2 thiện cảm${s.seasonal ? '\n${authoredMoneyText(s, haremPassivePreview(c, state: s))}' : ''}',
        money(s, 35),
      ),
    if (c.inHarem && !c.queen)
      (
        'queen',
        'Sắc phong Hoàng hậu',
        '1 hành động · chi ${money(s, 60)} ${moneyUnit(s)} · ảnh hưởng các gia tộc${s.seasonal ? '\n${haremPassivePreview(c, asQueen: true, state: s)}' : ''}',
        money(s, 60),
      ),
    if (c.inHarem && c.isConsort && s.seasonal)
      (
        'harem-quest',
        'Câu chuyện & passive',
        'Xem nhiệm vụ quan hệ và điều kiện đóng góp.',
        0,
      ),
    if (c.inHarem)
      (
        'visit',
        'Cùng dạo Ngự uyển',
        '1 hành động · chi 10 · thêm 1 lần hưởng lạc',
        money(s, 10),
      ),
  ];

  Future<void> _personDialog(Courtier c) async {
    setState(() => personDialogOpen = true);
    final options = _personOptions(c);
    final option = await showDialog<String>(
      context: context,
      builder:
          (context) => ImperialSimpleDialog(
            insetPadding: _personnelDialogInsets(context),
            title: Row(
              children: [
                CharacterPortrait(person: c, width: 66, height: 82),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    formatGameNumbers(c.name),
                    style: const TextStyle(fontFamily: 'Lora'),
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Surface(
                  padding: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Tag(c.displayRole, color: forest),
                          if (!c.isConsort && c.grade > 0)
                            Tag(courtGradeName(c.grade), color: forest),
                          Tag(c.faction),
                          Tag('${c.age} tuổi'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatGameNumbers(
                          'Đã biết: ${c.knownPersonalityText}\n${c.personalityProgress}\n${c.knownPersonalities.map((p) => '${p.label}: ${p.description}').join('\n')}',
                        ),
                        key: const ValueKey('personality-details'),
                        style: const TextStyle(fontSize: 12, height: 1.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatGameNumbers(abilityExplanation(c)),
                        key: const ValueKey('person-ability-help'),
                        style: const TextStyle(fontSize: 12, height: 1.8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatGameNumbers(
                          s.calendarText(
                            c.isConsort && s.seasonal
                                ? authoredMoneyText(
                                  s,
                                  haremPassivePreview(c, state: s),
                                )
                                : '${roleAbilityExplanation(c, s)}\n${officerWorkHint(c, s)}',
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: forest,
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!c.isConsort && s.hasCourtSystem) ...[
                        Text(
                          formatGameNumbers(
                            'Công trạng khả dụng ${c.merit} · Đã sử dụng ${c.meritSpent} · Tổng ${c.totalMerit}\nThành tích lớn ${c.majorMerits}',
                          ),
                        ),
                        if (c.meritHistory.isNotEmpty)
                          ExpansionTile(
                            title: const Text('Lịch sử công trạng'),
                            children: [
                              for (final m in c.meritHistory.reversed)
                                ListTile(
                                  dense: true,
                                  title: Text(
                                    formatGameNumbers(
                                      '${m.title}: +${m.points}${m.major ? ' · Đại công' : ''}',
                                    ),
                                  ),
                                  subtitle: Text(
                                    formatGameNumbers(s.date(m.turn)),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 8),
                      ],
                      const Text(
                        'Năng lực cao không bảo đảm trung thành hay liêm chính. Các phẩm chất chưa điều tra vẫn chưa được xác minh.',
                        style: TextStyle(
                          fontSize: 11,
                          color: muted,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...options.map(
                (option) => ImperialDialogOption(
                  leading: ImperialIcon(switch (option.$1) {
                    'reward' => 'treasury',
                    'investigate' => 'scroll',
                    'dismiss' => 'people',
                    'invite' => 'harem',
                    'harem-quest' => 'journal',
                    _ => 'citizens',
                  }, size: 38),
                  onPressed:
                      s.points < 1 ||
                              s.treasury < option.$4 ||
                              _courtOptionBlocked(c, option.$1) != null ||
                              (option.$1 == 'invite' &&
                                  haremAdmissionBlocked(s) != null) ||
                              (['invite', 'queen'].contains(option.$1) &&
                                  haremPromotionBlocked(s, c) != null)
                          ? null
                          : () => Navigator.pop(context, option.$1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatGameNumbers(option.$2),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: option.$1 == 'dismiss' ? terracotta : ink,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formatGameNumbers(
                          '${option.$3}${_courtOptionBlocked(c, option.$1) == null ? '' : '\n${_courtOptionBlocked(c, option.$1)}'}${['invite', 'queen'].contains(option.$1) && haremPromotionBlocked(s, c) != null ? '\n${haremPromotionBlocked(s, c)}' : ''}',
                        ),
                        style: const TextStyle(fontSize: 11, color: muted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
    if (!mounted) return;
    setState(() => personDialogOpen = false);
    await _handlePersonOption(c, option);
  }

  Future<void> _handlePersonOption(Courtier c, String? option) async {
    if (option == 'reward') {
      final selected = await confirmMeetingAction(
        context,
        _rewardMeetingAction(c),
      );
      if (selected != null && mounted) {
        await act('courtier', target: c.id, option: selected);
      }
    } else if (option == 'cut-office') {
      final office = courtOfficeFor(s, c.id);
      if (office != null) {
        await confirmCourtDismissal(
          context,
          s,
          office,
          (type, target, option) => act(type, target: target, option: option),
        );
      }
    } else if (option == 'promote') {
      await chooseCourtPromotion(
        context,
        s,
        c,
        (type, target, option) => act(type, target: target, option: option),
      );
    } else if (option == 'choose-office') {
      await _chooseOfficeFor(c);
    } else if (option == 'dismiss') {
      if (s.hasCourtSystem) {
        final office = courtOfficeFor(s, c.id);
        if (office != null) {
          await chooseCourtAppointment(
            context,
            s,
            office,
            (type, target, option) => act(type, target: target, option: option),
          );
        }
      } else {
        await _replacementDialog(c);
      }
    } else if (option == 'harem-quest') {
      selectedConsortId = c.id;
      navigate('harem-management');
    } else if (option != null) {
      await act('courtier', target: c.id, option: option);
    }
  }

  Future<void> _chooseOfficeFor(Courtier person) async {
    final officeId = await showDialog<String>(
      context: context,
      builder:
          (context) => ImperialSimpleDialog(
            title: Text(formatGameNumbers('Chọn chức vụ cho ${person.name}')),
            children: [
              for (final office in s.courtOffices)
                ImperialDialogOption(
                  onPressed:
                      courtAppointmentBlocked(s, person, office) == null
                          ? () => Navigator.pop(context, office.id)
                          : null,
                  child: Text(
                    formatGameNumbers(
                      '${office.role} · ${courtGradeName(office.grade)}\n${courtAppointmentBlocked(s, person, office) ?? (courtOfficeHolder(s, office)?.name ?? 'Đang trống')}',
                    ),
                  ),
                ),
            ],
          ),
    );
    if (officeId == null || !mounted) return;
    final office = s.courtOffices.firstWhere((o) => o.id == officeId);
    await chooseCourtAppointment(
      context,
      s,
      office,
      (type, target, option) => act(type, target: target, option: option),
      preferredCandidate: person,
    );
  }

  Future<void> _replacementDialog(Courtier outgoing) async {
    final candidates = [...s.officialsPool]..sort((a, b) {
      final fit = specialtyFit(
        b.specialty,
        specialtyForRole(outgoing.role),
      ).compareTo(specialtyFit(a.specialty, specialtyForRole(outgoing.role)));
      return fit != 0 ? fit : b.ability.compareTo(a.ability);
    });
    final chosen = await showDialog<String>(
      context: context,
      builder:
          (context) => ImperialSimpleDialog(
            insetPadding: _personnelDialogInsets(context),
            title: Text(
              formatGameNumbers('Chọn người tiếp nhận chức ${outgoing.role}'),
              style: const TextStyle(fontFamily: 'Lora'),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  formatGameNumbers(
                    'Thay ${outgoing.name}. Ngân khố ${s.treasury}. Mỗi lần thay tốn 1 hành động, Ổn định triều đình −${replacementDisruption(outgoing)}; phí theo năng lực, địa vị (ảnh hưởng) của ứng viên và chức vụ tiếp nhận: bậc ${appointmentRank(outgoing.role)}/4. Chức càng cao, phí càng lớn. Danh sách được giữ khi tải lại. Công việc thường chuyển sang người mới và giữ tiến độ. Tấu chương đã giao riêng cho người rời chức sẽ gián đoạn, không tự chuyển phân công.',
                  ),
                  style: const TextStyle(fontSize: 12, height: 1.8),
                ),
              ),
              for (final c in candidates)
                ImperialDialogOption(
                  key: ValueKey('appoint-candidate-${c.id}'),
                  leading: CharacterPortrait(person: c, width: 42, height: 56),
                  onPressed:
                      s.points < 1 ||
                              s.treasury < appointmentCost(c, outgoing.role, s)
                          ? null
                          : () => Navigator.pop(context, c.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatGameNumbers('${c.name} · ${c.faction}'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formatGameNumbers(
                            'Năng lực ${c.abilityLabel} · ${c.specialty} · ${fitLabel(specialtyFit(c.specialty, specialtyForRole(outgoing.role)))}\nĐịa vị: ảnh hưởng ${c.influence}/100 · bất mãn ${c.discontent}/100\nĐã biết: ${c.knownPersonalityText} · tính cách khác chưa rõ',
                          ),
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          formatGameNumbers(
                            'Bổ nhiệm: ${appointmentCost(c, outgoing.role, s)} ${moneyUnit(s)}${s.treasury < appointmentCost(c, outgoing.role, s) ? ' · Không đủ ngân khố' : ''}',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                s.treasury <
                                        appointmentCost(c, outgoing.role, s)
                                    ? terracotta
                                    : forest,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
    );
    if (chosen == null || !mounted) return;
    final candidate = s.officialsPool.firstWhere((c) => c.id == chosen);
    final yes = await showDialog<bool>(
      context: context,
      builder:
          (context) => ImperialAlertDialog(
            insetPadding: _personnelDialogInsets(context),
            title: Text(
              formatGameNumbers('Bổ nhiệm ${candidate.name}?'),
              style: const TextStyle(fontFamily: 'Lora'),
            ),
            content: SizedBox(
              width: 640,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _appointmentComparison(outgoing, candidate),
                    const SizedBox(height: 20),
                    Text(
                      formatGameNumbers(
                        'Tiếp nhận chức ${outgoing.role} (bậc ${appointmentRank(outgoing.role)}/4) thay ${outgoing.name}.\nNăng lực ${candidate.abilityLabel} · chuyên môn ${candidate.specialty}. Địa vị: ảnh hưởng ${candidate.influence}/100. Phí dựa trên cả năng lực, địa vị và chức vụ tiếp nhận.\n\nChi ${appointmentCost(candidate, outgoing.role, s)} ${moneyUnit(s)} · 1 hành động · uy quyền +1 · Ổn định triều đình −${replacementDisruption(outgoing)}.\nPhe ${candidate.faction} +5 thái độ, phe ${factionOpponents[candidate.faction]} −6; thành viên phe đối lập giảm 2 thiện cảm. ${outgoing.faction != candidate.faction ? 'Phe ${outgoing.faction} còn giảm 4 vì người cũ bị bãi chức.' : ''}\n\n${outgoing.influence >= 60 ? 'Phe người cũ còn bất mãn −1/${s.periodName} trong ${s.seasonal ? 1 : 3} ${s.periodName}. ' : ''}Công việc đang giao chuyển sang người mới, giữ tiến độ; thời hạn nhiệm vụ đại biến cố đã cam kết giữ nguyên. Các việc thường tính kết quả theo năng lực/chuyên môn của người mới. Tấu chương đã giao riêng cho người rời chức sẽ gián đoạn, không tự chuyển phân công.${s.stability <= replacementDisruption(outgoing) ? '\n\nCẢNH BÁO: thay người lúc này sẽ khiến Ổn định triều đình về 0 và kết thúc lượt chơi.' : ''}',
                      ),
                      style: const TextStyle(height: 1.8),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  formatGameNumbers(
                    'Bổ nhiệm · ${appointmentCost(candidate, outgoing.role, s)} ${moneyUnit(s)}',
                  ),
                ),
              ),
            ],
          ),
    );
    if (yes == true) {
      await act('appoint', target: outgoing.id, option: candidate.id);
    }
  }

  Widget _appointmentComparison(Courtier outgoing, Courtier candidate) {
    Widget entry(Courtier c, String title) => Surface(
      padding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatGameNumbers(title),
            style: const TextStyle(
              fontSize: 10,
              color: gold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Center(child: CharacterPortrait(person: c, width: 100, height: 124)),
          const SizedBox(height: 12),
          Text(
            formatGameNumbers(c.name),
            style: const TextStyle(fontFamily: 'Lora', fontSize: 18),
          ),
          Text(
            formatGameNumbers('${c.displayRole} · ${c.faction}'),
            style: const TextStyle(fontSize: 11, color: muted),
          ),
          const SizedBox(height: 10),
          Text(
            formatGameNumbers('Năng lực ${c.abilityLabel}'),
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            formatGameNumbers(c.specialty),
            style: const TextStyle(fontSize: 11, color: forest),
          ),
          Text(
            formatGameNumbers('Ảnh hưởng ${c.influence}/100'),
            style: const TextStyle(fontSize: 11),
          ),
          Text(
            formatGameNumbers('Đã biết: ${c.knownPersonalityText}'),
            style: const TextStyle(fontSize: 10, color: muted),
          ),
        ],
      ),
    );
    return MediaQuery.sizeOf(context).width < 650
        ? Column(
          children: [
            entry(outgoing, 'NGƯỜI ĐƯƠNG NHIỆM'),
            const SizedBox(height: 12),
            entry(candidate, 'ỨNG VIÊN TIẾP NHẬN'),
          ],
        )
        : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: entry(outgoing, 'NGƯỜI ĐƯƠNG NHIỆM')),
            const SizedBox(width: 16),
            Expanded(child: entry(candidate, 'ỨNG VIÊN TIẾP NHẬN')),
          ],
        );
  }

  Widget _health() => LayoutBuilder(
    builder: (context, box) {
      final portrait = Surface(
        child: Column(
          children: [
            CharacterPortrait(
              emperor: true,
              emperorAge: s.age,
              width: 156,
              height: 202,
            ),
            const SizedBox(height: 18),
            Text(
              formatGameNumbers(s.playerName),
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Lora', fontSize: 22),
            ),
            const SizedBox(height: 8),
            Tag('${s.age} TUỔI · NĂM TRỊ VÌ ${s.year}'),
            const SizedBox(height: 14),
            Text(
              formatGameNumbers(
                s.health <= 20
                    ? 'Long thể nguy cấp'
                    : s.illness > 0
                    ? 'Cần chăm sóc long thể'
                    : 'Long thể an hòa',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: s.health <= 20 ? terracotta : forest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatGameNumbers('Đã trị vì ${s.duration}'),
              style: const TextStyle(fontSize: 11, color: muted),
            ),
          ],
        ),
      );
      final status = Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.favorite_border, color: terracotta, size: 34),
                Text(
                  formatGameNumbers('${s.health}'),
                  style: const TextStyle(fontFamily: 'Lora', fontSize: 42),
                ),
                Text(' / 100', style: TextStyle(color: muted)),
                Tag('${s.age} TUỔI'),
              ],
            ),
            const SizedBox(height: 24),
            _smallMeter('Mệt mỏi tích lũy', s.fatigue, inverse: true),
            const SizedBox(height: 20),
            _smallMeter('Căng thẳng', s.stress, inverse: true),
            const SizedBox(height: 20),
            _smallMeter(
              'Mức hưởng lạc tích lũy',
              s.indulgence,
              maximum: 40,
              inverse: true,
            ),
            const SizedBox(height: 20),
            _smallMeter('Mức bệnh', s.illness, inverse: true),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              formatGameNumbers(s.calendarText(s.healthReport)),
              style: const TextStyle(color: forest),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  formatGameNumbers(
                    '${s.periodTitle} này: ${s.workThisWeek} mức công việc',
                  ),
                ),
                Text(formatGameNumbers('${s.restThisWeek} lần nghỉ')),
                Text(formatGameNumbers('${s.revelThisWeek} mức hưởng lạc')),
              ],
            ),
            if (s.exhaustedWeeks > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  formatGameNumbers(
                    'Đã mệt mỏi kéo dài ${s.exhaustedWeeks} ${s.periodName}.',
                  ),
                  style: const TextStyle(color: terracotta),
                ),
              ),
          ],
        ),
      );
      final care = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('Chăm sóc bản thân'),
          for (final a in actions.where(
            (a) => ['rest', 'revel', 'treat'].contains(a.id),
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                key: ValueKey('care-preview-${a.id}'),
                onTap: () => setState(() => selectedCareId = a.id),
                child: Surface(
                  selected: selectedCareId == a.id,
                  padding: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tag(
                        a.id == 'treat'
                            ? 'HIỆU QUẢ NGAY'
                            : 'KHI KHÉP ${s.periodName.toUpperCase()}',
                        color: a.id == 'treat' ? forest : gold,
                      ),
                      const SizedBox(height: 8),
                      _actionRow(a),
                    ],
                  ),
                ),
              ),
            ),
          if (selectedCareId != null)
            Surface(
              key: const ValueKey('care-preview-panel'),
              padding: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BỆ HẠ ĐANG CÂN NHẮC',
                    style: TextStyle(
                      fontSize: 10,
                      color: gold,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formatGameNumbers(
                      actions.firstWhere((a) => a.id == selectedCareId).title,
                    ),
                    style: const TextStyle(fontFamily: 'Lora', fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatGameNumbers(
                      _actionDescription(
                        actions.firstWhere((a) => a.id == selectedCareId),
                      ),
                    ),
                    style: const TextStyle(fontSize: 12, height: 1.8),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nhấn nút mũi tên trên thẻ để thực hiện. Chỉ xem trước chưa tiêu hành động.',
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
        ],
      );

      if (box.maxWidth < 900) {
        return RoomPane(
          child: Column(
            children: [
              portrait,
              const SizedBox(height: 16),
              status,
              const SizedBox(height: 16),
              care,
            ],
          ),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 204, child: RoomPane(padding: 4, child: portrait)),
          const VerticalDivider(width: 1, color: gold),
          Expanded(child: RoomPane(child: status)),
          const VerticalDivider(width: 1, color: gold),
          SizedBox(width: 320, child: RoomPane(child: care)),
        ],
      );
    },
  );

  Widget _smallMeter(
    String label,
    int? value, {
    int maximum = 100,
    bool inverse = false,
  }) {
    final ratio = (value ?? 0) / maximum;
    final bad = value != null && (inverse ? ratio > .55 : ratio < .3);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                formatGameNumbers(label),
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ),
            Text(
              formatGameNumbers(
                value == null
                    ? 'Chưa rõ'
                    : ['Năng lực', 'Thiện cảm'].contains(label)
                    ? '$value'
                    : '$value/$maximum',
              ),
              style: TextStyle(fontSize: 10, color: bad ? terracotta : forest),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 4,
            value: ratio.clamp(0, 1),
            backgroundColor: line,
            color: bad ? terracotta : const Color(0xFF9AA98C),
          ),
        ),
      ],
    );
  }

  Widget _journal() {
    final entries = s.journal.take(150).toList();
    final selected =
        entries.isEmpty
            ? null
            : entries[selectedChronicleIndex.clamp(0, entries.length - 1)];
    final index = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'BIÊN NIÊN TRIỀU ĐẠI',
          style: TextStyle(fontSize: 10, color: gold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color:
                  identical(entries[i], selected)
                      ? const Color(0xFFE5CFA0)
                      : Colors.transparent,
              child: InkWell(
                key: ValueKey('chronicle-entry-$i'),
                onTap: () => setState(() => selectedChronicleIndex = i),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatGameNumbers(
                          s.seasonal
                              ? s.date(entries[i].week)
                              : '${s.periodTitle} ${entries[i].week}',
                        ),
                        style: const TextStyle(fontSize: 10, color: gold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatGameNumbers(s.calendarText(entries[i].title)),
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 16,
                          color:
                              ['danger', 'warning'].contains(entries[i].tone)
                                  ? terracotta
                                  : ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (s.journal.length > 150)
          const Text(
            'Hiển thị 150 ghi chép gần nhất; lịch sử đầy đủ vẫn nằm trong bản lưu.',
            style: TextStyle(fontSize: 11, color: muted),
          ),
      ],
    );
    final reading = Column(
      key: const ValueKey('chronicle-reading'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Sử ký Thiên Hòa',
          'Những quyết định đã ban và những điều giang sơn còn nhớ.',
        ),
        if (selected == null)
          const Text(
            'Sử quan đang chờ ghi chép đầu tiên.',
            style: TextStyle(fontFamily: 'Lora', fontSize: 21),
          )
        else ...[
          Tag(
            s.seasonal
                ? s.date(selected.week)
                : '${s.periodTitle} ${selected.week}',
          ),
          const SizedBox(height: 18),
          Text(
            formatGameNumbers(s.calendarText(selected.title)),
            style: const TextStyle(
              fontFamily: 'Lora',
              fontSize: 26,
              height: 1.4,
            ),
          ),
          const Divider(height: 32, color: gold),
          Text(
            formatGameNumbers(s.calendarText(selected.text)),
            style: const TextStyle(fontSize: 14, height: 1.8),
          ),
        ],
      ],
    );
    return LayoutBuilder(
      builder: (context, bounds) {
        if (bounds.maxWidth < 760) {
          return RoomPane(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                reading,
                const Divider(height: 28, color: gold),
                index,
              ],
            ),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 300, child: RoomPane(child: index)),
            const VerticalDivider(width: 1, color: gold),
            Expanded(child: RoomPane(padding: 24, child: reading)),
          ],
        );
      },
    );
  }

  Widget _scores() {
    final scores = rankedScores(controller.archive.scores, rules: scoreRules);
    final oldRules =
        controller.archive.scores
            .map((s) => s.rules)
            .where((r) => r != rulesVersion)
            .toSet()
            .toList()
          ..sort();
    return RoomPane(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            'Những triều đại dài nhất',
            'Chỉ có thời gian giữ ngai vàng quyết định thứ hạng.',
          ),
          const Tag('THÀNH TÍCH TRÊN THIẾT BỊ NÀY'),
          if (oldRules.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(
                    formatGameNumbers(
                      'Luật ${rulesVersion.replaceFirst('mvp-', '')}',
                    ),
                  ),
                  selected: scoreRules == rulesVersion,
                  onSelected: (_) => setState(() => scoreRules = rulesVersion),
                ),
                for (final rules in oldRules)
                  ChoiceChip(
                    label: Text(
                      formatGameNumbers(
                        'Luật ${rules.replaceFirst('mvp-', '').replaceFirst(RegExp(r'\.0$'), '')} (cũ)',
                      ),
                    ),
                    selected: scoreRules == rules,
                    onSelected: (_) => setState(() => scoreRules = rules),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 22),
          Surface(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 55,
                        child: Text(
                          'HẠNG',
                          style: TextStyle(fontSize: 9, color: muted),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'NGƯỜI CHƠI',
                          style: TextStyle(fontSize: 9, color: muted),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'THỜI GIAN TRỊ VÌ',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 9, color: muted),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (scores.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 55),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: gold,
                          size: 42,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Sử sách vẫn đang chờ tên bạn',
                          style: TextStyle(fontFamily: 'Lora', fontSize: 20),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Hoàn thành một lượt chơi để ghi thành tích đầu tiên.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                  ),
                ...scores.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 55,
                          child: Text(
                            formatGameNumbers('${entry.rank}'.padLeft(2, '0')),
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 23,
                              color: entry.rank == 1 ? gold : muted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            formatGameNumbers(entry.score.playerName),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            formatGameNumbers(
                              reignTime(
                                entry.score.weeks,
                                seasonal: entry.score.seasonal,
                              ),
                            ),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 12, color: forest),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mỗi tên lưu thành tích tốt nhất. Bằng thời gian trị vì thì đồng hạng. Lượt bỏ dở không được ghi điểm.',
            style: TextStyle(fontSize: 11, color: muted),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: busy ? null : startDialog,
                child: const Text('Bắt đầu triều đại mới'),
              ),
              if (controller.state != null && !s.ended)
                OutlinedButton(
                  onPressed: () => navigate('citadel'),
                  child: const Text('Tiếp tục trị vì'),
                ),
              if (controller.state != null && !s.ended)
                OutlinedButton(
                  onPressed: () => navigate('home'),
                  child: const Text('Về trang chính'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> get _criticalStatNames => [
    if (s.stability <= 20) stabilityLabel,
    if (s.authority <= 20) 'Uy quyền',
    if (s.people <= 20) 'Lòng dân',
    if (armyCondition(s) <= 20) 'Quân lực',
    if (s.health <= 20) 'Sức khỏe',
  ];

  Widget _weekbar(bool desktop) {
    if (s.seasonal &&
        _criticalStatNames.isEmpty &&
        s.affairsThisWeek != 0 &&
        !(s.points == 0 && s.overtime == 0)) {
      return const SizedBox.shrink();
    }
    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: 'BeVietnam',
        fontSize: 12,
        color: imperialIvory,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: desktop ? 32 : 16,
          vertical: route == 'court' || route == 'kingdom' ? 8 : 16,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF08251E), Color(0xFF123D30), Color(0xFF061D18)],
          ),
          image: DecorationImage(
            image: AssetImage('assets/images/imperial/jade-texture.webp'),
            fit: BoxFit.cover,
            opacity: .25,
          ),
          border: Border(top: BorderSide(color: imperialGold)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_criticalStatNames.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        formatGameNumbers(
                          _criticalStatNames.length == 1
                              ? '${_criticalStatNames.single} nguy cấp'
                              : '${_criticalStatNames.length} chỉ số nguy cấp',
                        ),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFFFFAC8E),
                        ),
                      ),
                    ],
                    if (s.affairsThisWeek == 0) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Chưa xử lý quốc sự',
                        style: TextStyle(fontSize: 9, color: Color(0xFFFFAC8E)),
                      ),
                    ],
                  ],
                ),
              ),
              if (s.points == 0 && s.overtime == 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: busy ? null : _overtimeDialog,
                    child: const Text(
                      'Làm thêm',
                      style: TextStyle(fontSize: 11, color: Color(0xFFFFAC8E)),
                    ),
                  ),
                ),
              if (!s.seasonal)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: terracotta,
                    foregroundColor: imperialIvory,
                    side: const BorderSide(color: imperialGold),
                  ),
                  onPressed: busy ? null : _nextWeek,
                  child: Text(
                    formatGameNumbers(
                      desktop ? 'Sang tuần tiếp theo   →' : 'Sang tuần  →',
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _overtimeDialog() async {
    final yes = await showDialog<bool>(
      context: context,
      builder:
          (context) => ImperialAlertDialog(
            title: const Text(
              'Chong đèn làm thêm?',
              style: TextStyle(fontFamily: 'Lora'),
            ),
            content: Text(
              formatGameNumbers(
                'Có thêm ${s.seasonal ? 2 : 1} hành động, tối đa một lần mỗi ${s.periodName}. Mệt mỏi và căng thẳng tăng; sức khỏe cuối ${s.periodName} chịu thêm tác hại.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(formatGameNumbers('Để ${s.periodName} sau')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  formatGameNumbers(
                    s.seasonal ? 'Nhận thêm 2 hành động' : 'Làm thêm một việc',
                  ),
                ),
              ),
            ],
          ),
    );
    if (yes == true) await act('overtime');
  }

  Future<void> _nextWeek() async {
    final expired = s.petitions.where((p) => p.deadline <= s.week).toList();
    if (expired.isNotEmpty) {
      final yes = await showDialog<bool>(
        context: context,
        builder:
            (context) => ImperialAlertDialog(
              title: const Text(
                'Còn tấu chương tới hạn',
                style: TextStyle(fontFamily: 'Lora'),
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatGameNumbers(
                          'Nếu khép ${s.periodName}, các việc này sẽ được xử lý như sau:',
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...expired.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            formatGameNumbers(
                              s.authoredText(_petitionExpiryText(p)),
                            ),
                            style: TextStyle(fontSize: 12, color: terracotta),
                          ),
                        );
                      }),
                      if (expired.any(
                        (p) => [
                          'Khủng hoảng',
                          'Âm mưu',
                        ].contains(eventForState(s, p.definitionId).category),
                      ))
                        Text(
                          formatGameNumbers(
                            'Bỏ mặc khủng hoảng/âm mưu còn làm giảm 4 uy quyền và 3 Ổn định triều đình mỗi tấu chương, tối đa hai tấu chương mỗi ${s.periodName}.',
                          ),
                          style: TextStyle(fontSize: 12, color: terracotta),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Quay lại xử lý'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(formatGameNumbers('Vẫn sang ${s.periodName}')),
                ),
              ],
            ),
      );
      if (yes != true) return;
    }
    await act('endWeek');
    if (mounted && scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _landing() => Scaffold(
    body: LayoutBuilder(
      builder:
          (context, bounds) => SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: bounds.maxWidth > 700 ? 48 : 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Crest(size: 42),
                          const SizedBox(width: 13),
                          const Expanded(
                            child: Text(
                              'VẠN TUẾ',
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 21,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                          if (bounds.maxWidth > 500)
                            TextButton(
                              onPressed: () => navigate('scores'),
                              child: const Text(
                                'Bảng xếp hạng',
                                style: TextStyle(fontSize: 11),
                              ),
                            )
                          else
                            IconButton(
                              tooltip: 'Bảng xếp hạng',
                              onPressed: () => navigate('scores'),
                              icon: const Icon(
                                Icons.emoji_events_outlined,
                                color: gold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      Container(
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9EBDD),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Stack(
                          children: [
                            const Positioned(
                              right: -30,
                              bottom: 0,
                              width: 670,
                              height: 380,
                              child: PalaceArt(),
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFE9EBDD),
                                      const Color(
                                        0xFFE9EBDD,
                                      ).withValues(alpha: .15),
                                    ],
                                    stops: const [.15, 1],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(
                                bounds.maxWidth > 700 ? 48 : 26,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Tag('MỘT ĐỜI ĐẾ VƯƠNG'),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Mười tám tuổi.\nMột giang sơn.',
                                    style: TextStyle(
                                      fontFamily: 'Lora',
                                      fontSize: bounds.maxWidth > 700 ? 53 : 37,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  const SizedBox(
                                    width: 360,
                                    child: Text(
                                      'Ngai vàng đã thuộc về bạn.\nNhưng bạn sẽ giữ được nó bao lâu?',
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.9,
                                        color: forest,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      FilledButton(
                                        onPressed: busy ? null : startDialog,
                                        child: const Text('Bắt đầu trị vì   →'),
                                      ),
                                      if (controller.state != null && !s.ended)
                                        OutlinedButton(
                                          onPressed: () => navigate('citadel'),
                                          child: Text(
                                            formatGameNumbers(
                                              'Tiếp tục · ${s.duration}',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Chơi theo mùa · 12 hành động mỗi mùa · Tự lưu',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 38),
                      LayoutBuilder(
                        builder: (context, inner) {
                          const items = <(IconData, String, String)>[
                            (
                              Icons.account_balance_outlined,
                              'Một nước trong tay',
                              'Lo việc dân, giữ biên cương, cân bằng những thế lực trong triều.',
                            ),
                            (
                              Icons.history_edu_outlined,
                              'Bốn mùa một năm',
                              'Quyết định hôm nay có thể trở lại vào một mùa mưa khác.',
                            ),
                            (
                              Icons.favorite_border,
                              'Giữ ngai, giữ mình',
                              'Làm quá sức hay ham mê tửu sắc đều có thể khép lại triều đại.',
                            ),
                          ];
                          return Wrap(
                            spacing: 28,
                            runSpacing: 26,
                            children:
                                items
                                    .map(
                                      (item) => SizedBox(
                                        width:
                                            inner.maxWidth > 700
                                                ? (inner.maxWidth - 56) / 3
                                                : inner.maxWidth,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              item.$1,
                                              color: gold,
                                              size: 25,
                                            ),
                                            const SizedBox(height: 14),
                                            Text(
                                              formatGameNumbers(item.$2),
                                              style: const TextStyle(
                                                fontFamily: 'Lora',
                                                fontSize: 19,
                                              ),
                                            ),
                                            const SizedBox(height: 9),
                                            Text(
                                              formatGameNumbers(item.$3),
                                              style: const TextStyle(
                                                color: muted,
                                                fontSize: 11,
                                                height: 1.9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          );
                        },
                      ),
                      if (controller.archive.archivedRuns.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Surface(
                            child: Text(
                              formatGameNumbers(
                                'Bản 0.8 thêm đại biến cố có mục tiêu và thời hạn, chuỗi quyết định, nghĩa vụ và áp lực trị vì. ${controller.archive.archivedRuns.length} lượt cũ được giữ nguyên trong kho local; hãy bắt đầu triều đại mới để dùng luật mới. Thành tích các bản cũ được xem riêng trong bảng xếp hạng.',
                              ),
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      if (controller.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Surface(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatGameNumbers(controller.error!),
                                  style: const TextStyle(color: terracotta),
                                ),
                                TextButton(
                                  onPressed: controller.load,
                                  child: const Text('Thử đọc lại bản lưu'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        formatGameNumbers(
                          'VẠN TUẾ  /  BẢN CHƠI THỬ ${rulesVersion.replaceFirst('mvp-', '')}     •     Mỗi triều đại đều bắt đầu từ một quyết định.',
                        ),
                        style: const TextStyle(fontSize: 9, color: muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    ),
  );

  Widget _endingReason() {
    final title = switch (s.endKind) {
      'poisoning' => 'Bị mưu sát',
      'coup' => 'Ngai vàng bị đoạt',
      'courtCollapse' => 'Triều đình tan rã',
      'puppet' => 'Vua trở thành bù nhìn',
      'armyCollapse' => 'Quân đội tan rã',
      'rebellion' => 'Dân chúng nổi dậy',
      'invasion' => 'Giang sơn thất thủ',
      'oldAge' => 'Một đời đế vương khép lại',
      'illness' => 'Nhà vua băng hà',
      'exhaustion' => 'Long thể suy kiệt',
      _ => 'Triều đại khép lại',
    };
    final contextText = switch (s.endKind) {
      'coup' || 'courtCollapse' || 'puppet' =>
        'Uy quyền ${s.authority}/100 · Ổn định triều đình ${s.stability}/100',
      'rebellion' =>
        'Lòng dân ${s.people}/100 · Quân lực ${militaryStrength(s)}${s.population == null ? '/100' : ' điểm'}',
      'invasion' =>
        'Quân lực ${militaryStrength(s)}${s.population == null ? '/100' : ' điểm'} · Kinh thành đã thất thủ',
      'armyCollapse' =>
        'Quân lực ${militaryStrength(s)}${s.population == null ? '/100' : ' điểm'} · Nhà vua không còn lực lượng bảo vệ',
      'poisoning' =>
        'Sức khỏe ${s.health}/100 · Dấu vết đầu độc đã được xác minh',
      'illness' || 'exhaustion' =>
        'Sức khỏe ${s.health}/100 · Mệt mỏi ${s.fatigue}/100 · Căng thẳng ${s.stress}/100',
      'oldAge' => 'Nhà vua hưởng thọ ${s.age} tuổi.',
      _ => '',
    };
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Surface(
              padding: 30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.history_edu_outlined,
                        color: terracotta,
                        size: 23,
                      ),
                      SizedBox(width: 10),
                      Tag('BIẾN CỐ CUỐI CÙNG', color: terracotta),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Text(
                    formatGameNumbers(title),
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 32,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nguyên nhân kết thúc',
                    style: TextStyle(
                      fontSize: 11,
                      color: gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatGameNumbers(s.calendarText(s.endReason!)),
                    key: const ValueKey('ending-reason'),
                    style: const TextStyle(fontSize: 14, height: 1.9),
                  ),
                  if (contextText.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      formatGameNumbers(contextText),
                      style: const TextStyle(
                        fontSize: 11,
                        color: muted,
                        height: 1.8,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => navigate('ending-summary'),
                      child: const Text('Xem thời gian trị vì  →'),
                    ),
                  ),
                  if (s.outcomes.isNotEmpty) _outcomeSummary(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ending() => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Crest(size: 64),
              const SizedBox(height: 40),
              const Text(
                'Bạn đã trị vì được',
                style: TextStyle(fontFamily: 'Lora', fontSize: 25),
              ),
              const SizedBox(height: 18),
              Text(
                formatGameNumbers(s.duration),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 48,
                  color: forest,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 38),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton(
                    onPressed: busy ? null : startDialog,
                    child: const Text('Chơi lại'),
                  ),
                  OutlinedButton(
                    onPressed: () => navigate('scores'),
                    child: const Text('Xem scoreboard'),
                  ),
                  TextButton(
                    onPressed: () => navigate('home'),
                    child: const Text('Về màn hình chính'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class Crest extends StatelessWidget {
  const Crest({super.key, this.size = 40});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: forest,
      borderRadius: BorderRadius.circular(size * .23),
    ),
    child: ImperialIcon('citadel', size: size),
  );
}
