import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String restaurantId;
  final Map<String, dynamic> restaurantData;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text(restaurantData["Name"] ??
            "Restaurant Details"), // Zeigt den Namen des Restaurants an.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${restaurantData["Name"] ?? "Unbekannt"}"),
            const SizedBox(height: 8.0),
            Text(
                "PLZ: ${restaurantData["PLZ"]?.toString() ?? "Unbekannt"}"), // PLZ als String anzeigen.
            const SizedBox(height: 8.0), // Abstand.
            Text(
                "Note: ${restaurantData["Rating"]?.toString() ?? "Unbekannt"}"), // Bewertung als String anzeigen.
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRestaurantScreen(
                      restaurantId: restaurantId, // Restaurant-ID weitergeben.
                      restaurantData:
                          restaurantData, // Restaurant-Daten weitergeben.
                    ),
                  ),
                );
              },
              child: const Text("Bearbeiten"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditRestaurantScreen extends StatefulWidget {
  final String restaurantId;
  final Map<String, dynamic> restaurantData;

  const EditRestaurantScreen(
      {super.key, required this.restaurantId, required this.restaurantData});
  @override
  // ignore: library_private_types_in_public_api
  _EditRestaurantScreenState createState() => _EditRestaurantScreenState();
}

// Zustand der Bearbeitungsseite.
class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  final _formKey =
      GlobalKey<FormState>(); // Schlüssel für das Formular zur Validierung.
  late TextEditingController
      _nameController; // Controller für die Texteingabe des Namens.
  late TextEditingController
      _plzController; // Controller für die Texteingabe der PLZ.
  late TextEditingController
      _bewertungController; // Controller für die Bewertungseingabe.

  @override
  void initState() {
    super.initState();
    // Initialisiere die TextController mit den aktuellen Restaurantdaten.
    _nameController =
        TextEditingController(text: widget.restaurantData["Name"]);
    _plzController = TextEditingController(
        text: widget.restaurantData["PLZ"]
            .toString()); // PLZ in String umwandeln.
    _bewertungController = TextEditingController(
        text: widget.restaurantData["Bewertung"]
            .toString()); // Bewertung in String umwandeln.
  }

  @override
  void dispose() {
    // Befreie Ressourcen, wenn der Bildschirm nicht mehr benutzt wird.
    _nameController.dispose();
    _plzController.dispose();
    _bewertungController.dispose();
    super.dispose();
  }

  // Methode zum Aktualisieren des Restaurants in Firestore.
  void _updateRestaurant() {
    // Überprüfe, ob das Formular gültig ist.
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance
          .collection("Restaurants")
          .doc(widget.restaurantId) // Aktuelles Dokument anhand der ID finden.
          .update({
        "Name": _nameController.text, // Aktualisiere den Namen.
        "PLZ": int.parse(
            _plzController.text), // Aktualisiere die PLZ (als Integer).
        "Bewertung": double.parse(_bewertungController
            .text), // Aktualisiere die Bewertung (als Double).
      }).then((_) {
        // Nach erfolgreichem Update, zum vorherigen Bildschirm zurück.
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Restaurant"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Formular zur Validierung.
          child: Column(
            children: [
              TextFormField(
                controller: _nameController, // Eingabefeld für den Namen.
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) {
                  // Validierung für den Namen.
                  if (value == null || value.isEmpty) {
                    return "Geben Sie bitte einen Namen ein";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _plzController, // Eingabefeld für die PLZ.
                decoration: const InputDecoration(labelText: "PLZ"),
                keyboardType:
                    TextInputType.number, // Nur Zahlen als Eingabe zulassen.
                validator: (value) {
                  // Validierung für die PLZ.
                  if (value == null || value.isEmpty) {
                    return "Geben Sie bitte eine PLZ ein";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller:
                    _bewertungController, // Eingabefeld für die Bewertung.
                decoration: const InputDecoration(labelText: "Bewertung"),
                keyboardType:
                    TextInputType.number, // Nur Zahlen als Eingabe zulassen.
                validator: (value) {
                  // Validierung für die Bewertung.
                  if (value == null || value.isEmpty) {
                    return "Geben Sie bitte eine Bewertung ab";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _updateRestaurant, // Aktion zum Aktualisieren des Restaurants.
                child: const Text("Speichern"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
