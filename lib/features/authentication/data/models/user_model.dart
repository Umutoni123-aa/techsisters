import 'package:techsisters/features/authentication/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.emailVerified,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      emailVerified: entity.emailVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
    };
  }

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
