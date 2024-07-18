class ProblemModel {
  String? problemID;
  String packageID;
  String problemType;
  dynamic timestamp;

  ProblemModel({
    this.problemID,
    required this.packageID,
    required this.problemType,
    this.timestamp,
  });

  ProblemModel.fromJson(Map<String, dynamic> json)
      : problemID = json['problemID'],
        packageID = json['packageID'],
        problemType = json['problemType'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() {
    return {
      'problemID': problemID,
      'packageID': packageID,
      'problemType': problemType,
      'timestamp': timestamp,
    };
  }
}
