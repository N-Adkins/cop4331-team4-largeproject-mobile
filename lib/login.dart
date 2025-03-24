import 'package:flutter/material.dart';
import 'package:group4_mobile_app/session.dart';
import 'register.dart';
import 'mainMenu.dart';
import 'dart:developer';
import 'package:group4_mobile_app/api.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text("Login Page"),
        automaticallyImplyLeading: false, // To remove the default back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(  //Wrap the content with Form widget to manage validation
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //Logo section
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/images/clarityIcon.png', //make sure to add the logo image in the assets folder
                  width: 100,
                  height: 100,
                ),
              ),
              SizedBox(height: 30),

              //username input field
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

              //password input field
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

              //Login button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ApiService.postJson("/login", <String, String>{
                      "login": login!,
                      "password": password!,
                    }).then((response) {
                      if (response["error"] != null) {
                        if (response["error"] == '') {
                          Session.init(response['token']['accessToken']!);

                          // Redirect to main menu page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => EmptyPage()), // Make sure MainMenuPage is imported
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response["error"].toString())),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Internal Server Error"))
                        );

                      }
                    });
                  }
                },
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 20),

              //Register section
              Center(
                child: GestureDetector(
                  onTap: () {
                    //Navigate to the register page when the user clicks the text
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