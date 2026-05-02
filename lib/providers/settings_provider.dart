// lib/providers/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool   _isDarkMode           = false;
  bool   _notificationsEnabled = true;
  bool   _soundEnabled         = true;
  bool   _vibrationEnabled     = true;
  String _language             = 'fr';

  bool   get isDarkMode           => _isDarkMode;
  bool   get notificationsEnabled => _notificationsEnabled;
  bool   get soundEnabled         => _soundEnabled;
  bool   get vibrationEnabled     => _vibrationEnabled;
  String get language             => _language;

  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Locale get locale {
    switch (_language) {
      case 'ar': return const Locale('ar');
      case 'en': return const Locale('en');
      default:   return const Locale('fr');
    }
  }

  Future<void> loadSettings() async {
    final p = await SharedPreferences.getInstance();
    _isDarkMode           = p.getBool('darkMode')      ?? false;
    _notificationsEnabled = p.getBool('notifications') ?? true;
    _soundEnabled         = p.getBool('sound')         ?? true;
    _vibrationEnabled     = p.getBool('vibration')     ?? true;
    _language             = p.getString('language')    ?? 'fr';
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    (await SharedPreferences.getInstance()).setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleTheme() => toggleDarkMode();

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    (await SharedPreferences.getInstance()).setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    (await SharedPreferences.getInstance())
        .setBool('notifications', _notificationsEnabled);
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    (await SharedPreferences.getInstance())
        .setBool('sound', _soundEnabled);
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    (await SharedPreferences.getInstance())
        .setBool('vibration', _vibrationEnabled);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    (await SharedPreferences.getInstance()).setString('language', lang);
    notifyListeners();
  }

  // ── Traductions ──────────────────────────────────────
  String t(String key) {
    return _strings[_language]?[key] ?? _strings['fr']![key] ?? key;
  }

  static const Map<String, Map<String, String>> _strings = {
    'fr': {
      // ── Navigation & général ──────────────────────────
      'app_title':            'Check Présence',
      'scan':                 'Scanner',
      'employees':            'Employés',
      'history':              'Historique',
      'settings':             'Paramètres',
      'dashboard':            'Tableau de bord',
      'home':                 'Accueil',
      'attendance':           'Présences',
      'reports':              'Rapports',
      'version':              'Version',

      // ── Présence ─────────────────────────────────────
      'present':              'Présent',
      'absent':               'Absent',
      'check_in':             'Entrée',
      'check_out':            'Sortie',
      'total':                'Total',
      'today':                "Aujourd'hui",
      'work_duration':        'Durée travail',
      'duration':             'Durée',
      'last_scan':            'Dernier scan',
      'checkins_week':        'Check-ins semaine',
      'status_present':       'Présent',
      'status_absent':        'Absent',
      'status_late':          'En retard',
      'my_attendance':        'Ma présence',
      'attendance_history':   'Historique des présences',
      'no_attendance':        'Aucune présence enregistrée',
      'no_history':           'Aucun historique',
      'select_date':          'Sélectionner une date',
      'weekly_attendance':    'Présence semaine',
      'today_scans':          'Scans du jour',

      // ── Tableau de bord ───────────────────────────────
      'total_employees':      'Total employés',
      'present_today':        "Présents aujourd'hui",
      'absent_today':         "Absents aujourd'hui",
      'quick_actions':        'Actions rapides',
      'recent_activity':      'Activité récente',
      'no_activity':          "Aucune activité aujourd'hui",
      'statistics':           'Statistiques',

      // ── Employés ──────────────────────────────────────
      'name':                 'Nom',
      'department':           'Département',
      'position':             'Poste',
      'employee_list':        'Liste des employés',
      'search_employee':      'Rechercher un employé',
      'no_employees':         'Aucun employé trouvé',
      'add_employee':         'Ajouter employé',
      'create_employee':      'Créer un employé',
      'full_name':            'Nom complet',
      'employee_email':       "Email de l'employé",
      'employee_password':    'Mot de passe',
      'employee_department':  'Département',
      'employee_position':    'Poste',
      'create_account':       'Créer le compte',
      'account_created':      'Compte créé avec succès',
      'edit_employee':        'Modifier employé',
      'save_changes':         'Enregistrer les modifications',
      'employee_created_msg': 'Employé créé',  // suivi de : email / mdp
      'employee_updated':     'Employé modifié !',
      'confirm_delete':       'Confirmer',
      'delete_confirm_msg':   'Supprimer',      // suivi du nom
      'hr_admin_info':        "Seul l'admin RH peut créer des comptes employés.",
      'badge_qr':             'Badge QR',

      // ── Authentification ──────────────────────────────
      'login':                'Connexion',
      'logout':               'Déconnexion',
      'email':                'Email',
      'password':             'Mot de passe',
      'welcome':              'Bienvenue',
      'smart_presence':       'Gestion de présence intelligente',
      'forgot_password':      'Mot de passe oublié ?',
      'reset_password':       'Réinitialiser le mot de passe',
      'reset_email_sent':     'Email de réinitialisation envoyé !',
      'send_reset_link':      'Envoyer',
      'login_error':          'Email ou mot de passe incorrect',
      'enter_email':          'Entrez votre email',

      // ── Scan ──────────────────────────────────────────
      'scan_badge':           'Scanner le badge',
      'scan_title':           'Scanner',
      'scan_qr':              'Code QR',
      'scan_text':            'Texte',
      'scan_face':            'Visage',
      'ocr_scan':             'Scanner texte (OCR)',
      'verify_face':          'Vérifier visage',
      'camera_permission':    'Autorisation caméra requise',
      'camera_denied':        'Accès caméra refusé',
      'no_camera':            'Aucune caméra détectée',
      'scan_success':         'Scan réussi !',
      'face_detected':        'Visage détecté',
      'mobile_only':          'Cette fonctionnalité nécessite un appareil mobile',
      'allow_camera':         'Autoriser la caméra',
      'scanning':             'Traitement...',
      'stop_scan':            'Arrêter',
      'quick_test':           'Test rapide (démo)',
      'demo_mode':            'Mode démo',
      'badge_not_found':      'Badge non reconnu',
      'scan_error_qr':        'Erreur scan QR',
      'scan_error_text':      'Erreur reconnaissance texte',
      'scan_error_face':      'Erreur détection visage',
      'face_confirm_title':   'Visage détecté',
      'face_confirm_msg':     'Visage détecté - Vérification...\nConfirmer la présence ?',
      'face_confirmed':       'Présence confirmée manuellement',
      'face_not_detected':    'Aucun visage détecté',
      'employee_not_found':   'employé introuvable',
      'qr_not_detected':      'QR non détecté',
      'text_recognized':      'Texte reconnu',
      'processing':           'Traitement...',
      'scanner_label':        'Scan',

      // ── Paramètres ────────────────────────────────────
      'dark_mode':            'Mode sombre',
      'dark_mode_subtitle':   'Activer le thème sombre',
      'language':             'Langue',
      'admin':                'Admin',
      'employee_role':        'Employé',
      'notifications':        'Notifications',
      'sound':                'Son',
      'vibration':            'Vibration',
      'user_label':           'Utilisateur',

      // ── PDF / export ──────────────────────────────────
      'export_pdf':           'Exporter PDF',

      // ── Actions communes ──────────────────────────────
      'delete':               'Supprimer',
      'cancel':               'Annuler',
      'confirm':              'Confirmer',
      'save':                 'Enregistrer',
      'close':                'Fermer',
      'retry':                'Réessayer',
      'edit':                 'Modifier',

      // ── États ─────────────────────────────────────────
      'error':                'Erreur',
      'success':              'Succès',
      'loading':              'Chargement...',
      'no_data':              'Aucune donnée',
    },

    // ═══════════════════════════════════════════════════
    'en': {
      // ── Navigation & général ──────────────────────────
      'app_title':            'Check Presence',
      'scan':                 'Scan',
      'employees':            'Employees',
      'history':              'History',
      'settings':             'Settings',
      'dashboard':            'Dashboard',
      'home':                 'Home',
      'attendance':           'Attendance',
      'reports':              'Reports',
      'version':              'Version',

      // ── Présence ─────────────────────────────────────
      'present':              'Present',
      'absent':               'Absent',
      'check_in':             'Check In',
      'check_out':            'Check Out',
      'total':                'Total',
      'today':                'Today',
      'work_duration':        'Work Duration',
      'duration':             'Duration',
      'last_scan':            'Last scan',
      'checkins_week':        'Check-ins this week',
      'status_present':       'Present',
      'status_absent':        'Absent',
      'status_late':          'Late',
      'my_attendance':        'My Attendance',
      'attendance_history':   'Attendance history',
      'no_attendance':        'No attendance recorded',
      'no_history':           'No history',
      'select_date':          'Select date',
      'weekly_attendance':    'Weekly Attendance',
      'today_scans':          'Today Scans',

      // ── Tableau de bord ───────────────────────────────
      'total_employees':      'Total employees',
      'present_today':        'Present today',
      'absent_today':         'Absent today',
      'quick_actions':        'Quick actions',
      'recent_activity':      'Recent activity',
      'no_activity':          'No activity today',
      'statistics':           'Statistics',

      // ── Employés ──────────────────────────────────────
      'name':                 'Name',
      'department':           'Department',
      'position':             'Position',
      'employee_list':        'Employee list',
      'search_employee':      'Search employee',
      'no_employees':         'No employees found',
      'add_employee':         'Add Employee',
      'create_employee':      'Create employee',
      'full_name':            'Full name',
      'employee_email':       'Employee email',
      'employee_password':    'Password',
      'employee_department':  'Department',
      'employee_position':    'Position',
      'create_account':       'Create account',
      'account_created':      'Account created successfully',
      'edit_employee':        'Edit employee',
      'save_changes':         'Save changes',
      'employee_created_msg': 'Employee created',
      'employee_updated':     'Employee updated!',
      'confirm_delete':       'Confirm',
      'delete_confirm_msg':   'Delete',
      'hr_admin_info':        'Only the HR admin can create employee accounts.',
      'badge_qr':             'QR Badge',

      // ── Authentification ──────────────────────────────
      'login':                'Login',
      'logout':               'Logout',
      'email':                'Email',
      'password':             'Password',
      'welcome':              'Welcome',
      'smart_presence':       'Smart attendance management',
      'forgot_password':      'Forgot password?',
      'reset_password':       'Reset password',
      'reset_email_sent':     'Reset email sent!',
      'send_reset_link':      'Send',
      'login_error':          'Invalid email or password',
      'enter_email':          'Enter your email',

      // ── Scan ──────────────────────────────────────────
      'scan_badge':           'Scan Badge',
      'scan_title':           'Scanner',
      'scan_qr':              'QR Code',
      'scan_text':            'Text',
      'scan_face':            'Face',
      'ocr_scan':             'Scan Text (OCR)',
      'verify_face':          'Verify Face',
      'camera_permission':    'Camera permission required',
      'camera_denied':        'Camera access denied',
      'no_camera':            'No camera detected',
      'scan_success':         'Scan successful!',
      'face_detected':        'Face detected',
      'mobile_only':          'This feature requires a mobile device',
      'allow_camera':         'Allow camera',
      'scanning':             'Processing...',
      'stop_scan':            'Stop',
      'quick_test':           'Quick test (demo)',
      'demo_mode':            'Demo mode',
      'badge_not_found':      'Badge not recognised',
      'scan_error_qr':        'QR scan error',
      'scan_error_text':      'Text recognition error',
      'scan_error_face':      'Face detection error',
      'face_confirm_title':   'Face detected',
      'face_confirm_msg':     'Face detected – Verifying...\nConfirm attendance?',
      'face_confirmed':       'Attendance confirmed manually',
      'face_not_detected':    'No face detected',
      'employee_not_found':   'employee not found',
      'qr_not_detected':      'QR not detected',
      'text_recognized':      'Text recognised',
      'processing':           'Processing...',
      'scanner_label':        'Scan',

      // ── Paramètres ────────────────────────────────────
      'dark_mode':            'Dark mode',
      'dark_mode_subtitle':   'Enable dark theme',
      'language':             'Language',
      'admin':                'Admin',
      'employee_role':        'Employee',
      'notifications':        'Notifications',
      'sound':                'Sound',
      'vibration':            'Vibration',
      'user_label':           'User',

      // ── PDF / export ──────────────────────────────────
      'export_pdf':           'Export PDF',

      // ── Actions communes ──────────────────────────────
      'delete':               'Delete',
      'cancel':               'Cancel',
      'confirm':              'Confirm',
      'save':                 'Save',
      'close':                'Close',
      'retry':                'Retry',
      'edit':                 'Edit',

      // ── États ─────────────────────────────────────────
      'error':                'Error',
      'success':              'Success',
      'loading':              'Loading...',
      'no_data':              'No data',
    },

    // ═══════════════════════════════════════════════════
    'ar': {
      // ── Navigation & général ──────────────────────────
      'app_title':            'تسجيل الحضور',
      'scan':                 'مسح',
      'employees':            'الموظفون',
      'history':              'السجل',
      'settings':             'الإعدادات',
      'dashboard':            'لوحة التحكم',
      'home':                 'الرئيسية',
      'attendance':           'الحضور',
      'reports':              'التقارير',
      'version':              'الإصدار',

      // ── Présence ─────────────────────────────────────
      'present':              'حاضر',
      'absent':               'غائب',
      'check_in':             'دخول',
      'check_out':            'خروج',
      'total':                'المجموع',
      'today':                'اليوم',
      'work_duration':        'مدة العمل',
      'duration':             'المدة',
      'last_scan':            'آخر مسح',
      'checkins_week':        'تسجيلات هذا الأسبوع',
      'status_present':       'حاضر',
      'status_absent':        'غائب',
      'status_late':          'متأخر',
      'my_attendance':        'حضوري',
      'attendance_history':   'سجل الحضور',
      'no_attendance':        'لم يتم تسجيل أي حضور',
      'no_history':           'لا يوجد سجل',
      'select_date':          'اختر تاريخاً',
      'weekly_attendance':    'حضور الأسبوع',
      'today_scans':          'مسوحات اليوم',

      // ── Tableau de bord ───────────────────────────────
      'total_employees':      'إجمالي الموظفين',
      'present_today':        'الحاضرون اليوم',
      'absent_today':         'الغائبون اليوم',
      'quick_actions':        'إجراءات سريعة',
      'recent_activity':      'النشاط الأخير',
      'no_activity':          'لا يوجد نشاط اليوم',
      'statistics':           'إحصائيات',

      // ── Employés ──────────────────────────────────────
      'name':                 'الاسم',
      'department':           'القسم',
      'position':             'المنصب',
      'employee_list':        'قائمة الموظفين',
      'search_employee':      'البحث عن موظف',
      'no_employees':         'لم يتم العثور على موظفين',
      'add_employee':         'إضافة موظف',
      'create_employee':      'إنشاء موظف',
      'full_name':            'الاسم الكامل',
      'employee_email':       'بريد الموظف',
      'employee_password':    'كلمة المرور',
      'employee_department':  'القسم',
      'employee_position':    'المنصب',
      'create_account':       'إنشاء الحساب',
      'account_created':      'تم إنشاء الحساب بنجاح',
      'edit_employee':        'تعديل الموظف',
      'save_changes':         'حفظ التعديلات',
      'employee_created_msg': 'تم إنشاء الموظف',
      'employee_updated':     'تم تعديل الموظف!',
      'confirm_delete':       'تأكيد',
      'delete_confirm_msg':   'حذف',
      'hr_admin_info':        'فقط مسؤول الموارد البشرية يمكنه إنشاء حسابات الموظفين.',
      'badge_qr':             'شارة QR',

      // ── Authentification ──────────────────────────────
      'login':                'تسجيل الدخول',
      'logout':               'تسجيل الخروج',
      'email':                'البريد الإلكتروني',
      'password':             'كلمة المرور',
      'welcome':              'مرحباً',
      'smart_presence':       'إدارة الحضور الذكية',
      'forgot_password':      'نسيت كلمة المرور؟',
      'reset_password':       'إعادة تعيين كلمة المرور',
      'reset_email_sent':     'تم إرسال رابط إعادة التعيين!',
      'send_reset_link':      'إرسال',
      'login_error':          'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      'enter_email':          'أدخل بريدك الإلكتروني',

      // ── Scan ──────────────────────────────────────────
      'scan_badge':           'مسح الشارة',
      'scan_title':           'الماسح',
      'scan_qr':              'رمز QR',
      'scan_text':            'نص',
      'scan_face':            'وجه',
      'ocr_scan':             'قراءة النص',
      'verify_face':          'التحقق من الوجه',
      'camera_permission':    'مطلوب إذن الكاميرا',
      'camera_denied':        'تم رفض الوصول إلى الكاميرا',
      'no_camera':            'لم يتم اكتشاف كاميرا',
      'scan_success':         'تم المسح بنجاح!',
      'face_detected':        'تم اكتشاف وجه',
      'mobile_only':          'هذه الميزة تتطلب جهازاً محمولاً',
      'allow_camera':         'السماح بالكاميرا',
      'scanning':             'جارٍ المعالجة...',
      'stop_scan':            'إيقاف',
      'quick_test':           'اختبار سريع (تجريبي)',
      'demo_mode':            'وضع تجريبي',
      'badge_not_found':      'الشارة غير معروفة',
      'scan_error_qr':        'خطأ في مسح QR',
      'scan_error_text':      'خطأ في التعرف على النص',
      'scan_error_face':      'خطأ في اكتشاف الوجه',
      'face_confirm_title':   'تم اكتشاف وجه',
      'face_confirm_msg':     'تم اكتشاف وجه - جارٍ التحقق...\nتأكيد الحضور؟',
      'face_confirmed':       'تم تأكيد الحضور يدوياً',
      'face_not_detected':    'لم يتم اكتشاف أي وجه',
      'employee_not_found':   'الموظف غير موجود',
      'qr_not_detected':      'لم يتم اكتشاف QR',
      'text_recognized':      'تم التعرف على النص',
      'processing':           'جارٍ المعالجة...',
      'scanner_label':        'مسح',

      // ── Paramètres ────────────────────────────────────
      'dark_mode':            'الوضع المظلم',
      'dark_mode_subtitle':   'تفعيل المظهر الداكن',
      'language':             'اللغة',
      'admin':                'مسؤول',
      'employee_role':        'موظف',
      'notifications':        'الإشعارات',
      'sound':                'الصوت',
      'vibration':            'الاهتزاز',
      'user_label':           'مستخدم',

      // ── PDF / export ──────────────────────────────────
      'export_pdf':           'تصدير PDF',

      // ── Actions communes ──────────────────────────────
      'delete':               'حذف',
      'cancel':               'إلغاء',
      'confirm':              'تأكيد',
      'save':                 'حفظ',
      'close':                'إغلاق',
      'retry':                'إعادة المحاولة',
      'edit':                 'تعديل',

      // ── États ─────────────────────────────────────────
      'error':                'خطأ',
      'success':              'نجاح',
      'loading':              'جاري التحميل...',
      'no_data':              'لا توجد بيانات',
    },
  };
}