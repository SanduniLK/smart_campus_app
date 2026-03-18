import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/core/services/database_service.dart';

class EmailVerificationDialog extends StatefulWidget {
  final String email;
  final String userRole;
  final Map<String, dynamic>? userData;
  final VoidCallback? onVerified;

  const EmailVerificationDialog({
    super.key,
    required this.email,
    required this.userRole,
    this.userData,
    this.onVerified,
  });

  @override
  State<EmailVerificationDialog> createState() => _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  bool _isChecking = false;
  bool _isResending = false;
  bool _isSaving = false;
  final DatabaseService _db = DatabaseService();
  late final FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    Future.delayed(const Duration(seconds: 3), _checkVerificationStatus);
  }

  Future<void> _saveUserDataToDatabase() async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) return;

      Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': widget.email,
        'fullName': user.displayName ?? 'User',
        'role': widget.userRole,
        'isEmailVerified': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _db.insertOrUpdateUser(userData);

      if (widget.userRole == 'student' && widget.userData != null) {
        Map<String, dynamic> studentData = {
          'uid': user.uid,
          ...widget.userData!,
        };
        await _db.insertStudentDetails(studentData);
      } else if (widget.userRole == 'staff' && widget.userData != null) {
        Map<String, dynamic> staffData = {
          'uid': user.uid,
          ...widget.userData!,
        };
        await _db.insertStaffDetails(staffData);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _checkVerificationStatus() async {
    if (!mounted) return;

    setState(() => _isChecking = true);

    final isVerified = await _firebaseService.checkEmailVerified();

    if (!mounted) return;

    setState(() => _isChecking = false);

    if (isVerified) {
      setState(() => _isSaving = true);
      
      await _saveUserDataToDatabase();
      
      setState(() => _isSaving = false);

      if (mounted) {
        Navigator.pop(context);
        
        if (widget.onVerified != null) {
          widget.onVerified!();
        } else {
          _showSuccessDialog();
        }
      }
    } else {
      if (mounted) {
        Future.delayed(const Duration(seconds: 3), _checkVerificationStatus);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.electricPurple, AppColors.softMagenta],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Email Verified!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your account has been created successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.electricPurple, AppColors.softMagenta],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Go to Login',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);

    try {
      await _firebaseService.sendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email resent!', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend email', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.electricPurple, AppColors.softMagenta],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: _isChecking || _isSaving
                  ? const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 40),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              _isSaving ? 'Saving Your Data...' : 'Verify Your Email',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            if (!_isSaving) ...[
              Text(
                'We\'ve sent a verification link to',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.vibrantYellow,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Please check your inbox and click the verification link to activate your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ] else ...[
              Text(
                'Creating your profile as ${widget.userRole}...',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            if (_isChecking && !_isSaving)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 8),
                    Text(
                      'Checking verification status...',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            
            if (!_isSaving) ...[
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.electricPurple, AppColors.softMagenta],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _isResending ? null : _resendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isResending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Resend Email', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Open email app - implement later
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Open Email App',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'I\'ll verify later',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}