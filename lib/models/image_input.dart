import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _pickImage(ImageSource source) async {
    final pickedImage =
        await ImagePicker().pickImage(source: source, maxWidth: 600);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(_selectedImage!);
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Take Picture'),
            onTap: () {
              Navigator.of(ctx).pop();
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.of(ctx).pop();
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceActionSheet(context),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : const Text(
                    'No image taken',
                    textAlign: TextAlign.center,
                  ),
          ),
        ],
      ),
    );
  }
}
