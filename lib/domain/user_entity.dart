class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String role; // Always 'student' on registration. 'admin' is set only in backend for moderation.
  final bool verified; // Used for admin verification and badges
  final String? photoURL;
  final String? phone;
  final String? school;
  final String? campus;
  final String? studentId;
  final String? studentIdPhotoUrl;
  final String? location;
  final String? dateOfBirth;
  final String? gender;
  final String? profilePhotoUrl;
  final String? bio;
  final String? verificationStatus; // pending, approved, denied

  UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.verified,
    this.photoURL,
    this.phone,
    this.school,
    this.campus,
    this.studentId,
    this.studentIdPhotoUrl,
    this.location,
    this.dateOfBirth,
    this.gender,
    this.profilePhotoUrl,
    this.bio,
    this.verificationStatus,
  });

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    bool? verified,
    String? photoURL,
    String? phone,
    String? school,
    String? campus,
    String? studentId,
    String? studentIdPhotoUrl,
    String? location,
    String? dateOfBirth,
    String? gender,
    String? profilePhotoUrl,
    String? bio,
    String? verificationStatus,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      verified: verified ?? this.verified,
      photoURL: photoURL ?? this.photoURL,
      phone: phone ?? this.phone,
      school: school ?? this.school,
      campus: campus ?? this.campus,
      studentId: studentId ?? this.studentId,
      studentIdPhotoUrl: studentIdPhotoUrl ?? this.studentIdPhotoUrl,
      location: location ?? this.location,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bio: bio ?? this.bio,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

  factory UserEntity.fromMap(Map<String, dynamic> map, String uid) {
    return UserEntity(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      verified: map['verified'] ?? false,
      photoURL: map['photoURL'],
      phone: map['phone'],
      school: map['school'],
      campus: map['campus'],
      studentId: map['studentId'],
      studentIdPhotoUrl: map['studentIdPhotoUrl'],
      location: map['location'],
      dateOfBirth: map['dateOfBirth'],
      gender: map['gender'],
      profilePhotoUrl: map['profilePhotoUrl'],
      bio: map['bio'],
      verificationStatus: map['verificationStatus'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'verified': verified,
      'photoURL': photoURL,
      'phone': phone,
      'school': school,
      'campus': campus,
      'studentId': studentId,
      'studentIdPhotoUrl': studentIdPhotoUrl,
      'location': location,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'profilePhotoUrl': profilePhotoUrl,
      'bio': bio,
      'verificationStatus': verificationStatus,
    };
  }
} 