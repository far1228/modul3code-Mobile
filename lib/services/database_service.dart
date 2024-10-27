import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';

const String TODO_COLLECTION_REF = "todos";

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Todo> _todosRef;

  DatabaseService() {
    _todosRef = _firestore.collection(TODO_COLLECTION_REF).withConverter<Todo>(
      fromFirestore: (snapshots, _) => Todo.fromJson(snapshots.data()!),
      toFirestore: (todo, _) => todo.toJson(),
    );
  }

  Stream<QuerySnapshot<Todo>> getTodos() {
    return _todosRef.snapshots();
  }

  Future<void> addTodo(Todo todo) async {
    await _todosRef.add(todo);
  }

  Future<void> updateTodo(String todoId, Todo todo) async {
    await _todosRef.doc(todoId).update(todo.toJson());
  }

  Future<void> deleteTodo(String todoId) async {
    await _todosRef.doc(todoId).delete();
  }
}
