import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 700;
    final views = const [
      GroupsView(),
      UsersView(),
      AdminAttendanceView(),
      AdminPaymentsView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - O\'quv Markazi Boshqaruvi'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Admin: ${Provider.of<AppState>(context).currentUser?.name ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Chiqish',
            onPressed: () => Provider.of<AppState>(context, listen: false).logout(),
          ),
        ],
      ),
      bottomNavigationBar: isCompact
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.group), label: 'Guruhlar'),
                NavigationDestination(icon: Icon(Icons.people), label: 'Foydalanuvchilar'),
                NavigationDestination(icon: Icon(Icons.fact_check), label: 'Davomat'),
                NavigationDestination(icon: Icon(Icons.payment), label: 'To\'lovlar'),
              ],
            )
          : null,
      body: isCompact
          ? views[_selectedIndex]
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.grey.shade100,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.group),
                      label: Text('Guruhlar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people),
                      label: Text('Foydalanuvchilar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.fact_check),
                      label: Text('Davomat'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.payment),
                      label: Text('To\'lovlar'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: views[_selectedIndex],
                ),
              ],
            ),
    );
  }
}

class GroupsView extends StatelessWidget {
  const GroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final groups = appState.groups;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const Text(
                'Barcha Guruhlar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                icon: const Icon(Icons.add),
                label: const Text('Yangi guruh yaratish'),
                onPressed: () => _showEditOrCreateGroupDialog(context, appState, null),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: groups.isEmpty
                ? const Center(child: Text('Hozircha guruhlar mavjud emas'))
                : ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final teacher = appState.users.firstWhere(
                        (u) => u.id == group.teacherId,
                        orElse: () => User(id: '', name: 'Biriktirilmagan', role: UserRole.teacher, email: ''),
                      );
                      final studentCount = group.studentIds.length;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: const Icon(Icons.group, color: Colors.indigo),
                          ),
                          title: Text('${group.name} (${group.courseName})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Xona: ${group.room} | O\'qituvchi: ${teacher.name}\nKunlar: ${group.lessonDays.join(", ")} | Vaqt: ${group.startTime} - ${group.endTime}\nNarxi: ${group.price.toStringAsFixed(0)} so\'m | Holat: ${group.status}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text('$studentCount o\'quvchi'),
                                backgroundColor: Colors.blue.shade50,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Guruhni tahrirlash',
                                onPressed: () => _showEditOrCreateGroupDialog(context, appState, group),
                              ),
                            ],
                          ),
                          onTap: () => _showGroupDetailsDialog(context, group),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showEditOrCreateGroupDialog(BuildContext context, AppState appState, StudyGroup? groupToEdit) {
    final nameController = TextEditingController(text: groupToEdit?.name ?? 'ING-A1-01');
    final courseController = TextEditingController(text: groupToEdit?.courseName ?? 'IELTS tayyorgarlik');
    final roomController = TextEditingController(text: groupToEdit?.room ?? '201-xona');
    final startTimeController = TextEditingController(text: groupToEdit?.startTime ?? '09:00');
    final endTimeController = TextEditingController(text: groupToEdit?.endTime ?? '10:30');
    final startDateController = TextEditingController(text: groupToEdit?.startDate ?? '2025-03-01');
    final endDateController = TextEditingController(text: groupToEdit?.endDate ?? '2025-06-01');
    final priceController = TextEditingController(text: groupToEdit != null ? groupToEdit.price.toStringAsFixed(0) : '800000');
    final noteController = TextEditingController(text: groupToEdit?.note ?? '');

    final teachers = appState.users.where((u) => u.role == UserRole.teacher).toList();
    String? selectedTeacherId = groupToEdit?.teacherId ?? (teachers.isNotEmpty ? teachers.first.id : null);

    final allStudents = appState.users.where((u) => u.role == UserRole.student).toList();
    List<String> selectedStudentIds = List.from(groupToEdit?.studentIds ?? []);

    List<String> selectedLessonDays = List.from(groupToEdit?.lessonDays ?? ['Dushanba', 'Chorshanba', 'Juma']);
    const allDays = ['Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba'];
    String selectedStatus = groupToEdit?.status ?? 'Faol';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(groupToEdit == null ? 'Yangi guruh yaratish' : 'Guruhni tahrirlash'),
          content: SizedBox(
            width: 650,
            height: 550,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kurs, o\'qituvchi, o\'quvchilar, xona va dars vaqtini belgilang.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Guruh nomi *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: courseController,
                    decoration: const InputDecoration(labelText: 'Kurs *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTeacherId,
                    decoration: const InputDecoration(labelText: 'O\'qituvchi *', border: OutlineInputBorder()),
                    items: teachers.map((t) => DropdownMenuItem(value: t.id, child: Text('${t.name} (hisob faollashgan)'))).toList(),
                    onChanged: (val) => selectedTeacherId = val,
                  ),
                  const SizedBox(height: 16),
                  const Text('O\'quvchilarni qo\'shish (Faollashmaganlar ham qo\'shilishi mumkin)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                    child: allStudents.isEmpty
                        ? const Center(child: Text('Talabalar mavjud emas'))
                        : ListView.builder(
                            itemCount: allStudents.length,
                            itemBuilder: (context, index) {
                              final student = allStudents[index];
                              final isSelected = selectedStudentIds.contains(student.id);

                              return CheckboxListTile(
                                dense: true,
                                title: Text(student.name),
                                subtitle: Text('${student.email} · faollashmagan'),
                                value: isSelected,
                                onChanged: (val) {
                                  setStateDialog(() {
                                    if (val == true) {
                                      selectedStudentIds.add(student.id);
                                    } else {
                                      selectedStudentIds.remove(student.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: roomController,
                          decoration: const InputDecoration(labelText: 'Xona', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Oylik to\'lov (UZS)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Dars kunlari *', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: allDays.map((day) {
                      final isSelected = selectedLessonDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setStateDialog(() {
                            if (selected) {
                              selectedLessonDays.add(day);
                            } else {
                              selectedLessonDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startTimeController,
                          decoration: const InputDecoration(labelText: 'Boshlanish vaqti (masalan: 09:00)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: endTimeController,
                          decoration: const InputDecoration(labelText: 'Tugash vaqti (masalan: 10:30)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startDateController,
                          decoration: const InputDecoration(labelText: 'Boshlanish sanasi (YYYY-MM-DD)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: endDateController,
                          decoration: const InputDecoration(labelText: 'Tugash sanasi (YYYY-MM-DD)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Holat', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Faol', child: Text('Faol')),
                      DropdownMenuItem(value: 'To\'xtatilgan', child: Text('To\'xtatilgan')),
                    ],
                    onChanged: (val) => selectedStatus = val ?? 'Faol',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Izoh', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.isNotEmpty && selectedTeacherId != null) {
                  final price = double.tryParse(priceController.text) ?? 0.0;
                  final schedule = '${selectedLessonDays.join(", ")} ${startTimeController.text} - ${endTimeController.text}';
                  
                  if (groupToEdit == null) {
                    appState.createGroup(
                      nameController.text,
                      courseController.text,
                      selectedTeacherId!,
                      selectedStudentIds,
                      schedule,
                      price,
                      roomController.text,
                      selectedLessonDays,
                      startTimeController.text,
                      endTimeController.text,
                      startDateController.text,
                      endDateController.text,
                      selectedStatus,
                      noteController.text,
                    );
                  } else {
                    appState.updateGroup(
                      groupToEdit.id,
                      nameController.text,
                      courseController.text,
                      selectedTeacherId!,
                      selectedStudentIds,
                      schedule,
                      price,
                      roomController.text,
                      selectedLessonDays,
                      startTimeController.text,
                      endTimeController.text,
                      startDateController.text,
                      endDateController.text,
                      selectedStatus,
                      noteController.text,
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupDetailsDialog(BuildContext context, StudyGroup group) {
    showDialog(
      context: context,
      builder: (context) => Consumer<AppState>(
        builder: (context, appState, child) {
          final currentGroup = appState.groups.firstWhere((g) => g.id == group.id);
          final students = appState.users.where((u) => currentGroup.studentIds.contains(u.id)).toList();
          final teacher = appState.users.firstWhere((u) => u.id == currentGroup.teacherId, orElse: () => User(id: '', name: 'Nomaʼlum', role: UserRole.teacher, email: ''));

          return AlertDialog(
            title: Text('Guruh tafsiloti: ${currentGroup.name}'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kurs: ${currentGroup.courseName}'),
                  Text('O\'qituvchi: ${teacher.name}'),
                  Text('Xona: ${currentGroup.room}'),
                  Text('Dars kunlari: ${currentGroup.lessonDays.join(", ")}'),
                  Text('Vaqt: ${currentGroup.startTime} - ${currentGroup.endTime}'),
                  Text('Oylik to\'lov: ${currentGroup.price.toStringAsFixed(0)} so\'m'),
                  Text('Holat: ${currentGroup.status}'),
                  if (currentGroup.note.isNotEmpty) Text('Izoh: ${currentGroup.note}'),
                  const Divider(),
                  const Text('Guruhdagi o\'quvchilar:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: students.isEmpty
                        ? const Center(child: Text('Bu guruhda talabalar yo\'q'))
                        : ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.person, size: 20),
                                title: Text(student.name),
                                subtitle: Text(student.email),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                                  tooltip: 'Guruhdan chiqarish',
                                  onPressed: () {
                                    appState.removeStudentFromGroup(student.id, currentGroup.id);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Yopish')),
            ],
          );
        },
      ),
    );
  }
}

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  String _selectedRoleFilter = 'Barchasi';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allUsers = appState.users;
    final groups = appState.groups;

    final filteredUsers = allUsers.where((u) {
      if (_selectedRoleFilter == 'O\'qituvchilar') return u.role == UserRole.teacher;
      if (_selectedRoleFilter == 'Talabalar') return u.role == UserRole.student;
      if (_selectedRoleFilter == 'Adminlar') return u.role == UserRole.admin;
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Foydalanuvchilar va Kirish Parollari',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'O\'qituvchi va talabalarni qo\'shish, ularga saytga kirish parolini yaratish va boshqarish',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('Yangi foydalanuvchi qo\'shish'),
                onPressed: () => _showAddUserDialog(context, appState),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Role filters
          Wrap(
            spacing: 8,
            children: ['Barchasi', 'O\'qituvchilar', 'Talabalar', 'Adminlar'].map((filter) {
              final isSelected = _selectedRoleFilter == filter;
              return ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                selectedColor: Colors.indigo.shade100,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedRoleFilter = filter);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('Hech qanday foydalanuvchi topilmadi'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final roleStr = user.role == UserRole.admin
                          ? 'Admin'
                          : user.role == UserRole.teacher
                              ? 'O\'qituvchi'
                              : 'Talaba';

                      final roleColor = user.role == UserRole.admin
                          ? Colors.purple
                          : user.role == UserRole.teacher
                              ? Colors.teal
                              : Colors.orange;

                      String extraInfo = '';
                      if (user.role == UserRole.student) {
                        try {
                          final g = groups.firstWhere((grp) => grp.id == user.groupId);
                          extraInfo = 'Guruh: ${g.name}';
                        } catch (_) {
                          extraInfo = 'Guruh: biriktirilmagan';
                        }
                      } else if (user.role == UserRole.teacher) {
                        final assigned = groups.where((grp) => grp.teacherId == user.id).length;
                        extraInfo = 'Biriktirilgan guruhlar: $assigned ta';
                      }

                      final isCurrentUser = appState.currentUser?.id == user.id;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: roleColor.withValues(alpha: 0.15),
                              child: Icon(
                                user.role == UserRole.admin
                                    ? Icons.admin_panel_settings
                                    : user.role == UserRole.teacher
                                        ? Icons.school
                                        : Icons.person,
                                color: roleColor,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (isCurrentUser) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Siz', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('Email: ${user.email}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.key, size: 14, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Parol: ${user.password}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo.shade800,
                                          backgroundColor: Colors.indigo.shade50,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (extraInfo.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(extraInfo, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                                  ],
                                ],
                              ),
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Chip(
                                  label: Text(roleStr),
                                  backgroundColor: roleColor.withValues(alpha: 0.1),
                                  labelStyle: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'Foydalanuvchi ma\'lumotlari va parolini o\'zgartirish',
                                  onPressed: () => _showEditUserDialog(context, appState, user),
                                ),
                                if (!isCurrentUser)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    tooltip: 'Foydalanuvchini o\'chirish',
                                    onPressed: () => _confirmDeleteUser(context, appState, user),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, AppState appState) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController(text: '12345');
    UserRole selectedRole = UserRole.teacher;
    String? selectedGroupId = appState.groups.isNotEmpty ? appState.groups.first.id : null;
    String? localError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Yangi foydalanuvchi qo\'shish'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'O\'qituvchi yoki talaba uchun login va parol yarating. Ular aynan shu parol bilan saytga kira oladi.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<UserRole>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(labelText: 'Foydalanuvchi roli *', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: UserRole.teacher, child: Text('O\'qituvchi (Teacher)')),
                      DropdownMenuItem(value: UserRole.student, child: Text('Talaba (Student)')),
                      DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                    ],
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'F.I.O. (Ism va Familiya) *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Elektron pochta (Email - Login) *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Kirish paroli *',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Tasodifiy parol generatsiya qilish',
                        onPressed: () {
                          final rand = (10000 + DateTime.now().millisecond * 89) % 90000 + 10000;
                          setStateDialog(() {
                            passwordController.text = 'edu$rand';
                          });
                        },
                      ),
                    ),
                  ),
                  if (selectedRole == UserRole.student && appState.groups.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedGroupId,
                      decoration: const InputDecoration(labelText: 'Guruhni biriktirish', border: OutlineInputBorder()),
                      items: appState.groups.map((g) => DropdownMenuItem(value: g.id, child: Text('${g.name} (${g.courseName})'))).toList(),
                      onChanged: (val) => selectedGroupId = val,
                    ),
                  ],
                  if (localError != null) ...[
                    const SizedBox(height: 10),
                    Text(localError!, style: const TextStyle(color: Colors.red, fontSize: 13), textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                if (name.isEmpty || email.isEmpty || password.isEmpty) {
                  setStateDialog(() => localError = 'Barcha maydonlarni to\'ldiring!');
                  return;
                }
                final success = appState.addUser(
                  name,
                  email,
                  password,
                  selectedRole,
                  groupId: selectedRole == UserRole.student ? selectedGroupId : null,
                );
                if (!success) {
                  setStateDialog(() => localError = 'Bu email manzil allaqachon mavjud!');
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Yangi foydalanuvchi "$name" muvaffaqiyatli qo\'shildi! Parol: $password'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Yaratish va Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, AppState appState, User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController(text: user.password);
    String? selectedGroupId = user.groupId ?? (appState.groups.isNotEmpty ? appState.groups.first.id : null);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.name} ma\'lumotlarini tahrirlash'),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'F.I.O. (Ism va Familiya)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Elektron pochta (Email)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Yangi kirish paroli',
                    helperText: 'Foydalanuvchi saytga kirishi uchun yangi parol',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (user.role == UserRole.student && appState.groups.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedGroupId,
                    decoration: const InputDecoration(labelText: 'Biriktirilgan guruh', border: OutlineInputBorder()),
                    items: appState.groups.map((g) => DropdownMenuItem(value: g.id, child: Text('${g.name} (${g.courseName})'))).toList(),
                    onChanged: (val) => selectedGroupId = val,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                appState.updateUser(
                  user.id,
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                  groupId: user.role == UserRole.student ? selectedGroupId : null,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ma\'lumotlar va yangi parol saqlandi!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, AppState appState, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Foydalanuvchini o\'chirish'),
        content: Text('Haqiqatan ham "${user.name}" (${user.email}) ni tizimdan o\'chirmoqchimisiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              appState.deleteUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${user.name}" o\'chirildi')),
              );
            },
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}

class AdminAttendanceView extends StatelessWidget {
  const AdminAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final groups = appState.groups;
    final records = appState.attendanceRecords;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const Text(
                'Davomat Hisobotlari va Boshqaruvi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                icon: const Icon(Icons.add),
                label: const Text('Davomat kiritish/tahrirlash'),
                onPressed: () => _showSelectGroupForAttendanceDialog(context, groups),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text('Hozircha davomat yozuvlari mavjud emas'))
                : ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      StudyGroup? group;
                      try {
                        group = groups.firstWhere((g) => g.id == record.groupId);
                      } catch (_) {}

                      final presentCount = record.studentPresentMap.values.where((v) => v).length;
                      final totalCount = record.studentPresentMap.length;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.fact_check, color: Colors.white),
                          ),
                          title: Text('Guruh: ${group?.name ?? record.groupId}'),
                          subtitle: Text('Sana: ${record.date} | Qatnashdi: $presentCount / $totalCount talaba'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Davomatni tahrirlash',
                            onPressed: () {
                              if (group != null) {
                                final students = appState.users.where((u) => group!.studentIds.contains(u.id)).toList();
                                _showAttendanceDialog(context, group, students, existingRecord: record);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showSelectGroupForAttendanceDialog(BuildContext context, List<StudyGroup> groups) {
    if (groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avval guruh yarating')));
      return;
    }
    String? selectedGroupId = groups.first.id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Davomat olish uchun guruhni tanlang'),
        content: SizedBox(
          width: 350,
          child: DropdownButtonFormField<String>(
            initialValue: selectedGroupId,
            decoration: const InputDecoration(labelText: 'Guruh'),
            items: groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
            onChanged: (val) => selectedGroupId = val,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () {
              if (selectedGroupId != null) {
                Navigator.pop(context);
                final appState = Provider.of<AppState>(context, listen: false);
                final group = groups.firstWhere((g) => g.id == selectedGroupId);
                final students = appState.users.where((u) => group.studentIds.contains(u.id)).toList();
                _showAttendanceDialog(context, group, students);
              }
            },
            child: const Text('Davomat olish'),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDialog(BuildContext context, StudyGroup group, List<User> students, {AttendanceRecord? existingRecord}) {
    final dateController = TextEditingController(
      text: existingRecord?.date ?? DateTime.now().toIso8601String().split('T')[0],
    );
    final Map<String, bool> attendanceMap = {
      for (var s in students) s.id: existingRecord?.studentPresentMap[s.id] ?? true,
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Davomat: ${group.name}'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Sana (YYYY-MM-DD)'),
                ),
                const SizedBox(height: 16),
                const Text('Talabalar ro\'yxati:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                students.isEmpty
                    ? const Text('Bu guruhda talabalar yo\'q')
                    : SizedBox(
                        height: 250,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final isPresent = attendanceMap[student.id] ?? true;

                            return CheckboxListTile(
                              title: Text(student.name),
                              subtitle: Text(student.email),
                              value: isPresent,
                              onChanged: (val) {
                                setStateDialog(() {
                                  attendanceMap[student.id] = val ?? true;
                                });
                              },
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
            ElevatedButton(
              onPressed: students.isEmpty
                  ? null
                  : () {
                      final date = dateController.text.trim();
                      if (date.isNotEmpty) {
                        Provider.of<AppState>(context, listen: false).saveAttendance(
                          group.id,
                          date,
                          attendanceMap,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Davomat muvaffaqiyatli saqlandi!')),
                        );
                      }
                    },
              child: const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPaymentsView extends StatelessWidget {
  const AdminPaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final students = appState.users.where((u) => u.role == UserRole.student).toList();
    final groups = appState.groups;
    final payments = appState.paymentRecords;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'DIQQAT: Talabalar har oyning 10-kunigacha to\'liq to\'lov qilishlari shart!\nAgar to\'lov 100% bo\'lmasa, qolgan qarz hisoblanib, darslar bo\'yicha qarz miqdori va to\'lash muddati eslatib turiladi.',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Talabalar To\'lovlari va Qarz Nazorati (Mart 2025)',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text('Talabalar mavjud emas'))
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      StudyGroup? group;
                      try {
                        group = groups.firstWhere((g) => g.id == student.groupId || g.studentIds.contains(student.id));
                      } catch (_) {}

                      if (group == null) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(student.name),
                            subtitle: const Text('Guruhga biriktirilmagan'),
                          ),
                        );
                      }

                      PaymentRecord? payment;
                      try {
                        payment = payments.firstWhere((p) => p.studentId == student.id && p.groupId == group!.id && p.month == '2025-03');
                      } catch (_) {
                        payment = PaymentRecord(studentId: student.id, groupId: group.id, month: '2025-03', totalAmount: group.price, paidAmount: 0.0);
                      }

                      final total = group.price;
                      final paid = payment.paidAmount;
                      final remaining = total - paid;
                      final percent = total > 0 ? (paid / total) * 100 : 100.0;
                      final isFullyPaid = paid >= total;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    student.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Chip(
                                    label: Text(isFullyPaid ? 'To\'langan (100%)' : 'Qarz bor (${percent.toStringAsFixed(0)}%)'),
                                    backgroundColor: isFullyPaid ? Colors.green.shade50 : Colors.red.shade50,
                                    labelStyle: TextStyle(
                                      color: isFullyPaid ? Colors.green.shade700 : Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Guruh: ${group.name} | Kurs narxi: ${total.toStringAsFixed(0)} so\'m'),
                              const SizedBox(height: 4),
                              Text('To\'landi: ${paid.toStringAsFixed(0)} so\'m | Qoldiq qarz: ${remaining.toStringAsFixed(0)} so\'m',
                                  style: TextStyle(color: remaining > 0 ? Colors.red.shade700 : Colors.green.shade700, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              if (!isFullyPaid)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'ESLATMA: 10-kungi muddatgacha ${remaining.toStringAsFixed(0)} so\'m qarzdorlikni to\'lashingiz lozim!',
                                    style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('To\'lovni tahrirlash'),
                                  onPressed: () => _showUpdatePaymentDialog(context, student, group!, payment!),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showUpdatePaymentDialog(BuildContext context, User student, StudyGroup group, PaymentRecord payment) {
    final amountController = TextEditingController(text: payment.paidAmount.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('To\'lovni kiritish: ${student.name}'),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guruh narxi (Oylik): ${group.price.toStringAsFixed(0)} so\'m'),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'To\'langan summa (so\'mda)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () {
              final paid = double.tryParse(amountController.text) ?? 0.0;
              Provider.of<AppState>(context, listen: false).updatePayment(
                student.id,
                group.id,
                '2025-03',
                paid,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('To\'lov muvaffaqiyatli yangilandi!')),
              );
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }
}
