import 'package:flutter/material.dart';
import 'package:my_project/screens/countdown_page.dart';

class DetailsPage extends StatelessWidget {
  final String taskName;
  final String taskId;

  DetailsPage({
    required this.taskName,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Center(
              child: Text(
                "My Timer",
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
          ),
          Expanded(
            child: CountdownPage(taskName: taskName,taskId: taskId,), // Countdown sayfasını burada göster
          ),
        ],
      ),
    );
  }
}

