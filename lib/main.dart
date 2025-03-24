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
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                        'assets/images/clarityIcon.png', //make sure to add the logo image in the assets folder
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
                        Navigator.pushNamed(context, '/');
                      } else if (value == 'Notes') {
                        // You can replace with another route, see login/logout example
                        print('Navigate to Services');
                      } else if (value == 'FlashCards') {
                        // You can replace with another route
                        print('Navigate to Contact');
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()), // Make sure HomePage is imported
                      );                    },
                    child: Text('register'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()), // Make sure HomePage is imported
                      );
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to Clarity!',
          style: TextStyle(fontSize: 24, color : Color.fromARGB(200, 208, 0, 255)),
        ),
      ),
    );
  }
}