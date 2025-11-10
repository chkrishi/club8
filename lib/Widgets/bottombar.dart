import 'package:club8/assets/colors.dart';
import 'package:club8/assets/font_Styles.dart';
import 'package:club8/Services/providers.dart';
import 'package:club8/Widgets/nextbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Bottombar extends ConsumerWidget {
  const Bottombar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool cam = ref.watch(camProvider);
    bool audio = ref.watch(audioProvider);
    bool text = ref.watch(textProvider);

    bool nextEnabled = cam || audio || text;

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic_none),
          ),
          Text(
            '|',
            style: h1Bold,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined),
          ),
          NextButton(
            size: Size(250, 60),
            enabled: nextEnabled,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
