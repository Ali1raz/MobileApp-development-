#include <iostream>
#include <sstream>
#include <vector>
#include <string>
#include <cstdlib>
#include <ctime>
#include <limits>
#include <fstream>

using namespace std;
#include "header.h"
#include "user.h"
#include "comittee.h"

int main() {
//	cout << (0 && 1) << endl;
	Comittee com;
	int choice;
	do {
		cout << "[1]. Create comittee\n"
				"[2]. Add Users\n"
				"[3]. Print Comittee\n"
				"[4]. Display Users\n"
				"[5]. Deposite Installments\n"
				"[6]. Exit" << endl;
		cout << "Enter choice<int>: ";
		cin >> choice;

		switch (choice) {
			case 1:
				com.add_details();
				break;
			case 2:
				com.add_users();
				break;
			case 3:
				com.display_status();
				break;
			case 4:
				com.display_users();
				break;
			case 5:
				com.deposit_for_all();
				break;
			case 6:
				cout << "Exiting ...\n" << endl;
				break;
			default:
				cin.clear();
				cin.ignore(numeric_limits<streamsize>::max(), '\n');
				cout << "\nInvalid input" << endl;
		}
	} while (choice != 8);

	system("pause");
	return 0;
}

