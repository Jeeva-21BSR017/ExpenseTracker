class BudgetModel {
  final String id;
  final String uid;
  final String category;
  final double limit;

  BudgetModel({
    required this.id,
    required this.uid,
    required this.category,
    required this.limit,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> data, String id) {
    return BudgetModel(
      id: id,
      uid: data['uid'] ?? '',
      category: data['category'] ?? 'General',
      limit: (data['limit'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'category': category, 'limit': limit};
  }
}
