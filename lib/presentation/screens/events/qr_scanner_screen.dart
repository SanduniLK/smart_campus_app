// lib/presentation/screens/events/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_campus_app/business_logic/event/event_bloc.dart';
import 'package:smart_campus_app/business_logic/event/event_event.dart';
import 'package:smart_campus_app/business_logic/event/event_state.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? _controller;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan QR Code', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => _controller?.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller?.toggleTorch(),
          ),
        ],
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is QRScanned) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance marked successfully!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
          if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
            _isScanning = true;
          }
        },
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  if (!_isScanning) return;
                  _isScanning = false;
                  
                  final barcode = capture.barcodes.first;
                  final String? code = barcode.rawValue;
                  
                  if (code != null) {
                    // Parse QR: eventId|userId|timestamp
                    final parts = code.split('|');
                    if (parts.length >= 2) {
                      final eventId = int.parse(parts[0]);
                      final userId = parts[1];
                      context.read<EventBloc>().add(ScanQR(eventId, userId));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid QR Code'), backgroundColor: Colors.red),
                      );
                      _isScanning = true;
                    }
                  } else {
                    _isScanning = true;
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.glassSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner, size: 50, color: AppColors.electricPurple),
                  const SizedBox(height: 12),
                  const Text(
                    'Position the QR code inside the frame',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Only valid event QR codes will be accepted',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _controller?.switchCamera()),
                        icon: const Icon(Icons.cameraswitch, color: Colors.white54),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () => setState(() => _controller?.toggleTorch()),
                        icon: const Icon(Icons.flashlight_on, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}