import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String task;
  bool isDone;
  Timestamp createdOn;
  Timestamp updatedOn;

  Todo({
    required this.task,
    required this.isDone,
    required this.createdOn,
    required this.updatedOn,
  });

  Todo.fromJson(Map<String, Object?> json)
      : this(
          task: json['task'] as String? ?? '', // Provide a default value if null
          isDone: json['isDone'] as bool? ?? false, // Default to false if null
          createdOn: json['createdOn'] as Timestamp? ?? Timestamp.now(), // Default to now if null
          updatedOn: json['updatedOn'] as Timestamp? ?? Timestamp.now(), // Default to now if null
        );

  Todo copyWith({
    String? task,
    bool? isDone,
    Timestamp? createdOn,
    Timestamp? updatedOn,
  }) {
    return Todo(
      task: task ?? this.task,
      isDone: isDone ?? this.isDone,
      createdOn: createdOn ?? this.createdOn,
      updatedOn: updatedOn ?? this.updatedOn,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'task': task,
      'isDone': isDone,
      'createdOn': createdOn,
      'updatedOn': updatedOn,
    };
  }
}
