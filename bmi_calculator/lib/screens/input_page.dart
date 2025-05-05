import 'package:bmi_calculator/constants/theme.dart';
import 'package:bmi_calculator/enums/gender.dart';
import 'package:bmi_calculator/screens/result_screen.dart';
import 'package:bmi_calculator/widgets/card_section.dart';
import 'package:bmi_calculator/widgets/gender_card.dart';
import 'package:bmi_calculator/widgets/value_card.dart';
import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  Gender selectedGender = Gender.male;
  double height = 120.0;
  int weight = 60;
  int age = 20;

  double calculateBMI() {
    return weight / ((height / 100) * (height / 100));
  }

  String getResult(double bmi) {
    if (bmi >= 25) {
      return 'Overweight';
    } else if (bmi > 18.5) {
      return 'Normal';
    } else {
      return 'Underweight';
    }
  }

  String getInterpretation(double bmi) {
    if (bmi >= 25) {
      return 'You have a higher than normal body weight. Try to exercise more.';
    } else if (bmi > 18.5) {
      return 'You have a normal body weight. Good job!';
    } else {
      return 'You have a lower than normal body weight. You can eat a bit more.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BMI Calculator"), backgroundColor: AppTheme.primaryColor,),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  GenderCard(
                    gender: Gender.male,
                    isSelected: selectedGender == Gender.male,
                    onTap: () {
                      setState(() {
                        selectedGender = Gender.male;
                      });
                    },
                  ),
                  GenderCard(
                    gender: Gender.female,
                    isSelected: selectedGender == Gender.female,
                    onTap: () {
                      setState(() {
                        selectedGender = Gender.female;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CardSection(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("HEIGHT", style: TextStyle(color: Colors.white)),
                    Text(
                      "${height.round()} cm",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: height,
                      min: 120.0,
                      max: 220.0,
                      divisions: 100,
                      label: '${height.round()} cm',
                      onChanged: (val) {
                        setState(() {
                          height = val;
                        });
                      },
                      activeColor: AppTheme.activeColor,
                      inactiveColor: AppTheme.inactiveColor,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  ValueCard(
                    label: "WEIGHT",
                    value: weight,
                    onIncrement: () {
                      setState(() {
                        weight++;
                      });
                    },
                    onDecrement: () {
                      setState(() {
                        weight--;
                      });
                    },
                  ),
                  ValueCard(
                    label: "AGE",
                    value: age,
                    onIncrement: () {
                      setState(() {
                        age++;
                      });
                    },
                    onDecrement: () {
                      setState(() {
                        age--;
                      });
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                final bmi = calculateBMI();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ResultScreen(
                      bmi: bmi,
                      result: getResult(bmi),
                      interpretation: getInterpretation(bmi),
                    ),
                  ),
                );
              },
              child: Container(
                color: AppTheme.buttonColor,
                height: 60,
                width: double.infinity,
                child: Center(
                  child: Text(
                    "CALCULATE",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
