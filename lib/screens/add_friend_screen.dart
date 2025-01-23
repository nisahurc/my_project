import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'friends_list_screen.dart'; // FriendsListScreen'i eklemeyi unutmayın

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _friendId; // Eşleşen arkadaşın UID'si
  String? _friendNickname; // Eşleşen arkadaşın nickname'i

  Future<void> _searchUser() async {
    setState(() {
      _isSearching = true;
      _friendId = null;
      _friendNickname = null;
    });

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _searchController.text.trim())
        .get();

    if (query.docs.isNotEmpty) {
      final userData = query.docs.first.data();
      setState(() {
        _friendId = query.docs.first.id;
        _friendNickname = userData['nickname'] ?? "Unknown";
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
    }
  }

  Future<void> _addFriend() async {
    if (_friendId == null) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final currentUserDoc = FirebaseFirestore.instance.collection('users').doc(currentUserId);

    await currentUserDoc.update({
      'friends': FieldValue.arrayUnion([_friendId]), // Arkadaş UID'si listeye ekleniyor
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend added successfully!')),
    );

    setState(() {
      _friendId = null;
      _friendNickname = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Center(
              child: Text(
                "Add Friend",
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter user email',
                border: OutlineInputBorder(),
                suffixIcon: Container(
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100, // Arka plan rengi
                    borderRadius: BorderRadius.circular(8), // Köşe yuvarlama
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    color: Colors.purple[800], // İkon rengi
                    iconSize: 24, // İkon boyutu
                    onPressed: _searchUser,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            if (_isSearching) const CircularProgressIndicator(),
            if (_friendNickname != null) ...[
              ListTile(
                title: Text('Nickname: $_friendNickname'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addFriend,
                style: ElevatedButton.styleFrom(
                  backgroundColor:Colors.purple.shade200, // Arka plan rengi
                  foregroundColor: Colors.white, // Yazı rengi
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Yuvarlatılmış köşeler
                  ),
                  elevation: 5, // Gölge efekti
                ),
                child: const Text(
                  'Add Friend',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const Spacer(),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FriendsListScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.purple,
                    width: 2), // Çerçeve rengi ve kalınlığı
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Yuvarlatılmış köşeler
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: const Text(
                'View Friends',
                style: TextStyle(fontSize: 16, color: Colors.purple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



