import 'package:club8/assets/colors.dart';
import 'package:club8/assets/font_Styles.dart';
import 'package:club8/Screens/Onboarding%20Screen/oS.dart';
import 'package:club8/Widgets/recordedMediaCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestionInputArea extends ConsumerWidget {
  const QuestionInputArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionProvider);
    final notifier = ref.read(questionProvider.notifier);

    final controller = TextEditingController(text: state.textval);
    controller.selection =
        TextSelection.collapsed(offset: state.textval.length);

    return Column(
      children: [
        Container(
          height: state.hasAnyRecording || state.isRecordingAudio ? 250 : 350,
          width: 358,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: surfaceWhite_2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color:
                    state.hasAnyRecording ? Colors.transparent : primaryAccent,
                width: 1),
          ),
          constraints: const BoxConstraints(minHeight: 120),
          child: TextField(
            controller: controller,
            onChanged: notifier.updateText,
            maxLines: null,
            maxLength: 600,
            expands: true,
            keyboardType: TextInputType.multiline,
            style: s2,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: ' /Start typing here',
              hintStyle: s1Regular,
              counterText: '',
            ),
          ),
        ),
        if (state.hasAnyRecording) ...[
          if (state.recordedAudioPath != null)
            RecordedMediaCard(
              type: 'Audio',
              duration: state.recordingDuration,
              onDelete: notifier.deleteAudio,
            ),
          if (state.recordedVideoPath != null)
            RecordedMediaCard(
              type: 'Video',
              duration: state.recordingDuration,
              onDelete: notifier.deleteVideo,
            ),
        ],
        SizedBox(height: MediaQuery.of(context).size.height * 0.08),
      ],
    );
  }
}
