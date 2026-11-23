import 'package:flutter_test/flutter_test.dart';

import 'package:techsisters/features/notes/domain/validators/note_validator.dart';

void main() {
  group('NoteValidator.validateTitle', () {
    test('rejects an empty or blank title', () {
      expect(NoteValidator.validateTitle(null), isNotNull);
      expect(NoteValidator.validateTitle(''), isNotNull);
      expect(NoteValidator.validateTitle('   '), isNotNull);
    });

    test('rejects a title longer than the limit', () {
      final longTitle = 'a' * (NoteValidator.maxTitleLength + 1);
      expect(NoteValidator.validateTitle(longTitle), isNotNull);
    });

    test('accepts a normal title', () {
      expect(NoteValidator.validateTitle('Exam revision'), isNull);
    });
  });

  group('NoteValidator.validateContent', () {
    test('accepts empty content because the body is optional', () {
      expect(NoteValidator.validateContent(''), isNull);
      expect(NoteValidator.validateContent(null), isNull);
    });

    test('rejects content longer than the limit', () {
      final longContent = 'a' * (NoteValidator.maxContentLength + 1);
      expect(NoteValidator.validateContent(longContent), isNotNull);
    });
  });
}
