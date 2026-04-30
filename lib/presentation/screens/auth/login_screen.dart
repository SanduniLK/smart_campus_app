import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_event.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/core/services/database_service.dart';
import 'package:smart_campus_app/presentation/widgets/splash_screen/animated_glass_background.dart';


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

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _handleLogin() {
  if (_formKey.currentState!.validate()) {
    // Close any existing keyboard
    FocusScope.of(context).unfocus();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.electricPurple,
        ),
      ),
    );
    
    // Trigger login
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }
}

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.electricPurple),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          _showLoadingDialog();
        } 
        else if (state is AuthAuthenticated) {
          Navigator.pop(context); // Close loading
          // Navigate to home - HomeScreen will show correct dashboard based on role
          Navigator.pushReplacementNamed(context, '/home');
        } 
        else if (state is AuthEmailVerificationRequired) {
          Navigator.pop(context); // Close loading
          _showVerificationDialog(state.email);
        } 
        else if (state is AuthError) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              const AnimatedGlassBackground(),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBackButton(),
                      const SizedBox(height: 30),
                      _buildWelcomeHeader(),
                      const SizedBox(height: 40),
                      _buildLoginCard(),
                      const SizedBox(height: 24),
                      _buildSignUpLink(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildRememberRow(),
              const SizedBox(height: 24),
              _buildLoginButton(),
              
              // ✅ PASTE THE FIX BUTTON HERE
              const SizedBox(height: 16),
              _buildFixDatabaseButton(),  // Add this line
              
            ],
          ),
        ),
      ),
    ),
  );
}
Widget _buildFixDatabaseButton() {
  return Container(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () async {
        final db = DatabaseService();
        final database = await db.database;
        
        // Check existing columns
        final columns = await database.rawQuery("PRAGMA table_info(students)");
        print('Existing columns: ${columns.map((c) => c['name'])}');
        
        // Add level column
        try {
          await database.execute('ALTER TABLE students ADD COLUMN level TEXT');
          print('✅ Added level column');
        } catch (e) {
          print('level: $e');
        }
        
        // Add currentSemester column
        try {
          await database.execute('ALTER TABLE students ADD COLUMN currentSemester TEXT');
          print('✅ Added currentSemester column');
        } catch (e) {
          print('currentSemester: $e');
        }
        
        // Verify columns were added
        final newColumns = await database.rawQuery("PRAGMA table_info(students)");
        print('New columns: ${newColumns.map((c) => c['name'])}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database fixed! Try signing up again.')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text('Fix Database Now', style: TextStyle(color: Colors.white)),
    ),
  );
}

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      cursorColor: AppColors.electricPurple,
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14),
        hintText: 'Enter your email',
        hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5), fontSize: 14),
        prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.9)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.electricPurple.withOpacity(0.8), width: 2),
        ),
      ),
      validator: _validateEmail,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      cursorColor: AppColors.electricPurple,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14),
        hintText: 'Enter your password',
        hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5), fontSize: 14),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.9)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: Colors.white.withOpacity(0.9),
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.electricPurple.withOpacity(0.8), width: 2),
        ),
      ),
      validator: _validatePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildRememberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) => setState(() => _rememberMe = value ?? false),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return AppColors.electricPurple;
                return Colors.transparent;
              }),
            ),
            Text('Remember me', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text('Forgot Password?', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.electricPurple)),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.electricPurple, AppColors.softMagenta]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text('Sign In', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/role-selection'),
          child: Text('Sign Up', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _showVerificationDialog(String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Verification Required'),
        content: Text('Please verify your email: $email'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}