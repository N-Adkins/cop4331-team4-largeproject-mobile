import 'package:flutter/material.dart';
import 'dart:math';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  //3x3 grid represented by a list
  List<int> grid = List.generate(9, (index) => index);
  //index for correct button + scoreboard
  int correctButtonIndex = 0;
  int maxCount = 0;
  int count = 0;

  @override
  void initState() {
    super.initState();
    //shuffle the grid and select a random correct button
    grid.shuffle();
    correctButtonIndex = Random().nextInt(9);
  }

  //check to see if the button is correct, if so, continue, else update score + reset
  void onButtonClick(int index) {
    if (index == correctButtonIndex) {
      setState(() {
        count++;
        if (count > maxCount) {
          maxCount = count;
        }
        grid.shuffle();
        correctButtonIndex = Random().nextInt(9);
      });
    } else {
      setState(() {
        count = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Best Score: ${maxCount}\n Current: ${count}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.builder(
              itemCount: 9,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Color buttonColor = index == correctButtonIndex ? Color.fromARGB(200, 208, 0, 255) : Color.fromARGB(200, 208, 0, 30);
                return ElevatedButton(
                  onPressed: () => onButtonClick(index),
                  child: Text(
                    index == correctButtonIndex ? 'Correct!' : 'Incorrect', //button text
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor, //button color
                    padding: EdgeInsets.all(20),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
          ],
        ),
    ),
      ),
    );
  }
}
