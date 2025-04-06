import "dart:math";
import "user.dart";
import "utils.dart";
import 'package:dart_cms/database.dart';

class Comittee {
  int? id;
  bool comittee_created;
  double balance;
  double installment_price;
  int total_duration;
  int installments_number;
  int current_installment;
  int installments_completed;
  List<User> users;

  Comittee({
    this.id,
    required this.comittee_created,
    required this.balance,
    required this.installment_price,
    required this.total_duration,
    required this.installments_number,
    required this.current_installment,
    required this.installments_completed,
    required this.users,
  });

  factory Comittee.fromMap(Map<String, dynamic> map) => Comittee(
    id: map['id'],
    comittee_created: map['comittee_created'] == 1,
    balance: map['balance'],
    installment_price: map['installment_price'],
    total_duration: map['total_duration'],
    installments_number: map['installments_number'],
    current_installment: map['current_installment'],
    installments_completed: map['installments_completed'],
    users: [],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'balance': balance,
    'installment_price': installment_price,
    'comittee_created': comittee_created ? 1 : 0,
    'total_duration': total_duration,
    'installments_number': installments_number,
    'current_installment': current_installment,
    'installments_completed': installments_completed,
  };

  // ---- Comittee Setup ----

  void add_details() {
    if (comittee_created) {
      warning("Comittee already created");
      return;
    }

    clearConsole();
    info("Adding comittee details:");
    info(
      "[NOTE]: Number of users and installments count must/will be equal!\n",
    );

    total_duration = input_positive_int("Enter total duration(months): ");
    installments_number = input_positive_int(
      "Enter total installments count: ",
    );
    installment_price = input_double("Enter installment price: ");

    while (installment_price <= 0) {
      warning("Installment price must be positive.");
      installment_price = input_double("Enter installment price: ");
    }

    comittee_created = true;

    try {
      final dbHelper = DatabaseHelper();
      final newId = dbHelper.insertComittee(this);
      if (newId > 0) {
        id = newId;
        success("Committee created successfully!");
      } else {
        comittee_created = false;
        warning("Failed to create committee.");
      }
    } catch (e) {
      comittee_created = false;
      error("Error creating committee: $e");
    }
  }

  void edit_comittee() {
    clearConsole();

    if (!comittee_created || id == null) {
      warning("Committee not created yet!");
      return;
    }

    info("\nEditing Committee Details:");
    installment_price = input_double(
      "New installment price (current: $installment_price): ",
    );
    DatabaseHelper().updateComittee(this);
  }

  void delete_comittee() {
    if (!comittee_created || id == null) {
      warning("No committee to delete!");
      return;
    }

    clearConsole();

    print(red);
    final confirm = input_string("DELETE committee and ALL users? (yes/no): ");
    print(resetColor);

    if (confirm.toLowerCase() != 'yes' && confirm.toLowerCase() != 'y') {
      info("DELETION cancelled.");
      return;
    }

    try {
      DatabaseHelper().deleteComittee(id!);
      comittee_created = false;
      id = null;
      users.clear();
      balance = 0;
      success("Committee deleted successfully!");
    } catch (e) {
      error("Error deleting committee: $e");
    }
  }

  void display_comittee() {
    if (!comittee_created) {
      warning("Comittee not created yet");
      return;
    }

    clearConsole();
    int selected_users = users.where((user) => user.is_selected).length;

    info("\nComittee Details");
    info("Current Balance: $balance");
    info("Total Duration: $total_duration");
    info("Installment completed: $installments_completed");
    info("Current Installment completed: $current_installment");
    info("Total Users: ${users.length}");
    info("Total payedOut users: $selected_users");
    info("----");
  }

  // ---- User Management ----

  void add_users() {
    if (!comittee_created || id == null) {
      warning("You need to create committee first");
      return;
    }

    if (users.isNotEmpty) {
      info("Users already added");
      return;
    }

    clearConsole();
    info("Adding Users");

    for (int i = 0; i < installments_number; i++) {
      String name = input_string(
        "User[${i + 1}/$installments_number] - Enter name: ",
      );

      User user = User(
        id: 0,
        name: name,
        total_deposited: 0,
        total_received: 0,
        is_selected: false,
        comitteeId: id!,
      );

      try {
        user.id = DatabaseHelper().insertUser(user);
        users.add(user);
      } catch (e) {
        error("Error adding user: $e");
      }
    }

    info("Users added to database");
  }

  void display_users() {
    clearConsole();

    if (users.isEmpty) {
      warning("No users added!");
      return;
    }

    info("User details");
    for (var user in users) {
      user.print_user();
    }
  }

  void display_single_user() {
    if (users.isEmpty) {
      warning("No users available!");
      return;
    }

    clearConsole();

    int userId = input_int("Enter user ID to display: ");
    try {
      User user = users.firstWhere((u) => u.id == userId);
      user.print_user();
    } catch (_) {
      error("User with ID $userId not found!");
    }
  }

  void edit_user() {
    if (users.isEmpty) {
      warning("No users available!");
      return;
    }

    clearConsole();
    info("Editing User Details:");

    int userId = input_positive_int("Enter user ID to edit: ");
    User user = users.firstWhere(
      (u) => u.id == userId,
      orElse:
          () => User(
            id: -1,
            name: '',
            total_deposited: 0,
            total_received: 0,
            is_selected: false,
            comitteeId: -1,
          ),
    );

    if (user.id == -1) {
      warning("User not found!");
      return;
    }

    String newName = input_string("Enter new name (current: ${user.name}): ");
    user.name = newName;
    DatabaseHelper().updateUser(user);

    success("User updated successfully!");
  }

  // ---- Installments ----

  void deposit_for_all() {
    if (users.isEmpty) {
      warning("No users added!");
      return;
    }

    if (!comittee_created) {
      warning("No Comittee added!");
      return;
    }

    if (installments_completed >= installments_number) {
      info("All Installments Completed already!");
      return;
    }

    clearConsole();

    for (var user in users) {
      user.add_deposit(installment_price);
      DatabaseHelper().updateUser(user);
    }

    balance += (users.length * installment_price);
    installments_completed++;
    current_installment++;
    DatabaseHelper().updateComittee(this);

    info("Deposited for all users");
    info("Installments Completed: $installments_completed");
    info("Total Installments: $installments_number");
    info("Current Comittee Balance: $balance");

    select_user();
  }

  void select_user() {
    if (users.every((u) => u.is_selected)) {
      warning("All users already paid out.");
      return;
    }

    Random random = Random();
    User selectedUser;

    do {
      selectedUser = users[random.nextInt(users.length)];
    } while (selectedUser.is_selected);

    selectedUser.mark_selected();
    selectedUser.add_received(balance);
    balance = 0.0;

    success(
      "${selectedUser.name} has received balance: ${selectedUser.total_received}",
    );
    DatabaseHelper().updateComittee(this);
    DatabaseHelper().updateUser(selectedUser);
  }
}
