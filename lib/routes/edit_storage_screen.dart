import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/services/icons_helper.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stores_provider.dart';

class EditStorageScreen extends ConsumerStatefulWidget {
  final String initialName;
  final String initialIcon;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<IconData> onIconChanged;

  const EditStorageScreen({
    super.key,
    required this.initialName,
    required this.initialIcon,
    required this.onNameChanged,
    required this.onIconChanged,
  });

  @override
  EditStorageScreenState createState() => EditStorageScreenState();
}

class EditStorageScreenState extends ConsumerState<EditStorageScreen> {
  late String storageName;
  late String selectedIcon;
  List<String> filteredIcons = [];
  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final List<String> allIcons = IconsHelper.iconMap.keys.toList();

  @override
  void initState() {
    super.initState();
    storageName = widget.initialName;
    nameController.text = storageName;
    selectedIcon = widget.initialIcon;
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
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(AppLocalizations.of(context)!.editStorage),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.trash,
                        color: CupertinoColors.destructiveRed),
                    onPressed: () => _confirmDelete(context),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(AppLocalizations.of(context)!.save),
                    onPressed: () => _saveChanges(),
                  ),
                ],
              ),
            ),
            child: SafeArea(
              child: Material(
                child: _buildContent(context),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              centerTitle: true,
              title: Text(AppLocalizations.of(context)!.editStorage),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context),
                ),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () => _saveChanges(),
                ),
              ],
            ),
            body: _buildContent(context),
          );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Platform.isIOS
              ? CupertinoTextField(
                  controller: nameController,
                  placeholder: AppLocalizations.of(context)!.storageName,
                  onChanged: (value) => storageName = value,
                )
              : TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.storageName,
                  ),
                  onChanged: (value) => storageName = value,
                ),
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.searchIcon,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: filterIcons,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
              ),
              itemCount: filteredIcons.length,
              itemBuilder: (context, index) {
                final iconName = filteredIcons[index];
                return GestureDetector(
                  onTap: () => setState(() => selectedIcon = iconName),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: selectedIcon == iconName
                              ? Theme.of(context).primaryColor
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(IconsHelper.iconMap[iconName]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    widget.onNameChanged(storageName);
    widget.onIconChanged(IconsHelper.iconMap[selectedIcon]!);
    Navigator.of(context).pop();
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Platform.isIOS
          ? CupertinoAlertDialog(
              title: Text(AppLocalizations.of(context)!.confirmDelete),
              content: Text(AppLocalizations.of(context)!
                  .confirmDeleteMessage(storageName)),
              actions: [
                CupertinoDialogAction(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text(AppLocalizations.of(context)!.delete),
                  onPressed: () {
                    _deleteStorage();
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            )
          : AlertDialog(
              title: Text(AppLocalizations.of(context)!.confirmDelete),
              content: Text(AppLocalizations.of(context)!
                  .confirmDeleteMessage(storageName)),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.delete),
                  onPressed: () {
                    _deleteStorage();
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
    );
  }

  void _deleteStorage() {
    final stores = ref.read(storesProvider);
    final index = stores.indexWhere((store) => store['name'] == storageName);
    if (index != -1) {
      ref.read(storesProvider.notifier).removeStore(index);
    }
    Navigator.of(context).pop();
  }
}
