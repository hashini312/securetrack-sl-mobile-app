import 'role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../services/driver_api_service.dart';


class DriverProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const DriverProfileScreen({super.key, this.onBackToHome});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late String _driverName;
  late String _licenseNo;
  late String _vehicleNo;
  late String _phone;
  final String _dutyClearance = 'Active & Verified (RFID Linked)';

  @override
  void initState() {
    super.initState();
    final d = DriverApiService.currentDriverNotifier.value;
    _driverName = d.fullName;
    _licenseNo = '${d.licenseNo} (Heavy Articulated)';
    _vehicleNo = '${d.vehicleNo} (Prime Mover)';
    _phone = d.phone;
  }

  void _showEditProfileDialog(BuildContext context, bool isDark, Color textColor, Color cardColor, Color borderColor) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: _driverName);
    final licenseCtrl = TextEditingController(text: _licenseNo);
    final vehicleCtrl = TextEditingController(text: _vehicleNo);
    final phoneCtrl = TextEditingController(text: _phone);

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
                          'Edit Driver Credentials',
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
                  'Update your verified Sri Lanka Customs transit driver record.',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                // Driver Name Field
                _buildFieldLabel('Driver Full Name', textColor),
                TextFormField(
                  controller: nameCtrl,
                  style: GoogleFonts.poppins(fontSize: 13, color: textColor),
                  decoration: _buildInputDecoration('Enter driver name', Icons.person_outline_rounded, isDark, borderColor),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Driver name cannot be empty';
                    if (v.trim().length < 3) return 'Must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Driving License No Field
                _buildFieldLabel('Driving License Number', textColor),
                TextFormField(
                  controller: licenseCtrl,
                  style: GoogleFonts.poppins(fontSize: 13, color: textColor),
                  decoration: _buildInputDecoration('e.g. B-49201948', Icons.credit_card_rounded, isDark, borderColor),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'License number cannot be empty';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Assigned Vehicle Plate
                _buildFieldLabel('Assigned Vehicle / Prime Mover', textColor),
                TextFormField(
                  controller: vehicleCtrl,
                  style: GoogleFonts.poppins(fontSize: 13, color: textColor),
                  decoration: _buildInputDecoration('e.g. WP LC-2225', Icons.local_shipping_outlined, isDark, borderColor),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vehicle plate cannot be empty';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Phone Field
                _buildFieldLabel('Contact Mobile Phone', textColor),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(fontSize: 13, color: textColor),
                  decoration: _buildInputDecoration('e.g. +94 77 123 4567', Icons.phone_outlined, isDark, borderColor),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone number cannot be empty';
                    if (v.trim().length < 9) return 'Enter a valid phone number';
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
                          _driverName = nameCtrl.text.trim();
                          _licenseNo = licenseCtrl.text.trim();
                          _vehicleNo = vehicleCtrl.text.trim();
                          _phone = phoneCtrl.text.trim();
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF16A34A),
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text('Driver details updated successfully!'),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: Text(
                      'Save Driver Details',
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
                // Driver Header Card (matching Owner Profile Header Card)
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
                        child: Icon(Icons.local_shipping_rounded, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue, size: 34),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _driverName,
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lic: $_licenseNo • $_vehicleNo',
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
                                'Customs Authorized Driver',
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

                // Driver & Vehicle Credentials (matching Owner Contact Info Card)
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
                        'Driver & Vehicle Details',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileRow(Icons.credit_card_rounded, 'Driving License No', _licenseNo, textColor),
                      Divider(height: 24, color: borderColor),
                      _buildProfileRow(Icons.local_shipping_outlined, 'Assigned Vehicle', _vehicleNo, textColor),
                      Divider(height: 24, color: borderColor),
                      _buildProfileRow(Icons.phone_outlined, 'Driver Contact', _phone, textColor),
                      Divider(height: 24, color: borderColor),
                      _buildProfileRow(Icons.verified_user_outlined, 'Customs Duty Clearance', _dutyClearance, textColor),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Driver Duty & Trip Statistics (matching Owner Statistics Card)
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
                        'Trip & Safety Statistics',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatBox('01', 'Active Trip', const Color(0xFF16A34A), isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7)),
                          const SizedBox(width: 12),
                          _buildStatBox('142', 'Trips Completed', const Color(0xFF0284C7), isDark ? const Color(0xFF0369A1) : const Color(0xFFE0F2FE)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatBox('99.4%', 'Safety Score', isDark ? Colors.white70 : const Color(0xFF475569), isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                          const SizedBox(width: 12),
                          _buildStatBox('0', 'Violations', const Color(0xFFDC2626), isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2)),
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
                      'Edit Driver Credentials',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor),
                    ),
                    subtitle: Text(
                      'Update name, driving license, assigned truck, or phone',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
                    onTap: () => _showEditProfileDialog(context, isDark, textColor, cardColor, borderColor),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign Out Button
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
