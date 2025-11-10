import 'package:flutter_riverpod/legacy.dart';

final camProvider = StateProvider<bool>((ref) => false);
final audioProvider = StateProvider<bool>((ref) => false);
final textProvider = StateProvider<bool>((ref) => false);
final isRecordingProvider = StateProvider<bool>((ref) => false);
final hasRecordedProvider = StateProvider<bool>((ref) => false);
final audioBarsProvider =
    StateProvider<List<double>>((ref) => List.filled(32, 0));
final audioTimerProvider = StateProvider<String>((ref) => "00:00");
final waveformProvider = StateProvider<List<double>>((ref) => []);
