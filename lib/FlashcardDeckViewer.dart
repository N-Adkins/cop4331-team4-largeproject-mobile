import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:group4_mobile_app/api.dart';
import 'dart:developer' as dev;
import 'session.dart';
import 'package:group4_mobile_app/flashcardViewer.dart';


class Flashcard {
  final String question;
  final String answer;
  final int cardId;
  int confidence;

  Flashcard({required this.question, required this.answer, required this.cardId, required this.confidence});
}

class FlashcardDeckViewer extends StatefulWidget {
  final int deckId;
  final String title;

  const FlashcardDeckViewer({super.key, required this.deckId, required this.title});

  @override
  _FlashcardDeckViewerState createState() => _FlashcardDeckViewerState();
}

class _FlashcardDeckViewerState extends State<FlashcardDeckViewer>{
  //
  int? deckId;
  String? title;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Flashcard> _decks = [];
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
      'deckId': deckId.toString(),
      'userId': Session.userId.toString(), // Use the user ID from the Session class
    };

    try {
      final response = await ApiService.postJson("/search_flash_cards", requestDatasearch);

      // Process the response and update the UI
      if (response['error'] != null || response['error'] == '') {
        //log(response['results'].toString());
        setState(() {
          _decks = [];
          response['results'].forEach((deck) {
            _decks.add(Flashcard(cardId: deck['CardId'], question: deck['Question'], answer: deck['Answer'], confidence: deck['ConfidenceScore']));
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
  void _deleteDeck(Flashcard deck) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Deck'),
          content: Text('Are you sure you want to delete the card?'),
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
                ApiService.postJson("/delete_flash_card", <String, String>{
                  "jwtToken": Session.token!,
                  "userId": Session.userId.toString(),
                  "deckId": deckId.toString(),
                  "cardId": deck.cardId.toString(),
                }).then((response) {
                  if (response["error"] != null) {
                    if (response["error"] == '') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Card successfully deleted")),
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
  }

  // Function to handle the edit action
  void _editDeck(Flashcard deck) async{
    // --- edit api begins
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController editdeckTitleController = TextEditingController();
        TextEditingController cardAnswerController = TextEditingController();
        return AlertDialog(
          title: Text('Edit a Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editdeckTitleController,
                decoration: InputDecoration(
                  labelText: 'Card Question',
                ),
              ),

              TextField(
                controller: cardAnswerController,
                decoration: InputDecoration(
                  labelText: 'Card Answer',
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
                String deckTitle = editdeckTitleController.text;
                String deckAnswer = cardAnswerController.text;
                // --- add api starts
                ApiService.postJson("/update_flashcard", <String, String>{
                  "jwtToken": Session.token!,
                  "userId": Session.userId.toString(),
                  "cardId": deck.cardId.toString(),
                  "question": deckTitle,
                  "answer": deckAnswer,
                }).then((response) {
                  if (response["error"] != null) {
                    if (response["error"] == '') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Card successfully changed")),
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
                // --- edit api ends
                //_fetchFlashCardDecks();
                Navigator.pop(context);
              },
              child: Text('Confirm Change'),
            ),
          ],
        );
      },
    );
    // --- edit api ends
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    deckId = widget.deckId;
    title = widget.title;
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

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FlashcardViewer(deckId: deckId!, title: title!)),
                );
                // Navigate to the deck details or view
              },
              child: Text('Review'),
            ),
            SizedBox(width: 8),

            // Add Deck Button
            ElevatedButton(
              onPressed: () {
                // Show the dialog to add a deck
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController deckTitleController = TextEditingController();
                    TextEditingController cardAnswerController = TextEditingController();
                    return AlertDialog(
                      title: Text('Create a New Card'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: deckTitleController,
                            decoration: InputDecoration(
                              labelText: 'Card Question',
                            ),
                          ),

                          TextField(
                            controller: cardAnswerController,
                            decoration: InputDecoration(
                              labelText: 'Card Answer',
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
                            String cardAnswer = cardAnswerController.text;
                            // --- add api starts
                            ApiService.postJson("/add_flash_card", <String, String>{
                              "jwtToken": Session.token!,
                              "userId": Session.userId.toString(),
                              "deckId": deckId.toString(),
                              "question": deckTitle,
                              "answer": cardAnswer,
                            }).then((response) {
                              if (response["error"] != null) {
                                if (response["error"] == '') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Card successfully added")),
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
                      title: Text(deck.question),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
  //
}