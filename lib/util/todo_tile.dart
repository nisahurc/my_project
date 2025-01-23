import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../screens/countdown_page.dart'; // CountdownPage'in import edilmesi

class ToDoTile extends StatelessWidget {
  final String taskId;
  final String taskName;
  final Function(BuildContext)? deleteFunction;
  final Function()? updateFunction;
  final VoidCallback? onTap;

  ToDoTile({
    super.key,
    required this.taskId,
    required this.taskName,
    required this.deleteFunction,
    required this.updateFunction,
    this.onTap, required duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, top: 25.0, right: 25.0),
      child: Container(
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
            color: Color(0xFFf7e0ff),
            border: Border.all(
                color: Color(0xFFc8c6f5) )
        ),


        child: Slidable(
          endActionPane: ActionPane(
            motion: StretchMotion(),
            children: [
              SlidableAction(
                onPressed: deleteFunction,
                icon: Icons.delete,
                backgroundColor: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
                label: "Delete",

              )
            ],
          ),
          child: GestureDetector(
            onTap: onTap ??
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CountdownPage(taskName: taskName,taskId: taskId,),
                    ),
                  );
                },
            child: ListTile(
              title: Text(
                taskName,
                style:  const TextStyle(
                  fontSize:20,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: updateFunction, // Edit butonu için updateFunction çağırıyoruz
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
