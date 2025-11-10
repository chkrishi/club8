import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';

import 'package:club8/Assets/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WavyLinePainter extends CustomPainter {
  final double progress;
  WavyLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final fillWidth = size.width * progress;

    final paint = Paint()
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [secondaryAccent, text4],
        stops: [progress, progress + 0.00001],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    final waveAmplitude = size.height * 0.11;
    final waveLength = size.width / 15;

    for (double x = 0; x < size.width; x++) {
      final y = size.height / 2 +
          waveAmplitude * math.sin(2 * math.pi * x / waveLength);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    if (progress < 1.0) {
      final unfilledPaint = Paint()
        ..strokeWidth = 2.5
        ..color = text4
        ..style = PaintingStyle.stroke;

      final unfilledPath = Path();
      for (double x = fillWidth; x < size.width; x++) {
        final y = size.height / 2 +
            waveAmplitude * math.sin(2 * math.pi * x / waveLength);
        if (x == fillWidth) {
          unfilledPath.moveTo(x, y);
        } else {
          unfilledPath.lineTo(x, y);
        }
      }
      canvas.drawPath(unfilledPath, unfilledPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WavyLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class AudioWaveformPainter extends CustomPainter {
  final double animationValue;
  final bool isStatic;
  final bool isPlaying;
  final Duration playbackPosition;
  final Duration totalDuration;
  final List<double> waveformSamples;
  AudioWaveformPainter(
    this.animationValue, {
    this.isStatic = false,
    this.isPlaying = false,
    this.playbackPosition = Duration.zero,
    this.totalDuration = const Duration(seconds: 1),
    this.waveformSamples = const [], // INITIALIZE
  }) : super(
            repaint: Listenable.merge(
                [ValueNotifier(animationValue)])); // Only animate if dynamic

  @override
  void paint(Canvas canvas, Size size) {
    // Determine the played percentage
    double playedRatio = totalDuration.inMilliseconds > 0
        ? playbackPosition.inMilliseconds / totalDuration.inMilliseconds
        : 0.0;

    // Define paints
    final playedPaint = Paint()
      ..color = Colors.white // White/Light color for played portion
      ..style = PaintingStyle.fill;

    final unplayedPaint = Paint()
      ..color =
          primaryAccent.withOpacity(0.5) // Accent color for unplayed portion
      ..style = PaintingStyle.fill;

    const double barWidth = 4.5;
    const double barSpacing = 5.0;

    final bool useSamples = waveformSamples.isNotEmpty && isStatic;

    final int numberOfBars = useSamples
        ? waveformSamples.length
        : (size.width / (barWidth + barSpacing)).floor();

    final double totalBarWidth =
        (numberOfBars * barWidth) + ((numberOfBars - 1) * barSpacing);
    final double startingX =
        (size.width - totalBarWidth) / 2; // Center the waveform
    final double center = size.height / 2;

    // Calculate the width covered by the played time
    double playedWidth = size.width * playedRatio;

    for (int i = 0; i < numberOfBars; i++) {
      double heightRatio;

      if (useSamples) {
        // Use actual sample data for the static (recorded) waveform
        heightRatio = waveformSamples[i].clamp(0.1, 1.0);
      } else {
        // Fallback to animated for the recording UI (isStatic=false)
        final double baseHeight =
            0.3 + (Random(i * 100).nextDouble() * 0.7); // Base height 30-100%
        // Add subtle animation based on the global animation value
        heightRatio =
            (baseHeight + 0.1 * sin(i + animationValue * 5)).clamp(0.1, 1.0);
      }

      double height = size.height * heightRatio;
      if (height < 2) height = 2; // Minimum height for visibility

      double x = startingX + i * (barWidth + barSpacing);

      // Select paint based on whether the bar's center position is before the played width
      final paint = x < playedWidth ? playedPaint : unplayedPaint;

      // Draw the bar centered vertically
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, center - height / 2, barWidth, height),
          const Radius.circular(0.75), // Slight rounding
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.playbackPosition != playbackPosition ||
        !listEquals(oldDelegate.waveformSamples, waveformSamples);
  }
}

class AnimatedWaveform extends StatefulWidget {
  final bool isStatic;
  final bool isPlaying;
  final Duration totalDuration;
  final Duration playbackPosition;
  final List<double> waveformSamples;

  const AnimatedWaveform({
    super.key,
    this.isStatic = false,
    this.isPlaying = false,
    this.totalDuration = const Duration(seconds: 1),
    this.playbackPosition = Duration.zero,
    this.waveformSamples = const [],
  });

  @override
  State<AnimatedWaveform> createState() => AnimatedWaveformState();
}

class AnimatedWaveformState extends State<AnimatedWaveform> {
  double _animationValue = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.isStatic) {
      _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (mounted) {
          setState(() {
            _animationValue += 0.1;
            if (_animationValue > 2 * pi) {
              _animationValue -= 2 * pi;
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: widget.isStatic ? 150 : 150,
      child: CustomPaint(
        painter: AudioWaveformPainter(
          _animationValue,
          isStatic: widget.isStatic,
          isPlaying: widget.isPlaying,
          totalDuration: widget.totalDuration,
          playbackPosition: widget.playbackPosition,
          waveformSamples: widget.waveformSamples,
        ),
      ),
    );
  }
}
