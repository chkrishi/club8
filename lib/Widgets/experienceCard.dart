// lib/widgets/experience_card.dart
import 'dart:ui';
import 'package:club8/Assets/font_Styles.dart';
import 'package:flutter/material.dart';
import 'package:club8/Assets/colors.dart'; // Assuming your colors are here
import 'package:club8/Models/club8Model.dart'; // Your club model

class ExperienceCard extends StatelessWidget {
  final club experience;
  final bool isSelected;
  final VoidCallback onTap;

  const ExperienceCard({
    required this.experience,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  // Grayscale ColorFilter matrix (standard for 1.0 grayscale)
  static const ColorFilter greyscaleFilter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, // Red
    0.2126, 0.7152, 0.0722, 0, 0, // Green
    0.2126, 0.7152, 0.0722, 0, 0, // Blue
    0, 0, 0, 1, 0, // Alpha
  ]);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180, // Approximate height based on typical card size
        width: 160, // Approximate width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: primaryAccent, width: 2) // Selected border
              : Border.all(
                  color: border1, width: 1), // Unselected subtle border
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: ColorFiltered(
            // Apply grayscale only if the card is NOT selected
            colorFilter: isSelected
                ? const ColorFilter.mode(
                    Colors.transparent, BlendMode.saturation)
                : greyscaleFilter,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Image.network(
                  experience.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: primaryAccent,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error_outline, color: text)),
                ),

                // Gradient Overlay (Darkening effect for text)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, surfaceBlack_3],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.5, 1.0],
                    ),
                  ),
                ),

                // Text Content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experience.name,
                        style: b1Bold.copyWith(color: text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        experience.tagline,
                        style: s1Regular.copyWith(color: text3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Selection Indicator
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: primaryAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: text, width: 2),
                      ),
                      child: const Icon(Icons.check, color: text, size: 14),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
