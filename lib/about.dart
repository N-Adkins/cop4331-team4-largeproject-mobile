import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: AboutPage(),
  ));
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Heading
            Text(
              'Meet Team 4!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Grid of Group Members
            GridView.count(
              shrinkWrap: true, // Shrinks the grid to fit the content
              crossAxisCount: 3, // Number of items in a row
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildGroupMember('assets/images/Anant.png', 'Anant - Database'),
                _buildGroupMember('assets/images/Preston.png', 'Preston - API'),
                _buildGroupMember('assets/images/Jon.png', 'Jon - API'),
                _buildGroupMember('assets/images/Jonathan.png', 'Jonathan - Frontend'),
                _buildGroupMember('assets/images/Christian.png', 'Cristian - Frontend'),
                _buildGroupMember('assets/images/Noah.png', 'Noah - App'),
                _buildGroupMember('assets/images/Floyd.jpg', 'Floyd - App'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build each group member's image and name
  Widget _buildGroupMember(String imagePath, String memberName) {
    return Column(
      mainAxisSize: MainAxisSize.min,  // Makes the column take the least space it needs
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // CircleAvatar for image
        CircleAvatar(
          radius: 32, // Adjust the size of the avatar
          backgroundImage: AssetImage(imagePath), // Path to image asset
          backgroundColor: Colors.transparent, // Remove background color
        ),
        SizedBox(height: 8), // Space between image and text
        // Text for member name
        Text(
          memberName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
