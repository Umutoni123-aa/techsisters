import 'package:flutter/material.dart';
import 'package:techsisters/core/theme/app_theme.dart';

/// Multi-line text box for the body of a note.
///
/// Looks the same as the shared AppTextField (label above, white fill,
/// rounded slate border, violet border when focused), but grows to several
/// lines, which AppTextField does not support.
class NoteBodyField extends StatelessWidget {
  const NoteBodyField({super.key, required this.controller, this.validator});

  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.slate600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          minLines: 6,
          maxLines: 12,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: 'Write what you learned...',
            hintStyle: const TextStyle(color: AppColors.slate400),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.all(16),
            border: border(AppColors.slateBorder),
            enabledBorder: border(AppColors.slateBorder),
            focusedBorder: border(AppColors.primary, width: 2),
            errorBorder: border(AppColors.coral),
            focusedErrorBorder: border(AppColors.coral, width: 2),
          ),
        ),
      ],
    );
  }
}
