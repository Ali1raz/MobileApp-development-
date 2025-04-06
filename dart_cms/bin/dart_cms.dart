import 'package:dart_cms/database.dart';

import 'package:dart_cms/comittee.dart';
import 'package:dart_cms/utils.dart';

void main() {
  clearConsole();
  info("Welcome to the Comittee Management System");

  final dbHelper = DatabaseHelper();
  dbHelper.initDB();

  Comittee? com;
  final existing = dbHelper.getComittee();
  if (existing != null) {
    com = existing;
    com.users = dbHelper.getUsersByComittee(com.id!);
  } else {
    com = Comittee(
      comittee_created: false,
      balance: 0,
      installment_price: 0,
      total_duration: 0,
      installments_number: 0,
      current_installment: 0,
      installments_completed: 0,
      users: [],
    );
  }

  int choice;
  do {
    print(
      "\n[1]: Create comittee\n"
      "[2]: Print Comittee\n"
      "[3]: DELETE Comittee\n"
      "[4]: Edit Comittee\n"
      "[5]: Add Users\n"
      "[6]: Display Users\n"
      "[7]: Display User details\n"
      "[8]: Edit a User\n"
      "[9]: Deposite Installments\n"
      "[99]: Exit",
    );

    choice = input_int("Enter choice<int>: ");
    switch (choice) {
      case 1:
        com.add_details();
        break;
      case 2:
        com.display_comittee();
        break;
      case 3:
        com.delete_comittee();
        break;
      case 4:
        com.edit_comittee();
        break;
      case 5:
        com.add_users();
        break;
      case 6:
        com.display_users();
        break;
      case 7:
        com.display_single_user();
        break;
      case 8:
        com.edit_user();
        break;
      case 9:
        com.deposit_for_all();
        break;
      case 99:
        warning("Exiting ...");
        dbHelper.close();
        break;
      default:
        warning("invliad input, try again [1-10] or [99] to exit");
    }
  } while (choice != 99);
}
