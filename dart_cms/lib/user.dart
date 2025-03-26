class User {
  int id;
  String name;
  double total_received;
  double total_deposited;
  bool is_selected;
  int comitteeId;

  User({
    required this.id,
    required this.name,
    required this.total_deposited,
    required this.total_received,
    required this.is_selected,
    required this.comitteeId,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      total_deposited: map['total_deposited'],
      total_received: map['total_received'],
      is_selected: map['is_selected'] == 1,
      comitteeId: map['comittee_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'total_received': total_received,
      'total_deposited': total_deposited,
      'is_selected': is_selected ? 1 : 0,
      'comittee_id': comitteeId,
    };
  }

  void add_deposit(double a) {
    total_deposited += a;
  }

  void add_received(double a) {
    total_received += a;
  }

  void mark_selected() {
    is_selected = true;
  }

  void print_user() {
    print("\n----");
    print(
      "id: $id, "
      "Name: $name\n"
      "deposited: $total_deposited, "
      "received: $total_received\n"
      "is selected: ${is_selected ? 'YES' : 'No'}",
    );
  }
}
