import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../services/driver_api_service.dart';
import 'driver_main_nav.dart';
import 'driver_register_screen.dart';
import 'inspector_dashboard_screen.dart';

class DriverLoginScreen extends StatefulWidget {
  final bool isInspector;
  const DriverLoginScreen({super.key, this.isInspector = false});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late bool _isInspector;
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _codeCtrl = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isInspector = widget.isInspector;
    if (_isInspector) {
      _userCtrl.text = 'customs.inspector@customs.gov.lk';
      _passCtrl.text = 'Customs@2026';
      _codeCtrl.text = 'ORUGODAWATTA-RCT';
    } else {
      _userCtrl.text = 'driver@cargooverseas.lk';
      _passCtrl.text = 'Driver@2026';
      _codeCtrl.text = 'WP LC-2225';
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (_isInspector || username.toLowerCase() == 'inspector') {
      final error = await DriverApiService.loginInspector(username, password);
      setState(() => _isLoading = false);
      if (mounted) {
        if (error == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InspectorDashboardScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFEF4444),
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } else {
      final error = await DriverApiService.loginDriver(username, password);
      setState(() => _isLoading = false);
      if (mounted) {
        if (error == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DriverMainNav()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFEF4444),
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
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
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.primaryBlue),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
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
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _isInspector ? Icons.verified_user_rounded : Icons.local_shipping_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Title
                    Text(
                      _isInspector ? 'Customs Inspector Login' : 'Truck Driver Login',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isInspector
                          ? 'Official clearance, smart sealing & incident logging'
                          : settings.tr('app_subtitle'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Form Fields with Validation
                    _buildLabel(
                      _isInspector ? 'Inspector Badge / Username' : 'Driver Email or License ID',
                      textColor,
                    ),
                    _buildTextField(
                      controller: _userCtrl,
                      hint: _isInspector ? 'Enter inspector username' : 'e.g. driver@logistics.lk or B-1234567',
                      icon: _isInspector ? Icons.badge_outlined : Icons.account_circle_outlined,
                      isDark: isDark,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return _isInspector ? 'Please enter badge or username' : 'Please enter email or license ID';
                        }
                        if (v.contains('@')) {
                          final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!regex.hasMatch(v.trim())) {
                            return 'Please enter a valid email address';
                          }
                        } else if (v.trim().length < 3) {
                          return 'ID must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildLabel(settings.tr('password'), textColor),
                    _buildTextField(
                      controller: _passCtrl,
                      hint: 'Enter your password',
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
                        if (v == null || v.isEmpty) return 'Please enter your password';
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildLabel(
                      _isInspector ? 'Duty Terminal / Station Code' : settings.tr('truck_plate'),
                      textColor,
                    ),
                    _buildTextField(
                      controller: _codeCtrl,
                      hint: _isInspector ? 'e.g. ORUGODAWATTA-RCT' : 'e.g. WP LC-2225',
                      icon: _isInspector ? Icons.location_city_outlined : Icons.local_shipping_outlined,
                      isDark: isDark,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return _isInspector ? 'Please enter terminal code' : 'Please enter truck registration';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Quick Demo Accounts Selector (SRS Testing & Viva)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.badge_outlined, size: 14, color: AppColors.primaryBlue),
                              const SizedBox(width: 4),
                              Text(
                                _isInspector ? 'Quick Select Inspector (SRS):' : 'Quick Select Driver (SRS):',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: _isInspector
                                ? [
                                    _buildQuickChip('INSP 1: Hasitha', () {
                                      setState(() {
                                        _userCtrl.text = 'inspector1@securetrack.lk';
                                        _passCtrl.text = 'Customs@2026';
                                        _codeCtrl.text = 'KATUNAYAKE-BOI';
                                      });
                                    }, isDark),
                                    const SizedBox(width: 6),
                                    _buildQuickChip('INSP 2: Samantha', () {
                                      setState(() {
                                        _userCtrl.text = 'inspector2@securetrack.lk';
                                        _passCtrl.text = 'Customs@2026';
                                        _codeCtrl.text = 'COLOMBO-PORT';
                                      });
                                    }, isDark),
                                    const SizedBox(width: 6),
                                    _buildQuickChip('INSP 3: Nuwan', () {
                                      setState(() {
                                        _userCtrl.text = 'inspector3@securetrack.lk';
                                        _passCtrl.text = 'Customs@2026';
                                        _codeCtrl.text = 'BIYAGAMA-FTZ';
                                      });
                                    }, isDark),
                                  ]
                                : [
                                    _buildQuickChip('Driver 1: Sunil', () {
                                      setState(() {
                                        _userCtrl.text = 'driver1@securetrack.lk';
                                        _passCtrl.text = 'Driver@2026';
                                        _codeCtrl.text = 'WP-CAD-1234';
                                      });
                                    }, isDark),
                                    const SizedBox(width: 6),
                                    _buildQuickChip('Driver 2: Kamal', () {
                                      setState(() {
                                        _userCtrl.text = 'driver2@securetrack.lk';
                                        _passCtrl.text = 'Driver@2026';
                                        _codeCtrl.text = 'WP-CAR-5678';
                                      });
                                    }, isDark),
                                    const SizedBox(width: 6),
                                    _buildQuickChip('Driver 3: Nimantha', () {
                                      setState(() {
                                        _userCtrl.text = 'driver3@securetrack.lk';
                                        _passCtrl.text = 'Driver@2026';
                                        _codeCtrl.text = 'WP LC-2225';
                                      });
                                    }, isDark),
                                    const SizedBox(width: 6),
                                    _buildQuickChip('Driver 4: Roshen', () {
                                      setState(() {
                                        _userCtrl.text = 'driver4@securetrack.lk';
                                        _passCtrl.text = 'Driver@2026';
                                        _codeCtrl.text = 'WP-CBE-9901';
                                      });
                                    }, isDark),
                                    const SizedBox(width: 6),
                                    _buildQuickChip('Driver 5: Ruwan', () {
                                      setState(() {
                                        _userCtrl.text = 'driver5@securetrack.lk';
                                        _passCtrl.text = 'Driver@2026';
                                        _codeCtrl.text = 'WP-GA-3412';
                                      });
                                    }, isDark),
                                  ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleLogin,
                        icon: const Icon(Icons.lock_open_rounded, size: 20),
                        label: Text(
                          _isLoading
                              ? 'Authenticating...'
                              : (_isInspector ? 'Verify & Access Terminal' : settings.tr('login')),
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
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        _isInspector ? 'Forgot Inspector Credentials?' : 'Forgot Password or Need Roadside Dispatch?',
                        style: GoogleFonts.poppins(
                          color: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Divider(color: AppColors.borderLight),
                    const SizedBox(height: 14),

                    // Register Driver Button
                    if (!_isInspector) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DriverRegisterScreen()),
                          );
                        },
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                        label: Text(
                          settings.tr('register'),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
                          side: BorderSide(color: isDark ? AppColors.skyBlue : AppColors.primaryBlue),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],



                    const SizedBox(height: 14),
                    Text(
                      '© 2026 Sri Lanka Customs Authority\nSecureTrack SL Integrated Telemetry Suite',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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
  Widget _buildQuickChip(String label, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}