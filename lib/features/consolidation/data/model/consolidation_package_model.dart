class PackageModel {
  final String? packageID;
  final String rawTrackingNumber;
  final String trackingNumber;
  final String? carrier;
  final String status;
  final String? consolidatedInto;
  final double? height;
  final double? weight;
  final double? length;

  PackageModel({
    this.packageID,
    required this.rawTrackingNumber,
    required this.trackingNumber,
    this.carrier,
    required this.status,
    this.consolidatedInto,
    this.height,
    this.weight,
    this.length,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      packageID: json['packageID'],
      rawTrackingNumber: json['rawTrackingNumber'],
      trackingNumber: json['trackingNumber'],
      carrier: json['carrier'],
      status: json['status'],
      consolidatedInto: json['consolidatedInto'],
      height: json['height'],
      weight: json['weight'],
      length: json['length'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageID': packageID,
      'rawTrackingNumber': rawTrackingNumber,
      'trackingNumber': trackingNumber,
      'carrier': carrier,
      'status': status,
      'consolidatedInto': consolidatedInto,
      'height': height,
      'weight': weight,
      'length': length,
    };
  }

  PackageModel copyWith({
    String? packageID,
    String? rawTrackingNumber,
    String? trackingNumber,
    String? carrier,
    String? status,
    String? consolidatedInto,
    double? height,
    double? weight,
    double? length,
  }) {
    return PackageModel(
      packageID: packageID ?? this.packageID,
      rawTrackingNumber: rawTrackingNumber ?? this.rawTrackingNumber,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      carrier: carrier ?? this.carrier,
      status: status ?? this.status,
      consolidatedInto: consolidatedInto ?? this.consolidatedInto,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      length: length ?? this.length,
    );
  }
}
