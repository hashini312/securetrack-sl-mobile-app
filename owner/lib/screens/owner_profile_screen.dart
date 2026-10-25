import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'role_selection_screen.dart';

class OwnerProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const OwnerProfileScreen({super.key, this.onBackToHome});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  late String _companyName;
  late String _email;
  late String _phone;
  String _address = 'Level 14, World Trade Center, Echelon Square, Colombo 01';
  final String _tin = 'TIN-104928190 (SLC-IMP-40918)';

  @override
  void initState() {
    super.initState();
    final o = ApiService.currentOwnerNotifier.value;
    _companyName = o.companyName;
    _email = o.email;
    _phone = o.phone;
  }

  void _showEditProfileDialog(BuildContext context, bool isDark, Color textColor, Color cardColor, Color borderColor) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: _companyName);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);
    final addressCtrl = TextEditingController(text: _address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0B3A5A) : const Color(0xFFE0EDFB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryBlue, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Edit Profile Details',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Update your registered Sri Lanka Customs importer credentials.',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                // Company Name Field
                _buildFieldLabel('Company / Entity Name', textColor),
                TextFormField(
                  controller: nameCtrl,
                  style: GoogleFonts.poppins(fontSize: 13, color: textColor),
                  decoration: _buildInputDecoration('Enter registered company name', Icons.business_rounded, isDark, borderColor),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Company name cannot be empty';
                    if (v.trim().length < 3) return 'Must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Email Field (with strict validation)
                _buildFieldLabel('Official Contact Email', textColor),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(fontSize: 13, color: textColor),
                  decoration: _buildInputDecoration('e.g. info@company.lk', Icons.email_outlined, isDark, borderColor),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email address cannot be empty';
                    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!regex.hasMatch(v.trim())) return 'Please enter a valid email format';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Phone Field
                _buildFieldLabel('Direct Hotline Phone', textColor),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(fontSize: 13, color: textColor),
                  decoration: _buildInputDecoration('e.g. +94 11 234 5678', Icons.phone_outlined, isDark, borderColor),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone number cannot be empty';
                    if (v.trim().length < 9) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Address Field
                _buildFieldLabel('Registered Business Address', textColor),
                TextFormField(
                  controller: addressCtrl,
                  maxLines: 2,
                  style: GoogleFonts.poppins(fontSize: 13, color: textColor),
                  decoration: _buildInputDecoration('Registered office address', Icons.location_on_outlined, isDark, borderColor),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Address cannot be empty';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Save Changes Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          _companyName = nameCtrl.text.trim();
                          _email = emailCtrl.text.trim();
                          _phone = phoneCtrl.text.trim();
                          _address = addressCtrl.text.trim();
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF16A34A),
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text('Profile details updated successfully!'),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: Text(
                      'Save Profile Changes',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, bool isDark, Color borderColor) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC);
        final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              tooltip: 'Back',
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else if (widget.onBackToHome != null) {
                  widget.onBackToHome!();
                }
              },
            ),
            title: Text(settings.tr('profile'), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Company Header Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0B3A5A) : AppColors.skyLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.4)),
                        ),
                        child: Icon(Icons.business_rounded, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue, size: 34),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _companyName,
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Registration: PV-84920 • LL-SL-2026',
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Tier 1 Verified Importer (AEO)',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF166534),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Contact & Address Details
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.tr('company_info'),
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileRow(Icons.email_outlined, 'Official Email', _email, textColor),
                      Divider(height: 24, color: borderColor),
                      _buildProfileRow(Icons.phone_outlined, 'Direct Hotline', _phone, textColor),
                      Divider(height: 24, color: borderColor),
                      _buildProfileRow(Icons.location_on_outlined, 'Registered Office', _address, textColor),
                      Divider(height: 24, color: borderColor),
                      _buildProfileRow(Icons.verified_user_outlined, 'Customs TIN Code', _tin, textColor),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Account Statistics
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Statistics',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatBox('12', settings.tr('active_containers'), const Color(0xFF16A34A), isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7)),
                          const SizedBox(width: 12),
                          _buildStatBox('48', settings.tr('delivered_containers'), const Color(0xFF0284C7), isDark ? const Color(0xFF0369A1) : const Color(0xFFE0F2FE)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatBox('60', settings.tr('total_containers'), isDark ? Colors.white70 : const Color(0xFF475569), isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                          const SizedBox(width: 12),
                          _buildStatBox('2', settings.tr('alerts'), const Color(0xFFDC2626), isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Edit Profile Card (Replaced the Settings bar)
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0B3A5A) : const Color(0xFFE0EDFB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryBlue, size: 24),
                    ),
                    title: Text(
                      'Edit Profile Details',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor),
                    ),
                    subtitle: Text(
                      'Modify company name, official email, phone, or address',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
                    onTap: () => _showEditProfileDialog(context, isDark, textColor, cardColor, borderColor),
                  ),
                ),

                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
                    label: Text(
                      settings.tr('sign_out'),
                      style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, Color valueColor, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
