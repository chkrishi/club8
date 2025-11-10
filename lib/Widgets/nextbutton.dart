import 'package:club8/assets/colors.dart';
import 'package:club8/assets/font_Styles.dart';
import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool enabled;
  final Size size;
  const NextButton({
    super.key,
    required this.onPressed,
    required this.enabled,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = enabled ? text : text3;
    final borderColor = enabled ? boder2 : border1;

    return Container(
      decoration: enabled
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: -3,
                  offset: const Offset(0, -2),
                ),
              ],
            )
          : null,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          fixedSize: size,
          backgroundColor: base2_2,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withOpacity(0.05);
              }
              return null;
            },
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (enabled)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        surfaceWhite_2,
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.4],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next', style: enabled ? b1Regular : b1Regulard),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: textColor,
                    size: 25,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
