import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/variables.dart';

class ImageFullScreen extends StatefulWidget {
  final String imagePath;

  const ImageFullScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ImageFullScreen> createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<ImageFullScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        actions: [
          IconButton(
            onPressed: () {
              showAlertDialog(context);
            },
            icon: const Icon(
              Icons.delete,
            ),
          ),
        ],
      ),
      body: Center(
        child: Image.file(File(widget.imagePath)),
      ),
    );
  }

  deleteImage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      imagePaths.remove(filePath);
      showSnackBarText('Image file deleted: $filePath');
    } else {
      showSnackBarText('Image file does not exist: $filePath');
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context, 'cancel');
      },
    );
    Widget deleteButton = TextButton(
      child: const Text("Delete"),
      onPressed: () async {
        await deleteImage(widget.imagePath);
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop();
        setState(() {
          Navigator.of(context).pop();
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete"),
      content: const Text("Are u sure u wanna delete?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showSnackBarText(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.brown,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
