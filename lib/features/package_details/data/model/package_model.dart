class PackageModel {
  String? packageID;
  String? clientID;
  String? clientName;
  String? carrier;
  String? note;
  String? rawTrackingNumber;
  String? trackingNumber;
  String? status;
  String? consolidatedInto;
  double? height;
  double? weight;
  double? length;
  dynamic timestamp;

  PackageModel(
      {this.packageID,
      this.clientID,
      this.clientName,
      this.carrier,
      this.note,
      this.rawTrackingNumber,
      this.trackingNumber,
      this.status,
      this.consolidatedInto,
      this.height,
      this.weight,
      this.length,
      this.timestamp});

  PackageModel.fromJson(Map<String, dynamic> json) {
    packageID = json['packageID'];
    clientID = json['clientID'];
    clientName = json['clientName'];
    carrier = json['carrier'];
    note = json['note'];
    rawTrackingNumber = json['rawTrackingNumber'];
    trackingNumber = json['trackingNumber'];
    status = json['status'];
    consolidatedInto = json['consolidatedInto'];
    height = json['height']?.toDouble();
    weight = json['weight']?.toDouble();
    length = json['length']?.toDouble();
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    return {
      'packageID': packageID,
      'clientID': clientID,
      'clientName': clientName,
      'carrier': carrier,
      'note': note,
      'rawTrackingNumber': rawTrackingNumber,
      'trackingNumber': trackingNumber,
      'status': status,
      'consolidatedInto': consolidatedInto,
      'height': height,
      'weight': weight,
      'length': length,
      'timestamp': timestamp,
    };
  }
}
