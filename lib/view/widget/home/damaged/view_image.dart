import 'dart:io';

import 'package:flutter/material.dart';

class ViewImage extends StatelessWidget {
  final String image;

  const ViewImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: image,
          child: Image.file(
            File(image),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
