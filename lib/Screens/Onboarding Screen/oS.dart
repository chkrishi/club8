import 'dart:io';

import 'package:club8/assets/colors.dart';
import 'package:club8/assets/font_Styles.dart';
import 'package:club8/Widgets/appBar.dart';
import 'package:club8/Widgets/nextbutton.dart';
import 'package:club8/Widgets/questionInputArea.dart';
import 'package:club8/Widgets/recordedMediaCard.dart';
import 'package:club8/Widgets/videoplayer.dart';
import 'package:club8/Widgets/videorecorder.dart';
import 'package:club8/Widgets/wavyLine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import '../Experience Screen/eS1.dart';

final _recorder = AudioRecorder();

const int characterLimit = 600;

@immutable
class QuestionData {
  final String textval;
  final String? recordedAudioPath;
  final String? recordedVideoPath;
  final bool isRecordingAudio;
  final bool isRecordingVideo;
  final Duration recordingDuration;
  final bool isPlayingAudio;
  final Duration playbackPosition;
  final List<double> waveformSamples;

  const QuestionData({
    required this.textval,
    this.recordedAudioPath,
    this.recordedVideoPath,
    required this.isRecordingAudio,
    required this.isRecordingVideo,
    required this.recordingDuration,
    required this.isPlayingAudio,
    required this.playbackPosition,
    this.waveformSamples = const [],
  });

  factory QuestionData.initial() => const QuestionData(
        textval: '',
        isRecordingAudio: false,
        isRecordingVideo: false,
        recordingDuration: Duration.zero,
        isPlayingAudio: false,
        playbackPosition: Duration.zero,
        waveformSamples: [],
      );

  QuestionData copyWith({
    String? textval,
    String? recordedAudioPath,
    String? recordedVideoPath,
    bool? isRecordingAudio,
    bool? isRecordingVideo,
    Duration? recordingDuration,
    bool? isPlayingAudio,
    Duration? playbackPosition,
    List<double>? waveformSamples,
    bool clearAudioPath = false,
    bool clearVideoPath = false,
  }) {
    return QuestionData(
      textval: textval ?? this.textval,
      recordedAudioPath:
          clearAudioPath ? null : recordedAudioPath ?? this.recordedAudioPath,
      recordedVideoPath:
          clearVideoPath ? null : recordedVideoPath ?? this.recordedVideoPath,
      isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      isPlayingAudio: isPlayingAudio ?? this.isPlayingAudio,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      waveformSamples: waveformSamples ?? this.waveformSamples,
    );
  }

  bool get hasAnyRecording =>
      recordedAudioPath != null || recordedVideoPath != null;
  int get remainingCharacters => characterLimit - textval.length;
}

class QuestionNotifier extends StateNotifier<QuestionData> {
  Timer? _recordingTimer;
  final AudioPlayer _player = AudioPlayer();

