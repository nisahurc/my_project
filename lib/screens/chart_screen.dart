import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatefulWidget {
  final String userId;

  ChartScreen({required this.userId});

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;
  String? _selectedTask;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _fetchTasks(widget.userId);
  }

  Future<List<Map<String, dynamic>>> _fetchTasks(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Map<String, dynamic> _groupTasksByTaskName(List<Map<String, dynamic>> tasks) {
    Map<String, dynamic> groupedTasks = {};

    for (var task in tasks) {
      final taskName = task['taskName'] ?? 'Unnamed Task';
      final duration = task['duration'] is int
          ? task['duration'] as int
          : (task['duration'] as num).toInt();

      if (groupedTasks.containsKey(taskName)) {
        groupedTasks[taskName]['duration'] += duration;
        groupedTasks[taskName]['tasks'].add(task);
      } else {
        groupedTasks[taskName] = {
          'duration': duration,
          'tasks': [task],
        };
      }
    }

    return groupedTasks;
  }

  Widget _buildChart(Map<String, dynamic> data, String taskName) {
    if (!data.containsKey(taskName)) {
      return Center(
        child: Text("No data available for this task."),
      );
    }

    final taskData = data[taskName];
    final duration = taskData['duration'];

    return BarChart(
      BarChartData(
        maxY: (duration + 5.0).toDouble(),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                y: duration.toDouble(),
                colors: [Colors.purple.shade300],
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: SideTitles(showTitles: true),
          bottomTitles: SideTitles(
            showTitles: false,
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Center(
              child: Text(
                "Timer Charts",
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
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks found.'));
          }

          final groupedData = _groupTasksByTaskName(snapshot.data!);
          final taskNames = groupedData.keys.toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Padding küçültüldü
                child: DropdownButton<String>(
                  value: _selectedTask,
                  hint: Text(
                    "Select a task",
                    style: TextStyle(fontSize: 14.0), // Daha küçük yazı tipi
                  ),
                  isExpanded: true, // Genişletme özelliğini koruyabilirsiniz veya kaldırabilirsiniz
                  items: taskNames.map((taskName) {
                    return DropdownMenuItem<String>(
                      value: taskName,
                      child: Text(
                        taskName,
                        style: TextStyle(fontSize: 14.0), // Yazı tipi küçültüldü
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTask = newValue;
                    });
                  },
                  style: const TextStyle(fontSize: 14.0), // Seçilen yazının boyutu küçültüldü
                  borderRadius: BorderRadius.circular(8.0), // Köşeleri yuvarlatılmış dropdown menüsü
                  dropdownColor: Colors.white, // Arka plan rengini özelleştirebilirsiniz
                ),
              ),
              Expanded(
                child: _selectedTask != null
                    ? _buildChart(groupedData, _selectedTask!)
                    : Center(
                  child: Text("Please select a task to see its chart."),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
