import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import '../core/services/shared_preferences_service.dart';

class DependencyInjection {
  static Future<void> init() async {
    await Firebase.initializeApp();
    await Get.putAsync(() => SharedPreferencesService().init());
    Get.lazyPut<FirebaseFirestore>(() => FirebaseFirestore.instance, fenix: true);
  
  }
}
