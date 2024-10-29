import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/meal.dart';

class ViewMealsScreen extends StatefulWidget {
  @override
  _ViewMealsScreenState createState() => _ViewMealsScreenState();
}

class _ViewMealsScreenState extends State<ViewMealsScreen> {
  List<Meal> meals = [];
  Meal selectedMeal = Meal();

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    try {
      DocumentReference mealsDocRef = FirebaseFirestore.instance
          .collection('meals')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      DocumentSnapshot snapshot = await mealsDocRef.get();

      if (snapshot.exists) {
        List<dynamic> mealsList = snapshot['meals'] ?? [];
        setState(() {
          meals = mealsList.map((mealData) => Meal.fromJson(mealData)).toList();
          if (meals.isNotEmpty) {
            selectedMeal = meals[0];
          }
        });
      }
    } catch (e) {
      print("Errore durante il caricamento dei pasti: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualizzare pasti'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.0,
              children: [
                for (int i = 0; i < meals.length; i++)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedMeal = meals[i];
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: selectedMeal.id == meals[i].id
                          ? Colors.white
                          : Colors.black,
                      backgroundColor: selectedMeal.id == meals[i].id
                          ? Colors.blue
                          : Colors.grey[300],
                    ),
                    child: Text('${meals[i].mealType} - ${meals[i].date}'),
                  ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Macronutrienti',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      ...selectedMeal.macronutrients.entries.map(
                        (entry) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text('${entry.value.toStringAsFixed(2)}'),
                            ],
                          );
                        },
                      ).toList(),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prodotti',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      ...selectedMeal.products.map(
                        (product) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(product.productName),
                              Text('€${product.price.toStringAsFixed(3)}'),
                            ],
                          );
                        },
                      ).toList(),
                      SizedBox(height: 8.0),
                      Text(
                        'Costo Totale: €${selectedMeal.totalExpense.toStringAsFixed(3)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
