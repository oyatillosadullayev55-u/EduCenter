import 'package:flutter/foundation.dart';
import '../models/app_models.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Mock initial users with passwords
  final List<User> users = [
    User(id: 'u1', name: 'Alisher Admin', role: UserRole.admin, email: 'admin@educenter.uz', password: 'admin123'),
    User(id: 'u2', name: 'Rustam O\'qituvchi', role: UserRole.teacher, email: 'teacher1@educenter.uz', password: '12345', groupIds: ['g1']),
    User(id: 'u3', name: 'Malika O\'qituvchi', role: UserRole.teacher, email: 'teacher2@educenter.uz', password: '12345', groupIds: ['g2']),
    User(id: 'u4', name: 'Jasur Talaba', role: UserRole.student, email: 'student1@educenter.uz', password: '12345', groupId: 'g1'),
    User(id: 'u5', name: 'Zulayho Talaba', role: UserRole.student, email: 'student2@educenter.uz', password: '12345', groupId: 'g1'),
    User(id: 'u6', name: 'Behzod Talaba', role: UserRole.student, email: 'student3@educenter.uz', password: '12345', groupId: 'g2'),
  ];

  // Mock initial groups
  final List<StudyGroup> groups = [
    StudyGroup(
      id: 'g1',
      name: 'ING-A1-01',
      courseName: 'IELTS tayyorgarlik',
      teacherId: 'u2',
      studentIds: ['u4', 'u5'],
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
      teacherId: 'u3',
      studentIds: ['u6'],
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

  // Attendance records storage
  final List<AttendanceRecord> attendanceRecords = [];

  // Payment records storage
  final List<PaymentRecord> paymentRecords = [
    PaymentRecord(studentId: 'u4', groupId: 'g1', month: '2025-03', totalAmount: 800000.0, paidAmount: 800000.0),
    PaymentRecord(studentId: 'u5', groupId: 'g1', month: '2025-03', totalAmount: 800000.0, paidAmount: 300000.0),
    PaymentRecord(studentId: 'u6', groupId: 'g2', month: '2025-03', totalAmount: 700000.0, paidAmount: 0.0),
  ];

  bool login(String email, String password) {
    try {
      final user = users.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
      if (user.password == password) {
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
    final newId = 'g${groups.length + 1}';
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

    // Assign students to group and initialize payment record
    const currentMonth = '2025-03';
    for (var studentId in studentIds) {
      try {
        final student = users.firstWhere((u) => u.id == studentId);
        student.groupId = newId;

        // Add payment record if not exists
        final existingPayment = paymentRecords.indexWhere((p) => p.studentId == studentId && p.groupId == newId && p.month == currentMonth);
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

    notifyListeners();
  }

  // Admin: Update group with all detailed fields
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

      // Update payment record totals
      for (var p in paymentRecords) {
        if (p.groupId == groupId) {
          p.totalAmount = price;
        }
      }

      // Update students group assignment
      for (var s in users) {
        if (s.role == UserRole.student) {
          if (studentIds.contains(s.id)) {
            s.groupId = groupId;
            // Ensure payment record
            const currentMonth = '2025-03';
            if (!paymentRecords.any((p) => p.studentId == s.id && p.groupId == groupId && p.month == currentMonth)) {
              paymentRecords.add(PaymentRecord(studentId: s.id, groupId: groupId, month: currentMonth, totalAmount: price, paidAmount: 0.0));
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

      notifyListeners();
    } catch (_) {}
  }

  // Admin: Add a new user
  void addUser(String name, String email, String password, UserRole role, {String? groupId}) {
    final newId = 'u${users.length + 1}';
    final newUser = User(
      id: newId,
      name: name,
      role: role,
      email: email,
      password: password.isEmpty ? '12345' : password,
      groupId: role == UserRole.student ? groupId : null,
      groupIds: role == UserRole.teacher ? [] : null,
    );
    users.add(newUser);

    if (role == UserRole.student && groupId != null) {
      assignStudentToGroup(newId, groupId);
    }

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
    notifyListeners();
  }

  // Update Payment
  void updatePayment(String studentId, String groupId, String month, double paidAmount) {
    final index = paymentRecords.indexWhere((p) => p.studentId == studentId && p.groupId == groupId && p.month == month);
    if (index != -1) {
      paymentRecords[index].paidAmount = paidAmount;
    } else {
      final group = groups.firstWhere((g) => g.id == groupId, orElse: () => StudyGroup(id: groupId, name: '', courseName: '', teacherId: '', studentIds: [], schedule: '', price: 500000));
      paymentRecords.add(PaymentRecord(
        studentId: studentId,
        groupId: groupId,
        month: month,
        totalAmount: group.price,
        paidAmount: paidAmount,
      ));
    }
    notifyListeners();
  }
}
