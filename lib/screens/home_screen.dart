import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_project/screens/Welcome/welcome_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_project/screens/chart_screen.dart';
import 'package:my_project/screens/countdown_page.dart';
import 'package:my_project/util/todo_tile.dart';
// Bağımsız myDialogBox fonksiyonu
Dialog myDialogBox({
  required BuildContext context,
  required String name,
  required String condition,
  required VoidCallback onPressed,
  required TextEditingController nameController,
}) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6c5f95),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context); // Çıkış butonu düzeltildi
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Enter a task name",
              labelStyle: const TextStyle(color: Colors.black),
              hintText: 'e.g., Make exercises',
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFffb8f0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              condition,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController nameController = TextEditingController();
  CollectionReference get tasksCollection {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');
  }

  int _currentIndex = 0;

  Future<void> create(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return myDialogBox(
          context: context, // Burada context parametresini iletmelisiniz
          name: "Create new task",
          condition: "Create",
          nameController: nameController,
          onPressed: () {
            String name = nameController.text.trim();
            if (name.isNotEmpty) {
              addItems(name); // Task ekleme işlemi
            }
            Navigator.pop(context); // Dialog kapatılır
          },
        );
      },
    );
  }


  void addItems(String name) {
    tasksCollection.add({
      'taskName': name,
      'time': FieldValue.serverTimestamp(),
      'duration': 0, // Başlangıç süresi 0 olarak ayarlandı
    });
  }

  Future<void> update(BuildContext context, DocumentSnapshot documentSnapshot) async {
    nameController.text = documentSnapshot['taskName'];
    return showDialog(
      context: context,
      builder: (context) {
        return myDialogBox(
          context: context, // Context parametresi eklenmeli
          name: "Update Your Task",
          condition: "Update",
          nameController: nameController,
          onPressed: () async {
            String name = nameController.text.trim();
            if (name.isNotEmpty) {
              await tasksCollection.doc(documentSnapshot.id).update({
                'taskName': name, // Yeni task adı güncellenir
              });
            }
            nameController.clear(); // TextField temizlenir
            Navigator.pop(context); // Dialog kapatılır
          },
        );
      },
    );
  }


  Future<void> delete(String taskId) async {
    await tasksCollection.doc(taskId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text("Deleted successfully"),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "My Timer",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFc8c6f5),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: tasksCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final taskName = doc['taskName'];
                final taskId = doc.id;
                final duration = doc['duration'] ?? 0;
                return ToDoTile(
                  taskName: taskName,
                  taskId: taskId,
                  deleteFunction: (_) => delete(doc.id),
                  updateFunction: () => update(context,doc),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CountdownPage(
                          taskId: doc.id,
                          taskName: taskName,
                        ),
                      ),
                    );
                  },
                  duration: duration,
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => create(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Her bir tıklamada ilgili rotaya yönlendir
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/add_friend'); // Arkadaş Ekle
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChartScreen(
                    userId: FirebaseAuth.instance.currentUser!.uid,
                  ),
                ),
              );
              break;
            case 2:
              Navigator.pushNamed(context, '/'); // Ana sayfa
              break;
            case 3:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add friends',
            backgroundColor: Color(0xFFa291d7),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_chart),
            label: 'Charts',
            backgroundColor: Color(0xFFa291d7),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color(0xFFa291d7),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Color(0xFFa291d7),
          ),
        ],
      ),
    );
  }
}