class LifeEntry {
  final String id;
  final String type;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final bool completed;

  LifeEntry({
    required this.id,
    required this.type,
    required this.title,
    this.description = '',
    this.amount = 0,
    required this.date,
    this.category = '',
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'completed': completed,
    };
  }

  factory LifeEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    return LifeEntry(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(
        json['date'],
      ),
      category: json['category'] ?? '',
      completed: json['completed'] ?? false,
    );
  }
}
