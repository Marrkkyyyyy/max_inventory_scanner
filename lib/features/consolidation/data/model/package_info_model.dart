import 'dart:io';

class PackageInfo {
  final String trackingNumber;
  File? image;
  String? problemType;
  String? otherProblem;

  PackageInfo({
    required this.trackingNumber,
    this.image,
    this.problemType,
    this.otherProblem,
  });
}
