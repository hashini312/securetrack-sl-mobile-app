import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _tinController = TextEditingController();
  final TextEditingController _repNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _termsAccepted = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _companyController.dispose();
    _tinController.dispose();
    _repNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.alertRed,
          content: Text('Please accept the Sri Lanka Customs compliance terms.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final isDark = AppSettingsController.instance.isDarkMode;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Account Registered',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Company profile for "${_companyController.text.trim()}" has been registered successfully with Sri Lanka Customs.\n\nYou can now sign in using your credentials.',
            style: GoogleFonts.poppins(fontSize: 13, color: isDark ? const Color(0xFFCBD5E1) : AppColors.textDark),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Go back to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Back to Login',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? AppColors.darkBackground : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;

        return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Official Sri Lanka Customs SecureTrack SL Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 75,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  settings.tr('register'),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Container Owner & Importer Registration',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 26),

                // Company Name
                _buildLabel(settings.tr('company_name'), textColor),
                _buildTextField(
                  controller: _companyController,
                  hint: 'e.g. ABC Logistics Ltd',
                  icon: Icons.business_outlined,
                  isDark: isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter company name' : null,
                ),
                const SizedBox(height: 16),

                // BRN / TIN
                _buildLabel(settings.tr('brn'), textColor),
                _buildTextField(
                  controller: _tinController,
                  hint: 'e.g. PV-847291 / TIN-102948',
                  icon: Icons.verified_user_outlined,
                  isDark: isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter BRN or TIN number' : null,
                ),
                const SizedBox(height: 16),

                // Representative Name
                _buildLabel(settings.tr('rep_name'), textColor),
                _buildTextField(
                  controller: _repNameController,
                  hint: 'e.g. Kamal Perera',
                  icon: Icons.person_outline,
                  isDark: isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter representative name' : null,
                ),
                const SizedBox(height: 16),

                // Email Address
                _buildLabel(settings.tr('email'), textColor),
                _buildTextField(
                  controller: _emailController,
                  hint: 'contact@company.lk',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter email address';
                    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contact Phone
                _buildLabel(settings.tr('phone'), textColor),
                _buildTextField(
                  controller: _phoneController,
                  hint: '+94 11 234 5678',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  isDark: isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter telephone number' : null,
                ),
                const SizedBox(height: 16),

                // Password
                _buildLabel(settings.tr('password'), textColor),
                _buildTextField(
                  controller: _passwordController,
                  hint: 'Minimum 6 characters',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  isDark: isDark,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter a password';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                _buildLabel(settings.tr('confirm_password'), textColor),
                _buildTextField(
                  controller: _confirmPassController,
                  hint: 'Re-enter password',
                  icon: Icons.lock_outline,
                  obscureText: !_isConfirmVisible,
                  isDark: isDark,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Compliance Terms Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      activeColor: AppColors.primaryBlue,
                      onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          'I agree to Sri Lanka Customs IoT electronic seal tracking guidelines & legal declarations.',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted, height: 1.3),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleRegister,
                    icon: const Icon(Icons.person_add_rounded, size: 20),
                    label: Text(
                      _isLoading ? 'Registering Company...' : 'Create Account & Register',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Back to Login link
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    settings.tr('have_account'),
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
}

  Widget _buildLabel(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    bool isDark = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14, color: isDark ? Colors.white : AppColors.textDark),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.alertRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.alertRed, width: 1.5),
        ),
      ),
    );
  }
}
