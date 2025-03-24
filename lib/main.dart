import 'package:flutter/material.dart';
import 'login.dart';
import 'about.dart';
import 'register.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable to track the selected body content
  Widget _currentBody = Center(
    child: Text(
      'Welcome to Clarity!',
      style: TextStyle(fontSize: 24, color: Color.fromARGB(200, 208, 0, 255)),
    ),
  );

  // Function to update the body
  void _updateBody(Widget body) {
    setState(() {
      _currentBody = body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Color.fromARGB(255, 50, 50, 50), // Dark Gray
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side (Logo placeholder + Dropdown Menu)
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    color: Colors.black,
                    child: Center(
                      child: Image.asset(
                        'assets/images/clarityIcon.png', // Logo image in assets
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  DropdownButton<String>(
                    hint: Text(
                      'Menu',
                      style: TextStyle(color: Colors.white),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'home',
                        child: Text('Home'),
                      ),
                      DropdownMenuItem(
                        value: 'services',
                        child: Text('Services'),
                      ),
                      DropdownMenuItem(
                        value: 'contact',
                        child: Text('Contact'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == 'home') {
                        _updateBody(
                          Center(
                            child: Text(
                              'Welcome to Clarity!',
                              style: TextStyle(fontSize: 24, color: Color.fromARGB(200, 208, 0, 255)),
                            ),
                          ),
                        );
                      } else if (value == 'Notes') {
                        _updateBody(
                          Center(
                            child: Text(
                              'Notes APIs.',
                              style: TextStyle(fontSize: 24, color: Color.fromARGB(200, 208, 0, 255)),
                            ),
                          ),
                        );
                      } else if (value == 'Flashcard') {
                        _updateBody(
                          Center(
                            child: Text(
                              'Flashcard APIs.',
                              style: TextStyle(fontSize: 24, color: Color.fromARGB(200, 208, 0, 255)),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              // Right side (About & Login buttons)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateBody(AboutPage()); // Update body to RegisterPage
                    },
                    child: Text('About Us'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()), // Navigates to LoginPage
                      );
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _currentBody, // The dynamic body content
    );
  }
}
