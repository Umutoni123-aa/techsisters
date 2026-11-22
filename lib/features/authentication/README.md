# Authentication Feature

This directory contains the authentication feature for the TechSisters app, following clean architecture principles.

## Overview

The authentication feature handles user registration, login, password reset, and email verification using Firebase Authentication and Google Sign-In.

## Directory Structure

```
authentication/
├── data/
│   ├── datasources/
│   │   └── firebase_auth_datasource.dart    # Firebase authentication operations
│   ├── models/
│   │   └── user_model.dart                   # User data model
│   └── repositories/
│       └── auth_repository_impl.dart         # Repository implementation
├── domain/
│   ├── entities/
│   │   └── user_entity.dart                  # User entity (business logic)
│   ├── repositories/
│   │   └── auth_repository.dart              # Repository interface
│   └── usecases/
│       └── login_usecase.dart                # Authentication use cases
├── presentation/
│   ├── bloc/
│   │   ├── auth_bloc.dart                    # BLoC for state management
│   │   ├── auth_event.dart                   # Authentication events
│   │   └── auth_state.dart                   # Authentication states
│   ├── pages/
│   │   ├── login_page.dart                   # Login screen
│   │   └── register_page.dart                # Registration screen
│   └── widgets/
│       └── input_validators.dart             # Input validation utilities
└── README.md
```

## Features Implemented

### Authentication Methods
- ✅ Email/Password Registration
- ✅ Email/Password Login
- ✅ Google Sign-In
- ✅ Logout
- ✅ Password Reset
- ✅ Email Verification

### Input Validation
- ✅ Email format validation
- ✅ Password strength validation (min 6 chars, uppercase, lowercase, number)
- ✅ Display name validation
- ✅ Password confirmation matching

### UI Components
- ✅ Login Screen
- ✅ Registration Screen
- ✅ Password visibility toggle
- ✅ Loading states
- ✅ Error handling and display

## Testing

### Unit Tests
- `input_validators_test.dart`: Tests for email, password, and name validation

### Widget Tests
- `login_page_test.dart`: Tests for login screen UI and interactions

### Test Coverage
Aim: 70% or more coverage

Run tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Firebase Configuration

Before running the app, ensure Firebase is configured:

1. Create a Firebase project at https://console.firebase.google.com
2. Add iOS and Android apps to your Firebase project
3. Download and add configuration files:
   - `GoogleService-Info.plist` for iOS
   - `google-services.json` for Android
4. Enable authentication methods:
   - Email/Password
   - Google Sign-In

## State Management with BLoC

The authentication feature uses Flutter BLoC for state management:

### Events
- `RegisterEvent`: Register new user
- `LoginEvent`: Login with email/password
- `GoogleSignInEvent`: Login with Google
- `LogoutEvent`: Logout
- `ForgotPasswordEvent`: Send password reset email
- `SendEmailVerificationEvent`: Send email verification
- `CheckEmailVerificationEvent`: Check if email is verified
- `GetCurrentUserEvent`: Get current authenticated user

### States
- `AuthInitial`: Initial state
- `AuthLoading`: Loading state
- `AuthAuthenticated`: User is authenticated
- `AuthUnauthenticated`: User is not authenticated
- `EmailVerificationRequired`: Email verification needed
- `EmailVerified`: Email is verified
- `PasswordResetSent`: Password reset email sent
- `AuthError`: Error occurred

## Usage Example

```dart
// Add to your page
context.read<AuthBloc>().add(
  LoginEvent(
    email: 'user@example.com',
    password: 'Password123',
  ),
);

// Listen to state changes
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
    if (state is AuthAuthenticated) {
      // Navigate to home screen
    }
  },
  child: YourWidget(),
);
```

## Validation Rules

### Email
- Must be in valid email format
- Example: `user@example.com`

### Password
- Minimum 6 characters
- Must contain at least one uppercase letter
- Must contain at least one lowercase letter
- Must contain at least one number

### Display Name
- Minimum 2 characters
- Maximum 50 characters

## Error Handling

The feature provides user-friendly error messages for common Firebase authentication errors:
- User not found
- Incorrect password
- Email already in use
- Invalid email format
- Weak password
- Network errors

## Contributing

When making changes to this feature:
1. Follow clean architecture principles
2. Write unit tests for new functionality
3. Update widget tests for UI changes
4. Keep error messages user-friendly
5. Document any new validators or use cases

## Future Enhancements

- [ ] Phone number authentication
- [ ] Social login (Facebook, Apple)
- [ ] Two-factor authentication
- [ ] Biometric authentication
- [ ] Account recovery
- [ ] Session management
