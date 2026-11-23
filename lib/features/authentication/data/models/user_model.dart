import 'package:techsisters/features/authentication/domain/entities/user_entity.dart';

/// User model for data layer
class UserModel extends UserEntity {
  UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    bool emailVerified = false,
  }) : super(
    uid: uid,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
    emailVerified: emailVerified,
  );

  /// Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      emailVerified: entity.emailVerified,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
    };
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
  }
}
