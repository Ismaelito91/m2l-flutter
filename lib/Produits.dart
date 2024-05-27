import 'dart:io';

import 'package:ap4/Utilisateurs.dart';
import 'package:flutter/material.dart';
import 'package:ap4/API/ProduitsAPI.dart';
import 'package:ap4/Connexion.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Produits extends StatefulWidget { 
  const Produits({Key? key}) : super(key: key);

  @override
  State<Produits> createState() => _ProduitsState();
}

class _ProduitsState extends State<Produits> {
  late Future<List<dynamic>> _futureProduitsListe;

  String? _image;
  String? _error;

  @override
  void initState() {
    super.initState();
    _futureProduitsListe = ProduitsAPI.getAllProduits();
  }

  void _ajouterProduit(BuildContext context) async {
    // Créer des contrôleurs de texte pour chaque champ du formulaire
    _error = "";
    _image = null;
    TextEditingController nomController = TextEditingController();
    TextEditingController prixController = TextEditingController();
    TextEditingController quantiteController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Ajouter un produit"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nomController,
                    decoration:
                        const InputDecoration(labelText: 'Nom du produit'),
                  ),
                  TextField(
                    controller: prixController,
                    decoration: const InputDecoration(labelText: 'Prix'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: quantiteController,
                    decoration: const InputDecoration(labelText: 'Quantité'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  if (_image != null) const SizedBox(height: 10),
                  if (_image != null) Image.file(File(_image!)),
                  ElevatedButton(
                    onPressed: () async {
                      await selectImage();
                      setState(() {
                        _error = null;
                      });
                    },
                    child: _image == null
                        ? const Text('Sélectionner une image')
                        : const Text('Modifier l\'image'),
                  ),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
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
                    String nom = nomController.text;
                    String description = descriptionController.text;
                    if (nom.isEmpty ||
                        description.isEmpty ||
                        prixController.text.isEmpty ||
                        quantiteController.text.isEmpty) {
                      setState(() {
                        _error = "Veuillez remplir tous les champs";
                      });
                      return;
                    }

                    double prix = 0;
                    try {
                      prix = double.parse(prixController.text);

                      if (prix == 0) {
                        setState(() {
                          _error = "Le prix doit être supérieur à 0";
                        });
                        return;
                      }
                    } catch (e) {
                      setState(() {
                        _error = "Le prix doit être un nombre";
                      });
                      return;
                    }

                    int quantite = 0;
                    try {
                      quantite = int.parse(quantiteController.text);

                      if (quantite == 0) {
                        setState(() {
                          _error = "La quantité doit être supérieure à 0";
                        });
                        return;
                      }
                    } catch (e) {
                      setState(() {
                        _error = "La quantité doit être un nombre";
                      });
                      return;
                    }

                    if (_image == null) {
                      setState(() {
                        _error = "Veuillez sélectionner une image";
                      });
                      return;
                    }

                    // Upload de la photo
                    String imageURL = await ProduitsAPI.uploadPhoto(_image!);

                    // Appeler l'API pour ajouter le produit
                    await ProduitsAPI.addProduit(
                        nom, prix, quantite, description, imageURL);

                    // Fermer la boîte de dialogue
                    Navigator.of(context).pop();
                  } catch (error) {
                    throw Exception(
                        "Erreur lors de l'ajout du produit: $error");
                    // Afficher un message d'erreur si nécessaire
                  }
                },
                child: const Text("Ajouter"),
              ),
            ],
          );
        });
      },
    ).then((value) {
      // Mise à jour de la liste des produits
      setState(() {
        _futureProduitsListe = ProduitsAPI.getAllProduits();
      });
    });
  }

  void _supprimerProduit(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Supprimer le produit"),
          content:
              const Text("Êtes-vous sûr de vouloir supprimer ce produit ?"),
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
                  // Supprimer le produit
                  await ProduitsAPI.supprimerProduit(id);

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
    ).then((value) {
      // Mise à jour de la liste des produits
      setState(() {
        _futureProduitsListe = ProduitsAPI.getAllProduits();
      });
    });
  }

  Future<void> selectImage() async {
    String? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  Future<String?> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      return await image.path;
    }
    return null;
  }

  void _modifierProduit(
      BuildContext context, Map<String, dynamic> produit) async {
    _error = "";
    _image = null;

    // Créer des contrôleurs de texte pour chaque champ du formulaire
    TextEditingController nomController = TextEditingController();
    TextEditingController prixController = TextEditingController();
    TextEditingController quantiteController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    // Pré-remplir les champs avec les valeurs actuelles du produit
    nomController.text = produit['nom'];
    prixController.text = produit['prix'].toString();
    quantiteController.text = produit['quantite'].toString();
    descriptionController.text = produit['description'];
    var imageUrl = produit['image'];

    // Afficher une boîte de dialogue de modification en pré-remplissant les champs
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Modifier le produit"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nomController,
                    decoration:
                        const InputDecoration(labelText: 'Nom du produit'),
                  ),
                  TextField(
                    controller: prixController,
                    decoration: const InputDecoration(labelText: 'Prix'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: quantiteController,
                    decoration: const InputDecoration(labelText: 'Quantité'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  if (_image != null || imageUrl != null)
                    const SizedBox(height: 10),
                  if (_image != null) Image.file(File(_image!)),
                  if (_image == null && imageUrl != null)
                    Image.network(imageUrl),
                  ElevatedButton(
                    onPressed: () async {
                      await selectImage();
                      setState(() {
                        _error = null;
                      });
                    },
                    child: _image == null && imageUrl == null
                        ? const Text('Sélectionner une image')
                        : const Text('Modifier l\'image'),
                  ),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
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
                    // Vérifier la présence des champs obligatoires
                    String nouveauNom = nomController.text;
                    String? nouvelleDescription = descriptionController.text;
                    if (nouveauNom.isEmpty ||
                        nouvelleDescription.isEmpty ||
                        prixController.text.isEmpty ||
                        quantiteController.text.isEmpty) {
                      setState(() {
                        _error = "Veuillez remplir tous les champs";
                      });
                      return;
                    }

                    double nouveauPrix = 0;
                    try {
                      nouveauPrix = double.parse(prixController.text);

                      if (nouveauPrix == 0) {
                        setState(() {
                          _error = "Le prix doit être supérieur à 0";
                        });
                        return;
                      }
                    } catch (e) {
                      setState(() {
                        _error = "Le prix doit être un nombre";
                      });
                      return;
                    }

                    int? nouvelleQuantite = 0;
                    try {
                      nouvelleQuantite = int.parse(quantiteController.text);

                      if (nouvelleQuantite == 0) {
                        setState(() {
                          _error = "La quantité doit être supérieure à 0";
                        });
                        return;
                      }
                    } catch (e) {
                      setState(() {
                        _error = "La quantité doit être un nombre";
                      });
                      return;
                    }

                    if (_image == null && imageUrl == null) {
                      setState(() {
                        _error = "Veuillez sélectionner une image";
                      });
                      return;
                    }

                    // Upload de la photo
                    if (_image != null) {
                      imageUrl = await ProduitsAPI.uploadPhoto(_image!);
                    }

                    // Appeler la méthode de modification de produit avec les nouvelles valeurs
                    await ProduitsAPI.modifierProduit(
                        produit['id'],
                        nouveauNom,
                        nouveauPrix,
                        nouvelleQuantite,
                        nouvelleDescription,
                        imageUrl);

                    // Fermer la boîte de dialogue
                    Navigator.of(context).pop();
                  } catch (error) {
                    throw Exception(
                        "Erreur lors de la modification du produit: $error");
                  }
                },
                child: const Text("Modifier"),
              ),
            ],
          );
        });
      },
    ).then((value) {
      // Mise à jour de la liste des produits
      setState(() {
        _futureProduitsListe = ProduitsAPI.getAllProduits();
      });
    });
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
        title: const Text('Liste des produits'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFFF6C614),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: _deconnexion,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Utilisateurs()));
            },
          ),
        ],
      ),
      body: _buildProduitsList(),
      backgroundColor: const Color(0xFFDBDED0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _ajouterProduit(context);
        },
        backgroundColor: const Color(0xFFC92B39),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProduitsList() {
    return FutureBuilder<List<dynamic>>(
      future: _futureProduitsListe,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Erreur lors du chargement des produits"),
            );
          } else {
            List<dynamic> produitsList = snapshot.data ?? [];
            if (produitsList.isEmpty) {
              return const Center(
                child: Text("Pas de produits"),
              );
            } else {
              return ListView.builder(
                itemCount: produitsList.length,
                itemBuilder: (BuildContext context, int index) {
                  final produit = produitsList[index];
                  return Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Image.network(
                          produit['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // En cas d'erreur de chargement, afficher l'image par défaut
                            return Image.network(
                              'https://via.placeholder.com/150',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(produit['nom']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Prix: ${produit['prix']}'),
                            Text('Quantité: ${produit['quantite']}'),
                            Text('Description: ${produit['description']}'),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _modifierProduit(context, produit);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _supprimerProduit(produit['id']);
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