  QuestionNotifier() : super(QuestionData.initial());

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        recordingDuration: state.recordingDuration + const Duration(seconds: 1),
      );
    });
  }

  void updateText(String newText) {
    if (newText.length <= characterLimit) {
      state = state.copyWith(textval: newText);
    }
  }

  Future<void> startAudioRecording() async {
    stopAudioPlayback();

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      debugPrint("Microphone permission denied");
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav";

    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );

    state = state.copyWith(
      isRecordingAudio: true,
      recordedAudioPath: null,
      clearVideoPath: true,
      recordingDuration: Duration.zero,
      waveformSamples: [],
    );

    _startRecordingTimer();
  }

  Future<void> stopAudioRecording() async {
    _recordingTimer?.cancel();

    final path = await _recorder.stop();

    if (path == null || !File(path).existsSync()) {
      debugPrint("Recorder returned no file");
      return;
    }

    final duration = state.recordingDuration;
    final totalSamples = max(1, duration.inSeconds * 25);
    final samples = List.generate(totalSamples, (i) {
      final t = i / totalSamples;
      final noise = Random().nextDouble() * 0.7;
      return noise.clamp(0.2, 1.0);
    });

    state = state.copyWith(
      isRecordingAudio: false,
      recordedAudioPath: path,
      waveformSamples: samples,
    );

    debugPrint("Saved real audio to: $path");
  }

  void cancelAudioRecording() {
    _recordingTimer?.cancel();
    state = state.copyWith(
      isRecordingAudio: false,
      recordingDuration: Duration.zero,
      waveformSamples: [],
    );
  }

  void deleteAudio() {
    stopAudioPlayback();
    state = state.copyWith(clearAudioPath: true, waveformSamples: []);
  }

  Future<void> startAudioPlayback() async {
    final path = state.recordedAudioPath;
    if (path == null) {
      debugPrint("No audio to play");
      return;
    }

    try {
      await _player.setFilePath(path);

      _player.positionStream.listen((pos) {
        if (!mounted) return;
        state = state.copyWith(playbackPosition: pos);
      });

      _player.playerStateStream.listen((playerState) {
        if (!mounted) return;
        if (playerState.processingState == ProcessingState.completed) {
          stopAudioPlayback();
        }
      });

      await _player.play();
      state = state.copyWith(isPlayingAudio: true);
    } catch (e) {
      debugPrint("Audio playback error: $e");
    }
  }

  Future<void> pauseAudioPlayback() async {
    await _player.pause();
    state = state.copyWith(isPlayingAudio: false);
  }

  Future<void> stopAudioPlayback() async {
    await _player.stop();
    await _player.seek(Duration.zero);
    state = state.copyWith(
      isPlayingAudio: false,
      playbackPosition: Duration.zero,
    );
  }

  void startVideoRecording() {
    state = state.copyWith(
      isRecordingVideo: true,
      isRecordingAudio: false,
      recordedVideoPath: null,
      clearAudioPath: true,
      recordingDuration: Duration.zero,
    );
    _startRecordingTimer();
  }

  void stopVideoRecording() {
    _recordingTimer?.cancel();
    state = state.copyWith(
      isRecordingVideo: false,
      recordedVideoPath:
          'video/temp_${DateTime.now().millisecondsSinceEpoch}.mp4',
      recordingDuration: Duration(seconds: Random().nextInt(59)),
    );
  }

  void deleteVideo() {
    state = state.copyWith(clearVideoPath: true);
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _player.dispose();

    super.dispose();
  }
}

final questionProvider =
    StateNotifierProvider<QuestionNotifier, QuestionData>((ref) {
  return QuestionNotifier();
});

class QuestionScreen extends ConsumerWidget {
  QuestionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionProvider);
    final nextEnabled = state.textval.isNotEmpty || state.hasAnyRecording;

    return Scaffold(
      appBar: CommonAppBar(
        value: 0.3,
        start: 0.3,
        end: 0.6,
        fns: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ExperienceSelectionScreen()),
          );
        },
      ),
      backgroundColor: surfaceBlack_3,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.12),
              Text('Q2', style: s1Regular),
              SizedBox(height: 24),
              Text('Why do you want to host with us?', style: h2Bold),
              SizedBox(height: 8),
              if (!nextEnabled) ...[
                Text(
                  'Tell us about your intent and what motivates you to create experiences.',
                  style: b2Regular,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              ],
              QuestionInputArea(),
              QuestionControlPanel()
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionControlPanel extends ConsumerWidget {
  const QuestionControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionProvider);

    final nextEnabled = state.textval.isNotEmpty || state.hasAnyRecording;

    // 1. Audio Recording UI
    if (state.isRecordingAudio) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: AudioRecordingUI(
          state: state,
          notifier: ref.read(questionProvider.notifier),
        ),
      );
    }

    // 2. Video Recording UI
    if (state.isRecordingVideo) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: VideoRecordingUI(
          state: state,
          notifier: ref.read(questionProvider.notifier),
        ),
      );
    }

    // 3. Video Playback UI
    // Display the video card if a video is recorded (and not currently recording/playing audio)
    if (state.recordedVideoPath != null) {
      return Column(
        children: [
          VideoPlaybackCard(
            state: state,
            notifier: ref.read(questionProvider.notifier),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: NextButton(
              size: Size(600, 60),
              enabled: nextEnabled,
              onPressed: () {},
            ),
          ),
        ],
      );
    }

    return ActionButtonRow(
      state: state,
      notifier: ref.read(questionProvider.notifier),
    );
  }
}

