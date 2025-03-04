import "dart:io";
import "dart:math";

import "user.dart";
import "utils.dart";

final String COMITTEE_FILE = "COMITTEE_FILE.txt";
final String USER_FILE = "USER_FILE.txt";

class Comittee {
  bool comittee_created;
  double balance;
  double installment_price;
  int total_duration;
  int installemts_number;
  int current_installment;
  int installments_completed;
  List<User> users;

  Comittee()
    : balance = 0.0,
      comittee_created = false,
      current_installment = 0,
      installments_completed = 0,
      total_duration = 0,
      installemts_number = 0,
      installment_price = 0,
      users = [] {
    load_comittee_details();
    load_user_dertails();
  }

  void add_details() {
    if (!comittee_created) {
      print("Adding comittee details:");
      print(
        "[NOTE]: Number of users and installments count must/will be equal!\n",
      );
      total_duration = input_int("Enter total duration(months): ");
      installemts_number = input_int("Enter total installments count: ");
      installment_price = input_double("Enter installment price: ");
      print("\nComittee created!");
      comittee_created = true;
      save_comittee_details();
      return;
    }
    print("Comittee already created");
  }

  void add_users() {
    if (!comittee_created) {
      print("You need to create comittee first");
      return;
    }

    if (!users.isEmpty) {
      print("Users already added");
      return;
    }
    print("Adding Users");

    for (int i = 0; i < installemts_number; i++) {
      String name = input_string(
        "User[${i + 1}/$installemts_number] - Enter name: ",
      );
      users.add(User(name));
    }
    print("----");
    save_user_details();
  }

  void display_comittee() {
    if (!comittee_created) {
      print("Comittee not created yet");
      return;
    }
    int selected_users = users.where((user) => user.get_selected()).length;
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
    if (installments_completed == installemts_number) {
      print("Installments Completed already!");
      return;
    }
    for (var user in users) {
      user.add_deposit(installment_price);
      balance += installment_price;
    }
    installments_completed += 1;
    current_installment += 1;
    print("Installments Completed: $installments_completed");
    print("Total Installments: $installemts_number");
    print("Current Comittee Balance: $balance");
    select_user();
    save_comittee_details();
    save_user_details();
  }

  void select_user() {
    if (users.isEmpty) {
      print("No users added!");
      return;
    }
    bool all_selected = users.every((user) => user.get_selected());
    if (all_selected) {
      print("All users already selected");
      return;
    }
    Random random = Random();
    int random_index;
    do {
      random_index = random.nextInt(users.length);
    } while (users[random_index].get_selected());

    users[random_index].mark_selected();
    users[random_index].add_received(balance);
    print("${users[random_index].name} has received balance: $balance}");
    balance = 0.0;
    save_comittee_details();
    save_user_details();
  }

  void save_comittee_details() {
    File cf = File(COMITTEE_FILE);
    try {
      cf.writeAsStringSync(
        "$comittee_created\n$total_duration\n$installemts_number\n"
        "$installment_price\n$balance\n$installments_completed\n"
        "$current_installment\n",
      );
    } catch (e) {
      print("Error Saving Comittee details: $e");
    }
  }

  void load_comittee_details() {
    File cf = File(COMITTEE_FILE);
    if (!cf.existsSync()) {
      print("No saved comittee");
      return;
    }
    List<String> lines = cf.readAsLinesSync();
    if (lines.length < 7) {
      //   print("File corrupted");
      return;
    }
    comittee_created = lines[0] == "true";
    total_duration = int.parse(lines[1]);
    installemts_number = int.parse(lines[2]);
    installment_price = double.parse(lines[3]);
    balance = double.parse(lines[4]);
    installments_completed = int.parse(lines[5]);
    current_installment = int.parse(lines[6]);

    print("\nloaded comittee details from file");
  }

  void save_user_details() {
    File uf = File(USER_FILE);
    try {
      List<String> userlines =
          users
              .map(
                (user) =>
                    ("${user.id}|"
                        "${user.name}|"
                        "${user.total_deposited}|"
                        "${user.total_received}|"
                        "${user.is_selected ? '1' : '0'}"),
              )
              .toList();
      uf.writeAsStringSync("${users.length}\n${userlines.join('\n')}\n");
    } catch (e) {
      print("Error saving file: $e");
    }
  }

  void load_user_dertails() {
    File uf = File(USER_FILE);
    if (!uf.existsSync()) {
      print("No saved users data");
      return;
    }
    List<String> lines = uf.readAsLinesSync();
    int users_count = int.parse(lines[0]);
    users.clear();
    for (int i = 1; i <= users_count; i++) {
      List<String> tokens = lines[i].split("|");
      if (tokens.length < 5) {
        print("Eror reading user $i data");
        continue;
      }

      int id = int.parse(tokens[0]);
      String name = tokens[1];
      double dep = double.parse(tokens[2]);
      double rec = double.parse(tokens[3]);
      bool sel = tokens[4] == "1";

      User user = User(name);
      user.set_details(id, name, dep, rec, sel);
      users.add(user);
    }
    print("loaded user details from file");
  }
}
