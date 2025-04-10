import 'dart:io';

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
    warning("Invalid input. Please enter a valid number, e.g.<3> or <3.1>.");
  }
}

String input_operator(String prompt) {
  while (true) {
    stdout.write(prompt);
    String? input = stdin.readLineSync();
    if (input == null || input.trim().isEmpty) {
      warning("Empty input is not allowed.");
    } else if (!isValidOperator(input.trim())) {
      info("Please choose valid operators +, -, *, /.");
      error("Invalid operator. ");
    } else {
      return input.trim();
    }
  }
}

bool isValidOperator(String input) {
  RegExp reg = RegExp(r'^[+\-*/]$');

  return reg.hasMatch(input);
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
