import 'dart:io';

import 'package:club8/Assets/colors.dart';
import 'package:club8/Widgets/exitapp.dart';
import 'package:club8/Widgets/wavyLine.dart';
import 'package:flutter/material.dart';

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double value;
  final double start;
  final double end;
  final VoidCallback? fns;

  const CommonAppBar({
    super.key,
    required this.value,
    required this.start,
    required this.end,
    required this.fns,
  });

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _CommonAppBarState extends State<CommonAppBar> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final waveWidth = screenWidth * 0.6;

    return AppBar(
        backgroundColor: surfaceWhite_1,
        leading: BackButton(
          color: text,
          onPressed: widget.fns,
        ),
        centerTitle: true,
        title: SizedBox(
          width: waveWidth,
          height: 34,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: widget.start, end: widget.end),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return CustomPaint(
                painter: WavyLinePainter(progress: value),
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: text),
            onPressed: () {
              onWillPop(context);
            },
          )
        ]);
  }
}
