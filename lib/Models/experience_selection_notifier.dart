// lib/providers/experience_selection_notifier.dart (New File)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';

import 'package:flutter_riverpod/legacy.dart'; // For HashSet

// Define the State structure for the entire screen
class ExperienceSelectionState {
  // Use a Set for efficient selection/deselection and storing IDs
  final Set<int> selectedIds;
  final String descriptionText;

  ExperienceSelectionState({
    required this.selectedIds,
    required this.descriptionText,
  });

  ExperienceSelectionState copyWith({
    Set<int>? selectedIds,
    String? descriptionText,
  }) {
    return ExperienceSelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      descriptionText: descriptionText ?? this.descriptionText,
    );
  }
}

// State Notifier (Controller/ViewModel)
final selectionNotifierProvider = StateNotifierProvider<
    ExperienceSelectionNotifier, ExperienceSelectionState>(
  (ref) {
    return ExperienceSelectionNotifier();
  },
);

class ExperienceSelectionNotifier
    extends StateNotifier<ExperienceSelectionState> {
  ExperienceSelectionNotifier()
      : super(ExperienceSelectionState(
          selectedIds: HashSet<int>(),
          descriptionText: '',
        ));

  void toggleExperience(int id) {
    final newSelectedIds = Set<int>.from(state.selectedIds);
    if (newSelectedIds.contains(id)) {
      newSelectedIds.remove(id); // Deselect
    } else {
      newSelectedIds.add(id); // Select
    }

    // Optional: Reordering logic for "Brownie Point" (handled in UI for simplicity here)

    state = state.copyWith(selectedIds: newSelectedIds);
  }

  void updateDescription(String text) {
    // Character limit of 250 is enforced in the TextFormField, but we update the state
    final safeText = text.length > 250 ? text.substring(0, 250) : text;
    state = state.copyWith(descriptionText: safeText);
  }

  void logAndNavigate(BuildContext context) {
    // Requirement: Log the state
    print('--- EXPERIENCE SELECTION STATE ---');
    print('Selected Club IDs: ${state.selectedIds.toList()}');
    print('Description Text: "${state.descriptionText}"');

    // Requirement: Redirect to next page
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => const OnboardingQuestionScreen()),
    // );
  }
}
