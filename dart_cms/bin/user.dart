class User {
  int id;
  String name;
  double total_received;
  double total_deposited;
  bool is_selected;
  static int _idCounter = 0;

  User(String n)
    : id = ++_idCounter,
      name = n,
      total_deposited = 0.0,
      total_received = 0.0,
      is_selected = false;

  int get_id() {
    return id;
  }

  String get_name() {
    return name;
  }

  double get_total_deposited() {
    return total_deposited;
  }

  double get_total_received() {
    return total_received;
  }

  bool get_selected() {
    return is_selected;
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

  void set_details(int id, String n, double d, double r, bool i) {
    this.id = id;
    this.name = n;
    this.total_deposited = d;
    this.total_received = r;
    this.is_selected = i;
  }
}
