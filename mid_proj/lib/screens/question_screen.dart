import 'package:flutter/material.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Question")),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "0 / 10",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white60,
                  ),
                ), // current / total
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "0",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.green,
                  ),
                ), // correct
                SizedBox(width: 40),
                Text(
                  "10",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.red,
                  ),
                ), // wrong
              ],
            ),
            const Spacer(),
            Text("3 X 6 = 18?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),), // question
            SizedBox(height: 38,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: [
              CircleAvatar(backgroundColor: Colors.red, radius: 40, child: const Icon(Icons.close, size: 40,),),
              CircleAvatar(backgroundColor: Colors.green, radius: 40, child: const Icon(Icons.check, size: 40,),),
            ],),),
            SizedBox(height: 28,)
          ],
        ),
      ),
    );
  }
}
