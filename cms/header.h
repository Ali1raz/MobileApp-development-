#ifndef HEADER_H
#define HEADER_H
#include <iostream>

int input_int(string prompt) { // not my code
	int num;
    while (true) {
        cout << prompt;
        if (cin >> num && num > 0) {
            cin.ignore(numeric_limits<streamsize>::max(), '\n');
            return num;
        }
        cout << "Enter number greater then 0" << endl;
        cin.clear();
        cin.ignore(numeric_limits<streamsize>::max(), '\n');
    }
}

double input_double(string prompt) {
	double dbl;
	while (true) {
		cout << prompt;
		if (cin >> dbl) {
			cin.ignore(numeric_limits<streamsize>::max(), '\n');
			return dbl;
		}
		cin.clear();
		cin.ignore(numeric_limits<streamsize>::max(), '\n');
	}
}

string input_string(string prompt) {
	string str;
	while (true) {
		cout << prompt;
		cin.ignore();
		getline(cin, str);
		if (!str.empty()) {
			return str;
		}
		cout << "Field Required" << endl;
	}
}

vector<string> split(const string&s, char d) {
	vector<string> tokens;
	string token;
	istringstream tokenStream(s);
	while(getline(tokenStream, token, d)) {
		tokens.push_back(token);
	}
	return tokens;
}

#endif
