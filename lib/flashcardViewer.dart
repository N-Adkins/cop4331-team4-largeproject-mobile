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
  int confidence;

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
  bool showConfidence = false;
  int confidence = 0;
  bool reachedEnd = false;
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
      if (showConfidence) {
        ApiService.postJson('/rate_flash_card', <String, dynamic>{
          'userId': Session.userId,
          'deckId': deckId,
          'cardId': cards[currentIndex].cardId,
          'confidence': confidence,
          'jwtToken': Session.token,
        }).then((result) {
          dev.log(result.toString());
          var err = result['error'];
          if (err != null && err != '' && err != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(
                    'Failed to send confidence to server: $err'))
            );
          } else {
            cards[currentIndex].confidence = result['newScore'];
          }
        });

        // If done
        if (currentIndex == cards.length - 1) {
          reachedEnd = true;
        }

        currentIndex = (currentIndex + 1) % cards.length;
        showQuestion = true;
        showConfidence = false;
      } else {
        showConfidence = true;
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
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
                  value: reachedEnd ? 1 : currentIndex / cards.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              ),

              SizedBox(height: 16),

              showConfidence ? Column(
                children: [
                  Center(
                    child: Text('How confident are you?'),
                  ),
                  ElevatedButton(onPressed: () {
                    confidence = -2;
                    _nextCard();
                  }, child: Text('Not at all')),
                  ElevatedButton(onPressed: () {
                    confidence = -1;
                    _nextCard();
                  }, child: Text('Somewhat unsure')),
                  ElevatedButton(onPressed: () {
                    confidence = 0;
                    _nextCard();
                  }, child: Text('Neutral')),
                  ElevatedButton(onPressed: () {
                    confidence = 1;
                    _nextCard();
                  }, child: Text('Somewhat confident')),
                  ElevatedButton(onPressed: () {
                    confidence = 2;
                    _nextCard();
                  }, child: Text('Very confident')),
                ],
              ) : (reachedEnd ? Column(
                children: [
                  Center(child: Text('Completed review!', style:
                  TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
                    textAlign: TextAlign.center)),
                  SizedBox(height: 16),
                  Center(child: ElevatedButton(onPressed: () {
                    setState(() {
                      currentIndex = 0;
                      showQuestion = true;
                      showConfidence = false;
                      reachedEnd = false;
                    });
                  }, child: Text('Reset?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.deepPurple),
                    textAlign: TextAlign.center))
                  ),
                ],
              ) : AnimatedBuilder(
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
              ))
            ]
          )
        ),
      ),
      floatingActionButton: reachedEnd ? null : FloatingActionButton(
        onPressed: _nextCard,
        tooltip: 'Next Card',
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}