import 'package:flutter/material.dart';
import 'login.dart';
import 'about.dart';
import 'register.dart';
import 'searchFlashCardDeck.dart';
import 'session.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // Use HomePage instead of LoginPage as the initial screen
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
              // Left side (Logo placeholder)
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    color: Colors.black,
                    child: Center(
                      child: Image.asset(
                        'assets/images/clarity-logo.png', // Logo image in assets
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  // Removed dropdown and moved navigation to Drawer
                ],
              ),
              // Right side (About & Login buttons)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateBody(AboutPage()); // Update body to AboutPage
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
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer header
            UserAccountsDrawerHeader(
              accountName: Text('Welcome ${Session.firstName} !'),
              accountEmail: Text(''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person),
              ),
            ),
            // Home ListTile
            ListTile(
              title: Text('Home'),
              onTap: () {
                _updateBody(
                  Center(
                    child: Text(
                      'Welcome to Clarity!',
                      style: TextStyle(fontSize: 24, color: Color.fromARGB(200, 208, 0, 255)),
                    ),
                  ),
                );
                Navigator.pop(context); // Close the drawer
              },
            ),
            // Notes ListTile
            ListTile(
              title: Text('Notes'),
              onTap: () {
                _updateBody(
                  Center(
                    child: Text(
                      'Notes APIs.',
                      style: TextStyle(fontSize: 24, color: Color.fromARGB(200, 208, 0, 255)),
                    ),
                  ),
                );
                Navigator.pop(context); // Close the drawer
              },
            ),
            // Flashcard ListTile
            ListTile(
              title: Text('Flashcard'),
              onTap: () {
                _updateBody(searchFlashCardDeck());
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: _currentBody, // The dynamic body content
    );
  }
}
