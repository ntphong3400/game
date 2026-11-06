import 'package:flutter/material.dart';

import '../../models/game_state.dart';
import 'giang_son_page.dart';

class CapitalHub extends StatelessWidget {
  const CapitalHub({
    super.key,
    required this.state,
    required this.busy,
    required this.onNavigate,
    required this.onEndTurn,
    required this.onOvertime,
  });

  final GameState state;
  final bool busy;
  final ValueChanged<String> onNavigate;
  final VoidCallback onEndTurn, onOvertime;

  @override
  Widget build(BuildContext context) {
    const artwork = 'assets/images/kinh-thanh-watercolor-v2.webp';
    const locations = [
      (
        'treasury',
        'Ngân khố',
        'Ngân khố · Tiền và kho lương',
        Offset(.265, .255),
      ),
      (
        'people',
        'Phủ Bá Quan',
        'Phủ Bá Quan · Gặp gỡ và bổ nhiệm triều thần',
        Offset(.18, .625),
      ),
      (
        'harem',
        'Cung Ngọc Hoa',
        'Cung Ngọc Hoa · Quản lý hậu cung',
        Offset(.71, .205),
      ),
      (
        'health',
        'Điện Dưỡng Tâm',
        'Điện Dưỡng Tâm · Chăm sóc long thể',
        Offset(.69, .345),
      ),
      ('journal', 'Viện Quốc Sử', 'Viện Quốc Sử · Đọc sử ký', Offset(.80, .69)),
      (
        'scores',
        'Vọng Thiên Các',
        'Vọng Thiên Các · Xem thành tích',
        Offset(.53, .71),
      ),
    ];
    return GiangSonPage(
      state: state,
      busy: busy,
      section: 'capital',
      artwork: artwork,
      aspectRatio: 1.5,
      onNavigate: onNavigate,
      onEndTurn: state.seasonal ? null : onEndTurn,
      onOvertime: onOvertime,
      destinations: GiangSonDestinations(
        onNavigate: onNavigate,
        featuredPlace: GiangSonDestination(
          id: 'citadel-location-court',
          label: 'Điện Vĩnh An',
          description: 'Điện Vĩnh An · Xử lý tấu chương',
          route: 'court',
          artwork: artwork,
          artworkFocus: const Alignment(-.04, -.64),
          count: state.petitions.length,
        ),
        places: [
          for (final (id, label, description, anchor) in locations)
            GiangSonDestination(
              id: 'citadel-location-$id',
              label: label,
              description: description,
              route: id,
              artwork: artwork,
              artworkFocus: Alignment(anchor.dx * 2 - 1, anchor.dy * 2 - 1),
            ),
        ],
      ),
    );
  }
}
