
class TransacItem {
  final int? id;
  final String type;
  final double amount;
  final String date;
  final String description;
  final int userId; // Nuevo campo para asociar transacción con usuario


  TransacItem({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.userId, // Añadido
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': date,
      'description': description,
      'userId': userId, // Añadido
    };
  }

  factory TransacItem.fromMap(Map<String, dynamic> map) {
    return TransacItem(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      date: map['date'],
      description: map['description'],
      userId: map['userId'], // Añadido
    );
  }
}
