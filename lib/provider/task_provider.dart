import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> _tasks = [];
  String _filter = 'All';

  List<DocumentSnapshot> get tasks {
    if (_filter == 'Completed') {
      return _tasks.where((doc) => doc['completed'] == true).toList();
    } else if (_filter == 'Pending') {
      return _tasks.where((doc) => doc['completed'] == false).toList();
    }
    return _tasks;
  }

  String get filter => _filter;

  TaskProvider() {
    listenToTasks();
  }

  // Listen to tasks in Firestore
  void listenToTasks() {
    final user = _auth.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('tasks')
        .doc(user.uid)
        .collection('user_tasks')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _tasks = snapshot.docs;
      notifyListeners();
    });
  }

  // Set task filter
  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  // Add a new task
  Future<void> addTask(String title, String task, DateTime dateTime) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(user.uid)
        .collection('user_tasks')
        .add({
      'title': title,
      'task': task,
      'completed': false,
      'date': Timestamp.fromDate(dateTime),
      'timestamp': Timestamp.now(),
    });
  }

  // Update an existing task
  Future<void> updateTask(
      String id, String title, String task, DateTime dateTime) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(user.uid)
        .collection('user_tasks')
        .doc(id)
        .update({
      'title': title,
      'task': task,
      'date': Timestamp.fromDate(dateTime),
    });
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(user.uid)
        .collection('user_tasks')
        .doc(id)
        .delete();
  }

  // Toggle task completion
  Future<void> toggleCompletion(String id, bool current) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(user.uid)
        .collection('user_tasks')
        .doc(id)
        .update({'completed': !current});
  }
}
