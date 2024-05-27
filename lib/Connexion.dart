import 'package:ap4/Produits.dart';
import 'package:flutter/material.dart';
import 'package:ap4/API/ConnexionAPI.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  _ConnexionState createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _connexion() async {
    if (_formKey.currentState!.validate()) {
      String username = userNameController.text;
      String password = passwordController.text;

      try {
        // Appel à la fonction connexion sans attendre le token
        await ConnexionAPI.connexion(username, password);

        // Récupérer le token à partir du cookie
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');

        if (token != null) {
          // Décoder le token JWT pour obtenir les données
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

          // Récupérer l'ID de l'utilisateur à partir du token
          int userId = decodedToken['userId'];

          // Récupérer le rôle de l'utilisateur à partir de l'ID
          String role = await ConnexionAPI.getUserRole(userId);

          if (role == 'admin') {
            // Si l'utilisateur est un administrateur, naviguer vers la prochaine page
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Produits()));
          } else if (role == 'joueur') {
            // Si l'utilisateur n'est pas un administrateur, afficher un message d'erreur
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Pas de droit'),
                  content: const Text(
                      'Vous n\'avez pas les autorisations nécessaires.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            // Si le rôle est indéfini ou autre, afficher un message d'erreur
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Erreur'),
                  content: const Text(
                      'Erreur lors de la récupération du rôle de l\'utilisateur.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          // Si le token est null, afficher un message d'erreur
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Erreur'),
                content: const Text('Token introuvable.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur login'),
              content: const Text('Nom utilisateur ou mot de passe incorrect.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBDED0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Image.asset(
                'assets/logo.png',
                height: 120,
              ),
            ),
            const SizedBox(height: 80),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: userNameController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF6C614),
                          hintText: 'Nom d\'utilisateur',
                          hintStyle: TextStyle(color: Color(0xFFC92B39)),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Entrez un nom d\'utilisateur';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF6C614),
                          hintText: 'Mot de passe',
                          hintStyle: TextStyle(color: Color(0xFFC92B39)),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Entrez un mot de passe';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: MaterialButton(
                            onPressed: _connexion,
                            color: const Color(0xFFF6C614),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            child: const Text(
                              'Connexion',
                              style: TextStyle(color: Color(0xFFC92B39)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
