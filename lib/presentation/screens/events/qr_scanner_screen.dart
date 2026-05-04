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
import 'package:google_fonts/google_fonts.dart';

class QRScannerScreen extends StatefulWidget {
  final int eventId;
  final String eventName;
  final bool isOrganizer;
  
  const QRScannerScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    this.isOrganizer = false,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with TickerProviderStateMixin {
  MobileScannerController? _controller;
  bool _isScanning = true;
  bool _isProcessing = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Scan QR Code - ${widget.eventName}',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
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
                  // Camera Preview
                  ClipRRect(
                    child: MobileScanner(
                      controller: _controller,
                      onDetect: (capture) {
                        if (!_isScanning || _isProcessing) return;
                        
                        final barcode = capture.barcodes.first;
                        final String? code = barcode.rawValue;
                        
                        if (code != null && code.isNotEmpty) {
                          _processQRCode(code);
                        }
                      },
                    ),
                  ),
                  
                  // Scanner Frame Overlay
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 250 * _pulseAnimation.value,
                          height: 250 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.electricPurple,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.electricPurple.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Corner decorations
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: AppColors.electricPurple, width: 4),
                                      left: BorderSide(color: AppColors.electricPurple, width: 4),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: AppColors.electricPurple, width: 4),
                                      right: BorderSide(color: AppColors.electricPurple, width: 4),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: AppColors.electricPurple, width: 4),
                                      left: BorderSide(color: AppColors.electricPurple, width: 4),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: AppColors.electricPurple, width: 4),
                                      right: BorderSide(color: AppColors.electricPurple, width: 4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Scanning Line Animation
                  Positioned(
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          height: 2,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.electricPurple,
                                Colors.transparent,
                              ],
                            ),
                          ),
                          margin: EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: MediaQuery.of(context).size.height / 3 + (_pulseController.value * 100),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Processing Overlay
                  if (_isProcessing)
                    Container(
                      color: Colors.black.withValues(alpha: 0.8),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: AppColors.electricPurple),
                            const SizedBox(height: 16),
                            Text(
                              'Verifying QR Code...',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Bottom Info Panel
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.glassSurface,
                    AppColors.background,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 24, color: AppColors.electricPurple),
                      const SizedBox(width: 8),
                      Text(
                        'Scan QR Code',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Position the QR code inside the frame',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isOrganizer 
                        ? 'Scan student QR codes to mark attendance'
                        : 'Show this QR code at the event entrance',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: Icons.cameraswitch,
                        onPressed: () => _controller?.switchCamera(),
                      ),
                      const SizedBox(width: 20),
                      _buildControlButton(
                        icon: Icons.flashlight_on,
                        onPressed: () => _controller?.toggleTorch(),
                      ),
                      const SizedBox(width: 20),
                      _buildControlButton(
                        icon: Icons.refresh,
                        onPressed: () {
                          setState(() {
                            _isScanning = true;
                            _isProcessing = false;
                          });
                        },
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

  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Future<void> _processQRCode(String code) async {
    setState(() {
      _isScanning = false;
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 100)); // Small delay for UI

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
          _showErrorDialog('Attendance already marked for this user!');
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
            Expanded(
              child: Text(
                'Attendance Marked!',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              '✅ Successfully Scanned!',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isOrganizer 
                  ? 'Attendance recorded for ${widget.eventName}'
                  : 'You can now attend ${widget.eventName}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your attendance has been recorded in the system.',
                      style: GoogleFonts.poppins(color: Colors.green, fontSize: 12),
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
              Navigator.pop(context, true);
            },
            child: Text('OK', style: GoogleFonts.poppins(color: AppColors.electricPurple)),
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
            Expanded(
              child: Text(
                'Scan Failed',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isOrganizer
                          ? 'Make sure the student is registered for this event.'
                          : 'Make sure you are registered for this event and using a valid QR code.',
                      style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
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
            child: Text('Try Again', style: GoogleFonts.poppins(color: AppColors.electricPurple)),
          ),
        ],
      ),
    );
  }
}