import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  final String userId;

  const TasksScreen({super.key, required this.userId});

  Future<List<Map<String, dynamic>>> _getTasks() async {
    final tasksQuerySnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    return tasksQuerySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'taskName': data['taskName'] ?? 'Unknown Task',
        'duration': data['duration'] ?? 'No Duration',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Center(
              child: Text(
                "Tasks",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w500,
                  wordSpacing: 4.0,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
            )
          ],
        ),
        toolbarHeight: 80.0,
        backgroundColor: Color(0xFFc8c6f5),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
        ),
        leadingWidth: 80,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No tasks found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final task = snapshot.data![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['taskName'],
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFffb8f0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Duration: ${task['duration']}',
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
