import 'dart:convert';
//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp(const MyApp());
}

final String URL="http://10.0.0.142:5500/";
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 75, 171, 255)),
        ),
      home: TaskManager(),
      );
  }
}

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  List tasks=[];
  List completed=[];
  TextEditingController taskController = TextEditingController();
  void fetchTask()async{
    final response= await http.get(Uri.parse(URL));
    if (response.statusCode==200){
      final t=json.decode(response.body);
      print(t);
      setState(() {
        tasks=t;
      });
    }
    else{
      print("Failed to load task.");
    }
  }
  void addTask()async{
    final x=taskController.text;
    if (x.trim().isNotEmpty){
      try{
        await http.post(Uri.parse("$URL/add_task"),headers: {"Content-Type":"application/json"},body: json.encode({"text":x}));
        fetchTask();
      }
      catch(e){
        print("Failed to add task: $e");
      }
      taskController.clear();
    }
  }
  void deleteTask(int index)async{
    try{
      String id=tasks[index]["id"];
      await http.get(Uri.parse("$URL/delete_task/$id"));
      fetchTask();
    }
    catch(e){
      print("Failed to delete task: $e");
    }
  }
  void completeTask(int index)async{
    try {
      String id = tasks[index]["id"];
      await http.post(Uri.parse("$URL/complete_task/$id"));
      fetchTask();
    } catch (e) {
      print("Failed to complete task: $e");
    }
  }

  @override
  void initState(){
    super.initState();
    fetchTask();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Manager"),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text("Enter a task, then press Add", style: TextStyle(fontSize: 20),),
          Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: TextField(
              controller: taskController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Write your task here."
              ),
            ),
          ),
          ElevatedButton(onPressed: addTask, child: Text("Add your task.")),
          SizedBox(height: 20),
          Text("Your Tasks:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: tasks[index]["completed"],
                    onChanged: (value) {
                      completeTask(index);
                    },
                  ),

                  title: Text(
                    tasks[index]["text"],
                    style: TextStyle(
                      decoration: tasks[index]["completed"]
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}