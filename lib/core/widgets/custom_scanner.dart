import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

typedef BarcodeDetectedCallback = void Function(String barcode);

class CustomScanner extends StatefulWidget {
  const CustomScanner({
    super.key,
    this.width,
    this.height,
    required this.onBarcodeDetected,
  });

  final double? width;
  final double? height;
  final BarcodeDetectedCallback onBarcodeDetected;

  @override
  State<CustomScanner> createState() => _CustomScannerState();
}

class _CustomScannerState extends State<CustomScanner> {
  MobileScannerController cameraController = MobileScannerController(
    formats: [BarcodeFormat.all],
    cameraResolution: const Size(1920, 1080),
    returnImage: false,
  );
  bool _isBarcodeProcessed = false;

  @override
  Widget build(BuildContext context) {
    final scanWindowWidth = MediaQuery.of(context).size.width * 0.8;
    final scanWindowHeight = MediaQuery.of(context).size.height * 0.3;

    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          scanWindow: Rect.fromCenter(
            center: Offset(MediaQuery.of(context).size.width / 2,
                MediaQuery.of(context).size.height / 2),
            width: scanWindowWidth,
            height: scanWindowHeight,
          ),
          onDetect: (capture) async {
            if (_isBarcodeProcessed) return;

            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String scannedBarcode = barcodes.first.rawValue.toString();
              _isBarcodeProcessed = true;
              await cameraController.stop();
              widget.onBarcodeDetected(scannedBarcode);
            }
          },
        ),
        Center(
          child: Container(
            width: scanWindowWidth,
            height: scanWindowHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: scanWindowHeight,
                  width: scanWindowWidth,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
