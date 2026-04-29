import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/core/services/firebase_service.dart';
import 'package:smart_campus_app/presentation/widgets/email_verification_dialog.dart';
import 'package:smart_campus_app/presentation/widgets/splash_screen/animated_glass_background.dart';

class StaffSignUpScreen extends StatefulWidget {
  const StaffSignUpScreen({super.key});

  @override
  State<StaffSignUpScreen> createState() => _StaffSignUpScreenState();
}

class _StaffSignUpScreenState extends State<StaffSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final _staffIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _positionController = TextEditingController();
  final _workLocationController = TextEditingController();
  
  // Selection fields
  String _staffType = 'academic';
  String? _selectedTitle;
  String? _selectedFaculty;
  String? _selectedDepartment;
  String? _selectedDivision;
  
  // Focus nodes
  final _staffIdFocusNode = FocusNode();
  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  late final FirebaseService _firebaseService;

  // Data for dropdowns
  final List<String> _titles = [
    'Professor', 'Dr.', 'Mr.', 'Ms.', 'Mrs.', 'Eng.', 'Prof. Dr.'
  ];
  
  final List<String> _faculties = [
    'Faculty of Technology',
    'Faculty of Engineering',
    'Faculty of Science',
    'Faculty of Medicine',
    'Faculty of Business',
    'Faculty of Humanities',
    'Faculty of Law',
    'Faculty of Agriculture',
  ];
  
  final Map<String, List<String>> _departmentsByFaculty = {
    'Faculty of Technology': [
      'Department of ICT',
      'Department of Electrical Engineering',
      'Department of Mechanical Engineering',
      'Department of Civil Engineering',
    ],
    'Faculty of Engineering': [
      'Department of Computer Engineering',
      'Department of Electronics',
      'Department of Mechanical Engineering',
      'Department of Civil Engineering',
    ],
    'Faculty of Science': [
      'Department of Mathematics',
      'Department of Physics',
      'Department of Chemistry',
      'Department of Biology',
    ],
    'Faculty of Medicine': [
      'Department of Anatomy',
      'Department of Physiology',
      'Department of Pharmacology',
    ],
    'Faculty of Business': [
      'Department of Management',
      'Department of Finance',
      'Department of Marketing',
    ],
    'Faculty of Humanities': [
      'Department of English',
      'Department of History',
      'Department of Sociology',
    ],
    'Faculty of Law': [
      'Department of Public Law',
      'Department of Private Law',
    ],
    'Faculty of Agriculture': [
      'Department of Crop Science',
      'Department of Animal Science',
    ],
  };
  
  final List<String> _divisions = [
    'Administration', 'Library Services', 'Security Services', 
    'Finance Department', 'IT Support', 'Student Affairs',
    'Human Resources', 'Maintenance Services', 'Transport Services',
  ];

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
  }

  @override
  void dispose() {
    _staffIdController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _positionController.dispose();
    _workLocationController.dispose();
    _staffIdFocusNode.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  // Validators
  String? _validateStaffId(String? value) {
    if (value == null || value.isEmpty) return 'Staff ID is required';
    if (value.length < 3) return 'Staff ID must be at least 3 characters';
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Full name is required';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
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

  String? _validateTitle(String? value) {
    if (_staffType == 'academic' && (value == null || value.isEmpty)) {
      return 'Please select a title';
    }
    return null;
  }

  String? _validateFaculty(String? value) {
    if (_staffType == 'academic' && (value == null || value.isEmpty)) {
      return 'Please select a faculty';
    }
    return null;
  }

  String? _validateDepartment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a department';
    }
    return null;
  }

  String? _validateDivision(String? value) {
    if (_staffType == 'non_academic' && (value == null || value.isEmpty)) {
      return 'Please select a division';
    }
    return null;
  }

  String? _validatePosition(String? value) {
    if (_staffType == 'non_academic' && (value == null || value.isEmpty)) {
      return 'Position is required';
    }
    return null;
  }

  String _getFullNameWithTitle() {
    if (_staffType == 'academic' && _selectedTitle != null) {
      return '${_selectedTitle} ${_fullNameController.text.trim()}';
    }
    return _fullNameController.text.trim();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      setState(() => _isLoading = true);
      
      try {
        final fullNameWithTitle = _getFullNameWithTitle();
        
        final user = await _firebaseService.signUpStaff(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: fullNameWithTitle,
          staffId: _staffIdController.text.trim(),
          faculty: _selectedFaculty ?? '',
          department: _selectedDepartment ?? '',
          
        );
        
        setState(() => _isLoading = false);
        
        if (user != null && mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => EmailVerificationDialog(
              email: _emailController.text.trim(),
              userRole: 'staff',
              userData: {
                'staffId': _staffIdController.text.trim(),
                'staffType': _staffType,
                'fullName': fullNameWithTitle,
              },
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Conditions'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackButton(),
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildForm(),
                ],
              ),
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
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staff Registration',
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(
          'Create your staff account',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildStaffTypeRadios(),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _staffIdController,
                  focusNode: _staffIdFocusNode,
                  label: 'Staff ID',
                  icon: Icons.badge_rounded,
                  validator: _validateStaffId,
                ),
                const SizedBox(height: 15),
                if (_staffType == 'academic') ...[
                  _buildTitleDropdown(),
                  const SizedBox(height: 15),
                ],
                _buildTextField(
                  controller: _fullNameController,
                  focusNode: _fullNameFocusNode,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  validator: _validateFullName,
                ),
                const SizedBox(height: 15),
                if (_staffType == 'academic') ...[
                  _buildFacultyDropdown(),
                  const SizedBox(height: 15),
                ],
                _buildDepartmentDropdown(),
                const SizedBox(height: 15),
                if (_staffType == 'non_academic') ...[
                  _buildDivisionDropdown(),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _positionController,
                    focusNode: FocusNode(),
                    label: 'Position',
                    icon: Icons.work_outline,
                    validator: _validatePosition,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _workLocationController,
                    focusNode: FocusNode(),
                    label: 'Work Location',
                    icon: Icons.location_on_outlined,
                    validator: (value) => null,
                  ),
                  const SizedBox(height: 15),
                ],
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  validator: _validatePassword,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline_rounded,
                  validator: _validateConfirmPassword,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTermsCheckbox(),
                const SizedBox(height: 20),
                _buildSignUpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildStaffTypeRadios() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
    ),
    child: Row(
      children: [
        // Academic Radio - with Expanded to prevent overflow
        Expanded(
          child: Row(
            children: [
              Radio<String>(
                value: 'academic',
                groupValue: _staffType,
                onChanged: (value) {
                  setState(() {
                    _staffType = value!;
                    _selectedFaculty = null;
                    _selectedDepartment = null;
                  });
                },
                activeColor: AppColors.electricPurple,
              ),
              Expanded(
                child: Text(
                  'Academic',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Non-Academic Radio - with Expanded to prevent overflow
        Expanded(
          child: Row(
            children: [
              Radio<String>(
                value: 'non_academic',
                groupValue: _staffType,
                onChanged: (value) {
                  setState(() {
                    _staffType = value!;
                    _selectedDivision = null;
                  });
                },
                activeColor: AppColors.electricPurple,
              ),
              Expanded(
                child: Text(
                  'Non-Academic',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildTitleDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedTitle,
        hint: Text('Select Title', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
        dropdownColor: Colors.grey[900],
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        items: _titles.map((title) => DropdownMenuItem(value: title, child: Text(title))).toList(),
        onChanged: (value) => setState(() => _selectedTitle = value),
        validator: _validateTitle,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.drive_file_rename_outline, color: Colors.white.withValues(alpha: 0.8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFacultyDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedFaculty,
        hint: Text('Select Faculty', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
        dropdownColor: Colors.grey[900],
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        items: _faculties.map((faculty) => DropdownMenuItem(value: faculty, child: Text(faculty))).toList(),
        onChanged: (value) {
          setState(() {
            _selectedFaculty = value;
            _selectedDepartment = null;
          });
        },
        validator: _validateFaculty,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.school, color: Colors.white.withValues(alpha: 0.8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    List<String> departments = [];
    
    if (_staffType == 'academic' && _selectedFaculty != null) {
      departments = _departmentsByFaculty[_selectedFaculty] ?? [];
    } else if (_staffType == 'non_academic') {
      departments = [
        'Administration Department', 'Finance Department', 'Human Resources',
        'IT Services', 'Library Services', 'Security Services', 'Student Affairs',
      ];
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedDepartment,
        hint: Text('Select Department', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
        dropdownColor: Colors.grey[900],
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        items: departments.map((dept) => DropdownMenuItem(value: dept, child: Text(dept))).toList(),
        onChanged: (value) => setState(() => _selectedDepartment = value),
        validator: _validateDepartment,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.business_center, color: Colors.white.withValues(alpha: 0.8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDivisionDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedDivision,
        hint: Text('Select Division', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
        dropdownColor: Colors.grey[900],
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        items: _divisions.map((division) => DropdownMenuItem(value: division, child: Text(division))).toList(),
        onChanged: (value) => setState(() => _selectedDivision = value),
        validator: _validateDivision,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.category, color: Colors.white.withValues(alpha: 0.8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            cursorColor: AppColors.electricPurple,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
              floatingLabelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
              prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'I agree to the Terms & Conditions and Privacy Policy',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.electricPurple, AppColors.softMagenta],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricPurple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          'Create Account',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
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
}