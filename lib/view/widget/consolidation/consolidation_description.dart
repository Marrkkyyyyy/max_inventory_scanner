import 'package:flutter/material.dart';

class ConsolidationDescription extends StatelessWidget {
  const ConsolidationDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Combine multiple packages into one",
      style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black54),
    );
  }
}
