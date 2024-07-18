import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<File?> takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      return compressImage(File(image.path));
    }
    return null;
  }

  Future<File?> compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jpg'));
    final splitName = filePath.substring(0, (lastIndex));
    final outPath = "${splitName}_compressed.jpg";

    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 20,
    );

    return result?.path != null ? File(result!.path) : null;
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = 'package_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('package_images/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
