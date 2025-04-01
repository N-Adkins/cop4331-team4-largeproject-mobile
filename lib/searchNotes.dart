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
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NoteViewer(noteId: note.id, title: note.title)),
                          );
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
