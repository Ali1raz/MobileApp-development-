#ifndef USER_H
#define USER_H

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
		int get_id() {
			return id;
		}
		string get_name() {
			return name;
		}
		
		double get_total_deposited() {
			return total_deposited;
		}
		double get_total_received() {
			return total_received;
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

#endif
