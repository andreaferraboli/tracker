import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:tracker/services/icons_helper.dart';

class EditStorageScreen extends StatefulWidget {
  final String initialName;
  final String initialIcon; // Cambiato a String
  final ValueChanged<String> onNameChanged;
  final ValueChanged<IconData> onIconChanged; // Cambiato a String

  const EditStorageScreen({
    super.key,
    required this.initialName,
    required this.initialIcon,
    required this.onNameChanged,
    required this.onIconChanged,
  });

  @override
  _EditStorageScreenState createState() => _EditStorageScreenState();
}

class _EditStorageScreenState extends State<EditStorageScreen> {
  late String storageName;
  late String selectedIcon; // Cambiato a String
  List<String> filteredIcons = [];
  final TextEditingController searchController = TextEditingController();

  // Definisce tutte le icone in una lista come stringhe
  final List<String> allIcons = IconsHelper.iconMap.keys.toList();

  @override
  void initState() {
    super.initState();
    storageName = widget.initialName;
    selectedIcon = widget.initialIcon; // Imposta l'icona iniziale come stringa
    filteredIcons = allIcons;
  }

  void filterIcons(String query) {
    setState(() {
      filteredIcons = allIcons.where((icon) {
        return icon.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Dispensa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              widget.onNameChanged(storageName);
              widget.onIconChanged(IconsHelper.iconMap[selectedIcon]!); // Passa l'icona come stringa
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Nome Dispensa"),
              controller: TextEditingController(text: storageName),
              onChanged: (value) {
                setState(() {
                  storageName = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Cerca icona',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterIcons,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: filteredIcons.length,
                itemBuilder: (context, index) {
                  final icon = filteredIcons[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIcon = icon; // Aggiorna l'icona selezionata come stringa
                      });
                    },
                    child: Icon(
                      IconsHelper.iconMap[icon], // Usa la mappa per ottenere IconData
                      color: icon == selectedIcon ? Colors.blue : Colors.black,
                      size: 30,
                    ),
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
