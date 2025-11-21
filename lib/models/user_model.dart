class UserModel {
  final String uid;
  final String email;
  final String role; // 'admin' or 'user'

  UserModel({required this.uid, required this.email, required this.role});

  // Convert Firestore Document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  // Convert UserModel to Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {'email': email, 'role': role};
  }
}
