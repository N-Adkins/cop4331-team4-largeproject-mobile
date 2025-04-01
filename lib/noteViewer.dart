import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:group4_mobile_app/api.dart';
import 'dart:developer';
import 'session.dart';

class NoteViewer extends StatefulWidget {
  final int noteId;

  const NoteViewer({super.key, required this.noteId});

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
    noteId = widget.noteId;
    loadData();
  }

  Future<void> loadData() async {
    var note = await ApiService.postJson('/note/$noteId', <String, dynamic>{
        'userId': Session.userId,
        'jwtToken': Session.token,
    });
    var body = note['body'][0];

    setState(() {
      this.body = body;
      isLoading = false;
      log('Updated note state');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'Loading...')),
      body: Center(
        child: isLoading ? CircularProgressIndicator() : Markdown(
          data: body!,
        )
      )
    );
  }
}