import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/screens/splash/widgets/animated_glass_background.dart';
import 'package:smart_campus_app/presentation/widgets/email_verification_dialog.dart';

class StudentSignUpScreen extends StatefulWidget {
  const StudentSignUpScreen({super.key});

  @override
  State<StudentSignUpScreen> createState() => _StudentSignUpScreenState();
}

class _StudentSignUpScreenState extends State<StudentSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Page Controller for steps
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;
  
  // Controllers for Step 1 - Basic Info
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Controllers for Step 2 - Academic Info
  final _indexNumberController = TextEditingController();
  final _campusIdController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  
  // Controllers for Step 3 - Program Details
  String? _selectedDepartment;
  String? _selectedDegree;
  String? _selectedIntake;
  
  // Focus Nodes
  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  // State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  
  // Dropdown Data
  final List<String> departments = [
    'Department of ICT',
    'Department of Engineering',
    'Department of Mathematics',
    'Department of Physics',
    'Department of Chemistry',
  ];
  
  final Map<String, List<String>> degreesByDepartment = {
    'Department of ICT': ['BSc in Computer Science', 'BSc in Information Systems', 'BSc in Software Engineering'],
    'Department of Engineering': ['BSc in Electrical Engineering', 'BSc in Mechanical Engineering', 'BSc in Civil Engineering'],
    'Department of Mathematics': ['BSc in Mathematics', 'BSc in Statistics', 'BSc in Applied Mathematics'],
    'Department of Physics': ['BSc in Physics', 'BSc in Applied Physics'],
    'Department of Chemistry': ['BSc in Chemistry', 'BSc in Industrial Chemistry'],
  };
  
  final List<String> intakes = ['2022/2023', '2023/2024', '2024/2025', '2025/2026'];

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
    if (_currentStep == 0 && _validateStep1()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 1 && _validateStep2()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateStep1() {
    return _fullNameController.text.isNotEmpty &&
           _emailController.text.isNotEmpty &&
           _passwordController.text.isNotEmpty &&
           _confirmPasswordController.text.isNotEmpty &&
           _passwordController.text == _confirmPasswordController.text &&
           _agreeToTerms;
  }

  bool _validateStep2() {
    return _indexNumberController.text.isNotEmpty &&
           _campusIdController.text.isNotEmpty &&
           _nicController.text.isNotEmpty &&
           _phoneController.text.isNotEmpty &&
           _dobController.text.isNotEmpty;
  }

  void _completeSignUp() {
    if (_formKey.currentState!.validate()) {
    // Validate all required fields
    if (_selectedDepartment != null && 
        _selectedDegree != null && 
        _selectedIntake != null) {
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricPurple),
          ),
        ),
      );

      // Simulate profile completion
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context); // Close loading
        
        // Show email verification dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => EmailVerificationDialog(
            email: _emailController.text.trim(),
            userRole: 'student',
          ),
        );
      });
    } else {
      // Show error if program details not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete all program details',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
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
                      'Profile Created!',
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your student profile has been created successfully.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.8)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Go to Login',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedGlassBackground(),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.2))),
          
          SafeArea(
            child: Column(
              children: [
                // Top Bar with Back and Progress
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      _buildBackButton(),
                      const SizedBox(width: 16),
                      Expanded(child: _buildProgressBar()),
                    ],
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildHeader(),
                ),
                
                // PageView for Steps
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentStep = index);
                    },
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                    ],
                  ),
                ),
                
                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildNavigationButtons(),
                ),
              ],
            ),
          ),
          
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: _currentStep > 0 ? _previousPage : () => Navigator.pop(context),
            icon: Icon(
              _currentStep > 0 ? Icons.arrow_back_ios_new_rounded : Icons.close_rounded,
              color: Colors.white,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            splashRadius: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $_currentStep of $_totalSteps',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(_currentStep / _totalSteps * 100).toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.electricPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricPurple),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    String title = '';
    String subtitle = '';
    
    switch (_currentStep) {
      case 0:
        title = 'Basic Information';
        subtitle = 'Create your account credentials';
        break;
      case 1:
        title = 'Academic Details';
        subtitle = 'Tell us about your student info';
        break;
      case 2:
        title = 'Program Selection';
        subtitle = 'Choose your department and degree';
        break;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildGlassTextField(
              controller: _fullNameController,
              focusNode: _fullNameFocusNode,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              validator: _validateFullName,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              label: 'Email',
              icon: Icons.email_outlined,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              validator: _validatePassword,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                splashRadius: 20,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              label: 'Confirm Password',
              icon: Icons.lock_outline_rounded,
              validator: _validateConfirmPassword,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                splashRadius: 20,
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            _buildTermsCheckbox(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildGlassTextField(
            controller: _indexNumberController,
            label: 'Index Number',
            icon: Icons.numbers_rounded,
            validator: _validateIndexNumber,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _campusIdController,
            label: 'Campus ID',
            icon: Icons.badge_rounded,
            validator: _validateCampusId,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _nicController,
            label: 'NIC',
            icon: Icons.credit_card_rounded,
            validator: _validateNIC,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_rounded,
            validator: _validatePhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _dobController,
            label: 'Date of Birth (DD/MM/YYYY)',
            icon: Icons.cake_rounded,
            validator: _validateDOB,
            readOnly: true,
            onTap: () => _selectDate(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildGlassDropdown(
            value: _selectedDepartment,
            items: departments,
            label: 'Department',
            icon: Icons.school_rounded,
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value;
                _selectedDegree = null;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildGlassDropdown(
            value: _selectedDegree,
            items: _selectedDepartment != null 
                ? degreesByDepartment[_selectedDepartment] ?? [] 
                : [],
            label: 'Degree Program',
            icon: Icons.menu_book_rounded,
            onChanged: _selectedDepartment != null
                ? (value) => setState(() => _selectedDegree = value)
                : null,
          ),
          const SizedBox(height: 16),
          _buildGlassDropdown(
            value: _selectedIntake,
            items: intakes,
            label: 'Intake',
            icon: Icons.calendar_today_rounded,
            onChanged: (value) => setState(() => _selectedIntake = value),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            cursorColor: AppColors.electricPurple,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 14),
              floatingLabelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?)? onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: Colors.black.withOpacity(0.8),
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.white.withOpacity(0.8)),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 14),
              floatingLabelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return AppColors.electricPurple;
              return Colors.transparent;
            }),
            checkColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'I agree to the Terms & Conditions and Privacy Policy',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: _buildGlassButton(
              text: 'Back',
              onPressed: _previousPage,
              isPrimary: false,
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: _buildGlassButton(
            text: _currentStep == _totalSteps - 1 ? 'Complete' : 'Next',
            onPressed: _currentStep == _totalSteps - 1 ? _completeSignUp : _nextPage,
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                colors: [AppColors.electricPurple, AppColors.softMagenta],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isPrimary ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isPrimary ? Colors.white : Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricPurple),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.electricPurple,
              onPrimary: Colors.white,
              surface: Color(0xFF1F222B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }
}