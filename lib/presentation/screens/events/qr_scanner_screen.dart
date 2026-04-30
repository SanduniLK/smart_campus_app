// lib/presentation/screens/events/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/business_logic/event/event_bloc.dart';
import 'package:smart_campus_app/business_logic/event/event_event.dart';
import 'package:smart_campus_app/business_logic/event/event_state.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/database_service.dart';

class QRScannerScreen extends StatefulWidget {
  final int eventId;
  final String eventName;
  final bool isOrganizer;
  const QRScannerScreen({super.key,required this.eventId,
    required this.eventName,
    this.isOrganizer = false,});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? _controller;
  bool _isScanning = true;
  bool _isProcessing = false;

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
            _showSuccessDialog();
          }
          if (state is EventError) {
            _showErrorDialog(state.message);
          }
        },
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: (capture) {
                      if (!_isScanning || _isProcessing) return;
                      
                      final barcode = capture.barcodes.first;
                      final String? code = barcode.rawValue;
                      
                      if (code != null) {
                        _processQRCode(code);
                      }
                    },
                  ),
                  // Scanner overlay guide
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.electricPurple,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(50),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  if (_isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Processing QR Code...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
                        onPressed: () => _controller?.switchCamera(),
                        icon: const Icon(Icons.cameraswitch, color: Colors.white54),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () => _controller?.toggleTorch(),
                        icon: const Icon(Icons.flashlight_on, color: Colors.white54),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isScanning = true;
                            _isProcessing = false;
                          });
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white54),
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

  Future<void> _processQRCode(String code) async {
  setState(() {
    _isScanning = false;
    _isProcessing = true;
  });

  final parts = code.split('|');
  if (parts.length >= 2) {
    try {
      final scannedEventId = int.parse(parts[0]);
      final userId = parts[1];
      
      // Check if this QR code is for the expected event
      if (scannedEventId != widget.eventId) {
        _showErrorDialog('This QR code is for a different event!\nExpected: ${widget.eventName}');
        setState(() {
          _isScanning = true;
          _isProcessing = false;
        });
        return;
      }
      
      // If organizer, just verify the event matches (can scan any user's QR)
      // If attendee, verify it's their own QR
      if (!widget.isOrganizer) {
        final authState = context.read<AuthBloc>().state;
        if (authState is! AuthAuthenticated) {
          _showErrorDialog('User not authenticated');
          setState(() {
            _isScanning = true;
            _isProcessing = false;
          });
          return;
        }
        
        if (userId != authState.user.id) {
          _showErrorDialog('This QR code belongs to another user!');
          setState(() {
            _isScanning = true;
            _isProcessing = false;
          });
          return;
        }
      }
      
      // Check if already scanned
      final db = DatabaseService();
      final alreadyScanned = await db.hasUserScannedForEvent(widget.eventId, userId);
      
      if (alreadyScanned) {
        _showErrorDialog('This user has already scanned for this event!');
        setState(() {
          _isScanning = true;
          _isProcessing = false;
        });
        return;
      }
      
      // Proceed with scan
      context.read<EventBloc>().add(ScanQR(widget.eventId, userId));
      
    } catch (e) {
      _showErrorDialog('Invalid QR Code format');
      setState(() {
        _isScanning = true;
        _isProcessing = false;
      });
    }
  } else {
    _showErrorDialog('Invalid QR Code format');
    setState(() {
      _isScanning = true;
      _isProcessing = false;
    });
  }
}

  void _showSuccessDialog() {
    setState(() {
      _isProcessing = false;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            const Text('Attendance Marked!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              '✅ Successfully Scanned!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You can now attend the event.',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your attendance has been recorded in the system.',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Return to previous screen
            },
            child: const Text('OK', style: TextStyle(color: AppColors.electricPurple)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    setState(() {
      _isProcessing = false;
      _isScanning = true;
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            const Text('Scan Failed', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Make sure you are registered for this event and using a valid QR code.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again', style: TextStyle(color: AppColors.electricPurple)),
          ),
        ],
      ),
    );
  }
}