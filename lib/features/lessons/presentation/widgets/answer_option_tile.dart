import 'package:flutter/material.dart';
import 'package:techsisters/features/lessons/presentation/widgets/lessons_colors.dart';

/// One selectable answer, e.g. "A. The AI model might not have been trained…".
class AnswerOptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final bool selected;

  /// True when this selected option was checked and is wrong.
  final bool wrong;

  /// True when this selected option was checked and is right.
  final bool correct;
  final VoidCallback? onTap;

  const AnswerOptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.selected,
    required this.wrong,
    required this.correct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = wrong
        ? LessonsColors.coral
        : correct
        ? LessonsColors.green
        : LessonsColors.purple;
    final borderColor = selected ? accent : LessonsColors.border;
    final background = !selected
        ? Colors.white
        : wrong
        ? LessonsColors.coralSurface
        : correct
        ? LessonsColors.greenSurface
        : LessonsColors.purpleSurface.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  correct
                      ? Icons.check_circle
                      : wrong
                      ? Icons.cancel
                      : selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? accent : LessonsColors.border,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$letter.  ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                        TextSpan(text: text),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: LessonsColors.ink,
                    ),
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
