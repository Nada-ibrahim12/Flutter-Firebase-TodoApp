import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();
  List<Task> tasks = [];
  final User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference taskRef;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      taskRef = FirebaseDatabase.instance.ref().child('tasks').child(user!.uid);
      _fetchTasks();
    }
  }

  void _fetchTasks() {
    taskRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          tasks = data.values.map((e) => Task.fromMap(Map<String, dynamic>.from(e))).toList();
        });
      }
    });
  }

  void _addTask(String title) {
    if (user != null) {
      final newTask = Task(title: title);
      final newTaskRef = taskRef.push();
      newTaskRef.set(newTask.toMap()).then((_) {
        Fluttertoast.showToast(msg: 'Task added successfully');
        setState(() {
          tasks.add(newTask);
          _taskController.clear();
        });
      }).catchError((error) {
        Fluttertoast.showToast(msg: 'Failed to add task: $error');
      });
    } else {
      Fluttertoast.showToast(msg: 'User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0), // Adjust the height as needed
        child: AppBar(
          title: const Text(
            'TO-DO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
          ),
          elevation: 4.0,
          shadowColor: Colors.black54,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ];
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        tasks[index].title,
                        style: TextStyle(
                          decoration: tasks[index].isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      leading: Checkbox(
                        value: tasks[index].isCompleted,
                        onChanged: (value) {
                          setState(() {
                            tasks[index].isCompleted = value!;
                            taskRef.child(index.toString()).update({'isCompleted': value});
                          });
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            taskRef.child(index.toString()).remove();
                            tasks.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Enter task',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  String taskText = _taskController.text.trim();
                  if (taskText.isNotEmpty) {
                    _addTask(taskText);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Add Task',
                    style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

class Task {
  String title;
  bool isCompleted;

  Task({
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      isCompleted: map['isCompleted'],
    );
  }
}
