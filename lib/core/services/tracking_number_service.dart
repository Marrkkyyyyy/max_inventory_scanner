class TrackingNumberService {
  static String identifyCourier(String? barcodeResult) {
    if (barcodeResult == null || barcodeResult.isEmpty) {
      return "Unknown";
    }

    String cleaned = cleanBarcode(barcodeResult);

    final Map<String, RegExp> courierPatterns = {
      "UPS": RegExp(r'^1Z\w{16}$'),
      "USPS": RegExp(r'^9\d{21}(\d{4})?$'),
      "DHL": RegExp(r'^\d{10}$'),
      "FedEx": RegExp(r'^\d{12}$|^\d{24}$|^\d{34}$'),
      "Amazon US Logistics": RegExp(r'^TBA\w{12}$'),
      "Amazon Canada Logistics": RegExp(r'^TBC\w+$'),
      "International Tracked": RegExp(r'^[A-Z]{2}\d{9}[A-Z]{2}$'),
    };

    for (var entry in courierPatterns.entries) {
      if (entry.value.hasMatch(cleaned)) {
        return entry.key;
      }
    }

    return "Unknown";
  }

  static Future<String?> resolveTrackingNumber(String? barcodeResult) async {
    if (barcodeResult == null || barcodeResult.isEmpty) return null;

    String cleaned = cleanBarcode(barcodeResult);
    String courier = identifyCourier(cleaned);

    switch (courier) {
      case "FedEx":
        return cleaned.substring(cleaned.length - 12);
      case "USPS":
        return cleaned;
      default:
        return barcodeResult;
    }
  }

  static String cleanBarcode(String rawScan) {
    String cleaned = rawScan.replaceAll(' ', '').trim();

    if (cleaned.length >= 22 &&
        cleaned.substring(cleaned.length - 22).startsWith('9')) {
      return cleaned.substring(cleaned.length - 22);
    } else if (cleaned.length >= 22 &&
        cleaned.substring(cleaned.length - 26).startsWith('9')) {
      return cleaned.substring(cleaned.length - 26);
    }

    return cleaned;
  }

  static String getDisplayTrackingNumber(
      String logistic, String barcodeResult) {
    return logistic == 'USPS' ? cleanBarcode(barcodeResult) : barcodeResult;
  }

  static String getInternalTrackingNumber(
      String logistic, String displayedNumber) {
    if (logistic == 'FedEx' && displayedNumber.length >= 12) {
      return displayedNumber.substring(displayedNumber.length - 12);
    }
    return displayedNumber;
  }

  static String getLogisticResult(String barcodeResult) {
    return identifyCourier(barcodeResult);
  }
}
