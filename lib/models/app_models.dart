enum UserRole { admin, teacher, student }

class User {
  final String id;
  String name;
  final UserRole role;
  String email;
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role.name,
    'email': email,
    'password': password,
    'groupId': groupId,
    'groupIds': groupIds,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    role: UserRole.values.firstWhere(
      (r) => r.name == json['role'],
      orElse: () => UserRole.student,
    ),
    email: json['email'] as String,
    password: json['password'] as String? ?? '12345',
    groupId: json['groupId'] as String?,
    groupIds: (json['groupIds'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
  );
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'courseName': courseName,
    'teacherId': teacherId,
    'studentIds': studentIds,
    'schedule': schedule,
    'price': price,
    'room': room,
    'lessonDays': lessonDays,
    'startTime': startTime,
    'endTime': endTime,
    'startDate': startDate,
    'endDate': endDate,
    'status': status,
    'note': note,
  };

  factory StudyGroup.fromJson(Map<String, dynamic> json) => StudyGroup(
    id: json['id'] as String,
    name: json['name'] as String,
    courseName: json['courseName'] as String,
    teacherId: json['teacherId'] as String,
    studentIds: (json['studentIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    schedule: json['schedule'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    room: json['room'] as String? ?? '201-xona',
    lessonDays: (json['lessonDays'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const ['Dushanba', 'Chorshanba', 'Juma'],
    startTime: json['startTime'] as String? ?? '09:00',
    endTime: json['endTime'] as String? ?? '10:30',
    startDate: json['startDate'] as String? ?? '2025-03-01',
    endDate: json['endDate'] as String? ?? '2025-06-01',
    status: json['status'] as String? ?? 'Faol',
    note: json['note'] as String? ?? '',
  );
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

  Map<String, dynamic> toJson() => {
    'groupId': groupId,
    'date': date,
    'studentPresentMap': studentPresentMap,
  };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
    groupId: json['groupId'] as String,
    date: json['date'] as String,
    studentPresentMap: (json['studentPresentMap'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, v as bool),
    ) ?? {},
  );
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

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'groupId': groupId,
    'month': month,
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
  };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
    studentId: json['studentId'] as String,
    groupId: json['groupId'] as String,
    month: json['month'] as String,
    totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
  );
}
