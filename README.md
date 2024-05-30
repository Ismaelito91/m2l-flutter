# Maison des ligues 

## Description

Site d'administration backend pour une application de E-commerce qui vend des produits en lien avec le sport

## Fonctionnalités

- Gestion des produits
- Gestion des utilisateurs

## Installation

1. Clonez le dépôt (`git clone https://github.com/Ismaelito91/m2l-flutter.git`)
2. Exécutez `flutter pub get` pour installer les dépendances
3. Exécutez `flutter run` pour démarrer l'application

## Configuration Android
Pour appeler le backend, vous devez modifier l'URL d'appel dans le fichier constants.dart 

```dart
const String baseUrl = "http://10.0.2.2:3000";
```

## Contribution

Voici comment vous pouvez contribuer :

1. Fork du dépôt
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/ma-fonctionnalite`)
3. Commit et poussez vos modifications (`git commit -m "Ajouter ma fonctionnalité" && git push origin feature/ma-fonctionnalite`)
4. Ouvrez une pull request
