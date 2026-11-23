/// Input rules for notes. Kept in the domain layer so the same rules are
/// used by the form and covered by unit tests, instead of living in a widget.
///
/// The limits match the checks in `firestore.rules`.
class NoteValidator {
  const NoteValidator._();

  static const int maxTitleLength = 100;
  static const int maxContentLength = 5000;

  /// Returns an error message, or `null` when the title is valid.
  static String? validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) {
      return 'Please give your note a title.';
    }
    if (title.length > maxTitleLength) {
      return 'Titles can be at most $maxTitleLength characters.';
    }
    return null;
  }

  /// Returns an error message, or `null` when the content is valid.
  /// Content is optional, so an empty note body is allowed.
  static String? validateContent(String? value) {
    final content = value?.trim() ?? '';
    if (content.length > maxContentLength) {
      return 'Notes can be at most $maxContentLength characters.';
    }
    return null;
  }
}
