#ifndef COMITTEE_H
#define COMITTEE_H

#define USER_FILE "users_details.txt"
#define COMITTEE_FILE "comittee_details.txt"

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
				load_user_details();
			}

		void add_details() {
			if (!comittee_created) {
				cout << "Adding Comittee datails:" << endl;
				cout << "[NOTE]: Number of users and installments count must/will be equal!\n" << endl;
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
			for (int i=0; i < installments_number; i++) {
				string name;
				cout << "User[" << i+1 << "/" << installments_number << "]" << endl;
				
				name = input_string("Enter name: ");
				users.push_back(User(name));
			}
			cout << "----" << endl;	
			save_user_details();
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
			save_comittee_details();
			save_user_details();
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
			save_comittee_details();
			save_user_details();
		}
		
		void save_comittee_details() {
			ofstream cf(COMITTEE_FILE);
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
//            cout << "Comittee details saved" << endl;
//            system("notepad comittee_details.txt");
		}
		
		void load_comittee_details() {
			ifstream cf(COMITTEE_FILE);
			if(!cf) {
//				cout << "No saved committee" << endl;
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
			cout << "Loaded Comittee details from file ..." << endl;
		}
		
		void save_user_details() {
			ofstream uf(USER_FILE);
			if(!uf) {
				cout << "Error opening users file" << endl;
				return;
			}
			uf << users.size() << "\n";
			for (auto&user: users) {
				uf << user.get_id() << "|"
					<< user.get_name() << "|"
					<< user.get_total_deposited() << "|"
					<< user.get_total_received() << "|"
					<< user.get_selected() << "\n";
			}
			uf.close();
//			cout << "User details saved" << endl;
		}
		
		void load_user_details() {
			ifstream uf(USER_FILE);
			if (!uf) {
//				cout << "No saved user details" << endl;
				return;
			}
			int userCount;
			uf >> userCount;
			uf.ignore(numeric_limits<streamsize>::max(), '\n');
			users.clear(); // loading user form file
			for (int i = 0; i < userCount; i++) {
				string line;
				getline(uf, line);
				vector<string> tokens = split(line, '|');
				if(tokens.size() < 5) {
					cout << "Error reading user data " << i+1 << endl;
					continue;
				}
				int id = stoi(tokens[0]);
	            string name = tokens[1];
	            double dep = stod(tokens[2]);
				double rec = stod(tokens[3]);
	            bool selected = (tokens[4] == "1");
	            User user(name);
	            user.set_data(id, dep, rec, selected);
	            users.push_back(user);
			}
			uf.close();
			cout << "Loaded user details from file" << endl;
		}
};

#endif
