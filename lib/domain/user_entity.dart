class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String role; // student, seller, landlord, admin
  final bool verified;
  final String? photoURL;

  UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.verified,
    this.photoURL,
  });

  factory UserEntity.fromMap(Map<String, dynamic> map, String uid) {
    return UserEntity(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      verified: map['verified'] ?? false,
      photoURL: map['photoURL'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'verified': verified,
      'photoURL': photoURL,
    };
  }
} 