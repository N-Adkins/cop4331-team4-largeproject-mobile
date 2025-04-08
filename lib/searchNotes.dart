import 'package:flutter/material.dart';
import 'package:group4_mobile_app/noteViewer.dart';
import 'dart:developer';
import 'session.dart';
import 'api.dart'; // Import ApiService

class SearchNotesPage extends StatefulWidget {
  @override
  _SearchNotesPageState createState() => _SearchNotesPageState();
}

class NoteInfo {
  int id;
  String title;

  NoteInfo(this.id, this.title);
}

class _SearchNotesPageState extends State<SearchNotesPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<NoteInfo> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Update search query automatically as the user types
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Fetch the notes based on the search query
  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Create the request body to send to the API
    final Map<String, String> requestData = {
      'jwtToken': Session.token!,
      'search': _searchQuery,
      'userId': Session.userId.toString(), // Use the user ID from the Session class
    };

    try {
      final response = await ApiService.postJson("/search_notes", requestData);

      // Process the response and update the UI
      if (response['error'] == null || response['error'] == '') {
        log(response['results'].toString());
        setState(() {
          _notes = [];
          response['results'].forEach((note) {
            _notes.add(NoteInfo(note[1], note[2]));
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
  void _deleteNote(NoteInfo note) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete the note: "${note.title}"?'),
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
                ApiService.postJson("/delete_note", <String, String>{
                  "jwtToken": Session.token!,
                  "userId": Session.userId.toString(),
                  "noteId": note.id.toString(),
                }).then((response) {
                  if (response["error"] != null) {
                    if (response["error"] == '') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${note.title} successfully deleted")),
                      );
                      _fetchNotes();
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
      log('Deleting deck: ${note.title}');
      // You can add the API call for deleting the deck here
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Text('Notes', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.deepPurple,
              )),
            ),

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
              onPressed: _fetchNotes,
              child: Text('Search'),
            ),

            // Add Note Button
            ElevatedButton(
              onPressed: () {
                // Show the dialog to add a deck
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController deckTitleController = TextEditingController();
                    return AlertDialog(
                      title: Text('Create New Note'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: deckTitleController,
                            decoration: InputDecoration(
                              labelText: 'Note Title',
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
                            ApiService.postJson("/create_note", <String, String>{
                              "jwtToken": Session.token!,
                              "userId": Session.userId.toString(),
                              "title": deckTitle,
                            }).then((response) {
                              if (response["error"] != null) {
                                if (response["error"] == '') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("New Note successfully added")),
                                  );
                                  //_fetchNotes();
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
                            _fetchNotes();
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Add Note'),
            ), //end of add note

            SizedBox(height: 20),

            // Show Loading Spinner
            if (_isLoading) CircularProgressIndicator(),

            // Show error message if any
            if (_errorMessage != null) Text(_errorMessage!, style: TextStyle(color: Colors.red)),

            // Displaying the list of flashcard decks
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  var note = _notes[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(note.title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NoteViewer(noteId: note.id, title: note.title)),
                              );
                            },
                            child: Text('View'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _deleteNote(note),
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
