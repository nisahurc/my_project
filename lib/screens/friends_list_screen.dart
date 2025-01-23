import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  Future<List<Map<String, dynamic>>> _getFriends() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return [];

    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    final friendsIds = List<String>.from(currentUserDoc.data()?['friends'] ?? []);

    final friendsData = await Future.wait(
      friendsIds.map((friendId) async {
        final friendDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();

        return {
          'id': friendId, // Arkadaşın ID'si TasksScreen için gerekli
          'nickname': friendDoc.data()?['nickname'] ?? 'Unknown',
          'email': friendDoc.data()?['email'] ?? 'Unknown',
        };
      }),
    );

    return friendsData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Friends",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        toolbarHeight: 70.0,
        backgroundColor: const Color(0xFFc8c6f5),
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
        future: _getFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No friends added.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final friend = snapshot.data![index];
              return InkWell(
                onTap: () {
                },
                child: Container(
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
                        friend['nickname'],
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFffb8f0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        friend['email'],
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}

class TasksScreen extends StatelessWidget {
  final String userId;

  const TasksScreen({super.key, required this.userId});

  Future<List<Map<String, dynamic>>> _getTasks() async {
    final tasksQuerySnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId) // UserId'ye göre filtreleme
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
        title: const Text(
          "Tasks",
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFc8c6f5),
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

