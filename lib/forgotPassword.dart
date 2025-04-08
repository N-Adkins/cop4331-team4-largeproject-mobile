import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:group4_mobile_app/api.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your account\'s email';
                  }
                  return null;
                },
                onSaved: (value) => email = value,
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ApiService.postJson('/forgot_password', <String, dynamic>{
                      'email': email!,
                    }).then((response) {
                      if (response['message'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Internal server error'))
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                response['message'].toString()
                            ))
                        );
                        Navigator.pop(context);
                      }
                    });
                  }
                },
                child: Text(
                  "Reset",
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}