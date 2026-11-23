/// Checks the text a learner types when saving a portfolio project.
/// Each method returns an error message, or null when the value is fine, so
/// it can be used directly as a form field validator.
class ProjectValidator {
  ProjectValidator._();

  static const int minTitleLength = 3;
  static const int maxTitleLength = 60;

  /// The title is required and must be a sensible length.
  static String? validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'Please give your project a title';
    if (title.length < minTitleLength) {
      return 'The title must have at least $minTitleLength letters';
    }
    if (title.length > maxTitleLength) {
      return 'The title must be at most $maxTitleLength letters';
    }
    return null;
  }

  /// The link is optional, but when given it must be a web address.
  static String? validateLink(String? value) {
    final link = value?.trim() ?? '';
    if (link.isEmpty) return null;
    final uri = Uri.tryParse(link);
    final isWebAddress =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
    return isWebAddress ? null : 'Enter a web address starting with https://';
  }
}
