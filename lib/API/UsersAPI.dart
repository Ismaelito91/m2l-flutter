import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class UsersAPI {
  static Future<List<dynamic>> getAllUsers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var res = await http.get(
        Uri.parse("$baseUrl/api/admin/getAllUsers"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final Map utilisateursList = jsonDecode(res.body);
        if (utilisateursList.containsKey("users"))
          return utilisateursList["users"];
        else
          return [];
      } else {
        throw Exception("Erreur serveur: ${res.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur lors de la récupération des utilisateurs: $err");
    }
  }

  static Future<void> supprimerUtilisateur(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception(
            "Le token n'est pas disponible dans les préférences partagées.");
      }

      final response = await http.delete(
        Uri.parse("$baseUrl/api/admin/users/$id"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200 && response.statusCode != 404) {
        throw Exception("Erreur serveur: ${response.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur lors de la suppression de l'utilisateur: $err");
    }
  }

  static Future<void> modifierUtilisateur(
      int id, String? nom, String? prenom, String? email, String? role) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception(
            "Le token n'est pas disponible dans les préférences partagées.");
      }
      Map<String, dynamic> requestBody = {}; // Créer un corps de requête vide
      // Ajouter les valeurs modifiées au corps de requête si elles sont fournies
      if (nom != null) requestBody['nom'] = nom;
      if (prenom != null) requestBody['prenom'] = prenom;
      if (email != null) requestBody['email'] = email;
      if (role != null) requestBody['fonction'] = role;

      final response = await http.put(
        Uri.parse("$baseUrl/api/admin/users/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody), // Utiliser le corps de requête construit
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Erreur lors de la modification de l'utilisateur: ${response.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur lors de la modification de l'utilisateur: $err");
    }
  }
}
