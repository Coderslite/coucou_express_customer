import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/Constants.dart';

void sendNotification(
    List tokens, String title, String body, String orderId) async {
  print(jsonEncode(tokens));
  var response = await http.post(Uri.parse("$FIREBASE_URL/send-message"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "title": title,
        "body": body,
        "tokens": tokens,
        "orderId": orderId,
      }));
  var responseData = jsonDecode(response.body);

  if (responseData['status'] == true) {
    print("sent");
  } else {
    print("failed");
  }
}
