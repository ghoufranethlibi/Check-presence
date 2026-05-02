import 'package:firebase_database/firebase_database.dart';
import '../models/employee_model.dart';
import '../models/attendance_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _db = FirebaseDatabase.instance;

  List<Map<String, dynamic>> _listFromSnapshot(DataSnapshot snapshot) {
    final value = snapshot.value;
    if (value is! Map) return <Map<String, dynamic>>[];
    final map = value.cast<dynamic, dynamic>();
    return map.entries.map((entry) {
      final child = (entry.value as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      final id = (child['id'] as String?) ?? entry.key.toString();
      return <String, dynamic>{...child, 'id': id};
    }).toList();
  }

  // ── EMPLOYÉS ─────────────────────────────────────────
  Future<List<Employee>> getAllEmployees() async {
    final snapshot = await _db.ref('employees').get();
    final rows = _listFromSnapshot(snapshot).map(Employee.fromMap).toList();
    rows.sort((a, b) => a.name.compareTo(b.name));
    return rows;
  }

  Future<Employee?> getEmployeeById(String id) async {
    final byKey = await _db.ref('employees/$id').get();
    if (byKey.exists && byKey.value is Map) {
      final data = (byKey.value as Map).cast<String, dynamic>();
      return Employee.fromMap(<String, dynamic>{...data, 'id': data['id'] ?? id});
    }
    final all = await getAllEmployees();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Employee?> getEmployeeByQR(String qrCode) async {
    final snap = await _db.ref('employees').orderByChild('qrCode').equalTo(qrCode).limitToFirst(1).get();
    final list = _listFromSnapshot(snap);
    if (list.isEmpty) return null;
    return Employee.fromMap(list.first);
  }

  Future<void> addEmployee(Employee e) async {
    await _db.ref('employees/${e.id}').set(e.toMap());
  }

  Future<void> updateEmployee(Employee e) async {
    final ref = _db.ref('employees/${e.id}');
    final current = await ref.get();
    final existing = (current.value as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    await ref.set(<String, dynamic>{...existing, ...e.toMap()});
  }

  Future<void> deleteEmployee(String id) async {
    await _db.ref('employees/$id').remove();
  }

  // ── PRÉSENCES ────────────────────────────────────────
  Future<List<Attendance>> getTodayAttendance() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return getAttendanceByDate(today);
  }

  Future<List<Attendance>> getAttendanceByDate(String date) async {
    final snapshot =
        await _db.ref('attendance').orderByChild('date').equalTo(date).get();
    final rows = _listFromSnapshot(snapshot).map(Attendance.fromMap).toList();
    rows.sort((a, b) => b.checkIn.compareTo(a.checkIn));
    return rows;
  }

  Future<List<Attendance>> getEmployeeAttendance(String empId) async {
    final snapshot = await _db
        .ref('attendance')
        .orderByChild('employeeId')
        .equalTo(empId)
        .get();
    final rows = _listFromSnapshot(snapshot).map(Attendance.fromMap).toList();
    rows.sort((a, b) => b.checkIn.compareTo(a.checkIn));
    return rows;
  }

  Future<Attendance?> getTodayAttendanceForEmployee(String empId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final rows = await getEmployeeAttendance(empId);
    final todayRows = rows.where((a) => a.date == today).toList();
    if (todayRows.isEmpty) return null;
    todayRows.sort((a, b) => b.checkIn.compareTo(a.checkIn));
    return todayRows.first;
  }

  Future<void> addAttendance(Attendance a) async {
    await _db.ref('attendance/${a.id}').set(a.toMap());
  }

  Future<void> updateAttendance(Attendance a) async {
    final ref = _db.ref('attendance/${a.id}');
    final current = await ref.get();
    final existing = (current.value as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    await ref.set(<String, dynamic>{...existing, ...a.toMap()});
  }

  Future<Map<String, int>> getTodayStats() async {
    final employeesSnap =
        await _db.ref('employees').orderByChild('role').equalTo('employee').get();
    final attendanceToday = await getTodayAttendance();
    final uniquePresent = attendanceToday.map((e) => e.employeeId).toSet().length;
    final total = _listFromSnapshot(employeesSnap).length;
    final present = uniquePresent;
    return {'total': total, 'present': present, 'absent': total - present};
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final result = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now()
          .subtract(Duration(days: i))
          .toIso8601String()
          .substring(0, 10);
      final dayRecords = await getAttendanceByDate(date);
      final count = dayRecords.map((e) => e.employeeId).toSet().length;
      result.add({'date': date, 'count': count});
    }
    return result;
  }
}
