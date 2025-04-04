import 'package:flutter/material.dart';
import 'dart:developer';
import 'session.dart';
import 'api.dart'; // Import ApiService

class searchFlashCardDeck extends StatefulWidget {
  @override
  _SearchFlashCardDeck createState() => _SearchFlashCardDeck();
}

class DeckInfo {
  int deckId;
  String title;

  DeckInfo(this.deckId, this.title);
}

class _SearchFlashCardDeck extends State<searchFlashCardDeck> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<DeckInfo> _decks = [];
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
    final Map<String, String> requestDatasearch = {
      'jwtToken': Session.token!,
      'search': _searchQuery,
      'userId': Session.userId.toString(), // Use the user ID from the Session class
    };

    try {
      final response = await ApiService.postJson("/search_flashcard_decks", requestDatasearch);

      // Process the response and update the UI
      if (response['error'] == null || response['error'] == '') {
        log(response['results'].toString());
        setState(() {
          _decks = [];
          response['results'].forEach((deck) {
            _decks.add(DeckInfo(deck[1], deck[2]));
          });
        });
      } else {
        setState(() {
          _errorMessage = response['error']; // Handle error response from API
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred while fetching the data: $e"; // Handle other errors
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to handle the delete action
  void _deleteDeck(DeckInfo deck) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Deck'),
          content: Text('Are you sure you want to delete the deck: "${deck.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
                //--- delete API starts
                ApiService.postJson("/delete_flashcard_deck", <String, String>{
                  "jwtToken": Session.token!,
                  "userId": Session.userId.toString(),
                  "deckId": deck.deckId.toString(),
                }).then((response) {
                  if (response["error"] != null) {
                    if (response["error"] == '') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${deck.title} successfully deleted")),
                      );
                      _fetchFlashCardDecks();
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
                // --- delete API ends
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Perform the delete action here (API call)
      log('Deleting deck: ${deck.title}');
      // You can add the API call for deleting the deck here
    }
  }

  // Function to handle the edit action
  void _editDeck(DeckInfo deck) {
    log('Editing deck: ${deck.title}');
    // Navigate to the deck edit page or show a modal dialog to edit the deck.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchFlashCardDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Flashcard Decks', style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.deepPurple,
            )),

            SizedBox(height: 20),

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

            // Add Deck Button
            ElevatedButton(
              onPressed: () {
                // Show the dialog to add a deck
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController deckTitleController = TextEditingController();
                    return AlertDialog(
                      title: Text('Create a New Deck'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: deckTitleController,
                            decoration: InputDecoration(
                              labelText: 'Deck Title',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Close the dialog without doing anything
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            String deckTitle = deckTitleController.text;
                            // --- add api starts
                            ApiService.postJson("/create_flashcard_deck", <String, String>{
                              "jwtToken": Session.token!,
                              "userId": Session.userId.toString(),
                              "title": deckTitle,
                            }).then((response) {
                              if (response["error"] != null) {
                                if (response["error"] == '') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("${deckTitle} successfully added")),
                                  );
                                  _fetchFlashCardDecks();
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
                            // --- add api ends
                            Navigator.pop(context);
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Add Deck'),
            ),

            SizedBox(height: 20),

            // Show Loading Spinner
            if (_isLoading) CircularProgressIndicator(),

            // Show error message if any
            if (_errorMessage != null) Text(_errorMessage!, style: TextStyle(color: Colors.red)),

            // Displaying the list of flashcard decks
            Expanded(
              child: ListView.builder(
                itemCount: _decks.length,
                itemBuilder: (context, index) {
                  var deck = _decks[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(deck.title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              log('Button pressed for ${deck.title}');
                              // Navigate to the deck details or view
                            },
                            child: Text('Open'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _editDeck(deck),
                            child: Icon(Icons.edit),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _deleteDeck(deck),
                            child: Icon(Icons.delete),
                          ),
                        ],
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
