// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '-';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = '${info.version}+${info.buildNumber}');
      }
    } catch (e) {
      if (mounted) setState(() => _version = '1.0.0');
    }
  }

  String _getInitial(AuthService auth) {
    try {
      final name = auth.currentEmployee?.name;
      if (name != null && name.isNotEmpty) return name[0].toUpperCase();
      final email = auth.currentUser?.email;
      if (email != null && email.isNotEmpty) return email[0].toUpperCase();
      return 'U';
    } catch (e) { return 'U'; }
  }

  String _getDisplayName(AuthService auth, SettingsProvider settings) {
    try {
      final name = auth.currentEmployee?.name;
      if (name != null && name.isNotEmpty) return name;
      return auth.currentUser?.email ?? settings.t('user_label');
    } catch (e) { return settings.t('user_label'); }
  }

  String _getDisplayEmail(AuthService auth) {
    try {
      return auth.currentEmployee?.email ?? auth.currentUser?.email ?? '';
    } catch (e) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth     = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.t('settings')),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Carte utilisateur ──
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1E3A8A),
                child: Text(_getInitial(auth),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
              title:    Text(_getDisplayName(auth, settings),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_getDisplayEmail(auth)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: auth.isAdmin
                      ? Colors.blue.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  auth.isAdmin
                      ? settings.t('admin')
                      : settings.t('employee_role'),
                  style: TextStyle(
                    color: auth.isAdmin
                        ? Colors.blue.shade700 : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize:   12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Thème sombre ──
          Card(
            child: SwitchListTile(
              title:     Text(settings.t('dark_mode')),
              subtitle:  Text(settings.t('dark_mode_subtitle')),
              secondary: const Icon(Icons.dark_mode_outlined),
              value:     settings.isDarkMode,
              onChanged: settings.setTheme,
            ),
          ),
          const SizedBox(height: 10),

          // ── Langue ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                const Icon(Icons.language, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 12),
                Text(settings.t('language'),
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                _LangChip(settings: settings, lang: 'fr', label: '🇫🇷 FR'),
                const SizedBox(width: 4),
                _LangChip(settings: settings, lang: 'en', label: '🇬🇧 EN'),
                const SizedBox(width: 4),
                _LangChip(settings: settings, lang: 'ar', label: '🇹🇳 AR'),
              ]),
            ),
          ),
          const SizedBox(height: 10),

          // ── Version ──
          Card(
            child: ListTile(
              leading:  const Icon(Icons.info_outline,
                  color: Color(0xFF1E3A8A)),
              title:    Text(settings.t('version')),
              subtitle: Text(_version),
            ),
          ),
          const SizedBox(height: 20),

          // ── Déconnexion ──
          ElevatedButton.icon(
            onPressed: () async {
              await auth.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            icon:  const Icon(Icons.logout),
            label: Text(settings.t('logout')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────

class _LangChip extends StatelessWidget {
  final SettingsProvider settings;
  final String lang, label;
  const _LangChip(
      {required this.settings, required this.lang, required this.label});

  @override
  Widget build(BuildContext context) {
    final sel = settings.language == lang;
    return GestureDetector(
      onTap: () => settings.setLanguage(lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color:        sel ? const Color(0xFF1E3A8A) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize:   11,
              color:      sel ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}