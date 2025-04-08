import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class Flashcard {
  String question;
  String answer;
  int cardId;

  Flashcard({required this.question, required this.answer, required this.cardId});
}

class FlashcardEditor extends StatefulWidget {
  final int deckId;
  final String title;

  const FlashcardEditor({required this.deckId, required this.title});

  @override
  _FlashcardEditorState createState() => _FlashcardEditorState();
}

class _FlashcardEditorState extends State<FlashcardEditor> {
  late int deckId;
  late String title;


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${deckId}')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Expanded(
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FlashcardViewer(deckId: deck.deckId, title: deck.title)),
                          );
                          // Navigate to the deck details or view
                        },
                        child: Text('Review'),
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
      )
    );
  }
}