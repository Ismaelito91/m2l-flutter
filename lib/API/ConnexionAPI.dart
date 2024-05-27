import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class ConnexionAPI {
  static Future<void> connexion(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/login"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String token = responseData['token'];
        // Stockage du token dans un cookie
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      } else {
        throw Exception("Erreur d'authentification: ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Erreur lors de la connexion: $error");
    }
  }

  static Future<String> getUserRole(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/admin/users/$userId"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Bearer ${await SharedPreferences.getInstance().then((prefs) => prefs.getString('token'))}',
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty && responseData.containsKey('user')) {
          List userDataList = responseData['user'];
          if (userDataList.isNotEmpty &&
              userDataList[0]!.containsKey('fonction')) {
            var userData = userDataList[0];
            return userData['fonction'];
          } else {
            throw Exception(
                "Réponse JSON invalide : aucune clé 'fonction' trouvée.");
          }
        } else {
          throw Exception("Réponse JSON invalide : aucune clé 'user' trouvée.");
        }
      } else {
        throw Exception(
            "Erreur de récupération du rôle: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur lors de la récupération du rôle: $e");
    }
  }
}
