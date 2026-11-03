import 'package:flutter/material.dart';
import 'background_music.dart';

class MusicScope extends InheritedNotifier<BackgroundMusicController> {
  const MusicScope({
    super.key,
    required BackgroundMusicController controller,
    required super.child,
  }) : super(notifier: controller);

  static BackgroundMusicController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MusicScope>()?.notifier;
}

class MusicToggle extends StatelessWidget {
  const MusicToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final music = MusicScope.maybeOf(context);
    if (music == null || !music.supported) return const SizedBox.shrink();
    return IconButton(
      key: const ValueKey('background-music-toggle'),
      tooltip: music.enabled ? 'Tắt nhạc nền' : 'Bật nhạc nền',
      color: const Color(0xFFD9B873),
      visualDensity: VisualDensity.compact,
      onPressed: () => music.setEnabled(!music.enabled),
      icon: Icon(
        music.enabled ? Icons.volume_up_outlined : Icons.volume_off_outlined,
        size: 20,
      ),
    );
  }
}
