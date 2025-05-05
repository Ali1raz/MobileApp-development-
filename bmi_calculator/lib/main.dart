import 'package:bmi_calculator/screens/input_page.dart';

import 'package:flutter/material.dart';
import 'constants/theme.dart';

void main() => runApp(const BMICalculator());

class BMICalculator extends StatelessWidget {
  const BMICalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: AppTheme.primaryColor,
        scaffoldBackgroundColor: AppTheme.scaffoldBackgroundColor,
      ),
      debugShowCheckedModeBanner: false,
      home: InputPage(),
    );
  }
}
