import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/presentation/widgets/splash_screen/animated_glass_background.dart';
import 'package:smart_campus_app/presentation/widgets/glass_dropdown.dart';
import 'package:smart_campus_app/presentation/widgets/email_verification_dialog.dart';
import 'package:smart_campus_app/presentation/widgets/glass_text_field.dart';

class StudentSignUpScreen extends StatefulWidget {
  const StudentSignUpScreen({super.key});

  @override
  State<StudentSignUpScreen> createState() => _StudentSignUpScreenState();
}

class _StudentSignUpScreenState extends State<StudentSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  int _currentStep = 0;
  final int _totalSteps = 3;
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _indexNumberController = TextEditingController();
  final _campusIdController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  
  // Focus Nodes
  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  String? _selectedDepartment;
  String? _selectedDegree;
  String? _selectedIntake;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final List<String> _departments = [
    'Department of ICT',
    'Department of Engineering',
    'Department of Mathematics',
    'Department of Physics',
    'Department of Chemistry',
  ];
  
  final Map<String, List<String>> _degreesByDepartment = {
    'Department of ICT': ['BSc in Computer Science', 'BSc in Information Systems', 'BSc in Software Engineering'],
    'Department of Engineering': ['BSc in Electrical Engineering', 'BSc in Mechanical Engineering', 'BSc in Civil Engineering'],
    'Department of Mathematics': ['BSc in Mathematics', 'BSc in Statistics', 'BSc in Applied Mathematics'],
    'Department of Physics': ['BSc in Physics', 'BSc in Applied Physics'],
    'Department of Chemistry': ['BSc in Chemistry', 'BSc in Industrial Chemistry'],
  };
  
  final List<String> _intakes = ['2022/2023', '2023/2024', '2024/2025', '2025/2026'];

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _indexNumberController.dispose();
    _campusIdController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  // Validation Methods
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Full name is required';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _validateIndexNumber(String? value) {
    if (value == null || value.isEmpty) return 'Index number is required';
    return null;
  }

  String? _validateCampusId(String? value) {
    if (value == null || value.isEmpty) return 'Campus ID is required';
    return null;
  }

  String? _validateNIC(String? value) {
    if (value == null || value.isEmpty) return 'NIC is required';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length < 10) return 'Enter a valid phone number';
    return null;
  }

  String? _validateDOB(String? value) {
    if (value == null || value.isEmpty) return 'Date of birth is required';
    return null;
  }

  void _nextPage() {
    bool isValid = false;
    
    if (_currentStep == 0) {
      isValid = _fullNameController.text.isNotEmpty &&
                _emailController.text.isNotEmpty &&
                _passwordController.text.isNotEmpty &&
                _confirmPasswordController.text.isNotEmpty &&
                _passwordController.text == _confirmPasswordController.text &&
                _agreeToTerms;
    } else if (_currentStep == 1) {
      isValid = _indexNumberController.text.isNotEmpty &&
                _campusIdController.text.isNotEmpty &&
                _nicController.text.isNotEmpty &&
                _phoneController.text.isNotEmpty &&
                _dobController.text.isNotEmpty;
    }

    if (isValid) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeSignUp() async {
    if (_formKey.currentState == null) return;
    
    if (_selectedDepartment == null || _selectedDegree == null || _selectedIntake == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select department, degree and intake'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      print('📧 Creating user with email: ${_emailController.text}');
      
      final user = await FirebaseService.signUpStudent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        indexNumber: _indexNumberController.text.trim(),
        campusId: _campusIdController.text.trim(),
        nic: _nicController.text.trim(),
        phone: _phoneController.text.trim(),
        dob: _dobController.text.trim(),
        department: _selectedDepartment!,
        degree: _selectedDegree!,
        intake: _selectedIntake!,
      );
      
      setState(() => _isLoading = false);
      
      if (user != null && mounted) {
        print('✅ User created successfully: ${user.email}');
        print('📧 Verification email sent to: ${user.email}');
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => EmailVerificationDialog(
            email: _emailController.text.trim(),
            userRole: 'student',
            userData: {
              'fullName': _fullNameController.text.trim(),
              'indexNumber': _indexNumberController.text.trim(),
              'campusId': _campusIdController.text.trim(),
              'nic': _nicController.text.trim(),
              'phone': _phoneController.text.trim(),
              'dob': _dobController.text.trim(),
              'department': _selectedDepartment,
              'degree': _selectedDegree,
              'intake': _selectedIntake,
            },
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Error creating user: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dobController.text = "${picked.day}/${picked.month}/${picked.year}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedGlassBackground(),
          
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildHeader(),
                
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) => setState(() => _currentStep = index),
                      children: [
                        _buildStep1(),
                        _buildStep2(),
                        _buildStep3(),
                      ],
                    ),
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
          ),
          
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              onPressed: _currentStep > 0 
                ? _previousPage 
                : () => Navigator.pop(context),
              icon: Icon(
                _currentStep > 0 ? Icons.arrow_back_ios_new : Icons.close,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${_currentStep + 1}/$_totalSteps',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                  backgroundColor: Colors.white24,
                  color: AppColors.electricPurple,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title = '';
    switch (_currentStep) {
      case 0: title = 'Basic Information'; break;
      case 1: title = 'Academic Details'; break;
      case 2: title = 'Program Selection'; break;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassTextField(
            controller: _fullNameController,
            focusNode: _fullNameFocusNode,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
            validator: _validateFullName,
          ),
          const SizedBox(height: 16),
          GlassTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          GlassTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            validator: _validatePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          GlassTextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            label: 'Confirm Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirmPassword,
            validator: _validateConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            value: _agreeToTerms,
            onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
            title: Text(
              'I agree to Terms & Conditions',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            activeColor: AppColors.electricPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassTextField(
            controller: _indexNumberController,
            label: 'Index Number',
            icon: Icons.numbers,
            validator: _validateIndexNumber,
          ),
          const SizedBox(height: 16),
          GlassTextField(
            controller: _campusIdController,
            label: 'Campus ID',
            icon: Icons.badge,
            validator: _validateCampusId,
          ),
          const SizedBox(height: 16),
          GlassTextField(
            controller: _nicController,
            label: 'NIC',
            icon: Icons.credit_card,
            validator: _validateNIC,
          ),
          const SizedBox(height: 16),
          GlassTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
          const SizedBox(height: 16),
          GlassTextField(
            controller: _dobController,
            label: 'Date of Birth',
            icon: Icons.cake,
            readOnly: true,
            onTap: _selectDate,
            validator: _validateDOB,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassDropdown(
            value: _selectedDepartment,
            items: _departments,
            label: 'Department',
            icon: Icons.school,
            onChanged: (val) => setState(() { 
              _selectedDepartment = val; 
              _selectedDegree = null; 
            }),
          ),
          const SizedBox(height: 16),
          if (_selectedDepartment != null)
            GlassDropdown(
              value: _selectedDegree,
              items: _degreesByDepartment[_selectedDepartment] ?? [],
              label: 'Degree Program',
              icon: Icons.book,
              onChanged: (val) => setState(() => _selectedDegree = val),
            ),
          if (_selectedDepartment != null) const SizedBox(height: 16),
          GlassDropdown(
            value: _selectedIntake,
            items: _intakes,
            label: 'Intake',
            icon: Icons.calendar_month,
            onChanged: (val) => setState(() => _selectedIntake = val),
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.electricPurple, AppColors.softMagenta],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: _completeSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Complete Registration',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    if (_currentStep >= 2) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.electricPurple, AppColors.softMagenta],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Next',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricPurple),
            ),
          ),
        ),
      ),
    );
  }
}