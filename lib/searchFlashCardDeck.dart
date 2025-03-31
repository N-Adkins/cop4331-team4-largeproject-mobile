import 'package:flutter/material.dart';
import 'session.dart';
import 'api.dart'; // Import ApiService

class searchFlashCardDeck extends StatefulWidget {
  @override
  _SearchFlashCardDeck createState() => _SearchFlashCardDeck();
}

class _SearchFlashCardDeck extends State<searchFlashCardDeck> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, String>> _flashCardDecks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Update search query automatically as the user types
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Fetch the flashcards based on the search query
  Future<void> _fetchFlashCardDecks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Create the request body to send to the API
    final Map<String, String> requestData = {
      'searchQuery': _searchQuery,
      'userId': Session.userId.toString(), // Use the user ID from the Session class
    };

    try {
      final response = await ApiService.postJson("/search_flashcard_decks", requestData);

      // Process the response and update the UI
      if (response['error'] == null) {
        // Assuming the API response contains a list of flashcard decks in 'data'
        setState(() {
          _flashCardDecks = List<Map<String, String>>.from(response['data']);
        });
      } else {
        setState(() {
          _errorMessage = response['error']; // Handle error response from API
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred while fetching the data."; // Handle other errors
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search FlashCard Decks"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Search Button
            ElevatedButton(
              onPressed: _fetchFlashCardDecks,
              child: Text('Search'),
            ),

            SizedBox(height: 20),

            // Show Loading Spinner
            if (_isLoading) CircularProgressIndicator(),

            // Show error message if any
            if (_errorMessage != null) Text(_errorMessage!, style: TextStyle(color: Colors.red)),

            // Displaying the list of flashcard decks
            Expanded(
              child: ListView.builder(
                itemCount: _flashCardDecks.length,
                itemBuilder: (context, index) {
                  var deck = _flashCardDecks[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(deck['title']!),
                      trailing: ElevatedButton(
                        onPressed: () {
                          print('Button pressed for ${deck['title']}');
                          // Add any action for the button, like navigating to the deck details
                        },
                        child: Text('Open'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
