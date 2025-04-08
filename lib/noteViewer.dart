import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:group4_mobile_app/api.dart';
import 'dart:developer';
import 'session.dart';

class NoteViewer extends StatefulWidget {
  final int noteId;
  final String title;

  const NoteViewer({super.key, required this.noteId, required this.title});

  @override
  _NoteViewerState createState() => _NoteViewerState();
}

class _NoteViewerState extends State<NoteViewer> {
  int? noteId;
  String? title;
  String? body;
  bool isLoading = true;
  bool aiIsLoading = false;
  //editor
  bool isEditing = false;  //Track if we are editing
  TextEditingController _controller = TextEditingController();  //Controller for text input


  @override
  void initState() {
    super.initState();
    noteId = widget.noteId;
    title = widget.title;
    loadBody();
  }

  Future<void> loadBody() async {
    var note = await ApiService.postJson('/note/$noteId', <String, dynamic>{
      'userId': Session.userId,
      'jwtToken': Session.token,
    });
    var body = note['body'][0] ?? ""; //if the body is null, assign a blank body

    setState(() {
      this.body = body;
      isLoading = false;
      _controller.text = body;  //retains previous texts
      log('Updated note state');
    });
  }

  // --- start of edit note API
  Future<void> saveBody() async {
    var response = await ApiService.postJson('/update_note', <String, dynamic>{
      'userId': Session.userId,
      'jwtToken': Session.token,
      'body': _controller.text,
      'title': title.toString(),
      'noteId': noteId,
    });

    if (response["error"] == '') {
      setState(() {
        body = _controller.text;
        isEditing = false;  // Switch back to view mode
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Changes Saved')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: ${response["error"]}')),
      );
    }
  }
  // --- end of edit note API

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(title ?? 'Loading...'),
        actions: [
          ElevatedButton(
              onPressed: () {
                if (aiIsLoading) {
                  return;
                }
                setState(() { aiIsLoading = true; } );
                ApiService.postJson('/flashcards/generate_from_note', <String, dynamic>{
                  'noteId': noteId,
                  'jwtToken': Session.token,
                }).then((response) {
                  setState(() { aiIsLoading = false; } );
                  if (response["error"] != null) {
                    if (response["error"] == "") {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(
                              'Successfully generated flashcard deck'))
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(
                              response["error"].toString()
                          ))
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(
                            'Successfully generated flashcard deck'
                        ))
                    );
                  }
                });
              },
              child: aiIsLoading ? Text("Generating...") : Text("Generate Deck")
          )
        ]
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: isEditing
                  ? TextField(
                controller: _controller,
                maxLines: null,  // Allow multiple lines
                decoration: InputDecoration(
                  hintText: 'Edit your note...',
                  border: OutlineInputBorder(),
                ),
              )
                  : Markdown(
                selectable: true,
                data: body!,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(textScaler: TextScaler.linear(1.5)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton( //calls edit API
        onPressed: () {
          if (isEditing) {
            saveBody();  //Save the edited body
          } else {
            setState(() {
              isEditing = true;  //Switch to editing mode
            });
          }
        },
        child: Icon(isEditing ? Icons.save : Icons.edit),
        tooltip: isEditing ? 'Save' : 'Edit',
      ),
    );
  }
}

