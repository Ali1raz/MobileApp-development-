import 'dart:io';

void main() {
  while (true) {
    print("Enter num1:");
    double num1 = double.parse(stdin.readLineSync()!);
    print("Enter operator(+, -, *, /):");
    String operator = stdin.readLineSync()!;
    print("Enter num2:");
    double num2 = double.parse(stdin.readLineSync()!);

    double result;

    switch (operator) {
      case '+':
        result = add(num1, num2);
        break;
      case '-':
        result = subtract(num1, num2);
        break;
      case '*':
        result = multiply(num1, num2);
        break;
      case '/':
        result = divide(num1, num2);
        break;
      default:
        print('Invalid operator input');
        continue;
    }

    print('Result for $num1 $operator $num2: $result');

    print("continue calculator? (y/n):");
    String c = stdin.readLineSync()!;
    if (c.toLowerCase() != "y") break;
  }
}

double add(double a, double b) {
  return a + b;
}

double subtract(double a, double b) {
  return a - b;
}

double multiply(double a, double b) {
  return a * b;
}

double divide(double a, double b) {
  if (b == 0) {
    print("Cannot divide by 0");
    return 0;
  }
  return a / b;
}
