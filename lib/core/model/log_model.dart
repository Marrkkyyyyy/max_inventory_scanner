class LogModel {
  String? logID;
  String? packageID;
  String? userID;
  String? photoUrl;
  String? problemID;
  String? status;
  dynamic timestamp;

  LogModel({
    this.logID,
    this.packageID,
    this.userID,
    this.photoUrl,
    this.problemID,
    this.status,
    this.timestamp,
  });

  LogModel.fromJson(Map<String, dynamic> json) {
    logID = json['logID'];
    packageID = json['packageID'];
    userID = json['userID'];
    photoUrl = json['photoUrl'];
    problemID = json['problemID'];
    status = json['status'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    return {
      'logID': logID,
      'packageID': packageID,
      'userID': userID,
      'photoUrl': photoUrl,
      'problemID': problemID,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
