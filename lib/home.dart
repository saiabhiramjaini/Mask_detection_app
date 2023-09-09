import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? _selectedImage;
  List _predictions = [];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  detectImage(File image) async {
    var prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _predictions = prediction!;
    });
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
    detectImage(_selectedImage!);
  }

  Future _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
    detectImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _pickImageFromGallery();
              },
              child: const Text("pick image from gallery"),
            ),
            ElevatedButton(
              onPressed: () {
                _pickImageFromCamera();
              },
              child: const Text("pick image from camera"),
            ),
            const SizedBox(
              height: 20,
            ),
            _selectedImage != null
                ? Column(
                    children: [
                      Column(
                        children: [
                          Image.memory(
                            _selectedImage!.readAsBytesSync(),
                            height: 400,
                            width: 400,
                            fit: BoxFit.contain,
                          ),
                          _predictions.isNotEmpty
                              ? Text(_predictions[0]['label'])
                              : const Text("No predictions"),
                        ],
                      )
                    ],
                  )
                : const Text("please select an image"),
          ],
        ),
      ),
    );
  }
}
