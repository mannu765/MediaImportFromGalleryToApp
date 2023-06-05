import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../utils/variables.dart';
import 'ImageFullScreen.dart';

class ImportMedia extends StatefulWidget {
  const ImportMedia({Key? key}) : super(key: key);

  @override
  State<ImportMedia> createState() => _ImportMediaState();
}

class _ImportMediaState extends State<ImportMedia> {
  String filePath = '';
  final _picker = ImagePicker();
  String picture = '';
  Uint8List? imageDecoded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Import Media'),
        actions: [
          IconButton(
            onPressed: () {
              bottomSheet();
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: imagePaths.isEmpty
          ? const Center(child: Text('No Images Imported'))
          : GridView.builder(
              itemCount: imagePaths.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageFullScreen(imagePath: imagePaths[index]),
                      ),
                    ).then((value) {
                      setState(() {
                        imagePaths = imagePaths;
                      });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      children: [
                        Container(
                          height: 140,
                          width: 160,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.file(
                                File(imagePaths[index]),
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              imagePaths[index].substring(
                                  imagePaths[index].lastIndexOf('/') + 1),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void bottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose Photo from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await pickImage(ImageSource.gallery);
                },
              ),
            ],
          );
        });
  }

  Future<void> pickImage(ImageSource source) async {
    // print('reached pickImage');
    final XFile? pickedImage = await _picker.pickImage(source: source);

    if (pickedImage != null) {
      picture = base64Encode(File(pickedImage.path).readAsBytesSync());
      setState(() {
        imageDecoded = base64Decode(picture);
      });
      await saveImage(imageDecoded!);
    }
  }

  Future<void> saveImage(Uint8List imageBytes) async {
    // print('reached saveImage');
    // Get the document directory using path_provider
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String documentPath = documentDirectory.path;

    // Define the file path
    String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    fileName = 'my_image_$timestamp.jpg';
    filePath =
        '$documentPath/$fileName'; // You can change the extension as per your requirements (e.g., my_image.png)

    // Save the image file
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    imagePaths.add(filePath);
    setState(() {});
    showSnackBarText('Saved successfully');

    if (!mounted) {
      return;
    }

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
