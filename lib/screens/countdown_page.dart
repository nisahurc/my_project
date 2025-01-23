import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class CountdownPage extends StatefulWidget {
  final String taskId; // Görevin ID'si
  final String taskName; // Görevin adı

  CountdownPage({required this.taskId, required this.taskName});

  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  Duration duration = Duration();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchInitialTime(); // Firebase'den mevcut süreyi al
  }

  // Firebase'den mevcut süreyi al
  void fetchInitialTime() async {
    final taskDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('tasks')
        .doc(widget.taskId)
        .get();

    if (taskDoc.exists) {
      final taskData = taskDoc.data();
      setState(() {
        duration = Duration(seconds: taskData?['duration'] ?? 0);
      });
    }
  }

  // Firebase'e süreyi kaydet
  Future<void> updateTaskDuration() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('tasks')
        .doc(widget.taskId)
        .update({
      'duration': duration.inSeconds,
    });
  }

  // Timer başlat
  void startTimer({bool resets = false}) {
    if (resets) {
      reset();
    }
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  // Timer durdur
  void stopTimer({bool resets = false}) async {
    if (timer != null) {
      timer?.cancel();
      await updateTaskDuration(); // Firebase'e süreyi kaydet
      setState(() {}); // Butonları güncellemek için ekranı yeniden çiz
    }
  }

  // Süreyi sıfırla
  void reset() {
    setState(() => duration = Duration());
  }

  // Süreyi artır
  void addTime() {
    setState(() {
      final seconds = duration.inSeconds + 1;
      duration = Duration(seconds: seconds);
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
                widget.taskName,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTaskName(),
            const SizedBox(height: 20),
            buildTime(),
            const SizedBox(height: 80),
            buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget buildTaskName() => Text(
    widget.taskName,
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.purple[800],
    ),
  );

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildTimeCard(time: hours, header: 'HOURS'),
        const SizedBox(width: 8),
        buildTimeCard(time: minutes, header: 'MINUTES'),
        const SizedBox(width: 8),
        buildTimeCard(time: seconds, header: 'SECONDS'),
      ],
    );
  }

  Widget buildTimeCard({required String time, required String header}) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFFfbe2e1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple[800],
            fontSize: 72,
          ),
        ),
      ),
      const SizedBox(height: 24),
      Text(header),
    ],
  );

  Widget buildButtons() {
    final isRunning = timer == null ? false : timer!.isActive;

    return isRunning
        ? ElevatedButton(
      onPressed: () {
        stopTimer(resets: false);
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('STOP'),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => startTimer(resets: false),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('START'),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            reset();
            updateTaskDuration(); // Firebase'e sıfırlanmış süreyi kaydet
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: const Text('RESET'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    stopTimer(resets: false); // Timer'ı kapatmadan önce durdur
    super.dispose();
  }
}

