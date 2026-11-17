class CalcHistoryItem {
  final String expression;
  final String result;
  final String date;

  CalcHistoryItem({required this.expression, required this.result, required this.date});

  Map<String, dynamic> toJson() => {'expression': expression, 'result': result, 'date': date};
  factory CalcHistoryItem.fromJson(Map<String, dynamic> json) => CalcHistoryItem(
        expression: json['expression'] ?? '',
        result: json['result'] ?? '',
        date: json['date'] ?? '',
      );
}

class Customer {
  String id;
  String name;
  String phone;
  double balance;

  Customer({required this.id, required this.name, required this.phone, required this.balance});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone, 'balance': balance};
  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      );
}

class NoteItem {
  String id;
  String title;
  String content;
  String date;

  NoteItem({required this.id, required this.title, required this.content, required this.date});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'content': content, 'date': date};
  factory NoteItem.fromJson(Map<String, dynamic> json) => NoteItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        date: json['date'] ?? '',
      );
}
