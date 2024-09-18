import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:restaurant_rating_app/firebase_options.dart';
import 'package:restaurant_rating_app/src%20Kopie/features/feature1/presentation/RestaurantsDetail_screen.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

// Zustand der Seite "RestaurantListPage", der die Logik für die Anzeige der Restaurants enthält.
class _RestaurantListPageState extends State<RestaurantListPage> {
  // Firestore-Instanz für Datenbankoperationen.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialisierung der Firebase App beim Start der Seite.
  @override
  void initState() {
    super.initState();
    _initializeFirebase(); // Ruft die Firebase-Initialisierungsmethode auf.
  }

  // Asynchrone Methode zur Initialisierung der Firebase App.
  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions
          .currentPlatform, // Firebase-Konfigurationsoptionen.
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 201, 211, 183),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 201, 211, 183),
        title: const Text("Restaurants"),
      ),
      // Body enthält eine StreamBuilder für Echtzeit-Datenanzeige von Firestore.
      body: StreamBuilder<QuerySnapshot>(
        // Stream von der "Restaurants"-Sammlung in Firestore, sortiert nach PLZ in absteigender Reihenfolge.
        stream: _firestore
            .collection('Restaurants')
            .orderBy("PLZ", descending: true)
            .snapshots(),
        // Builder zum Anzeigen des Daten-Streams.
        builder: (context, snapshot) {
          // Fehlerabfrage.
          if (snapshot.hasError) {
            return const Center(child: Text("Es ist ein Fehler aufgetreten"));
          }

          // Abfrage, ob keine Daten vorhanden sind.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Keine Daten gefunden"));
          }

          // Zeigt einen Ladeindikator, wenn die Verbindung zum Firestore noch besteht.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extrahiert die Restaurants-Dokumente aus dem Snapshot.
          final restaurants = snapshot.data?.docs ?? [];

          // Erzeugt eine Liste basierend auf der Anzahl der Restaurant-Dokumente.
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              // Extrahiert die Daten des aktuellen Restaurants als Map.
              final restaurantData =
                  restaurants[index].data() as Map<String, dynamic>;
              // Speichert die ID des Restaurants.
              final restaurantId = restaurants[index].id;

              // Listenelement für jedes Restaurant.
              return ListTile(
                // Zeigt den Namen des Restaurants an (fällt auf "Unbekannt" zurück, falls nicht vorhanden).
                title: Text(restaurantData["Name"] ?? "Unbekannt"),
                // Zeigt die PLZ und Bewertung des Restaurants an.
                subtitle: Text(
                    "PLZ: ${restaurantData["PLZ"]}, Bewertung: ${restaurantData["Rating"]}"),
                // Bei Antippen wird eine neue Seite geöffnet, die Details des Restaurants anzeigt.
                onTap: () {
                  // Navigiert zur RestaurantDetailScreen und übergibt die Restaurant-Daten und -ID.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantDetailScreen(
                        restaurantId: restaurantId, // ID des Restaurants.
                        restaurantData: restaurantData, // Restaurantdaten.
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      // Schaltfläche zum Hinzufügen eines neuen Restaurants.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Zeigt den Dialog zum Hinzufügen eines neuen Restaurants.
          _showAddRestaurantDialog();
        },
        // Icon für die Schaltfläche.
        child: const Icon(Icons.add),
      ),
    );
  }

  // Methode zur Anzeige eines Dialogs zum Hinzufügen eines neuen Restaurants.
  void _showAddRestaurantDialog() {
    // Controller zur Eingabe von Name, PLZ und Bewertung des neuen Restaurants.
    final nameController = TextEditingController();
    final plzController = TextEditingController();
    final ratingController = TextEditingController();

    // Zeigt den Dialog zur Eingabe der Restaurantdetails an.
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // Titel des Dialogs.
            title: const Text("Neues Restaurant hinzufügen"),
            // Inhalt des Dialogs, der die Eingabefelder enthält.
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Eingabefeld für den Namen des Restaurants.
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                // Eingabefeld für die PLZ, nur Zahlen erlaubt.
                TextField(
                  controller: plzController,
                  decoration: const InputDecoration(labelText: "PLZ"),
                  keyboardType: TextInputType.number,
                ),
                // Eingabefeld für die Bewertung, nur Zahlen erlaubt.
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(labelText: "Bewertung"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            // Schaltflächen im Dialog: Abbrechen und Hinzufügen.
            actions: [
              // Schaltfläche zum Schließen des Dialogs ohne Aktion.
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Abbrechen")),
              // Schaltfläche zum Hinzufügen des neuen Restaurants.
              TextButton(
                onPressed: () {
                  // Fügt das neue Restaurant in die Firestore-Sammlung ein.
                  _firestore.collection("Restaurants").add({
                    "Name": nameController.text,
                    "PLZ": int.parse(plzController.text),
                    "Bewertung": int.parse(ratingController.text),
                  });
                  // Schließt den Dialog nach dem Hinzufügen.
                  Navigator.of(context).pop();
                },
                child: const Text("Hinzufügen"),
              ),
            ],
          );
        });
  }
}
