import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService extends GetxService {
  late SharedPreferences _prefs;

  Future<SharedPreferencesService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> registerUser(String name, String location, String userID) async {
    await _prefs.setString('name', name);
    await _prefs.setString('location', location);
    await _prefs.setString('userID', userID);
  }

  String? getName() => _prefs.getString('name');
  String? getLocation() => _prefs.getString('location');
  String? getUserID() => _prefs.getString('userID');
}