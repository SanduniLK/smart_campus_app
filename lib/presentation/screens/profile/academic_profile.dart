// lib/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_event.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/data/models/user_model.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _user = state.user;
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildProfileInfo(),
            const SizedBox(height: 32),
            _buildRoleInfo(),
            const SizedBox(height: 32),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.electricPurple, AppColors.softMagenta],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                _user.fullName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getDisplayName(),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getRoleText(),
              style: TextStyle(fontSize: 12, color: _getRoleColor()),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayName() {
    if (_user.isStaff && _user.staffType == 'academic') {
      return 'Dr. ${_user.fullName}';
    }
    return _user.fullName;
  }

  String _getRoleText() {
    if (_user.isStudent) return 'Student';
    if (_user.isAcademicStaff) return 'Academic Staff';
    if (_user.isNonAcademicStaff) return 'Administrative Staff';
    return 'Staff';
  }

  Color _getRoleColor() {
    if (_user.isStudent) return Colors.green;
    if (_user.isAcademicStaff) return AppColors.electricPurple;
    if (_user.isNonAcademicStaff) return AppColors.success;
    return AppColors.textSecondary;
  }

  Widget _buildProfileInfo() {
    return GlassCard(
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', _user.email),
          const Divider(color: Colors.white24, height: 1),
          _buildInfoRow(Icons.person_outline, 'Full Name', _user.fullName),
          const Divider(color: Colors.white24, height: 1),
          _buildInfoRow(Icons.badge_outlined, 'Role', _getRoleText()),
          if (_user.department != null) ...[
            const Divider(color: Colors.white24, height: 1),
            _buildInfoRow(Icons.business_outlined, 'Department', _user.department!),
          ],
          if (_user.phone != null && _user.phone!.isNotEmpty) ...[
            const Divider(color: Colors.white24, height: 1),
            _buildInfoRow(Icons.phone_outlined, 'Phone', _user.phone!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.electricPurple),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleInfo() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Account Information',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          _buildRoleDetailRow('Account Type', _getRoleText()),
          if (_user.isStudent) ...[
            _buildRoleDetailRow('Index Number', _user.indexNumber ?? 'Not set'),
            _buildRoleDetailRow('Degree', _user.degree ?? 'Not set'),
            _buildRoleDetailRow('Intake', _user.intake ?? 'Not set'),
          ],
          if (_user.isAcademicStaff) ...[
            _buildRoleDetailRow('Staff Type', 'Academic'),
            _buildRoleDetailRow('Staff ID', _user.staffId ?? 'Not set'),
            _buildRoleDetailRow('Faculty', _user.faculty ?? 'Not set'),
          ],
          if (_user.isNonAcademicStaff) ...[
            _buildRoleDetailRow('Staff Type', 'Administrative'),
            _buildRoleDetailRow('Staff ID', _user.staffId ?? 'Not set'),
            
          ],
        ],
      ),
    );
  }

  Widget _buildRoleDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.redAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text(
          'Logout',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}