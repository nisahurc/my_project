import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase{
  List toDoList =[];
  final _myBox = Hive.box('mybox');
  void createInitialData(){
    toDoList =[
      ["Make Tutorial"],
      ["Do Exercise"],
    ];
  }
  void loadData(){
    toDoList =_myBox.get("TODOLIST");
  }
  void updateDataBase(){
    _myBox.put("TODOLIST",toDoList);
  }
}