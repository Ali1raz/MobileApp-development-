#include <iostream>
#include <sstream>
#include <vector>
#include <string>
#include <cstdlib>
#include <ctime>

using namespace std;

vector<string> split(const string&s, char d) {
	vector<string> tokens;
	string token;
	istringstream tokenStream(s);
	while(getline(tokenStream, token, d)) {
		tokens.push_back(token);
	}
	return tokens;
}

class User {
		int id;
		string name;
		double total_deposited;
		double total_received;
		bool is_selected;

	public:
		static int idCounter;
		User(string n): is_selected(false) {
			id = ++idCounter;
			name = n;
		}
		
		bool get_selected() {
			return is_selected;
		}

		void print_user () {
			cout << "----\nUser id:" << id << "\n"
				     << "name: " << name << "\n"
				     << "deposited " << total_deposited << "\n"
				     << "received " << total_received << "\n"
				     << "selected " << (is_selected ? "Yes" : "No") << "\n"
				     << endl;
		}

		void add_deposit(double a) {
			total_deposited += a;
		}

		void add_receieved(double a) {
			total_received += a;
		}


		void mark_selected () {
			is_selected = true;
		}
};
int User::idCounter = 0;

class Comittee {
		bool comittee_created;
		vector<User> users;
		double 	balance;
		double installment;
		int total_duration;
		int installments_number;
		int current_installment;
		int installments_completed;
	public:
		Comittee(): balance(0.0), current_installment(0), installments_completed(0),
			total_duration(0), installments_number(0) {}

		void add_details() {
			cout << "Adding Comittee datails:" << endl;
			cout << "Enter total duration(months): ";
			cin >> total_duration;
			cout << "Enter total installments count: ";
			cin >> installments_number;
			
			cout << "total Price will be: " << installments_number * total_duration << endl;
			comittee_created = true;
		}

		void add_users() {
			if (comittee_created) {
				if (users.size() >4) {
					cout << "Comittee full(max 4 members)" << endl;
					return;
				}
				cout << "Adding Users" << endl;
				for (int i=0; i<4; i++) {
					string name;
					cout << "User[" << i+1 << "]" << endl;
					cout << "Enter name: ";
					cin.ignore();
					getline(cin, name);
					users.push_back(User(name));
				}
				cout << "----" << endl;	
			} else {
				cout << "You need to add comittee details first" << endl;
			}
		}

		void display_status () {
			cout << "\nComittee details:\n"
			     << "Current Balance: " << balance << "\n"
			     << "Total Duration: " << total_duration << "\n"
			     << "Installments Completed: " << installments_completed << "/" << installments_number << "\n"
			     << "Total Users: " << users.size() << endl;
			cout << "----" << endl;
		}

		void display_users() {
			if (users.empty()) {
				cout << "No User added ..." << endl;
				return;
			}
			cout << "Users details" << endl;
			for (auto& user : users) {
				user.print_user();
			}
		}
		
		void deposit_for_all() {
			
		}
		
		void select_user() {
			if (users.empty()) {
				cout << "No users available" << endl;
				return;
			}
			bool all_selected = true;
			for (auto& user: users) {
				if (!user.get_selected()) {
					all_selected = false;
					break;
				}
			}
			
			if (all_selected) {
				cout << "All users are already selected" << endl;
				return;
			}
			int random_index;
			do {
				random_index = rand() % users.size();
			} while(users[random_index].get_selected());
			
			users[random_index].mark_selected();
			users[random_index].print_user();
		}
};


int main() {
//	cout << (0 && 1) << endl;
	Comittee com;
	int choice;
	do {
		cout << "[1]. Create comittee\n"
				"[2]. Add Users\n"
				"[3]. Print Comittee\n"
				"[4]. Display Users\n"
				"[5]. Select Random User\n"
				"[6]. Select Random User\n"
				"[8]. Exit" << endl;
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
				com.select_user();
				break;
			case 8:
				cout << "Exiting ...\n" << endl;
				break;
			default:
				cout << "invalid input" << endl;
		}
	} while (choice != 8);

	system("pause");
	return 0;
}

