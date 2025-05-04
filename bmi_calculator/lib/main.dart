import 'package:flutter/material.dart';

void main() => runApp(const BMICalculator());

enum Gender { male, female }

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  Gender? selectedGender;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF0A0E21),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("BMI Calculator")),
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
                        "147 cm",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: 147.0,
                        min: 100.0,
                        max: 220.0,
                        divisions: 120,
                        label: '147 cm',
                        onChanged: (val) {},
                        activeColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    ValueCard(label: "WEIGHT", value: 60),
                    ValueCard(label: "AGE", value: 20),
                  ],
                ),
              ),
              Container(
                color: Colors.red,
                height: 60,
                width: double.infinity,
                child: Center(
                  child: Text(
                    "CALCULATE",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenderCard extends StatelessWidget {
  final Gender gender;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderCard({
    super.key,
    required this.gender,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: CardSection(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                gender == Gender.male ? Icons.male : Icons.female,
                size: 60,
                color: isSelected ? Colors.red : Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                gender == Gender.male ? 'MALE' : 'FEMALE',
                style: TextStyle(color: isSelected ? Colors.red : Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ValueCard extends StatelessWidget {
  final String label;
  final int value;

  const ValueCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CardSection(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: Colors.white)),
            Text('$value', style: TextStyle(color: Colors.white, fontSize: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: Icon(Icons.remove, color: Colors.white),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CardSection extends StatelessWidget {
  final Widget child;

  const CardSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
