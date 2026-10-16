import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final student = appState.currentUser!;

    // Find student's group
    StudyGroup? myGroup;
    try {
      myGroup = appState.groups.firstWhere((g) => g.id == student.groupId || g.studentIds.contains(student.id));
    } catch (_) {
      myGroup = null;
    }

    // Find teacher of this group if any
    User? teacher;
    if (myGroup != null) {
      try {
        teacher = appState.users.firstWhere((u) => u.id == myGroup!.teacherId);
      } catch (_) {
        teacher = null;
      }
    }

    // Classmates in the same group
    final classmates = myGroup != null
        ? appState.users.where((u) => myGroup!.studentIds.contains(u.id)).toList()
        : <User>[];

    return Scaffold(
      appBar: AppBar(
        title: Text('Talaba Paneli - ${student.name}'),
        backgroundColor: Colors.deepOrange,
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
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.deepOrange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xush kelibsiz!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    const SizedBox(height: 8),
                    Text('Sizning emailingiz: ${student.email}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mening Guruhim Ma\'lumotlari',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
            const SizedBox(height: 12),
            myGroup == null
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Siz hali hech qanday guruhga biriktirilmagansiz. Admin bilan bog\'laning.'),
                    ),
                  )
                : Expanded(
                    child: ListView(
                      children: [
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Guruh: ${myGroup.name}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text('Kurs: ${myGroup.courseName}', style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Dars jadvali: ${myGroup.schedule}', style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('O\'qituvchi: ${teacher?.name ?? 'Biriktirilmagan'}', style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Guruhdoshlaringiz:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 2,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: classmates.length,
                            itemBuilder: (context, index) {
                              final classmate = classmates[index];
                              final isMe = classmate.id == student.id;
                              return ListTile(
                                leading: const Icon(Icons.person, color: Colors.deepOrange),
                                title: Text(
                                  classmate.name + (isMe ? ' (Siz)' : ''),
                                  style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
                                ),
                                subtitle: Text(classmate.email),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
