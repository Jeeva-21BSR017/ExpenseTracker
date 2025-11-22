import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String uid;
  final double amount;
  final String type;
  final String category;
  final String note;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.uid,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.date,
  });

  factory TransactionModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      uid: data['uid'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: data['type'] ?? 'expense',
      category: data['category'] ?? 'General',
      note: data['note'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'amount': amount,
      'type': type,
      'category': category,
      'note': note,
      'date': Timestamp.fromDate(date),
    };
  }
}
