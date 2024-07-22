
import 'package:flutter/material.dart';

class ConsolidationDescription extends StatelessWidget {
  const ConsolidationDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Combine multiple packages into one shipment",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}