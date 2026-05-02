import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../firebase_options.dart';
import '../../models/employee_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/database_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Employee? employee;
  const AddEmployeeScreen({super.key, this.employee});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(text: 'emp123');
  final _positionCtrl = TextEditingController(text: 'Employe');

  final _db = DatabaseService();

  String _dept = 'Informatique';
  bool _loading = false;

  final List<String> _depts = [
    'Informatique',
    'Ressources Humaines',
    'Finance',
    'Marketing',
    'Direction',
    'Commercial',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameCtrl.text = widget.employee!.name;
      _emailCtrl.text = widget.employee!.email;
      _positionCtrl.text = widget.employee!.position;
      _dept = widget.employee!.department;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final settings = context.read<SettingsProvider>();

    try {
      if (widget.employee == null) {
        final email = _emailCtrl.text.trim();
        final password = _passwordCtrl.text.trim();

        final appName =
            'temp_${DateTime.now().millisecondsSinceEpoch}';

        final secondaryApp = await Firebase.initializeApp(
          name: appName,
          options: DefaultFirebaseOptions.currentPlatform,
        );

        String uid = '';

        try {
          final secondaryAuth =
              FirebaseAuth.instanceFor(app: secondaryApp);

          final cred = await secondaryAuth
              .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          uid = cred.user!.uid;

          await secondaryAuth.signOut();
        } finally {
          await secondaryApp.delete();
        }

        await FirebaseDatabase.instance
            .ref('users/$uid')
            .set({
          'role': 'employee',
          'email': email,
          'name': _nameCtrl.text.trim(),
          'department': _dept,
          'position': _positionCtrl.text.trim(),
          'createdAt': DateTime.now().toIso8601String(),
        });

        await FirebaseDatabase.instance
            .ref('employees/$uid')
            .set({
          'id': uid,
          'name': _nameCtrl.text.trim(),
          'email': email,
          'department': _dept,
          'position': _positionCtrl.text.trim(),
          'role': 'employee',
          'photoUrl': '',
          'qrCode': 'BADGE_$uid',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await _db.addEmployee(Employee(
          id: uid,
          name: _nameCtrl.text.trim(),
          department: _dept,
          position: _positionCtrl.text.trim(),
          email: email,
          role: 'employee',
          photoUrl: '',
          qrCode: 'BADGE_$uid',
          createdAt: DateTime.now(),
        ));
      } else {
        await _db.updateEmployee(widget.employee!.copyWith(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          department: _dept,
          position: _positionCtrl.text.trim(),
        ));
      }

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.employee == null
                ? '${settings.t('employee_created_msg')}'
                : settings.t('employee_updated'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? settings.t('error')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isEdit = widget.employee != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit
            ? settings.t('edit_employee')
            : settings.t('add_employee')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: Color(0x1A1E3A8A),
                child: Icon(Icons.person,
                    size: 44, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameCtrl,
                decoration:
                    _dec('${settings.t('full_name')} *', Icons.person),
                validator: (v) =>
                    (v?.trim().isEmpty ?? true)
                        ? settings.t('error')
                        : null,
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _emailCtrl,
                decoration: _dec(
                    '${settings.t('employee_email')} *',
                    Icons.email),
                validator: (v) {
                  if (v?.trim().isEmpty ?? true)
                    return settings.t('error');
                  if (!v!.contains('@'))
                    return settings.t('login_error');
                  return null;
                },
              ),

              const SizedBox(height: 14),

              if (!isEdit)
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: _dec(
                      '${settings.t('employee_password')} *',
                      Icons.lock),
                  validator: (v) =>
                      v!.length < 6
                          ? settings.t('error')
                          : null,
                ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _dept,
                decoration: _dec(
                    settings.t('employee_department'),
                    Icons.business),
                items: _depts
                    .map((d) =>
                        DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _dept = v!),
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _positionCtrl,
                decoration: _dec(
                    settings.t('employee_position'),
                    Icons.work),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text(settings.t('add_employee')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _positionCtrl.dispose();
    super.dispose();
  }
}
