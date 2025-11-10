import 'package:club8/assets/font_Styles.dart';
import 'package:club8/Screens/Onboarding%20Screen/oS.dart';
import 'package:club8/Widgets/wavyLine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../assets/colors.dart';

class RecordedMediaCard extends ConsumerWidget {
  final String type; // 'Audio' or 'Video'
  final Duration duration;
  final VoidCallback onDelete;

  const RecordedMediaCard({
    required this.type,
    required this.duration,
    required this.onDelete,
    super.key,
  });

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(questionProvider.notifier);
    final isAudio = type == 'Audio';

    // State watching for Audio Playback
    final isPlaying = isAudio
        ? ref.watch(questionProvider.select((state) => state.isPlayingAudio))
        : false;
    final playbackPosition = isAudio
        ? ref.watch(questionProvider.select((state) => state.playbackPosition))
        : Duration.zero;
    final waveformSamples = isAudio
        ? ref.watch(questionProvider.select((state) => state.waveformSamples))
        : <double>[];

    // Determine the duration to show (total or current playback position)
    final displayDuration = isAudio && isPlaying ? playbackPosition : duration;
    final formattedDuration = _formatDuration(displayDuration);

    void onPlayPauseTapped() {
      if (isAudio) {
        if (isPlaying) {
          notifier.pauseAudioPlayback();
        } else {
          notifier.startAudioPlayback();
        }
      } else {
        print('Playing video: $formattedDuration');
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceBlack_5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: onPlayPauseTapped,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: primaryAccent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAudio && isPlaying ? Icons.pause : Icons.play_arrow,
                color: text,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: isAudio
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: AnimatedWaveform(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formattedDuration,
                        style: s1Regular.copyWith(color: text),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(Icons.videocam, color: text2, size: 24),
                      const SizedBox(width: 8),
                      // Text is flexible within the Expanded container
                      Flexible(
                        child: Text(
                          'Video (${_formatDuration(duration)})',
                          style: b1Regular.copyWith(color: text),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
          // Added a small gap before the Delete button for visual separation
          const SizedBox(width: 8),

          // 3. Delete Button (Fixed width, uses minimum space)
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: secondaryAccent, size: 24),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
