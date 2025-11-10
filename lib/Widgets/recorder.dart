import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _filePath;

  List<double> _barAmplitudes = List.generate(60, (_) => 0.0);
  StreamSubscription? _recorderSubscription;
  StreamSubscription? _playerSubscription;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _player.openPlayer();
  }

  @override
  void dispose() {
    _recorderSubscription?.cancel();
    _playerSubscription?.cancel();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  // ---------------- RECORDING ----------------
  Future<void> startRecording() async {
    final path =
        '${Directory.systemTemp.path}/audio_${DateTime.now().millisecondsSinceEpoch}.pcm';
    _filePath = path;

    await _recorder.startRecorder(toFile: _filePath, codec: Codec.pcm16);

    _recorderSubscription = _recorder.onProgress?.listen((event) {
      final decibel = event.decibels ?? -60;
      final normalized = (decibel + 60) / 60;
      setState(() {
        _barAmplitudes.removeAt(0);
        _barAmplitudes.add(Random().nextDouble() * normalized * 100);
      });
    });

    setState(() => _isRecording = true);
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    _recorderSubscription?.cancel();
    setState(() => _isRecording = false);
  }

  Future<void> startPlaying() async {
    if (_filePath == null || !File(_filePath!).existsSync()) return;

    final amplitudes = await extractAmplitudes(_filePath!, 120);

    await _player.startPlayer(
      fromURI: _filePath,
      codec: Codec.pcm16,
      whenFinished: () {
        _playerSubscription?.cancel();
        setState(() {
          _isPlaying = false;
        });
      },
    );

    setState(() => _isPlaying = true);

    _playerSubscription = _player.onProgress?.listen((event) {
      final pos = event.position.inMilliseconds.toDouble();
      final dur = event.duration?.inMilliseconds.toDouble() ?? 1;
      final progress = (pos / dur).clamp(0.0, 1.0);

      final visibleBars = 60;
      final start = (amplitudes.length * progress)
          .toInt()
          .clamp(0, amplitudes.length - visibleBars);
      final window = amplitudes.skip(start).take(visibleBars).toList();

      setState(() {
        _barAmplitudes = window;
      });
    });
  }

  Future<void> stopPlaying() async {
    await _player.stopPlayer();
    _playerSubscription?.cancel();
    setState(() => _isPlaying = false);
  }

  // ---------------- PCM → AMPLITUDES ----------------
  Future<List<double>> extractAmplitudes(String path, int samples) async {
    final file = File(path);
    final bytes = await file.readAsBytes();

    final amplitudes = <double>[];
    final step = (bytes.length ~/ 2) ~/ samples;

    for (int i = 0; i < samples; i++) {
      int start = i * step * 2;
      int sum = 0;
      for (int j = 0; j < step * 2; j += 2) {
        if (start + j + 1 >= bytes.length) break;
        int val = bytes[start + j] | (bytes[start + j + 1] << 8);
        sum += val.abs();
      }
      amplitudes.add(sum / step / 32768);
    }
    return amplitudes;
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Instagram-style Waveform',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Waveform display
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CustomPaint(
                painter: ScrollingWaveformPainter(
                  amplitudes: _barAmplitudes,
                  isPlaying: _isPlaying,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  onPressed: _isRecording ? stopRecording : startRecording,
                  child: Text(_isRecording ? 'Stop Recording' : 'Record'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent),
                  onPressed: _isPlaying ? stopPlaying : startPlaying,
                  child: Text(_isPlaying ? 'Stop Playing' : 'Play'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- PAINTER ----------------
class ScrollingWaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final bool isPlaying;

  ScrollingWaveformPainter({required this.amplitudes, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: isPlaying
            ? [Colors.greenAccent.shade100, Colors.greenAccent.shade700]
            : [Colors.redAccent.shade100, Colors.redAccent.shade700],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isPlaying ? 5 : 0)
      ..style = PaintingStyle.fill;

    final barCount = amplitudes.length;
    final barWidth = size.width / (barCount * 1.3);
    final gap = barWidth / 2;

    for (int i = 0; i < barCount; i++) {
      final amp = amplitudes[i];
      final barHeight = (amp * size.height).clamp(30, size.height);
      final x = i * (barWidth + gap);
      final y = (size.height - barHeight) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight.toDouble()),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScrollingWaveformPainter oldDelegate) =>
      oldDelegate.amplitudes != amplitudes ||
      oldDelegate.isPlaying != isPlaying;
}
