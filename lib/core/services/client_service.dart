import 'dart:convert';
import 'package:flutter/services.dart';

class ClientService {
  List<String> allClients = [];

  Future<void> loadClients() async {
    final String response = await rootBundle.loadString('assets/client.json');
    final data = await json.decode(response);
    allClients = List<String>.from(
        data.map((client) => "${client['firstName']} ${client['lastName']}"));
  }

  List<String> getSuggestions(String query) {
    query = query.toLowerCase();
    return allClients
        .where((client) => client.toLowerCase().contains(query))
        .take(5)
        .toList();
  }
}
