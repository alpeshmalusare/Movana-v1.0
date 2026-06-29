import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/library_service.dart';
import '../../core/theme/movana_theme.dart';
import '../home/discovery_controller.dart';

class MyTheatreScreen extends ConsumerWidget {
  const MyTheatreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchedIds = ref.watch(libraryProvider).watched;
    final liveMovies = ref.watch(liveMoviesProvider).valueOrNull ?? const [];
    final watched = liveMovies.where((movie) => watchedIds.contains(movie.id)).toList();
    final hours = watched.fold<int>(0, (sum, movie) => sum + movie.runtimeMinutes) ~/ 60;
    final avg = watched.isEmpty ? 0.0 : watched.map((e) => e.rating).reduce((a, b) => a + b) / watched.length;
    final theatreScore = (60 + watched.length * 4).clamp(0, 100);
    return SafeArea(
      child: ListView(
        key: const ValueKey('my-theatre-screen'),
        padding: const EdgeInsets.all(20),
        children: [
          const Text('My Theatre', key: ValueKey('theatre-title'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          Container(
            key: const ValueKey('shareable-stats-card'),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: MovanaColors.card, borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image.asset(AppAssets.icon, width: 42),
              const SizedBox(height: 18),
              Text('I’ve watched ${watched.length} titles', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Theatre Score $theatreScore/100', style: const TextStyle(color: MovanaColors.accent, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('Average Rating ${avg.toStringAsFixed(1)} • $hours hours watched', style: const TextStyle(color: MovanaColors.textSecondary)),
              const SizedBox(height: 12),
              const Text('Shared from Movana', style: TextStyle(color: MovanaColors.accent, fontWeight: FontWeight.w800)),
            ]),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const ValueKey('share-theatre-button'),
            onPressed: () => _shareTheatreImage(watched, avg, theatreScore),
            icon: const Icon(Icons.ios_share),
            label: const Text('Share Theatre'),
          ),
          const SizedBox(height: 26),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _StatCard(label: 'Movies Watched', value: watched.where((m) => m.contentType.name == 'movie').length.toString()),
            _StatCard(label: 'Series Watched', value: watched.where((m) => m.contentType.name == 'series').length.toString()),
            _StatCard(label: 'Favourite Genre', value: watched.isEmpty ? '—' : watched.first.genres.first),
            _StatCard(label: 'Favourite OTT', value: watched.isEmpty || watched.first.providers.isEmpty ? '—' : watched.first.providers.first),
            _StatCard(label: 'Favourite Actor', value: watched.isEmpty ? '—' : watched.first.cast.first),
            _StatCard(label: 'Favourite Director', value: watched.isEmpty ? '—' : watched.first.director),
          ]),
          const SizedBox(height: 28),
          const Text('Achievements', key: ValueKey('achievements-title'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const _Achievement(label: 'Watched 100 Movies'),
          const _Achievement(label: 'Watched 250 Movies'),
          const _Achievement(label: 'Watched Every Christopher Nolan Movie'),
          const _Achievement(label: 'Watched Every Harry Potter Movie'),
        ],
      ),
    );
  }
}

Future<void> _shareTheatreImage(List<dynamic> watched, double avg, int theatreScore) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const size = Size(1080, 1350);
  final paint = Paint()..color = MovanaColors.background;
  canvas.drawRect(Offset.zero & size, paint);
  final glow = Paint()
    ..shader = ui.Gradient.radial(const Offset(540, 0), 850, [MovanaColors.accent.withOpacity(.26), Colors.transparent]);
  canvas.drawRect(Offset.zero & size, glow);
  _drawText(canvas, 'MOVANA', const Offset(72, 90), 46, MovanaColors.accent, FontWeight.w900);
  _drawText(canvas, 'My Theatre', const Offset(72, 185), 78, Colors.white, FontWeight.w900);
  _drawText(canvas, 'Movana User', const Offset(72, 240), 34, MovanaColors.textSecondary, FontWeight.w700);
  final movieCount = watched.where((m) => m.contentType.name == 'movie').length;
  final seriesCount = watched.where((m) => m.contentType.name == 'series').length;
  final stats = [
    ('Theatre Score', '$theatreScore/100'),
    ('Movies Watched', '$movieCount'),
    ('Series Watched', '$seriesCount'),
    ('Average Rating', avg.toStringAsFixed(1)),
  ];
  for (var i = 0; i < stats.length; i++) {
    final x = 72.0 + (i % 2) * 480;
    final y = 320.0 + (i ~/ 2) * 150;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 420, 108), const Radius.circular(28)), Paint()..color = MovanaColors.card);
    _drawText(canvas, stats[i].$1, Offset(x + 28, y + 38), 24, MovanaColors.textSecondary, FontWeight.w700);
    _drawText(canvas, stats[i].$2, Offset(x + 28, y + 82), 38, Colors.white, FontWeight.w900);
  }
  _drawText(canvas, 'Recently Watched', const Offset(72, 690), 36, Colors.white, FontWeight.w900);
  for (var i = 0; i < watched.take(6).length; i++) {
    final movie = watched[i];
    final rect = Rect.fromLTWH(72 + i * 156, 725, 126, 186);
    try {
      final image = await _loadUiImage(movie.posterUrl as String);
      canvas.save();
      canvas.clipRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)));
      paintImage(canvas: canvas, rect: rect, image: image, fit: BoxFit.cover);
      canvas.restore();
    } catch (_) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)), Paint()..color = MovanaColors.card);
    }
  }
  _drawText(canvas, 'Generated with Movana', const Offset(72, 1240), 32, MovanaColors.accent, FontWeight.w900);
  _drawText(canvas, 'Stop Scrolling. Start Watching.', const Offset(72, 1284), 28, MovanaColors.textSecondary, FontWeight.w700);
  final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('${Directory.systemTemp.path}/movana-my-theatre.png');
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  await Share.shareXFiles([XFile(file.path)], text: 'My Theatre on Movana — Theatre Score $theatreScore/100');
}

void _drawText(Canvas canvas, String text, Offset offset, double size, Color color, FontWeight weight) {
  final painter = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: weight)), textDirection: TextDirection.ltr)..layout(maxWidth: 900);
  painter.paint(canvas, offset);
}

Future<ui.Image> _loadUiImage(String url) async {
  final request = await HttpClient().getUrl(Uri.parse(url));
  final response = await request.close();
  final bytes = await response.fold<List<int>>([], (previous, element) => previous..addAll(element));
  final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
  return (await codec.getNextFrame()).image;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
        key: ValueKey('stat-card-$label'),
        width: 158,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: MovanaColors.card, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(label, style: const TextStyle(color: MovanaColors.textSecondary))]),
      );
}

class _Achievement extends StatelessWidget {
  const _Achievement({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => ListTile(key: ValueKey('achievement-$label'), leading: const Icon(Icons.workspace_premium_outlined, color: MovanaColors.accent), title: Text(label), subtitle: const Text('Locked', style: TextStyle(color: MovanaColors.textSecondary)));
}