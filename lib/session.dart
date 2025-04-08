import 'dart:developer';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class Session {
  static String? token;
  static int? userId;
  static String? firstName;
  static String? lastName;

  static void init(String token) {
    Session.token = token;
    JWT decoded = JWT.decode(token);
    Session.userId = decoded.payload['userId'];
    Session.firstName = decoded.payload['firstName'];
    Session.lastName = decoded.payload['lastName'];
  }

  static void refresh(String token) {
    Session.token = token;
  }
}
