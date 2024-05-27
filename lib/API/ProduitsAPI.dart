import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class ProduitsAPI {
  static Future<List<dynamic>> getAllProduits() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var res = await http.get(
        Uri.parse("$baseUrl/api/admin/getAllProducts"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final List<dynamic> produitsList = jsonDecode(res.body);
        return produitsList;
      } else {
        throw Exception("Erreur serveur: ${res.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur lors de la récupération des produits: $err");
    }
  }

  static Future<void> addProduit(String nom, double prix, int quantite,
      String description, String? imageURL) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception(
            "Le token n'est pas disponible dans les préférences partagées.");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/admin/produits"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'nom': nom,
          'prix': prix,
          'quantite': quantite,
          'description': description,
          'image': imageURL,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception("Erreur serveur: ${response.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur lors de l'ajout du produit: $err");
    }
  }

  static Future<void> supprimerProduit(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception(
            "Le token n'est pas disponible dans les préférences partagées.");
      }

      final response = await http.delete(
        Uri.parse("$baseUrl/api/admin/produits/$id"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200 && response.statusCode != 404) {
        throw Exception("Erreur serveur: ${response.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur lors de la suppression du produit: $err");
    }
  }

  static Future<String> uploadPhoto(String photo) async {
    try {
      final dio = Dio();
      dio.options.contentType = "multipart/form-data";
      final multiPartFile = await MultipartFile.fromFile(
        photo,
        filename: photo.split('/').last,
      );
      FormData formData = FormData.fromMap({
        "file": multiPartFile,
      });
      final response = await dio.post(
        "$baseUrl/api/produits/upload",
        data: formData,
      );
      if (response.statusCode != 200) {
        throw Exception("Erreur serveur: ${response.statusCode}");
      }
      return baseUrl + "/images/" + response.data['image'];
    } catch (err) {
      throw Exception("Erreur lors de l'envoi de la photo: $err");
    }
  }

  static Future<void> modifierProduit(int id, String? nom, double? prix,
      int? quantite, String? description, String? imageURL) async {
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
      if (prix != null) requestBody['prix'] = prix;
      if (quantite != null) requestBody['quantite'] = quantite;
      if (description != null) requestBody['description'] = description;
      if (imageURL != null) requestBody['image'] = imageURL;

      final response = await http.put(
        Uri.parse("$baseUrl/api/admin/produits/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody), // Utiliser le corps de requête construit
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Erreur lors de la modification du produit: ${response.statusCode}");
      }
    } catch (err) {
      throw Exception("Erreur lors de la modification du produit: $err");
    }
  }
}
