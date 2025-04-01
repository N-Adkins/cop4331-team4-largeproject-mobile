import 'dart:convert';
import 'dart:developer';
import 'package:group4_mobile_app/session.dart';
import 'package:http/http.dart' as http;

class SignupResponse {
  int? userId;
  String? firstName;
  String? lastName;
}

class ApiService {
  static String baseUrl = "http://coolestappever.xyz:5000/api";

  static Future<Map<String, dynamic>> postJson<Payload>(String endpoint, Payload payload) async {
    try {
      var url = Uri.parse(baseUrl + endpoint);
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);
        if (body['jwtToken'] != null) {
          Session.refresh(body['jwtToken']);
        }
      } else {
        log("Returned status ${response.statusCode}");
      }
    } catch (e) {
      log(e.toString());
    }
    return {};
  }
}