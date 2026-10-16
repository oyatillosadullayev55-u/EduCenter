import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final teacher = appState.currentUser!;
    
    // Filter groups assigned to this teacher
    final teacherGroups = appState.groups.where((g) => g.teacherId == teacher.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('O\'qituvchi Paneli - ${teacher.name}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Chiqish',
            onPressed: () => appState.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mening Guruhlarim va Davomat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sizga biriktirilgan guruhlar, talabalar va davomatni belgilash:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: teacherGroups.isEmpty
                  ? const Center(
                      child: Text('Sizga hozircha hech qanday guruh biriktirilmagan.'),
                    )
                  : ListView.builder(
                      itemCount: teacherGroups.length,
                      itemBuilder: (context, index) {
                        final group = teacherGroups[index];
                        final students = appState.users
                            .where((u) => group.studentIds.contains(u.id))
                            .toList();

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Text(
                                      group.name,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                                    ),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Chip(
                                          label: Text('Jadval: ${group.schedule}'),
                                          backgroundColor: Colors.teal.shade50,
                                        ),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(Icons.fact_check, size: 16),
                                          label: const Text('Davomat olish'),
                                          onPressed: () => _showAttendanceDialog(context, group, students),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Kurs: ${group.courseName}', style: const TextStyle(color: Colors.black87)),
                                const Divider(height: 24),
                                const Text(
                                  'Talabalar:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                students.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text('Bu guruhda talabalar hali yo\'q', style: TextStyle(color: Colors.grey)),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: students.length,
                                        itemBuilder: (context, sIndex) {
                                          final student = students[sIndex];
                                          return ListTile(
                                            dense: true,
                                            leading: const CircleAvatar(
                                              radius: 14,
                                              child: Icon(Icons.person, size: 16),
                                            ),
                                            title: Text(student.name),
                                            subtitle: Text(student.email),
                                          );
                                        },
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
      ),
    );
  }

  void _showAttendanceDialog(BuildContext context, StudyGroup group, List<User> students) {
    final dateController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0],
    );
    // Initial map: all present by default
    final Map<String, bool> attendanceMap = {
      for (var s in students) s.id: true,
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Davomat olish: ${group.name}'),
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
                const Text('Talabalar ro\'yxati (Belgilash - qatnashdi):', style: TextStyle(fontWeight: FontWeight.bold)),
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
