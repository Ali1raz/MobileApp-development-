import 'utils.dart';
import 'calculate.dart';

void main() {
  clearConsole();
  info("|\t------------------");
  print("|\t:: DART CALCULATOR ::");
  info("|\t------------------\n");
  double num1 = input_double("Enter num1<int>: ");
  String op = input_operator("Enter operator: ");
  double num2 = input_double("Enter num2<int>: ");
  print("num1: $num1, num2: $num2, op: $op");

  double result = calculate(num1, num2, op);

  success("Result: $result");
}
