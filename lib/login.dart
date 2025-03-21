//login page, need logo, route to register, route to mainMenu, and apis

import 'package:flutter/material.dart';
import 'register.dart';
import 'dart:developer';
import 'package:group4_mobile_app/api.dart';

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
  final _formKey = GlobalKey<FormState>();
  String? login;
  String? password;
  //final TextEditingController _usernameController = TextEditingController();
  //final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text("Login Page"),
        automaticallyImplyLeading: false, // To remove the default back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(  // Wrap the content with Form widget to manage validation and saving
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Logo section - replace with your image asset
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
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Username';
                  }
                  return null;
                },
                onSaved: (value) => login = value,
              ),
              SizedBox(height: 16),

              // Password input field
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Password';
                  }
                  return null;
                },
                onSaved: (value) => password = value,
              ),
              SizedBox(height: 24),

              // Login button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ApiService.postJson("/login", <String, String>{
                      "login": login!,
                      "password": password!,
                    }).then((response) {
                      if (response["error"] != null) {
                        if (response["error"] == "") {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Successfully logged in'))
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response["error"].toString()))
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response["error"].toString()))
                        );
                      }
                    });
                  }
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
                    // Navigate to the register page when the user clicks the text
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
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
      ),
    );
  }
}