import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantFilterScreen extends StatefulWidget {
  const RestaurantFilterScreen({super.key});

  @override
  _RestaurantFilterScreenState createState() => _RestaurantFilterScreenState();
}

class _RestaurantFilterScreenState extends State<RestaurantFilterScreen> {
  String? _selectedRating; // Speicherung der ausgewählte Bewertung.
  String _plz = ""; // Speicherung der PLZ, die ich eingebe.
  final TextEditingController _plzController =
      TextEditingController(); // Dies ist der Controller für mein PLZ-Textfeld.

  // Funktion, um Firestore-Daten basierend auf Rating und PLZ zu filtern.
  Stream<QuerySnapshot> _filterRestaurants() {
    Query query = FirebaseFirestore.instance
        .collection("Restaurants"); // Holen der Restaurant-Sammlung.

    // Filter nach Bewertung (Rating)
    if (_selectedRating != null) {
      // Wenn eine Bewertung ausgewählt ist.
      int rating = int.parse(
          _selectedRating!); // Konvertierung der Bewertung in eine Zahl.
      query = query.where("rating",
          isEqualTo:
              rating); // Filterung der Restaurants nach dieser Bewertung.
    }

    // Filter nach PLZ, wenn eine eingegeben wurde.
    if (_plz.isNotEmpty) {
      // Wenn eine PLZ eingegeben wurde.
      query = query.where("PLZ",
          isEqualTo: _plz); // Filterung der Restaurants nach dieser PLZ.
    }

    return query
        .snapshots(); // Die gefilterten Restaurants als Stream zurückgeben.
  }

  // Funktion zum Löschen eines Dokuments
  Future<void> _showDeleteDialog(String documentId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Der Dialog kann nicht durch Tippen außerhalb geschlossen werden.
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Löschen bestätigen"),
          content:
              const Text("Möchten Sie dieses Restaurant wirklich löschen?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Löschen"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRestaurant(
                    documentId); // Ruft die Funktion auf, um das Restaurant zu löschen.
              },
            ),
          ],
        );
      },
    );
  }

  // Funktion zum Löschen eines Dokuments.
  Future<void> _deleteRestaurant(String documentId) async {
    try {
      await FirebaseFirestore
          .instance // Versucht, das Restaurant aus der Datenbank zu löschen.
          .collection("Restaurants")
          .doc(documentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Restaurant erfolgreich gelöscht")), // Zeigt eine Nachricht, dass das Restaurant gelöscht wurde.
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Fehler beim Löschen: $e")), // Zeigt eine Nachricht, wenn ein Fehler aufgetreten ist.
      );
    }
  }

  // Funktion zum Zurücksetzen der Filter.
  void _resetFilters() {
    setState(() {
      _selectedRating = null; // Setzt die Bewertung zurück.
      _plz = ""; // Setzt die PLZ zurück.
      _plzController.clear(); // Setzt das Textfeld für die PLZ zurück.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 238, 183),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 233, 238, 183),
        title: const Text("Restaurant Filter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Wähle Rating aus",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedRating, // Der aktuelle Wert des Dropdown-Menüs.
              hint: const Text(
                  "Rating auswählen"), // Hinweis, wenn kein Wert ausgewählt ist.
              items: ["1", "2", "3", "4", "5"].map((String value) {
                return DropdownMenuItem<String>(
                  value:
                      value, // Der Wert, der im Dropdown-Menü angezeigt wird.
                  child: Text(
                      value), // Der Text, der im Dropdown-Menü angezeigt wird.
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedRating =
                      newValue; // Setzt die neue ausgewählte Bewertung.
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller:
                  _plzController, // Weist den Controller dem Textfeld zu.
              decoration: const InputDecoration(
                labelText: "PLZ eingeben",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType
                  .number, // Stellt sicher, dass nur Zahlen eingegeben werden.
              onChanged: (value) {
                setState(() {
                  _plz = value; // Setzt die eingegebene PLZ.
                });
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed:
                    _resetFilters, // Ruft die Funktion zum Zurücksetzen auf, wenn der Button gedrückt wird.
                child: const Text("Zurücksetzen"),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _filterRestaurants(), // Zeigt die gefilterten Restaurants an.
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child:
                          CircularProgressIndicator(), // Zeigt einen Lade-Spinner an, wenn die Daten noch geladen werden.
                    );
                  }

                  var restaurants =
                      snapshot.data!.docs; // Holt die Restaurant-Dokumente.

                  if (restaurants.isEmpty) {
                    return const Center(
                      child: Text(
                          "Keine Restaurants gefunden"), // Zeigt eine Nachricht, wenn keine Restaurants gefunden wurden.
                    );
                  }

                  return ListView.builder(
                    itemCount: restaurants.length, // Anzahl der Restaurants.
                    itemBuilder: (context, index) {
                      var restaurant = restaurants[
                          index]; // Holt ein Restaurant aus der Liste.
                      var data = restaurant.data() as Map<String,
                          dynamic>; // Konvertiert die Daten des Restaurants in eine Map.

                      String name = data["name"]?.toString() ??
                          "Unbekannt"; // Holt den Namen des Restaurants oder zeigt "Unbekannt" an.
                      int? rating = data["rating"]
                          as int?; // Holt die Bewertung des Restaurants.
                      String plz = data["PLZ"]?.toString() ??
                          "Unbekannt"; // Holt die PLZ des Restaurants oder zeigt "Unbekannt" an.

                      String ratingString = rating?.toString() ??
                          "0"; // Setzt die Bewertung auf "0", wenn keine Bewertung vorhanden ist.

                      return ListTile(
                        title:
                            Text(name), // Zeigt den Namen des Restaurants an.
                        subtitle: Text(
                            "Rating: $ratingString, PLZ: $plz"), // Zeigt Bewertung und PLZ des Restaurants an.
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteDialog(restaurant
                                .id); // Zeigt den Lösch-Dialog, wenn das Symbol gedrückt wird.
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
