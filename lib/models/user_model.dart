class UserModel {
  final String uid;
  final String email;
  final String role;
  final String? displayName;
  final String? photoUrl;
  final Map<String, bool> notifications;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.photoUrl,
    this.notifications = const {
      'expenseAlert': true,
      'budgetExceeded': true,
      'weeklyReport': false,
      'newUpdates': true,
    },
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      notifications: data['notifications'] != null
          ? Map<String, bool>.from(data['notifications'])
          : const {
              'expenseAlert': true,
              'budgetExceeded': true,
              'weeklyReport': false,
              'newUpdates': true,
            },
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'notifications': notifications,
    };
  }
}
