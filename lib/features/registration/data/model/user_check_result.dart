import '../../../../core/enums/status_result.dart';

class UserCheckResult {
  final StatusResult result;
  final String? userID;

  UserCheckResult(this.result, {this.userID});
}