class VideoPlaybackCard extends StatelessWidget {
  final QuestionData state;
  final QuestionNotifier notifier;

  const VideoPlaybackCard({
    required this.state,
    required this.notifier,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceBlack_5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.videocam, color: primaryAccent, size: 24),
                    const SizedBox(width: 8),
                    Text('Recorded Video', style: s1Regular),
                  ],
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: notifier.deleteVideo,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            color: surfaceBlack_3,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_fill, color: text3, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Video Path: ${state.recordedVideoPath}',
                  style: b2Regular?.copyWith(color: text3),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Duration: ${state.recordingDuration.inSeconds}s',
                  style: b2Regular?.copyWith(color: text3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioRecordingUI extends StatelessWidget {
  final QuestionData state;
  final QuestionNotifier notifier;
  const AudioRecordingUI(
      {required this.state, required this.notifier, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        '${state.recordingDuration.inMinutes.toString().padLeft(2, '0')}:${(state.recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: surfaceBlack_5,
      child: Expanded(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SimpleControlIcon(
                  icon: Icons.close,
                  color: text3,
                  onTap: notifier.cancelAudioRecording,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AnimatedWaveform(),
                      const SizedBox(width: 12),
                      Text(
                        formattedTime,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                _SimpleControlIcon(
                  icon: Icons.done,
                  color: primaryAccent,
                  onTap: notifier.stopAudioRecording,
                ),
              ],
            ),
            ActionButtonRow(state: state, notifier: notifier)
          ],
        ),
      ),
    );
  }
}

class VideoRecordingUI extends ConsumerWidget {
  final QuestionData state;
  final QuestionNotifier notifier;
  const VideoRecordingUI(
      {required this.state, required this.notifier, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool canProceed = state.textval.isNotEmpty || state.hasAnyRecording;

    String formattedTime =
        '${state.recordingDuration.inMinutes.toString().padLeft(2, '0')}:${(state.recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: surfaceBlack_5,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SimpleControlIcon(
                icon: Icons.close,
                color: canProceed ? primaryAccent : secondaryAccent,
                onTap: () {
                  notifier.deleteVideo();
                },
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam, color: primaryAccent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Recording: $formattedTime',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              _SimpleControlIcon(
                icon: Icons.done,
                color: canProceed ? primaryAccent : secondaryAccent,
                onTap: notifier.stopVideoRecording,
              ),
            ],
          ),
          ActionButtonRow(
            state: state,
            notifier: ref.read(questionProvider.notifier),
          )
        ],
      ),
    );
  }
}

class ActionButtonRow extends StatelessWidget {
  final QuestionData state;
  final QuestionNotifier notifier;

  const ActionButtonRow({
    required this.state,
    required this.notifier,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool canProceed = state.textval.isNotEmpty || state.hasAnyRecording;

    final bool audioDisabled = state.isPlayingAudio ||
        state.recordedVideoPath != null ||
        state.isRecordingVideo;

    final bool videoDisabled = state.isPlayingAudio ||
        state.isRecordingAudio ||
        state.recordedAudioPath != null;

    return Container(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.mic_none,
                  color: audioDisabled ? text3 : text, size: 28),
              onPressed: audioDisabled
                  ? null
                  : () {
                      notifier.startAudioRecording();
                    },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.videocam_outlined,
                  color: videoDisabled ? text3 : text, size: 28),
              onPressed: videoDisabled
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoRecordScreen(),
                        ),
                      );
                    },
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.55,
              ),
              child: NextButton(
                onPressed: () {},
                enabled: canProceed,
                size: const Size(double.infinity, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleControlIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SimpleControlIcon({
    required this.icon,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
