// lib/screens/employee/employee_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:check_presence/models/attendance_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';
import '../auth/login_screen.dart';
import 'my_attendance_screen.dart';
import '../settings_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});
  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen>
    with SingleTickerProviderStateMixin {
  int _idx = 0;
  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))
      ..forward();
    _fade  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
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

  void _goTo(int index) => setState(() => _idx = index);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final screens  = [
      _EmployeeDashboard(
        fade:          _fade,
        slide:         _slide,
        onGoToHistory: () => _goTo(1),
        onGoToSettings: () => _goTo(2),
      ),
      const MyAttendanceScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:       _idx,
        onTap:              _goTo,
        selectedItemColor:  const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: settings.t('home')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: settings.t('history')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: settings.t('settings')),
        ],
      ),
    );
  }
}

// ── Dashboard ─────────────────────────────────────────────────

class _EmployeeDashboard extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final VoidCallback onGoToHistory;
  final VoidCallback onGoToSettings;

  const _EmployeeDashboard({
    required this.fade,
    required this.slide,
    required this.onGoToHistory,
    required this.onGoToSettings,
  });

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _getInitial(AuthService auth) {
    final name = auth.currentEmployee?.name ?? '';
    if (name.isNotEmpty) return name[0].toUpperCase();
    final email = auth.currentUser?.email ?? '';
    if (email.isNotEmpty) return email[0].toUpperCase();
    return 'E';
  }

  @override
  Widget build(BuildContext context) {
    final auth       = context.watch<AuthService>();
    final attendance = context.watch<AttendanceService>();
    final settings   = context.watch<SettingsProvider>();
    final user       = auth.currentEmployee;

    final todayRecord = attendance.todayAttendance
            .where((a) => a.employeeId == user?.id)
            .isNotEmpty
        ? attendance.todayAttendance
            .firstWhere((a) => a.employeeId == user?.id)
        : null;

    final thisWeekCount = attendance.todayAttendance
        .where((a) =>
            DateTime.tryParse(a.date)?.isAfter(
                DateTime.now().subtract(const Duration(days: 7))) ??
            false)
        .length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
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
                // ── Carte utilisateur ──
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1E3A8A),
                      child: Text(_getInitial(auth),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                      user?.name ?? auth.currentUser?.email ??
                          settings.t('employee_role'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      user?.position.isNotEmpty == true
                          ? user!.position
                          : user?.department ?? '',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:        Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        settings.t('employee_role'),
                        style: TextStyle(
                            color:      Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize:   12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Stats ──
                Row(children: [
                  _SmallStat(
                    label: settings.t('checkins_week'),
                    value: '$thisWeekCount',
                    icon:  Icons.calendar_view_week,
                  ),
                  const SizedBox(width: 10),
                  _SmallStat(
                    label: settings.t('last_scan'),
                    value: todayRecord != null
                        ? _fmt(todayRecord.checkIn) : '--:--',
                    icon:  Icons.access_time_filled,
                  ),
                ]),
                const SizedBox(height: 16),

                // ── Actions rapides ──
                Text(settings.t('quick_actions'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onGoToHistory,
                      child: _QuickAction(
                          label: settings.t('history'),
                          icon:  Icons.history),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: onGoToSettings,
                      child: _QuickAction(
                          label: settings.t('settings'),
                          icon:  Icons.settings),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // ── Activité récente ──
                Text(settings.t('recent_activity'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 8),
                if (attendance.todayAttendance.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(settings.t('no_activity'),
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    ),
                  )
                else
                  ...attendance.todayAttendance.take(5).map((a) => Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF1E3A8A),
                        child: Icon(Icons.timelapse,
                            color: Colors.white, size: 18),
                      ),
                      title:    Text(a.employeeName),
                      subtitle: Text(
                          '${a.department} · ${a.workDurationFormatted}'),
                    ),
                  )),

                // ── Carte présence du jour ──
                if (todayRecord != null) ...[
                  const SizedBox(height: 10),
                  _TodayCard(record: todayRecord),
                ],

                const SizedBox(height: 16),

                // ── Déconnexion ──
                ElevatedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    }
                  },
                  icon:  const Icon(Icons.logout),
                  label: Text(settings.t('logout')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _TodayCard extends StatelessWidget {
  final Attendance record;
  const _TodayCard({required this.record});

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Row(children: [
        Expanded(
            child: _TimeInfo(settings.t('check_in'), _fmt(record.checkIn),
                Colors.green, Icons.login)),
        Container(height: 40, width: 1, color: Colors.grey.shade300),
        Expanded(
            child: _TimeInfo(
                settings.t('check_out'),
                record.checkOut != null ? _fmt(record.checkOut!) : '--:--',
                record.checkOut != null ? Colors.red : Colors.grey,
                Icons.logout)),
        Container(height: 40, width: 1, color: Colors.grey.shade300),
        Expanded(
            child: _TimeInfo(settings.t('duration'),
                record.workDurationFormatted, Colors.blue, Icons.timer)),
      ]),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final String label, time;
  final Color  color;
  final IconData icon;
  const _TimeInfo(this.label, this.time, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: color, size: 18),
    const SizedBox(height: 4),
    Text(time,
        style: TextStyle(
            color:      color,
            fontWeight: FontWeight.bold,
            fontSize:   14)),
    Text(label,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
  ]);
}

class _SmallStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _SmallStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Icon(icon, color: const Color(0xFF1E3A8A)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  const _QuickAction({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
    ),
    child: Column(children: [
      Icon(icon, color: const Color(0xFF1E3A8A)),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    ]),
  );
}