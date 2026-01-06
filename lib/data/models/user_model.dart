import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final bool emailVerified;
  final DateTime? lastSignInTime;
  final DateTime? creationTime;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.emailVerified,
    this.lastSignInTime,
    this.creationTime,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      emailVerified: user.emailVerified,
      lastSignInTime: user.metadata.lastSignInTime,
      creationTime: user.metadata.creationTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'emailVerified': emailVerified,
      'lastSignInTime': lastSignInTime?.toIso8601String(),
      'creationTime': creationTime?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      emailVerified: map['emailVerified'] ?? false,
      lastSignInTime: map['lastSignInTime'] != null
          ? DateTime.parse(map['lastSignInTime'])
          : null,
      creationTime: map['creationTime'] != null
          ? DateTime.parse(map['creationTime'])
          : null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? emailVerified,
    DateTime? lastSignInTime,
    DateTime? creationTime,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      emailVerified: emailVerified ?? this.emailVerified,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      creationTime: creationTime ?? this.creationTime,
    );
  }

  String get name => displayName ?? email.split('@').first;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, emailVerified: $emailVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.emailVerified == emailVerified &&
        other.lastSignInTime == lastSignInTime &&
        other.creationTime == creationTime;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        emailVerified.hashCode ^
        lastSignInTime.hashCode ^
        creationTime.hashCode;
  }
}
