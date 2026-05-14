import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // TODO: Replace these with your actual Cloudinary details
  static const String cloudName = "dkqkg1fzk";
  static const String uploadPreset = "springBoot";

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      // ADDED: A 20-second timeout so it never spins infinitely
// UPDATED: Give the emulator 60 seconds to finish the upload
      final response = await request.send().timeout(const Duration(seconds: 60));      
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200) {
        // Success! Return the permanent Cloudinary URL
        return jsonMap['secure_url']; 
      } else {
        // Print the exact error Cloudinary gives us
        print('Cloudinary Error: ${response.statusCode} - ${jsonMap['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Cloudinary Upload Exception: $e');
      return null;
    }
  }
}