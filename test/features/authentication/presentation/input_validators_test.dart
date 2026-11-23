import 'package:flutter_test/flutter_test.dart';
import 'package:techsisters/features/authentication/presentation/widgets/input_validators.dart';

/// Input validator tests
void main() {
  group('InputValidator', () {
    group('validateEmail', () {
      test('should return error when email is empty', () {
        final result = InputValidator.validateEmail('');
        expect(result, 'Email is required');
      });

      test('should return error when email is null', () {
        final result = InputValidator.validateEmail(null);
        expect(result, 'Email is required');
      });

      test('should return error for invalid email format', () {
        final result = InputValidator.validateEmail('invalid-email');
        expect(result, 'Please enter a valid email');
      });

      test('should return null for valid email', () {
        final result = InputValidator.validateEmail('test@example.com');
        expect(result, null);
      });

      test('should validate email with numbers', () {
        final result = InputValidator.validateEmail('user123@example.com');
        expect(result, null);
      });

      test('should validate email with hyphens and dots', () {
        final result = InputValidator.validateEmail(
          'user.name-123@example.co.uk',
        );
        expect(result, null);
      });
    });

    group('validatePassword', () {
      test('should return error when password is empty', () {
        final result = InputValidator.validatePassword('');
        expect(result, 'Password is required');
      });

      test('should return error when password is null', () {
        final result = InputValidator.validatePassword(null);
        expect(result, 'Password is required');
      });

      test('should return error when password is too short', () {
        final result = InputValidator.validatePassword('Pass1');
        expect(result, 'Password must be at least 6 characters');
      });

      test('should return error when password lacks lowercase letters', () {
        final result = InputValidator.validatePassword('PASSWORD123');
        expect(result, 'Password must contain lowercase letters');
      });

      test('should return error when password lacks uppercase letters', () {
        final result = InputValidator.validatePassword('password123');
        expect(result, 'Password must contain uppercase letters');
      });

      test('should return error when password lacks numbers', () {
        final result = InputValidator.validatePassword('Password');
        expect(result, 'Password must contain numbers');
      });

      test('should return null for valid password', () {
        final result = InputValidator.validatePassword('Password123');
        expect(result, null);
      });

      test('should validate strong password', () {
        final result = InputValidator.validatePassword('SecurePass456!');
        expect(result, null);
      });
    });

    group('validateDisplayName', () {
      test('should return error when name is empty', () {
        final result = InputValidator.validateDisplayName('');
        expect(result, 'Name is required');
      });

      test('should return error when name is null', () {
        final result = InputValidator.validateDisplayName(null);
        expect(result, 'Name is required');
      });

      test('should return error when name is too short', () {
        final result = InputValidator.validateDisplayName('A');
        expect(result, 'Name must be at least 2 characters');
      });

      test('should return error when name is too long', () {
        final result = InputValidator.validateDisplayName('A' * 51);
        expect(result, 'Name must be less than 50 characters');
      });

      test('should return null for valid name', () {
        final result = InputValidator.validateDisplayName('John Doe');
        expect(result, null);
      });

      test('should validate name with numbers', () {
        final result = InputValidator.validateDisplayName('Jane123');
        expect(result, null);
      });
    });

    group('validateConfirmPassword', () {
      test('should return error when confirm password is empty', () {
        final result = InputValidator.validateConfirmPassword(
          'Password123',
          '',
        );
        expect(result, 'Please confirm your password');
      });

      test('should return error when confirm password is null', () {
        final result = InputValidator.validateConfirmPassword(
          'Password123',
          null,
        );
        expect(result, 'Please confirm your password');
      });

      test('should return error when passwords do not match', () {
        final result = InputValidator.validateConfirmPassword(
          'Password123',
          'Password456',
        );
        expect(result, 'Passwords do not match');
      });

      test('should return null when passwords match', () {
        final result = InputValidator.validateConfirmPassword(
          'Password123',
          'Password123',
        );
        expect(result, null);
      });
    });
  });
}
