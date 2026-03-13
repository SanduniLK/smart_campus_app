import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _showLoadingDialog();
      try {
        final user = await FirebaseService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) Navigator.pop(context);

        if (user != null && mounted) {
          _showSnackBar('Login successful!', AppColors.success);
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacementNamed(context, '/home');
          });
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        _showSnackBar(e.toString(), Colors.redAccent);
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glassSurface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const CircularProgressIndicator(color: AppColors.electricPurple),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Same Mesh Background as Splash
          const Positioned.fill(child: MeshBackgroundPainter()),

          // 2. Glass Blur Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: AppColors.background.withOpacity(0.4)),
            ),
          ),

          // 3. Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildGlassTextField(
                      controller: _emailController,
                      label: "Email",
                      icon: Icons.alternate_email_rounded,
                      hint: "it21xxxx@ruh.ac.lk",
                    ),
                    const SizedBox(height: 20),
                    _buildGlassTextField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock_outline_rounded,
                      hint: "••••••••",
                      isPassword: true,
                    ),
                    const SizedBox(height: 15),
                    _buildRememberForgot(),
                    const SizedBox(height: 40),
                    _buildLoginButton(),
                    const SizedBox(height: 30),
                    _buildSocialSection(),
                    const SizedBox(height: 40),
                    _buildSignUpLink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back!",
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
        ),
        Text(
          "Sign in to access your smart campus",
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(label, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.glassSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder.withOpacity(0.1)),
              ),
              child: TextFormField(
                controller: controller,
                obscureText: isPassword ? _obscurePassword : false,
                style: GoogleFonts.poppins(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.3)),
                  prefixIcon: Icon(icon, color: AppColors.electricPurple, size: 22),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
                validator: (v) => v!.isEmpty ? "$label is required" : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              activeColor: AppColors.electricPurple,
              side: BorderSide(color: AppColors.textSecondary.withOpacity(0.5)),
              onChanged: (v) => setState(() => _rememberMe = v!),
            ),
            Text("Remember me", style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text("Forgot Password?", style: GoogleFonts.poppins(color: AppColors.electricPurple, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [AppColors.electricPurple, AppColors.softMagenta]),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text("Sign In", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.cardBorder.withOpacity(0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text("Or continue with", style: GoogleFonts.poppins(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 12)),
            ),
            Expanded(child: Divider(color: AppColors.cardBorder.withOpacity(0.2))),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            _socialButton(Icons.g_mobiledata_rounded, "Google"),
            const SizedBox(width: 15),
            _socialButton(Icons.facebook_rounded, "Facebook"),
          ],
        ),
      ],
    );
  }

  Widget _socialButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: AppColors.glassSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.cardBorder.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Don't have an account? ", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/register'),
            child: Text("Sign Up", style: GoogleFonts.poppins(color: AppColors.electricPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// --- ඔයාගේ MeshBackgroundPainter එක මෙතනට පාවිච්චි කරන්න ---
class MeshBackgroundPainter extends StatelessWidget {
  const MeshBackgroundPainter({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: -100, right: -50, child: _GlowCircle(color: AppColors.electricPurple.withOpacity(0.4), size: 400)),
        Positioned(bottom: -50, left: -100, child: _GlowCircle(color: AppColors.softMagenta.withOpacity(0.3), size: 450)),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withOpacity(0)])),
    );
  }
}