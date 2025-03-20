import 'package:flutter/material.dart';

//the default generated webpage, TO BE DELETED

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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EmptyPage(),
    );
  }
}

class EmptyPage extends StatefulWidget {
  @override
  EmptyPageState createState() => EmptyPageState();
}

class EmptyPageState extends State<EmptyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with vsync from this State object
    // TabController only controls the main tabs (Notes/Flashcard/About)
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // 'this' refers to the current State object
  }

  @override
  void dispose() {
    _tabController.dispose(); //Dispose of the TabController when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Replace the AppBar with TabBar
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          kToolbarHeight,
        ), // Specify height of the TabBar
        child: Material(
          color: Colors.blue,
          child: TabBar(
            controller: _tabController,
            tabs: [
              //Tab Titles
              Tab(text: 'Notes'),
              Tab(text: 'Flashcard'),
              Tab(text: 'About'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          //start of Notes tab
          Center(
            child: Material(
              color: Colors.white, //background color
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,//allights buttons to top of the page
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Button for Summary
                      TextButton(
                        onPressed: () {
                          _tabController.index = 0;  //defaults to Notes tab
                        },
                        child: Text('Summary', style: TextStyle(color: Colors.black)),
                      ),
                      // Button for Edit
                      TextButton(
                        onPressed: () {
                          _tabController.index = 1;  //defaults to Flashcard tab
                        },
                        child: Text('Edit', style: TextStyle(color: Colors.black)),
                      ),
                      // Button for LLM
                      TextButton(
                        onPressed: () {
                          _tabController.index = 2;  //defaults to About tab
                        },
                        child: Text('LLM', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),//end of tab 1 (Notes)

          Center(child: Text('Flashcard')),
          Center(child: Text('About')),
        ],
      ),
    );
  }
} //end of EmptyPageState
