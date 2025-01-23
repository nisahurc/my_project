import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Center(
              child: Text(
                "Help",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight:FontWeight.bold,
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
        backgroundColor: Color (0xFFc8c6f5),
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back,
              color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Bir önceki sayfaya döner (HomeScreen)
          },
        ),
      ),
      body: Container(
        color: Colors.grey.shade100, // Arka plan rengi
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            const Text(
              "How can we help you?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black45),
            ),
            const SizedBox(height: 20),

            // Sık Sorulan Sorular
            _buildSectionTitle("Frequently Asked Questions"),
            _buildFaqItem(
              context,
              "How can I change the app language?",
              "You can change the language by navigating to the settings page and selecting 'Language'.",
            ),
            _buildFaqItem(
              context,
              "How do I enable dark mode?",
              "Go to the settings page and toggle the 'Dark Mode' switch.",
            ),
            _buildFaqItem(
              context,
              "Who can I contact for support?",
              "You can reach out to our support team at support@myproject.com.",
            ),
            const SizedBox(height: 30),

            // İletişim Bilgileri
            _buildSectionTitle("Contact Us"),
            _buildContactItem(Icons.email, "support@myproject.com", Colors.red[200]!),
            _buildContactItem(Icons.phone, "+90553 905 7537", Colors.blue[100]!),
          ],
        ),
      ),
    );
  }

  // Sık sorulan sorular başlığı
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black45),
      ),
    );
  }

  // Her bir soru ve cevabı ayrı bir kart olarak tasarlıyoruz
  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: Icon(Icons.help_outline, color: Colors.blue[100]),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(answer),
      ),
    );
  }

  // İletişim bilgisi her bir satır için tasarım
  Widget _buildContactItem(IconData icon, String info, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 10),
          Text(
            info,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

