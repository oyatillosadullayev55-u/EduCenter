import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  List<User> users = [
    User(
      id: 'u1',
      name: 'Asosiy Admin',
      role: UserRole.admin,
      email: 'admin@educenter.uz',
      password: 'admin123',
    ),
  ];

  List<StudyGroup> groups = [];
  List<AttendanceRecord> attendanceRecords = [];
  List<PaymentRecord> paymentRecords = [];

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AppState() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final usersJson = prefs.getString('educenter_users');
      if (usersJson != null && usersJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(usersJson);
        users = decoded.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
        // Ensure at least one admin exists
        if (!users.any((u) => u.role == UserRole.admin)) {
          users.insert(
            0,
            User(
              id: 'u1',
              name: 'Asosiy Admin',
              role: UserRole.admin,
              email: 'admin@educenter.uz',
              password: 'admin123',
            ),
          );
        }
      }

      final groupsJson = prefs.getString('educenter_groups');
      if (groupsJson != null && groupsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(groupsJson);
        groups = decoded.map((item) => StudyGroup.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        // Initial default groups
        groups = [
          StudyGroup(
            id: 'g1',
            name: 'ING-A1-01',
            courseName: 'IELTS tayyorgarlik',
            teacherId: '',
            studentIds: [],
            schedule: 'Dushanba, Chorshanba, Juma 09:00 - 10:30',
            price: 800000.0,
            room: '201-xona',
            lessonDays: ['Dushanba', 'Chorshanba', 'Juma'],
            startTime: '09:00',
            endTime: '10:30',
            startDate: '2025-03-01',
            endDate: '2025-06-01',
            status: 'Faol',
            note: 'Intensiv guruh',
          ),
          StudyGroup(
            id: 'g2',
            name: 'PYTHON-202',
            courseName: 'Python va Django',
            teacherId: '',
            studentIds: [],
            schedule: 'Seshanba, Payshanba, Shanba 10:00 - 12:00',
            price: 700000.0,
            room: '302-xona',
            lessonDays: ['Seshanba', 'Payshanba', 'Shanba'],
            startTime: '10:00',
            endTime: '12:00',
            startDate: '2025-03-01',
            endDate: '2025-06-01',
            status: 'Faol',
            note: 'Backend kursi',
          ),
        ];
        await _saveToStorage();
      }

      final attendanceJson = prefs.getString('educenter_attendance');
      if (attendanceJson != null && attendanceJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(attendanceJson);
        attendanceRecords = decoded.map((item) => AttendanceRecord.fromJson(item as Map<String, dynamic>)).toList();
      }

      final paymentsJson = prefs.getString('educenter_payments');
      if (paymentsJson != null && paymentsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(paymentsJson);
        paymentRecords = decoded.map((item) => PaymentRecord.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error loading from storage: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('educenter_users', jsonEncode(users.map((u) => u.toJson()).toList()));
      await prefs.setString('educenter_groups', jsonEncode(groups.map((g) => g.toJson()).toList()));
      await prefs.setString('educenter_attendance', jsonEncode(attendanceRecords.map((a) => a.toJson()).toList()));
      await prefs.setString('educenter_payments', jsonEncode(paymentRecords.map((p) => p.toJson()).toList()));
    } catch (e) {
      debugPrint('Error saving to storage: $e');
    }
  }

  bool login(String email, String password) {
    try {
      final user = users.firstWhere(
        (u) => u.email.trim().toLowerCase() == email.trim().toLowerCase(),
      );
      if (user.password.trim() == password.trim()) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Admin: Add a new user (teacher, student, admin) with custom password
  bool addUser(String name, String email, String password, UserRole role, {String? groupId}) {
    final cleanEmail = email.trim().toLowerCase();
    if (users.any((u) => u.email.trim().toLowerCase() == cleanEmail)) {
      return false; // Email already taken
    }

    final newId = 'u_${DateTime.now().millisecondsSinceEpoch}';
    final newUser = User(
      id: newId,
      name: name.trim(),
      role: role,
      email: cleanEmail,
      password: password.trim().isEmpty ? '12345' : password.trim(),
      groupId: role == UserRole.student ? groupId : null,
      groupIds: role == UserRole.teacher ? [] : null,
    );
    users.add(newUser);

    if (role == UserRole.student && groupId != null) {
      assignStudentToGroup(newId, groupId);
    }

    _saveToStorage();
    notifyListeners();
    return true;
  }

  // Admin: Update user details or change password
  void updateUser(String userId, String name, String email, String password, {String? groupId}) {
    try {
      final user = users.firstWhere((u) => u.id == userId);
      user.name = name.trim();
      user.email = email.trim().toLowerCase();
      if (password.trim().isNotEmpty) {
        user.password = password.trim();
      }

      if (user.role == UserRole.student && groupId != null && groupId != user.groupId) {
        assignStudentToGroup(userId, groupId);
      }

      _saveToStorage();
      notifyListeners();
    } catch (_) {}
  }

  // Admin: Delete user
  void deleteUser(String userId) {
    if (_currentUser?.id == userId) return;

    final userIndex = users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      final user = users[userIndex];
      for (var g in groups) {
        g.studentIds.remove(userId);
      }
      if (user.role == UserRole.teacher) {
        for (var g in groups) {
          if (g.teacherId == userId) {
            g.teacherId = '';
          }
        }
      }
      paymentRecords.removeWhere((p) => p.studentId == userId);
      users.removeAt(userIndex);
      _saveToStorage();
      notifyListeners();
    }
  }

  // Admin: Create group with all detailed fields
  void createGroup(
    String name,
    String courseName,
    String teacherId,
    List<String> studentIds,
    String schedule,
    double price,
    String room,
    List<String> lessonDays,
    String startTime,
    String endTime,
    String startDate,
    String endDate,
    String status,
    String note,
  ) {
    final newId = 'g_${DateTime.now().millisecondsSinceEpoch}';
    final newGroup = StudyGroup(
      id: newId,
      name: name,
      courseName: courseName,
      teacherId: teacherId,
      studentIds: studentIds,
      schedule: schedule,
      price: price,
      room: room,
      lessonDays: lessonDays,
      startTime: startTime,
      endTime: endTime,
      startDate: startDate,
      endDate: endDate,
      status: status,
      note: note,
    );
    groups.add(newGroup);

    try {
      final teacher = users.firstWhere((u) => u.id == teacherId);
      teacher.groupIds ??= [];
      teacher.groupIds!.add(newId);
    } catch (_) {}

    const currentMonth = '2025-03';
    for (var studentId in studentIds) {
      try {
        final student = users.firstWhere((u) => u.id == studentId);
        student.groupId = newId;

        final existingPayment = paymentRecords.indexWhere(
          (p) => p.studentId == studentId && p.groupId == newId && p.month == currentMonth,
        );
        if (existingPayment == -1) {
          paymentRecords.add(PaymentRecord(
            studentId: studentId,
            groupId: newId,
            month: currentMonth,
            totalAmount: price,
            paidAmount: 0.0,
          ));
        }
      } catch (_) {}
    }

    _saveToStorage();
    notifyListeners();
  }

  // Admin: Update group
  void updateGroup(
    String groupId,
    String name,
    String courseName,
    String teacherId,
    List<String> studentIds,
    String schedule,
    double price,
    String room,
    List<String> lessonDays,
    String startTime,
    String endTime,
    String startDate,
    String endDate,
    String status,
    String note,
  ) {
    try {
      final group = groups.firstWhere((g) => g.id == groupId);
      final oldTeacherId = group.teacherId;

      group.name = name;
      group.courseName = courseName;
      group.teacherId = teacherId;
      group.studentIds = studentIds;
      group.schedule = schedule;
      group.price = price;
      group.room = room;
      group.lessonDays = lessonDays;
      group.startTime = startTime;
      group.endTime = endTime;
      group.startDate = startDate;
      group.endDate = endDate;
      group.status = status;
      group.note = note;

      for (var p in paymentRecords) {
        if (p.groupId == groupId) {
          p.totalAmount = price;
        }
      }

      for (var s in users) {
        if (s.role == UserRole.student) {
          if (studentIds.contains(s.id)) {
            s.groupId = groupId;
            const currentMonth = '2025-03';
            if (!paymentRecords.any((p) => p.studentId == s.id && p.groupId == groupId && p.month == currentMonth)) {
              paymentRecords.add(PaymentRecord(
                studentId: s.id,
                groupId: groupId,
                month: currentMonth,
                totalAmount: price,
                paidAmount: 0.0,
              ));
            }
          } else if (s.groupId == groupId) {
            s.groupId = null;
          }
        }
      }

      if (oldTeacherId != teacherId) {
        try {
          final oldTeacher = users.firstWhere((u) => u.id == oldTeacherId);
          oldTeacher.groupIds?.remove(groupId);
        } catch (_) {}
        try {
          final newTeacher = users.firstWhere((u) => u.id == teacherId);
          newTeacher.groupIds ??= [];
          if (!newTeacher.groupIds!.contains(groupId)) {
            newTeacher.groupIds!.add(groupId);
          }
        } catch (_) {}
      }

      _saveToStorage();
      notifyListeners();
    } catch (_) {}
  }

  // Admin: Delete group
  void deleteGroup(String groupId) {
    groups.removeWhere((g) => g.id == groupId);
    for (var u in users) {
      if (u.groupId == groupId) u.groupId = null;
      u.groupIds?.remove(groupId);
    }
    attendanceRecords.removeWhere((a) => a.groupId == groupId);
    paymentRecords.removeWhere((p) => p.groupId == groupId);
    _saveToStorage();
    notifyListeners();
  }

  // Admin: Assign student to group
  void assignStudentToGroup(String studentId, String groupId) {
    for (var g in groups) {
      g.studentIds.remove(studentId);
    }
    try {
      final group = groups.firstWhere((g) => g.id == groupId);
      if (!group.studentIds.contains(studentId)) {
        group.studentIds.add(studentId);
      }

      final student = users.firstWhere((u) => u.id == studentId);
      student.groupId = groupId;

      const currentMonth = '2025-03';
      if (!paymentRecords.any((p) => p.studentId == studentId && p.groupId == groupId && p.month == currentMonth)) {
        paymentRecords.add(PaymentRecord(
          studentId: studentId,
          groupId: groupId,
          month: currentMonth,
          totalAmount: group.price,
          paidAmount: 0.0,
        ));
      }

      _saveToStorage();
      notifyListeners();
    } catch (_) {}
  }

  // Admin: Remove student from group
  void removeStudentFromGroup(String studentId, String groupId) {
    try {
      final group = groups.firstWhere((g) => g.id == groupId);
      group.studentIds.remove(studentId);

      final student = users.firstWhere((u) => u.id == studentId);
      if (student.groupId == groupId) {
        student.groupId = null;
      }
      _saveToStorage();
      notifyListeners();
    } catch (_) {}
  }

  // Save Attendance
  void saveAttendance(String groupId, String date, Map<String, bool> studentPresentMap) {
    attendanceRecords.removeWhere((r) => r.groupId == groupId && r.date == date);

    attendanceRecords.add(AttendanceRecord(
      groupId: groupId,
      date: date,
      studentPresentMap: studentPresentMap,
    ));
    _saveToStorage();
    notifyListeners();
  }

  // Update Payment
  void updatePayment(String studentId, String groupId, String month, double paidAmount) {
    final index = paymentRecords.indexWhere((p) => p.studentId == studentId && p.groupId == groupId && p.month == month);
    if (index != -1) {
      paymentRecords[index].paidAmount = paidAmount;
    } else {
      final group = groups.firstWhere(
        (g) => g.id == groupId,
        orElse: () => StudyGroup(
          id: groupId,
          name: '',
          courseName: '',
          teacherId: '',
          studentIds: [],
          schedule: '',
          price: 500000,
        ),
      );
      paymentRecords.add(PaymentRecord(
        studentId: studentId,
        groupId: groupId,
        month: month,
        totalAmount: group.price,
        paidAmount: paidAmount,
      ));
    }
    _saveToStorage();
    notifyListeners();
  }
}
