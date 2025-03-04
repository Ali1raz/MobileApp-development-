import 'utils.dart';
import 'comittee.dart';

void main() {
  Comittee com = Comittee();
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
        break;
      default:
        print("invliad input, try again [1-6]");
    }
  } while (choice != 6);
}
