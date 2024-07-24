import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<File?> takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    return image != null ? File(image.path) : null;
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = 'package_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('package_images/$fileName');

      Uint8List compressedData = await FlutterImageCompress.compressWithFile(
            imageFile.absolute.path,
            quality: 30,
            minWidth: 1024,
            minHeight: 1024,
          ) ??
          Uint8List(0);

      SettableMetadata metadata = SettableMetadata(
        cacheControl: 'public,max-age=300',
        contentType: 'image/jpeg',
      );

      UploadTask uploadTask = ref.putData(compressedData, metadata);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
