import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/todo.dart';
import '../services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayTextInputDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: const Text(
        "Todo",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        children: [
          _messagesListView(),
        ],
      ),
    );
  }

  Widget _messagesListView() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.80,
      width: MediaQuery.sizeOf(context).width,
      child: StreamBuilder<QuerySnapshot<Todo>>(
        stream: _databaseService.getTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Add a todo!"));
          }

          List<Todo> todos = snapshot.data!.docs.map((doc) => doc.data()).toList();

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos[index];
              String todoId = snapshot.data!.docs[index].id;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer,
                  title: Text(todo.task),
                  subtitle: Text(
                    DateFormat("dd-MM-yyyy h:mm a").format(todo.updatedOn.toDate()),
                  ),
                  trailing: Checkbox(
                    value: todo.isDone,
                    onChanged: (value) {
                      Todo updatedTodo = todo.copyWith(
                        isDone: value ?? false,
                        updatedOn: Timestamp.now(),
                      );
                      _databaseService.updateTodo(todoId, updatedTodo);
                    },
                  ),
                  onLongPress: () {
                    _databaseService.deleteTodo(todoId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _displayTextInputDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a todo'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(hintText: "Todo...."),
          ),
          actions: <Widget>[
            MaterialButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              child: const Text('Ok'),
              onPressed: () {
                final task = _textEditingController.text.trim();
                if (task.isNotEmpty) { // Check if the task is not empty
                  Todo todo = Todo(
                    task: task,
                    isDone: false,
                    createdOn: Timestamp.now(),
                    updatedOn: Timestamp.now(),
                  );
                  _databaseService.addTodo(todo);
                  Navigator.pop(context);
                  _textEditingController.clear();
                } else {
                  // Show a warning or error if the task is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a todo.")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
