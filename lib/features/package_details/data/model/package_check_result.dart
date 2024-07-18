import '../../../../core/enums/status_result.dart';

class PackageCheckResult {
  final StatusResult result;
  final String? note;
  final String? status;

  PackageCheckResult(this.result, {this.note, this.status});
}
