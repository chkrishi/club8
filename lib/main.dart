import 'package:club8/Assets/colors.dart';
import 'package:club8/Screens/Experience%20Screen/eS1.dart';
import 'package:club8/Screens/Onboarding%20Screen/oS.dart';
import 'package:club8/Widgets/recorder.dart';
import 'package:club8/Widgets/videorecorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '8 club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryAccent),
      ),
      home: SafeArea(child: ExperienceSelectionScreen()),
    );
  }
}
