import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../scan_screen.dart';
import '../settings_screen.dart';
import 'add_employee_screen.dart';
import 'employee_list_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  int _idx = 0;
  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(_fade);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AttendanceService>().loadTodayData();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final screens = [
      _HomeTab(fade: _fade, slide: _slide),
      const EmployeeListScreen(),
      const ScanScreen(isAdminMode: true),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _idx, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: settings.t('dashboard')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.people_alt),
              label: settings.t('employees')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.fact_check),
              label: settings.t('attendance')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: settings.t('settings')),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  const _HomeTab({required this.fade, required this.slide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final auth = context.watch<AuthService>();
    final attendance = context.watch<AttendanceService>();
    final settings = context.watch<SettingsProvider>();
    final employee = auth.currentEmployee;
    final stats = attendance.todayStats;
    final recent = attendance.todayAttendance.take(6).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary
                ]
              : const [
                  Color(0xFF1E3A8A),
                  Color(0xFF3B82F6)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HeaderCard(name: employee?.name ?? auth.currentUser?.email ?? settings.t('admin'), role: settings.t('admin'), onLogout: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  }
                }),
                const SizedBox(height: 14),
                Row(children: [
                  _StatCard(label: settings.t('total_employees'), value: '${stats['total'] ?? 0}', icon: Icons.people),
                  const SizedBox(width: 10),
                  _StatCard(label: settings.t('present_today'), value: '${stats['present'] ?? 0}', icon: Icons.check_circle),
                  const SizedBox(width: 10),
                  _StatCard(label: settings.t('absent_today'), value: '${stats['absent'] ?? 0}', icon: Icons.cancel),
                ]),
                const SizedBox(height: 16),
                Text(settings.t('quick_actions'), style: TextStyle(color: isDark ? theme.colorScheme.onPrimary : Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  _QuickBtn(icon: Icons.person_add_alt_1, label: settings.t('create_employee'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEmployeeScreen()))),
                  const SizedBox(width: 10),
                  _QuickBtn(icon: Icons.qr_code_scanner, label: settings.t('scan'), onTap: () {}),
                ]),
                const SizedBox(height: 16),
                Text(settings.t('recent_activity'), style: TextStyle(color: isDark ? theme.colorScheme.onPrimary : Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (recent.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(settings.t('no_activity'), style: TextStyle(color: isDark ? theme.colorScheme.onSurfaceVariant : Colors.grey)),
                      ),
                    ),
                  )
                else
                  ...recent.map((e) => Card(
                        child: ListTile(
                          leading: Icon(Icons.history, color: isDark ? theme.colorScheme.primary : const Color(0xFF1E3A8A)),
                          title: Text(e.employeeName),
                          subtitle: Text('${e.department} · ${e.workDurationFormatted}'),
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name, role;
  final VoidCallback onLogout;
  const _HeaderCard({required this.name, required this.role, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: isDark ? theme.colorScheme.primary : const Color(0xFF1E3A8A),
            child: Text(initial, style: TextStyle(color: isDark ? theme.colorScheme.onPrimary : Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.primaryContainer : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(role, style: TextStyle(fontSize: 11, color: isDark ? theme.colorScheme.onPrimaryContainer : Colors.black)),
              ),
            ]),
          ),
          IconButton(
            onPressed: onLogout,
            icon: Icon(Icons.logout, color: isDark ? theme.colorScheme.error : Colors.red),
            tooltip: settings.t('logout'),
          ),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Icon(icon, color: isDark ? theme.colorScheme.primary : Colors.blue.shade900),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 11, color: isDark ? theme.colorScheme.onSurfaceVariant : Colors.black)),
          ]),
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Column(children: [
            Icon(icon, color: isDark ? theme.colorScheme.primary : const Color(0xFF1E3A8A)),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
