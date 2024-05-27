import 'package:ap4/API/UsersAPI.dart';
import 'package:ap4/Produits.dart';
import 'package:flutter/material.dart';
import 'package:ap4/Connexion.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Utilisateurs extends StatefulWidget {
  const Utilisateurs({Key? key}) : super(key: key);

  @override
  State<Utilisateurs> createState() => _UtilisateursState();
}

class _UtilisateursState extends State<Utilisateurs> {
  late Future<List<dynamic>> _futureUtilisateursListe;

  String role = '';

  @override
  void initState() {
    super.initState();
    _futureUtilisateursListe = UsersAPI.getAllUsers();
  }

  void _supprimerUtilisateur(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Supprimer l'utilisateur"),
          content: const Text(
              "Êtes-vous sûr de vouloir supprimer cet utilisateur ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Supprimer l'utilisateur
                  await UsersAPI.supprimerUtilisateur(id);

                  // Mise à jour de la liste des utilisatuers
                  _futureUtilisateursListe = UsersAPI.getAllUsers();

                  // Rafraîchir l'interface utilisateur après avoir mis à jour les données
                  setState(() {});

                  // Fermer la boîte de dialogue
                  Navigator.of(context).pop();
                } catch (error) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }

  void _modifierUtilisateur(
      BuildContext context, Map<String, dynamic> utilisateur) async {
    // Créer des contrôleurs de texte pour chaque champ du formulaire
    TextEditingController nomController = TextEditingController();
    TextEditingController prenom = TextEditingController();
    TextEditingController email = TextEditingController();

    // Pré-remplir les champs avec les valeurs actuelles de l'utilsiateur
    nomController.text = utilisateur['nom'];
    prenom.text = utilisateur['prenom'];
    email.text = utilisateur['email'];
    role = utilisateur['fonction'];

    // Afficher une boîte de dialogue de modification en pré-remplissant les champs
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Modifier l'utilisateur"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: prenom,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Rôle'),
                  value: role,
                  onChanged: (String? newValue) {
                    setState(() {
                      role = newValue ?? "";
                    });
                  },
                  items: <String>['admin', 'joueur']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Récupérer les valeurs modifiées
                  String? nouveauNom =
                      nomController.text.isNotEmpty ? nomController.text : null;
                  String? nouveauPrenom =
                      prenom.text.isNotEmpty ? prenom.text : null;
                  String? nouvelEmail =
                      email.text.isNotEmpty ? email.text : null;
                  String? nouveauRole = role;

                  // Appeler la méthode de modification d'utilisateur avec les nouvelles valeurs
                  await UsersAPI.modifierUtilisateur(utilisateur['id'],
                      nouveauNom, nouveauPrenom, nouvelEmail, nouveauRole);

                  // Mise à jour de la liste des utilisateurs
                  _futureUtilisateursListe = UsersAPI.getAllUsers();

                  // Rafraîchir l'interface utilisateur après avoir mis à jour les données
                  setState(() {});

                  // Fermer la boîte de dialogue
                  Navigator.of(context).pop();
                } catch (error) {
                  throw Exception(
                      "Erreur lors de la modification de l'utilisateur: $error");
                }
              },
              child: const Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  void _deconnexion() async {
    // Supprimer le token des préférences partagées
    SharedPreferences token = await SharedPreferences.getInstance();
    await token.remove('token');

    // Naviguer vers l'écran de connexion
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Connexion()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des utilisateurs'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFFF6C614),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: _deconnexion,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Produits()));
            },
          ),
        ],
      ),
      body: _buildUtilisateursList(),
      backgroundColor: const Color(0xFFDBDED0),
    );
  }

  Widget _buildUtilisateursList() {
    return FutureBuilder<List<dynamic>>(
      future: _futureUtilisateursListe,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Erreur lors du chargement des utilisateurs"),
            );
          } else {
            List<dynamic> utilisateursList = snapshot.data ?? [];
            if (utilisateursList.isEmpty) {
              return const Center(
                child: Text("Pas d'utilisateurs"),
              );
            } else {
              return ListView.builder(
                itemCount: utilisateursList.length,
                itemBuilder: (BuildContext context, int index) {
                  final utilisateur = utilisateursList[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(utilisateur['nom']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Prénom: ${utilisateur['prenom']}"),
                            Text("Email: ${utilisateur['email']}"),
                            Text("Rôle: ${utilisateur['fonction']}"),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _modifierUtilisateur(context, utilisateur);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _supprimerUtilisateur(utilisateur['id']);
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            }
          }
        }
      },
    );
  }
}
