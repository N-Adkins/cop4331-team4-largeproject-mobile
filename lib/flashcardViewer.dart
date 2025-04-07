import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:group4_mobile_app/api.dart';
import 'dart:developer' as dev;
import 'session.dart';

class Flashcard {
  final String question;
  final String answer;
  final int cardId;
  final int confidence;

  Flashcard({required this.question, required this.answer, required this.cardId, required this.confidence});
}

class FlashcardViewer extends StatefulWidget {
  final int deckId;
  final String title;

  const FlashcardViewer({super.key, required this.deckId, required this.title});

  @override
  _FlashcardViewerState createState() => _FlashcardViewerState();
}

class _FlashcardViewerState extends State<FlashcardViewer>
  with SingleTickerProviderStateMixin {
  int? deckId;
  String? title;
  List<Flashcard> cards = List<Flashcard>.empty(growable: true);
  int currentIndex = 0;
  bool showQuestion = true;
  bool isLoading = true;

  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    deckId = widget.deckId;
    title = widget.title;
    _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(_controller);
    loadBody();
  }

  Future<void> loadBody() async {
    var deck = await ApiService.postJson('/get_cards_for_review', <String, dynamic>{
        'userId': Session.userId,
        'deckId': deckId,
        'jwtToken': Session.token,
    });

    setState(() {
      // Load the cards into the state array
      for (var card in deck['cards']) {
        dev.log(card.toString());
        var flashcard = Flashcard(cardId: card['CardId'], question: card['Question'], answer: card['Answer'], confidence: card['ConfidenceScore']);
        cards.add(flashcard);
      }

      // Prioritize low confidence scores
      cards.sort((card1, card2) {
        return card1.confidence.compareTo(card2.confidence);
      });

      isLoading = false;
    });
  }

  void _flipCard() async {
    if (_controller.isAnimating) return;

    await _controller.forward();

    setState(() {
      showQuestion = !showQuestion;
    });

    _controller.reset();
  }

  void _nextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % cards.length;
      showQuestion = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Force app to be vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final card = isLoading ? null : cards[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Loading...'),
      ),
      body: isLoading ? CircularProgressIndicator() : Center(
        child: GestureDetector(
          onTap: _flipCard,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100.0),
                child: LinearProgressIndicator(
                  value: currentIndex / cards.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              ),

              SizedBox(height: 16),

              AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  // Detect when flip is halfway done then start showing the other side
                  final bool isFrontVisible = _flipAnimation.value < (pi / 2);

                  final String displayText = isFrontVisible
                      ? (showQuestion ? card!.question : card!.answer)
                      : (showQuestion ? card!.answer : card!.question);

                  final double innerRotation = isFrontVisible ? 0.0 : pi;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationX(_flipAnimation.value),
                    child: Container(
                      width: 700,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationX(innerRotation),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.grey[200],
                              child: Text(
                                isFrontVisible ? (showQuestion ? 'Question' : 'Answer') : (showQuestion ? 'Answer' : 'Question'),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  displayText,
                                  style: TextStyle(fontSize: 24, color: Colors.black87),
                                  textAlign: TextAlign.center,
                                )
                              )
                            )
                          ]
                        )
                      )
                    )
                  );
                }
              )
            ]
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextCard,
        tooltip: 'Next Card',
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}