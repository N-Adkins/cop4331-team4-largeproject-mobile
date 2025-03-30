import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:group4_mobile_app/api.dart';
import 'dart:developer';
import 'session.dart';

class NoteViewer extends StatefulWidget {
  @override
  _NoteViewerState createState() => _NoteViewerState();
}

class _NoteViewerState extends State<NoteViewer> {
  int? noteId;
  String? title;
  String? body;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // This is all temporary for testing this out
    var results = await ApiService.postJson('/search_notes/', <String, dynamic>{
      'userId': Session.userId,
      'search': 'Test',
      'jwtToken': Session.token,
    });
    var noteId = results['results'][0][1];
    var title = results['results'][0][2];
    log(results.toString());

    var note = await ApiService.postJson('/note/$noteId', <String, dynamic>{
        'userId': Session.userId,
        'jwtToken': Session.token,
    });
    var body = note['body'][0];
    log(note.toString());

    setState(() {
      this.noteId = noteId;
      this.title = title;
      this.body = body;
      isLoading = false;
      log('Updated note state');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
        log("Forced UI rebuild");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test note viewer")),
      body: Center(
        child: isLoading ? CircularProgressIndicator() : Markdown(
          data: body!,
        )
      )
    );
  }
}