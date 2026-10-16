enum UserRole { admin, teacher, student }

class User {
  final String id;
  final String name;
  final UserRole role;
  final String email;
  String password;
  String? groupId; // For student
  List<String>? groupIds; // For teacher

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.password = '12345',
    this.groupId,
    this.groupIds,
  });
}

class StudyGroup {
  final String id;
  String name;
  String courseName;
  String teacherId;
  List<String> studentIds;
  String schedule; // Legacy schedule string
  double price; // Oylik to'lov (UZS)
  String room; // Xona (masalan: 201-xona)
  List<String> lessonDays; // Dars kunlari (Dushanba, Seshanba, ...)
  String startTime; // Boshlanish vaqti
  String endTime; // Tugash vaqti
  String startDate; // Boshlanish sanasi
  String endDate; // Tugash sanasi
  String status; // Holat (Faol, To'xtatilgan)
  String note; // Izoh

  StudyGroup({
    required this.id,
    required this.name,
    required this.courseName,
    required this.teacherId,
    required this.studentIds,
    required this.schedule,
    this.price = 0.0,
    this.room = '201-xona',
    this.lessonDays = const ['Dushanba', 'Chorshanba', 'Juma'],
    this.startTime = '09:00',
    this.endTime = '10:30',
    this.startDate = '2025-03-01',
    this.endDate = '2025-06-01',
    this.status = 'Faol',
    this.note = '',
  });
}

class AttendanceRecord {
  final String groupId;
  final String date; // YYYY-MM-DD
  final Map<String, bool> studentPresentMap; // studentId -> isPresent

  AttendanceRecord({
    required this.groupId,
    required this.date,
    required this.studentPresentMap,
  });
}

class PaymentRecord {
  final String studentId;
  final String groupId;
  final String month; // YYYY-MM
  double totalAmount; // Guruh narxi
  double paidAmount; // To'langan summa

  PaymentRecord({
    required this.studentId,
    required this.groupId,
    required this.month,
    required this.totalAmount,
    this.paidAmount = 0.0,
  });
}
