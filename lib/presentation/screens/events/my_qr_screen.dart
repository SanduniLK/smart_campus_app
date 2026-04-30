// lib/presentation/screens/events/my_qr_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';

class MyQRScreen extends StatelessWidget {
  final int eventId;
  final String eventName;
  
  const MyQRScreen({
    super.key, 
    required this.eventId,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }
    
    final userId = authState.user.id;
    final qrData = '$eventId|$userId|${DateTime.now().millisecondsSinceEpoch}';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My QR Code', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
                eyeStyle: const QrEyeStyle(
                  color: AppColors.electricPurple,
                  eyeShape: QrEyeShape.circle,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  color: AppColors.electricPurple,
                  dataModuleShape: QrDataModuleShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              eventName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Show this QR code at the venue entrance',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Valid for one-time scan only',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}