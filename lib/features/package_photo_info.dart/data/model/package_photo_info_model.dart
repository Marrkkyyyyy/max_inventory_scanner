import 'package:max_inventory_scanner/core/model/log_model.dart';
import 'package:max_inventory_scanner/features/package_details/data/model/problem_model.dart';

class PackagePhotoInfo {
  final String? status;
  final String photoUrl;
  final String? problemType;

  PackagePhotoInfo({
    this.status,
    required this.photoUrl,
    this.problemType,
  });

  factory PackagePhotoInfo.fromLogAndProblem(
      LogModel log, ProblemModel? problem) {
    return PackagePhotoInfo(
      status: log.status,
      photoUrl: log.photoUrl!,
      problemType: problem?.problemType,
    );
  }
}
