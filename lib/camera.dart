import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'insert.dart';

Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();

  return status.isGranted;
}

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    double scanArea =
        MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400
        ? 150.0
        : 300.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea,
        ),
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      ),
    );
  }

void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    bool isProcessing = false; // Mencegah perpindahan halaman ganda

    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && !isProcessing) {
        isProcessing = true;
        await controller.pauseCamera();

        if (!mounted) return;

        // Berpindah ke InsertPage hanya membawa kode teks QR saja secara aman
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => InsertPage(scannedCode: scanData.code),
              ),
            )
            .then((result) {
              if (result == true) {
                Navigator.of(context).pop(true); // Sukses, balik ke Dashboard
              } else {
                isProcessing = false;
                controller
                    .resumeCamera(); // Jika batal, kamera scanner aktif lagi
              }
            });
      }
    });
  }

  void _onPermissionSet(
    BuildContext context,
    QRViewController? ctrl,
    bool permission,
  ) {
    log('Permission set to $permission');
    if (!permission) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('no Permission')));
    }
  }
}
