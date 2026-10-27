import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported Languages in Sri Lanka Customs ecosystem
enum AppLanguage {
  english('en', 'English'),
  sinhala('si', 'සිංහල'),
  tamil('ta', 'தமிழ்');

  final String code;
  final String label;

  const AppLanguage(this.code, this.label);
}

/// Central Localization Translations Dictionary for Sri Lanka Customs SecureTrack SL
class AppTranslations {
  AppTranslations._();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'SecureTrack SL',
      'app_subtitle': 'IoT Container Monitoring Framework',
      'dashboard': 'Home',
      'tracking': 'Navigate',
      'alerts': 'Notifications',
      'containers': 'Trip Details',
      'profile': 'Profile',
      'settings': 'Settings',
      'hello': 'Hello',
      'on_track': 'On Route',
      'arrived': 'Delivered',
      'delayed': 'Delayed',
      'speed': 'Speed',
      'battery': 'Battery',
      'location': 'Location',
      'route': 'Route Corridor',
      'eta': 'ETA',
      'sign_out': 'Log Out',
      'appearance': 'Appearance',
      'theme_mode': 'App Theme',
      'light_mode': 'Light Theme',
      'dark_mode': 'Dark Theme',
      'language': 'Language',
      'select_language': 'Select Language',
      'notifications_alarms': 'Notifications & Alarms',
      'seal_tamper_siren': 'Tamper Siren Alarm',
      'seal_tamper_siren_sub': 'Play high-priority audible siren when e-seal is breached',
      'route_deviation_alert': 'Geofence Deviation Alerts',
      'route_deviation_alert_sub': 'Notify if truck departs designated Customs corridor',
      'low_battery_alert': 'Low Battery Alerts (<25%)',
      'low_battery_alert_sub': 'Notify when IoT tracking device needs battery recharge',
      'security': 'Security & Access',
      'biometric_unlock': 'Biometric / Fingerprint Lock',
      'biometric_unlock_sub': 'Require fingerprint verification on app launch',
      'customs_support': 'Sri Lanka Customs Support',
      'emergency_hotline': 'Customs Emergency Hotline (1937)',
      'emergency_hotline_sub': '24/7 Direct line to Sri Lanka Customs ICT & Control Room',
      'call_now': 'Call Hotline',
      'help_docs': 'Project Info & SRS Documentation',
      'app_version': 'Version 1.0.0 (ITUM Project)',
      'save_changes': 'Saved Successfully',
      'login': 'Start Shift & Sign In',
      'register': 'Register as Authorized Driver',
      'driver_reg_title': 'Driver Onboarding & Registration',
      'license_no': 'Driving License Number',
      'full_name': 'Driver Full Name',
      'nic_no': 'National ID (NIC) Number',
      'truck_plate': 'Assigned Vehicle Plate (e.g. WP LC-2225)',
      'phone': 'Contact Telephone',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'have_account': 'Already registered? Back to Login',
    },
    'si': {
      'app_title': 'සිකියුර්ට්‍රැක් ශ්‍රී ලංකා',
      'app_subtitle': 'IoT බහාලුම් අධීක්ෂණ පද්ධතිය',
      'dashboard': 'ප්‍රධාන පුවරුව',
      'tracking': 'මගපෙන්වීම',
      'alerts': 'දැනුම්දීම්',
      'containers': 'ගමන් විස්තර',
      'profile': 'පැතිකඩ',
      'settings': 'සැකසුම්',
      'hello': 'ආයුබෝවන්',
      'on_track': 'ගමනේ යෙදෙන',
      'arrived': 'භාරදුන්',
      'delayed': 'ප්‍රමාද වූ',
      'speed': 'වේගය',
      'battery': 'බැටරිය',
      'location': 'ස්ථානය',
      'route': 'ගමන් මාර්ගය',
      'eta': 'ළඟාවන වේලාව',
      'sign_out': 'ඉවත් වන්න (Log Out)',
      'appearance': 'පෙනුම සහ තේමාව',
      'theme_mode': 'යෙදුමේ තේමාව',
      'light_mode': 'ලා පැහැති තේමාව (Light)',
      'dark_mode': 'අඳුරු තේමාව (Dark)',
      'language': 'භාෂාව',
      'select_language': 'භාෂාව තෝරන්න',
      'notifications_alarms': 'දැනුම්දීම් සහ අනතුරු ඇඟවීම්',
      'seal_tamper_siren': 'මුද්‍රා අනතුරු ඇඟවීමේ හඬ (Siren)',
      'seal_tamper_siren_sub': 'මුද්‍රාව කැඩූ විගස ශබ්ද අනතුරු ඇඟවීමක් නිකුත් කිරීම',
      'route_deviation_alert': 'මාර්ගයෙන් පිටවීමේ අනතුරු ඇඟවීම්',
      'route_deviation_alert_sub': 'නියමිත රේගු මාර්ගයෙන් පිට පැන්න විට දැනුම් දීම',
      'low_battery_alert': 'අඩු බැටරි අනතුරු ඇඟවීම (<25%)',
      'low_battery_alert_sub': 'IoT උපාංගයේ බැටරිය අඩු වූ විට දැනුම් දීම',
      'security': 'ආරක්ෂාව සහ පිවිසුම',
      'biometric_unlock': 'ඇඟිලි සලකුණු අගුල (Fingerprint)',
      'biometric_unlock_sub': 'යෙදුම විවෘත කිරීමට ඇඟිලි සලකුණු භාවිතා කිරීම',
      'customs_support': 'ශ්‍රී ලංකා රේගු සහය',
      'emergency_hotline': 'හදිසි රේගු දුරකථන අංකය (1937)',
      'emergency_hotline_sub': 'පැය 24 පුරා රේගු පාලන මැදිරිය හා සම්බන්ධ වීමට',
      'call_now': 'ඇමතුමක් ගන්න',
      'help_docs': 'ව්‍යාපෘති විස්තර සහ SRS ලේඛන',
      'app_version': 'අනුවාදය 1.0.0 (ITUM Project)',
      'save_changes': 'සාර්ථකව සුරැකිණි',
      'login': 'රාජකාරිය අරඹන්න (Sign In)',
      'register': 'නව රියදුරු ලියාපදිංචිය',
      'driver_reg_title': 'රේගු බලයලත් රියදුරු ලියාපදිංචිය',
      'license_no': 'රියදුරු බලපත්‍ර අංකය',
      'full_name': 'සම්පූර්ණ නම',
      'nic_no': 'ජාතික හැඳුනුම්පත් අංකය (NIC)',
      'truck_plate': 'ලොරි රථයේ අංකය (උදා: WP LC-2225)',
      'phone': 'දුරකථන අංකය',
      'password': 'මුරපදය (Password)',
      'confirm_password': 'මුරපදය නැවත තහවුරු කරන්න',
      'have_account': 'දැනටමත් ලියාපදිංචි වී ඇත්නම් පිවිසෙන්න',
    },
    'ta': {
      'app_title': 'செக்யூர்டிராக் இலங்கை',
      'app_subtitle': 'IoT கொள்கலன் கண்காணிப்பு கட்டமைப்பு',
      'dashboard': 'முகப்பு',
      'tracking': 'வழிசெலுத்தல்',
      'alerts': 'அறிவிப்புகள்',
      'containers': 'பயண விவரங்கள்',
      'profile': 'சுயவிவரம்',
      'settings': 'அமைப்புகள்',
      'hello': 'வணக்கம்',
      'on_track': 'பயணத்தில்',
      'arrived': 'ஒப்படைக்கப்பட்டது',
      'delayed': 'தாமதமானது',
      'speed': 'வேகம்',
      'battery': 'மின்கலன்',
      'location': 'இடம்',
      'route': 'பாதை',
      'eta': 'நேரம்',
      'sign_out': 'வெளியேறு (Log Out)',
      'appearance': 'தோற்றம்',
      'theme_mode': 'பயன்பாட்டு வடிவம்',
      'light_mode': 'வெளிச்ச முறை (Light)',
      'dark_mode': 'இருண்ட முறை (Dark)',
      'language': 'மொழி (Language)',
      'select_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'notifications_alarms': 'அறிவிப்புகள் & எச்சரிக்கைகள்',
      'seal_tamper_siren': 'சீல் சேத ஒலி எச்சரிக்கை',
      'seal_tamper_siren_sub': 'சீல் சேதமடைந்தவுடன் உரத்த எச்சரிக்கை ஒலித்தல்',
      'route_deviation_alert': 'பாதை விலகல் எச்சரிக்கைகள்',
      'route_deviation_alert_sub': 'சுங்கப் பாதையை விட்டு வெளியேறினால் அறிவிக்கும்',
      'low_battery_alert': 'குறைந்த மின்கல எச்சரிக்கை (<25%)',
      'low_battery_alert_sub': 'IoT சாதன மின்கலன் குறையும் போது அறிவித்தல்',
      'security': 'பாதுகாப்பு & அணுகல்',
      'biometric_unlock': 'கைரேகை பூட்டு (Fingerprint)',
      'biometric_unlock_sub': 'பயன்பாட்டைத் திறக்க கைரேகையைப் பயன்படுத்தவும்',
      'customs_support': 'இலங்கை சுங்க ஆதரவு',
      'emergency_hotline': 'சுங்க அவசர உதவி எண் (1937)',
      'emergency_hotline_sub': '24/7 இலங்கை சுங்க கட்டுப்பாட்டு அறை தொடர்பு',
      'call_now': 'அழைக்கவும்',
      'help_docs': 'திட்ட விவரங்கள் மற்றும் SRS ஆவணங்கள்',
      'app_version': 'பதிப்பு 1.0.0 (ITUM Project)',
      'save_changes': 'வெற்றிகரமாக சேமிக்கப்பட்டது',
      'login': 'உள்நுழைக (Sign In)',
      'register': 'ஓட்டுநர் பதிவு',
      'driver_reg_title': 'சுங்க அங்கீகரிக்கப்பட்ட ஓட்டுநர் பதிவு',
      'license_no': 'ஓட்டுநர் உரிம எண்',
      'full_name': 'முழு பெயர்',
      'nic_no': 'தேசிய அடையாள அட்டை எண் (NIC)',
      'truck_plate': 'வாகன எண் (எ.கா. WP LC-2225)',
      'phone': 'தொலைபேசி எண்',
      'password': 'கடவுச்சொல்',
      'confirm_password': 'கடவுச்சொல்லை உறுதிப்படுத்துக',
      'have_account': 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழைக',
    }
  };

  static String get(String key, AppLanguage language) {
    final langCode = language.code;
    return _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

/// Global Application Settings, Theme & Language Controller
class AppSettingsController extends ChangeNotifier {
  AppSettingsController._();
  static final AppSettingsController instance = AppSettingsController._();

  ThemeMode _themeMode = ThemeMode.light;
  AppLanguage _language = AppLanguage.english;

  bool _sealTamperSiren = true;
  bool _geofenceAlerts = true;
  bool _batteryAlerts = true;
  bool _biometricLogin = false;
  final String _customsHotline = '1937';
  String _serverIp = '10.70.141.85';

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AppLanguage get language => _language;
  bool get sealTamperSiren => _sealTamperSiren;
  bool get geofenceAlerts => _geofenceAlerts;
  bool get batteryAlerts => _batteryAlerts;
  bool get biometricLogin => _biometricLogin;
  String get customsHotline => _customsHotline;
  String get serverIp => _serverIp;

  String tr(String key) => AppTranslations.get(key, _language);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _serverIp = prefs.getString('backend_server_ip') ?? '10.70.141.85';
      final isDark = prefs.getBool('is_dark_mode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

      final langCode = prefs.getString('app_lang_code') ?? 'en';
      if (langCode == 'si') {
        _language = AppLanguage.sinhala;
      } else if (langCode == 'ta') {
        _language = AppLanguage.tamil;
      } else {
        _language = AppLanguage.english;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Driver Settings init fallback: $e');
    }
  }

  void setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', mode == ThemeMode.dark);
    }
  }

  void toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(newMode);
  }

  void setLanguage(AppLanguage lang) async {
    if (_language != lang) {
      _language = lang;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_lang_code', lang.code);
    }
  }

  void setServerIp(String ip) async {
    final clean = ip.trim();
    if (_serverIp != clean && clean.isNotEmpty) {
      _serverIp = clean;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('backend_server_ip', _serverIp);
    }
  }

  void setSealTamperSiren(bool value) {
    _sealTamperSiren = value;
    notifyListeners();
  }

  void setGeofenceAlerts(bool value) {
    _geofenceAlerts = value;
    notifyListeners();
  }

  void setBatteryAlerts(bool value) {
    _batteryAlerts = value;
    notifyListeners();
  }

  void setBiometricLogin(bool value) {
    _biometricLogin = value;
    notifyListeners();
  }
}
