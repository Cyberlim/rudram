import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { credit, debit }
enum TransactionCategory { order, cashback, refund, topup, reward }

class WalletTransaction {
  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;

  WalletTransaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.category,
  });

  factory WalletTransaction.fromMap(String id, Map<String, dynamic> data) {
    return WalletTransaction(
      id: id,
      title: data['title'] ?? '',
      date: data['date'] != null 
          ? (data['date'] as Timestamp).toDate() 
          : DateTime.now(),
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: data['type'] == 'debit' 
          ? TransactionType.debit 
          : TransactionType.credit,
      category: _parseCategory(data['category']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'type': type.name,
      'category': category.name,
    };
  }

  static TransactionCategory _parseCategory(String? cat) {
    switch (cat) {
      case 'order': return TransactionCategory.order;
      case 'cashback': return TransactionCategory.cashback;
      case 'refund': return TransactionCategory.refund;
      case 'topup': return TransactionCategory.topup;
      case 'reward': return TransactionCategory.reward;
      default: return TransactionCategory.topup;
    }
  }
}
