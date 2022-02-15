import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token = '';
  DateTime _expiry = DateTime.now();
  String _userId = '';

  bool get isAuth {
    return _token != '';
  }

  String get token {
    if (_expiry.isAfter(DateTime.now()) && _token.isNotEmpty) {
      return _token;
    }
    return '';
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBN4aJaNKmE0Z1MY8BGa2z0iCPrDNMPVe0');

    try {
      var response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));

      final data = json.decode(response.body) as Map<String, dynamic>?;

      if (data == null) {
        throw Exception('$urlSegment returned wrong response');
      }

      if (data.containsKey('error')) {
        throw Exception(data['error']['message']);
      } else if (response.statusCode != 200) {
        throw Exception('Unknown error!');
      }

      _token = data['idToken']!;
      _userId = data['localId']!;
      _expiry =
          DateTime.now().add(Duration(seconds: int.parse(data['expiresIn'])));

      notifyListeners();
      return;
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
