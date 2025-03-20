//login page, need logo, route to register, route to mainMenu, and apis

import 'package:flutter/material.dart';

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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text("Login Page"),
        automaticallyImplyLeading: false, // To remove the default back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Logo section - replace with your image asset
            //IN: Add the logo image to your Flutter project under the assets folder.
//Update the pubspec.yaml file to include the assets
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/images/clarityIcon.png', // Make sure to add the logo image in the assets folder
                width: 100, // Adjust as needed
                height: 100, // Adjust as needed
              ),
            ),
            SizedBox(height: 30),

            // Username input field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Password input field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),

            // Login button
            ElevatedButton(
              onPressed: () {
                // Handle login logic here
                String username = _usernameController.text;
                String password = _passwordController.text;
                // Implement login logic (e.g., check credentials)
                print('Logging in with username: $username and password: $password');
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Make button full width
              ),
            ),
            SizedBox(height: 20),

            // Register section
            Center(
              child: GestureDetector(
                onTap: () {
                  // Handle register navigation default
                  print("Go to register screen");

                  // Navigate to the register page when the user clicks the text
                  //Navigator.push(
                  //context,
                  //MaterialPageRoute(builder: (context) => RegisterPage()),);
                },
                child: Text(
                  'Don\'t have an account? Register here',
                  style: TextStyle(

                    color: Colors.blue,
                    fontSize: 16,
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
