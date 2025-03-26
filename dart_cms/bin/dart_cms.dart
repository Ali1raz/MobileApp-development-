import 'package:dart_cms/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dart_cms/utils.dart';
import 'package:dart_cms/comittee.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

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
      "[2]: Add Users\n"
      "[3]: Print Comittee\n"
      "[4]: Display Users\n"
      "[5]: Deposite Installments\n"
      "[6]: Exit",
    );

    choice = input_int("Enter choice<int>: ");
    switch (choice) {
      case 1:
        com.add_details();
        break;
      case 2:
        com.add_users();
        break;
      case 3:
        com.display_comittee();
        break;
      case 4:
        com.display_users();
        break;
      case 5:
        com.deposit_for_all();
        break;
      case 6:
        print("Exiting ...");
        dbHelper.close();
        break;
      default:
        print("invliad input, try again [1-6]");
    }
  } while (choice != 6);
}
