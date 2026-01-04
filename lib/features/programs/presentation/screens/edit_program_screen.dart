import 'package:flutter/material.dart';

import 'create_program_screen.dart';

/// Edit program screen - extends create program with existing data
class EditProgramScreen extends StatelessWidget {
  final String programId;

  const EditProgramScreen({
    super.key,
    required this.programId,
  });

  @override
  Widget build(BuildContext context) {
    // For now, reuse CreateProgramScreen
    // Will load existing program data and pass to form
    return const CreateProgramScreen();
  }
}
