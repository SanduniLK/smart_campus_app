class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final bool isEmailVerified;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isEmailVerified,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      fullName: map['fullName'],
      role: map['role'],
      isEmailVerified: map['isEmailVerified'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'isEmailVerified': isEmailVerified ? 1 : 0,
    };
  }
}