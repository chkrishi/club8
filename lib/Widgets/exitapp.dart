import 'dart:io';

import 'package:flutter/material.dart';

Future<bool> onWillPop(BuildContext context) async {
  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Exit App'),
      content: const Text('Are you sure you want to exit the app?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Stay
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true), // Exit
          child: const Text('Yes'),
        ),
      ],
    ),
  );

  if (shouldExit == true) {
    exit(0); // Exit the app
  }
  return false; // Prevent default back navigation
}
