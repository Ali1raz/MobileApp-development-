import 'package:flutter/material.dart';
import '../enums/gender.dart';
import 'card_section.dart';

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