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
      warning("Try again<int>.");
    }
  }
  return number;
}

int input_positive_int(String prompt) {
  int? number;
  while (true) {
    stdout.write(prompt);
    String? input = stdin.readLineSync();
    if (input != null && int.tryParse(input) != null && int.parse(input) > 0) {
      number = int.parse(input);
      break;
    } else {
      warning("Try again<int GREATER THAN 0>.");
    }
  }
  return number;
}

double input_double(String prompt) {
  while (true) {
    stdout.write(prompt);
    String? input = stdin.readLineSync();
    if (input != null) {
      double? number = double.tryParse(input);
      if (number != null) {
        return number;
      }
    }
    warning("Invalid input. Please enter a valid number.");
  }
}

String input_string(String prompt) {
  while (true) {
    stdout.write(prompt);
    String? input = stdin.readLineSync();

    if (input == null) {
      warning("Please try again.");
    } else if (input.trim().isEmpty) {
      warning("Empty input is not allowed.");
    } else {
      return input;
    }
  }
}

const String resetColor = '\x1B[0m';
const String red = '\x1B[31m';
const String green = '\x1B[32m';
const String yellow = '\x1B[33m';
const String blue = '\x1B[34m';

void info(String message) {
  print('$blue$message$resetColor');
}

void success(String message) {
  print('$green$message$resetColor');
}

void warning(String message) {
  print('$yellow$message$resetColor');
}

void error(String message) {
  print('$red$message$resetColor');
}

void clearConsole() {
  // For Windows: try using ANSI codes if supported, otherwise fallback to 'cls'
  if (Platform.isWindows) {
    // Try using ANSI escape codes
    stdout.write('\x1B[2J\x1B[0;0H');
    // If that doesn't work, uncomment the next two lines:
    // var result = Process.runSync('cls', [], runInShell: true);
    // stdout.write(result.stdout);
  } else {
    // For Linux and macOS
    stdout.write('\x1B[2J\x1B[0;0H');
  }
}
