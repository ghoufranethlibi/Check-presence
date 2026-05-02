import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance;
  final _employeeDb = DatabaseService();

  bool _isLoading = false;
  bool _isAdmin = false;
  Employee? _currentEmployee;

  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  String get role => _isAdmin ? 'admin' : 'employee';
  bool get isLoggedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;
  Employee? get currentEmployee => _currentEmployee;

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _loadUserRole(cred.user);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreSession() async {
    await _loadUserRole(_auth.currentUser);
    notifyListeners();
  }

  Future<void> _loadUserRole(User? user) async {
    if (user == null) {
      _isAdmin = false;
      _currentEmployee = null;
      return;
    }

    final userSnap = await _db.ref('users/${user.uid}').get();
    final data = (userSnap.value as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final roleSnap = await _db.ref('users/${user.uid}/role').get();
    _isAdmin = roleSnap.value == 'admin';
    final employeeId = (data['employeeId'] as String?) ?? user.uid;
    _currentEmployee = await _employeeDb.getEmployeeById(employeeId);

    _currentEmployee ??= Employee(
      id: employeeId,
      name: user.displayName ?? user.email?.split('@').first ?? 'Utilisateur',
      department: (data['department'] as String?) ?? 'Informatique',
      position: (data['position'] as String?) ?? 'Employe',
      email: user.email ?? '',
      role: _isAdmin ? 'admin' : 'employee',
      photoUrl: (data['photoUrl'] as String?) ?? user.photoURL,
      qrCode: (data['qrCode'] as String?) ?? 'BADGE_$employeeId',
      createdAt: DateTime.now(),
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
    _isAdmin = false;
    _currentEmployee = null;
    notifyListeners();
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
