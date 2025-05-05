
class TransacItem {
  final int? id;
  final String type;
  final double amount;
  final String date;
  final String description;

  TransacItem({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': date,
      'description': description,
    };
  }

  factory TransacItem.fromMap(Map<String, dynamic> map) {
    return TransacItem(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      date: map['date'],
      description: map['description'],
    );
  }
}
