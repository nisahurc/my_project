import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/util/edit_item.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  String gender = "man";
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      nicknameController.text = data['nickname'] ?? '';
      emailController.text = data['email'] ?? '';
      gender = data['gender'] ?? 'man';
      setState(() {});
    }
  }

  Future<void> _updateUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final nickname = nicknameController.text.trim();
    final email = emailController.text.trim();

    if (nickname.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nickname and Email cannot be empty!")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'nickname': nickname,
        'email': email,
        'gender': gender,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account updated successfully!")),
      );

      Navigator.pop(context); // İşlem tamamlandığında geri dön
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating account: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Center(
              child: Text(
                "Account",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/avatar.png",
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              const SizedBox(height: 60),
              EditItem(
                title: "Nickname",
                widget: TextField(
                  controller: nicknameController,
                  decoration: const InputDecoration(
                    hintText: "Enter your nickname",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                widget: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: "Enter your email",
                    border: OutlineInputBorder(),
                  ),
                ),
                title: "Email",
              ),
              const SizedBox(height: 40),
              EditItem(
                title: "Gender",
                widget: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          gender = "man";
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: gender == "man"
                            ? Colors.blue[100]
                            : Colors.grey.shade200,
                        fixedSize: const Size(50, 50),
                      ),
                      icon: Icon(
                        Ionicons.male,
                        color: gender == "man" ? Colors.white : Colors.black,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          gender = "woman";
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: gender == "woman"
                            ? Colors.pink[100]
                            : Colors.grey.shade200,
                        fixedSize: const Size(50, 50),
                      ),
                      icon: Icon(
                        Ionicons.female,
                        color: gender == "woman" ? Colors.white : Colors.black,
                        size: 18,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Save Changes Butonu
              Center(
                child: ElevatedButton(
                  onPressed: _updateUserData, // Güncelleme işlemi
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[100], // Mor renk
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

