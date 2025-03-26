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

  factory Comittee.fromMap(Map<String, dynamic> map) {
    return Comittee(
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
  }

  Map<String, dynamic> toMap() {
    print("Comittee toMap");
    return {
      'id': id,
      'balance': balance,
      'installment_price': installment_price,
      'comittee_created': comittee_created ? 1 : 0,
      'total_duration': total_duration,
      'installment_number': installments_number,
      'current_installment': current_installment,
      'installments_completed': installments_completed,
    };
  }

  void add_details() {
    if (comittee_created) {
      print("Comittee already created");
      return;
    }
    print("Adding comittee details:");
    print(
      "[NOTE]: Number of users and installments count must/will be equal!\n",
    );
    total_duration = input_int("Enter total duration(months): ");
    installments_number = input_int("Enter total installments count: ");
    installment_price = input_double("Enter installment price: ");

    print('[DEBUGING] creating comittee');
    int id = DatabaseHelper().insertComittee(this);
    print('[DEBUGING] 12121212');

    if (id == -1) {
      print('[DEBUGING] Error creating comittee');
    } else {
      this.id = id;
      print("[DEBUGING] Comittee ID: $id");
      comittee_created = true;
      DatabaseHelper().updateComittee(this);
    }
  }

  void add_users() {
    if (!comittee_created) {
      print("You need to create committee first");
      return;
    }

    if (id == null) {
      print("Error: Comittee ID is null. Make sure it's created first.");
      return;
    }

    if (installments_number <= 0) {
      print("Error: Installments count is invalid.");
      return;
    }

    if (users.isNotEmpty) {
      print("Users already added");
      return;
    }

    print("Adding Users");

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
        print("Error adding user: $e");
      }
    }

    print("Users added to database");
  }

  void display_comittee() {
    if (!comittee_created) {
      print("Comittee not created yet");
      return;
    }
    int selected_users = users.where((user) => user.is_selected).length;
    print("\nComittee Details");
    print("Current Balance: $balance");
    print("Total Duration: $total_duration");
    print("Installment completed: $installments_completed");
    print("Total Users: ${users.length}");
    print("Total payedOut users: $selected_users");
    print("----");
  }

  void display_users() {
    if (users.isEmpty) {
      print("No users added!");
      return;
    }
    print("User details");
    for (var user in users) {
      user.print_user();
    }
  }

  void deposit_for_all() {
    if (users.isEmpty) {
      print("No users added!");
      return;
    }
    if (!comittee_created) {
      print("No Comittee added!");
      return;
    }
    if (installments_completed >= installments_number) {
      print("All Installments Completed!");
      return;
    }
    for (var user in users) {
      user.add_deposit(installment_price);
    }
    // Changed from .map() to for loop to ensure execution
    for (final user in users) {
      DatabaseHelper().updateUser(user);
    }

    balance += (users.length * installment_price);
    installments_completed++;
    current_installment++;
    DatabaseHelper().updateComittee(this);

    print("Deposited for all users");
    print("Installments Completed: $installments_completed");
    print("Total Installments: $installments_number");
    print("Current Comittee Balance: $balance");

    select_user();
  }

  void select_user() {
    if (users.every((u) => u.is_selected)) {
      print("All users already paid out.");
      return;
    }

    Random random = Random();
    User? selectedUser;

    do {
      selectedUser = users[random.nextInt(users.length)];
    } while (selectedUser.is_selected);

    selectedUser.mark_selected();
    selectedUser.add_received(balance);
    balance = 0.0;
    print(
      "${selectedUser.name} has received balance: ${selectedUser.total_received}",
    );
    DatabaseHelper().updateComittee(this);
    DatabaseHelper().updateUser(selectedUser);
  }
}
