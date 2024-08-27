// lib/register_face_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart'
    as img; // Add image package for image manipulation
import 'api_service.dart';

class RegisterFacePage extends StatefulWidget {
  @override
  _RegisterFacePageState createState() => _RegisterFacePageState();
}

class _RegisterFacePageState extends State<RegisterFacePage> {
  final _apiService = ApiService('http://10.0.2.2:5000');
  XFile? _imageFile;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  String _message = '';
  Color _messageColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![0],
      ResolutionPreset.high,
    );
    await _cameraController?.initialize();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final resizedImage = await _resizeImage(imageFile);
      setState(() {
        _imageFile = XFile(resizedImage.path);
      });
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final XFile file = await _cameraController!.takePicture();
    final File imageFile = File(file.path);
    final resizedImage = await _resizeImage(imageFile);
    setState(() {
      _imageFile = XFile(resizedImage.path);
    });
  }

  Future<File> _resizeImage(File imageFile) async {
    final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    if (image == null) {
      throw Exception('Failed to decode image.');
    }

    // Resize the image to a consistent size
    final img.Image resizedImage =
        img.copyResize(image, width: 600); // Adjust width as needed

    // Convert back to a file
    final resizedImageFile = File('${imageFile.path}_resized.jpg')
      ..writeAsBytesSync(img.encodeJpg(resizedImage));

    return resizedImageFile;
  }

  Future<void> _registerFace() async {
    if (_imageFile == null) return;

    final result = await _apiService.registerFace(_imageFile!);
    setState(() {
      _message = result['message'];
      _messageColor = result['status'] == 'success' ? Colors.green : Colors.red;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Face'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_imageFile == null)
              _cameraController != null &&
                      _cameraController!.value.isInitialized
                  ? Container(
                      height: 300,
                      width: double.infinity,
                      child: CameraPreview(_cameraController!),
                    )
                  : Center(child: CircularProgressIndicator())
            else
              Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                height: 300, // Set a fixed height for consistency
                width: double.infinity,
                child: Image.file(
                  File(_imageFile!.path),
                  fit: BoxFit.cover, // Adjust the fit as needed
                ),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image from Gallery'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _takePicture,
              child: Text('Take Picture with Camera'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _registerFace,
              child: Text('Register Face'),
            ),
            SizedBox(height: 20),
            Text(
              _message,
              style: TextStyle(
                color: _messageColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
