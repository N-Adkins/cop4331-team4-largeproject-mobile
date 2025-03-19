import 'package:flutter/material.dart';

void main() {
  //this is the root widget of the app
  runApp(MyApp());
}

//StatelessWidget is the default static widget when UI doesn't change
//StatefulWidget is the opposite, may have to change later
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Empty Flutter Page',
      theme: ThemeData(primarySwatch: Colors.blue,), home: EmptyPage(),
    );

  }
}

//This displays the texts
class EmptyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu'),
      ),
      body: Center(
        child: Text('This is an empty page.'),
      ),
    );
  }

}