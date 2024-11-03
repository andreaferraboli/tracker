import 'package:flutter/material.dart';
import 'package:tracker/models/storage_card.dart';
import 'package:tracker/routes/storage_screen.dart';
import 'package:tracker/services/icons_helper.dart';

import 'edit_storage_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Map<String, dynamic>> storages = [
    {'icon': Icons.kitchen, 'title': 'Fridge'},
    {'icon': Icons.storage, 'title': 'Pantry'},
    {'icon': Icons.ac_unit, 'title': 'Freezer'},
    {'icon': Icons.restaurant, 'title': 'Other'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vedere Inventario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            ...storages.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> storage = entry.value;
              return GestureDetector(
                onLongPress: () => _navigateToEditStorageScreen(context, index),
                onTap: () {
                  Navigator.push(
                    context,
                     MaterialPageRoute(
                      builder: (context) => StorageScreen(
                        name: storage['title'],
                      ),
                    ),
                  );
                },
                child: StorageCard(
                  icon: storage['icon'],
                  title: storage['title'],
                  isAddButton: false,
                ),
              );
            }).toList(),
            StorageCard(
              icon: Icons.add,
              title: "Aggiungi",
              isAddButton: true,
              onAddPressed: () => _navigateToEditStorageScreen(context, -1),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditStorageScreen(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStorageScreen(
          initialName: index >= 0 ? storages[index]['title'] : '',
          initialIcon: index >= 0
              ? IconsHelper.iconName(storages[index]['icon'])
              : 'home',
          onNameChanged: (newName) {
            setState(() {
              if (index >= 0) {
                storages[index]['title'] = newName;
              } else {
                storages.add({'icon': Icons.home, 'title': newName});
              }
            });
          },
          onIconChanged: (newIcon) {
            setState(() {
              if (index >= 0) {
                storages[index]['icon'] = newIcon;
              } else {
                storages.last['icon'] = newIcon;
              }
            });
          },
        ),
      ),
    );
  }
}
