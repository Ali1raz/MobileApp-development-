import 'dart:io';

int input_int(String prompt) {
  stdout.write(prompt);
  return int.parse(stdin.readLineSync() ?? '0');
}

double input_double(String prompt) {
  stdout.write(prompt);
  return double.parse(stdin.readLineSync() ?? '0.0');
}

String input_string(String prompt) {
  stdout.write(prompt);
  return stdin.readLineSync() ?? '';
}
