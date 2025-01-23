import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/screens/edit_screen.dart';
import 'package:my_project/screens/help_screen.dart';
import 'package:my_project/util/forward_button.dart';
import 'package:my_project/util/setting_item.dart';
import 'package:hive/hive.dart';
import 'package:my_project/util/setting_switch.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box box;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    box = Hive.box('mybox'); // Hive kutusunu al
    isDarkMode = box.get('isDarkMode', defaultValue: false); // Tema durumunu yükle
  }

  void _updateTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
    box.put('isDarkMode', value); // Hive'a yeni tema durumunu kaydet
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getNicknameStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // Eğer kullanıcı oturum açmamışsa boş bir stream döndür
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Center(
              child: Text(
                "Settings",
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
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Image.asset("assets/images/avatar.png", width: 70, height: 70),
                    const SizedBox(width: 20),
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: getNicknameStream(), // Nickname stream'i çeken metod
                      builder: (context, snapshot) {
                        String displayName = "No nickname";
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          displayName = "Loading...";
                        } else if (snapshot.hasData && snapshot.data?.data() != null) {
                          displayName = snapshot.data!.data()!['nickname'] ?? "No nickname";
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              " ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Spacer(),
                    ForwardButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditAccountScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SettingItem(
                title: "Language",
                icon: Ionicons.earth,
                bgColor: Colors.orange.shade100,
                iconColor: Colors.orange,
                value: "English",
                onTap: () {},
              ),
              const SizedBox(height: 20),
              SettingItem(
                title: "Notifications",
                icon: Ionicons.notifications,
                bgColor: Colors.blue.shade100,
                iconColor: Colors.blue,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              SettingSwitch(
                title: "Dark Mode",
                icon: Ionicons.moon,
                bgColor: Colors.purple.shade100,
                iconColor: Colors.purple,
                value: isDarkMode,
                onTap: (value) {
                  _updateTheme(value);
                },
              ),
              const SizedBox(height: 20),
              SettingItem(
                title: "Help",
                icon: Ionicons.nuclear,
                bgColor: Colors.red.shade100,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
