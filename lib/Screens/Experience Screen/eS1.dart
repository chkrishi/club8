// lib/screens/experience_selection_screen.dart

import 'package:club8/Assets/colors.dart';
import 'package:club8/Assets/font_Styles.dart';
import 'package:club8/Models/experience_selection_notifier.dart';
import 'package:club8/Models/urlProvider.dart';
import 'package:club8/Widgets/appbar.dart';
import 'package:club8/Widgets/exitapp.dart';
import 'package:club8/Widgets/experienceCard.dart';
import 'package:club8/Widgets/nextbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Onboarding Screen/oS.dart';

class ExperienceSelectionScreen extends ConsumerWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(clubProvider);
    final selectionState = ref.watch(selectionNotifierProvider);
    final notifier = ref.read(selectionNotifierProvider.notifier);

    final isNextEnabled = selectionState.selectedIds.isNotEmpty ||
        selectionState.descriptionText.isNotEmpty;

    return Scaffold(
        backgroundColor: base2_1,
        appBar: CommonAppBar(
          value: 0.3,
          start: 0,
          end: 0.3,
          fns: () => onWillPop(context),
        ),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.19),
                Text('Q1', style: s1Regular),
                Text(
                  'What kind of hotspots do you want to host?',
                  style: h1Bold.copyWith(color: text),
                ),
                const SizedBox(height: 24),
                clubsAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(color: primaryAccent),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      'Error loading experiences: $err',
                      style: b1Regular.copyWith(color: negative),
                    ),
                  ),
                  data: (clubs) {
                    return SizedBox(
                      height: 196,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: clubs.length,
                        itemBuilder: (context, index) {
                          final clubItem = clubs[index];
                          final isSelected =
                              selectionState.selectedIds.contains(clubItem.id);

                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: SizedBox(
                              width: 180,
                              child: ExperienceCard(
                                experience: clubItem,
                                isSelected: isSelected,
                                onTap: () =>
                                    notifier.toggleExperience(clubItem.id),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildDescriptionTextField(
                  ref,
                  selectionState.descriptionText,
                  notifier,
                ),
                const SizedBox(height: 10),
                NextButton(
                    size: Size(600, 60),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => QuestionScreen()));
                    },
                    enabled: isNextEnabled)
              ],
            ),
          ),
        ));
    // bottomNavigationBar: Padding(
    //     padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    //     child: ));
  }

  Widget _buildDescriptionTextField(
      WidgetRef ref, String currentText, ExperienceSelectionNotifier notifier) {
    const int characterLimit = 250;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: currentText,
          onChanged: notifier.updateDescription,
          maxLength: characterLimit,
          maxLines: 4,
          minLines: 4,
          cursorColor: primaryAccent,
          keyboardType: TextInputType.multiline,
          style: b1Regular.copyWith(color: text),
          decoration: InputDecoration(
            hintText: 'Any other experience type you’d like to mention?',
            hintStyle: b1Regular.copyWith(color: text3),
            counterText: '${currentText.length}/$characterLimit',
            counterStyle: s1Regular.copyWith(
                color: currentText.length == characterLimit
                    ? primaryAccent
                    : text3),
            filled: true,
            fillColor: surfaceWhite_2,
            contentPadding: const EdgeInsets.all(16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border1, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
