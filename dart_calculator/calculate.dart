double calculate(double n1, double n2, String op) {
  switch (op) {
    case '+':
      return add(n1, n2);
    case '-':
      return subtract(n1, n2);
    case '*':
      return multiply(n1, n2);
    case '/':
      return divide(n1, n2);
    default:
      print("Invalid Operator: $op.");
      return 0;
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
