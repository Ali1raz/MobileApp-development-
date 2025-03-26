import 'dart:io';

int input_int(String prompt) {
  int? number;
  while (true) {
    stdout.write(prompt);
    String? input = stdin.readLineSync();
    if (input != null && int.tryParse(input) != null) {
      number = int.parse(input);
      break;
    } else {
      print("Try again<int>.");
    }
  }
  return number;
}

double input_double(String prompt) {
  while (true) {
    stdout.write(prompt);
    String? input = stdin.readLineSync();
    print("input: $input");
    if (input != null) {
      double? number = double.tryParse(input);
      if (number != null) {
        return number;
      }
    }
    print("Invalid input. Please enter a valid number.");
  }
}

String input_string(String prompt) {
  while (true) {
    stdout.write(prompt);
    String? input = stdin.readLineSync();

    if (input == null) {
      print("Please try again.");
    } else if (input.trim().isEmpty) {
      print("Empty input is not allowed.");
    } else {
      return input;
    }
  }
}
