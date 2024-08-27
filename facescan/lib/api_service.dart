// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<Map<String, dynamic>> registerFace(XFile imageFile) async {
    var uri = Uri.parse('$baseUrl/register');
    var request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    var responseString = await response.stream.bytesToString();
    return json.decode(responseString);
  }

  Future<Map<String, dynamic>> verifyFace(XFile imageFile) async {
    var uri = Uri.parse('$baseUrl/verify');
    var request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    var responseString = await response.stream.bytesToString();
    return json.decode(responseString);
  }
}
