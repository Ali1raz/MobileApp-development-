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
		User(string n): is_selected(false), total_deposited(0), total_received(0) {
			id = ++idCounter;
			name = n;
		}
		
		string get_name() {
			return name;
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
		
		void set_data(int _id, double dep, double rec, bool selected) {
	        id = _id;
	        total_deposited = dep;
	        total_received = rec;
	        is_selected = selected;
	    }
};
int User::idCounter = 0;

class Comittee {
		bool comittee_created;
		vector<User> users;
		double 	balance;
		double installment_price;
		int total_duration;
		int installments_number;
		int current_installment;
		int installments_completed;
	public:
		Comittee(): balance(0.0), comittee_created(false), current_installment(0), installments_completed(0),
			total_duration(0), installments_number(0) {
				load_comittee_details();
			}

		void add_details() {
			if (!comittee_created) {
				cout << "Adding Comittee datails:" << endl;
				cout << "[NOTE]: Number of users and total duration must/will be equal!\n" << endl;
				total_duration = input_int("Enter total duration(months): ");
				installments_number = input_int("Enter total installments count: ");
				installment_price = input_double("Enter Installment price(RS): ");
				cout << "total Price will be: " << installments_number * installment_price << endl;
				cout << "\nComittee created!" << endl;
				comittee_created = true;
				save_comittee_details();
				return;
			}
			cout << "Comittee already created!" << endl;
		}

		void add_users() {
			if (!comittee_created) {
				cout << "You need to add comittee details first" << endl;
				return;
			}
			
			if (!users.empty()) {
				cout << "Users already added" << endl;
				return;
			}
			cout << "Adding Users" << endl;
			for (int i=0; i<total_duration; i++) {
				string name;
				cout << "User[" << i+1 << "/" << total_duration << "]" << endl;
				
				name = input_string("Enter name: ");
				users.push_back(User(name));
			}
			cout << "----" << endl;	
		}
		

		void display_status () {
			if (!comittee_created) {
				cout << "Comittee not created yet" << endl;
				return;
			}
			int selected_users = 0;
			for (auto& user: users) {
				if (user.get_selected()) {
					selected_users++;
				}
			}
			cout << "\nComittee details:\n"
			     << "Current Balance: " << balance << "\n"
			     << "Total Duration: " << total_duration << "\n"
			     << "Installments Completed: " << installments_completed << "/" << installments_number << "\n"
			     << "Total Users: " << users.size() << "\n"
				 << "Total PayedOut Users: " << selected_users << endl;
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
			if (users.empty()) {
				cout << "No user available" << endl;
				return;
			}
			if (!comittee_created) {
				cout << "Comittee not created" << endl;
				return;
			}
			
			if (installments_completed == installments_number) {
				cout << "Installments completed" << endl;
				return;
			}
			for (auto &user: users) {
				user.add_deposit(installment_price);
				balance += installment_price;
			}
			installments_completed += 1;
			current_installment += 1;
			cout << "Installments complete: " << installments_completed << endl;
			cout << "Total Installments: " << installments_number << endl;
			cout << "Current Balance: " << balance << endl;
			select_user();
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
			users[random_index].add_receieved(balance);
			cout << users[random_index].get_name() << " has received the balance: " << balance << endl;
			balance =0;
		}
		
		void save_comittee_details() {
			ofstream cf("comittee_details.txt");
			if(!cf) {
				cout << "Error opening committee file" << endl;
				return;
			}
			cf  << comittee_created << "\n"
            	<< total_duration << "\n"
                << installments_number << "\n"
                << installment_price << "\n"
                << balance << "\n"
                << installments_completed << "\n"
                << current_installment << "\n";
            cf.close();
            cout << "Comittee details saved" << endl;
//            system("notepad comittee_details.txt");
		}
		
		void load_comittee_details() {
			ifstream cf("comittee_details.txt");
			if(!cf) {
				cout << "No saved committee" << endl;
				return;
			}
			cf  >> comittee_created
				>> total_duration
				>> installments_number
				>> installment_price
				>> balance
				>> installments_completed
				>> current_installment;
			cf.close();
			cout << "Comittee details loaded from fle" << endl;
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
				"[5]. Deposite Installments\n"
				"[8]. Exit" << endl;
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
			case 8:
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

