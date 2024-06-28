Future<String?> identifyCourier(String? barcodeResult) async {
  if (barcodeResult == null || barcodeResult.isEmpty) {
    return "Unknown";
  }

  barcodeResult = cleanBarcode(barcodeResult);

  final RegExp upsPattern = RegExp(r'^1Z\w{16}$');
  final RegExp uspsPattern = RegExp(r'^9\d{21}$');
  final RegExp dhlPattern = RegExp(r'^\d{10}$');
  final RegExp fedexPattern = RegExp(r'^\d{24}$|^\d{34}$');
  final RegExp amazonUsPattern = RegExp(r'^TBA\w{12}$');
  final RegExp amazonCaPattern = RegExp(r'^TBC\w+$');

  if (upsPattern.hasMatch(barcodeResult)) {
    return "UPS";
  } else if (uspsPattern.hasMatch(barcodeResult)) {
    return "USPS";
  } else if (dhlPattern.hasMatch(barcodeResult)) {
    return "DHL";
  } else if (fedexPattern.hasMatch(barcodeResult)) {
    return "FedEx";
  } else if (amazonUsPattern.hasMatch(barcodeResult)) {
    return "Amazon US Logistics";
  } else if (amazonCaPattern.hasMatch(barcodeResult)) {
    return "Amazon Canada Logistics";
  } else {
    return "Unknown";
  }
}

Future<String?> resolvedTrackingNumber(String? barcodeResult) async {
  if (barcodeResult == null || barcodeResult.isEmpty) return null;

  String cleaned = cleanBarcode(barcodeResult);
  String? courier = await identifyCourier(cleaned);

  if (courier == "FedEx") {
    return cleaned.substring(cleaned.length - 12);
  } else if (courier == "USPS") {
    return cleaned;
  }

  return barcodeResult;
}

String cleanBarcode(String rawScan) {
  String cleaned = rawScan.replaceAll(' ', '').trim();

  if (cleaned.length >= 22) {
    String last22 = cleaned.substring(cleaned.length - 22);
    if (last22.startsWith('9')) {
      return last22;
    }
  }

  return cleaned;
}
