import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/task_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _taskController = TextEditingController();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _editingTaskId;
  String? _errorText;

  // Format remaining time
  String _formatTimeLeft(DateTime dateTime) {
    final now = DateTime.now();
    final diff = dateTime.difference(now);
    if (diff.isNegative) return "Time's up";
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    return '$days days $hours hrs $minutes mins left';
  }

  // Submit add/update task
  Future<void> _submitTask(TaskProvider taskProvider) async {
    final task = _taskController.text.trim();
    final title = _titleController.text.trim();
    final date = _selectedDate;
    final time = _selectedTime;

    if (title.isEmpty || task.isEmpty || date == null || time == null) {
      setState(() {
        _errorText = 'Please fill all fields and pick date & time';
      });
      return;
    }

    final fullDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    final confirm = await _showConfirmDialog(
        _editingTaskId == null ? 'Add this task?' : 'Update this task?');
    if (!confirm) return;

    if (_editingTaskId == null) {
      await taskProvider.addTask(title, task, fullDateTime);
    } else {
      await taskProvider.updateTask(_editingTaskId!, title, task, fullDateTime);
      _editingTaskId = null;
    }

    _taskController.clear();
    _titleController.clear();
    _selectedDate = null;
    _selectedTime = null;
    _errorText = null;
    Navigator.pop(context);
  }

  // Open edit modal
  void _editTask(String id, String task, String title, Timestamp? timestamp) {
    final dt = timestamp?.toDate();
    setState(() {
      _editingTaskId = id;
      _taskController.text = task;
      _titleController.text = title;
      _selectedDate = dt;
      _selectedTime = dt != null ? TimeOfDay.fromDateTime(dt) : null;
      _errorText = null;
    });
    _openTaskModal();
  }

  // Show confirmation dialog
  Future<bool> _showConfirmDialog(String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm'),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes')),
            ],
          ),
        ) ??
        false;
  }

  // Open modal for adding/updating task
  void _openTaskModal() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_editingTaskId == null ? 'Add Task' : 'Update Task'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Task Title')),
              const SizedBox(height: 10),
              TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No date chosen'
                        : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: const Text("Pick Date"),
                )
              ]),
              Row(children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? 'No time chosen'
                        : 'Time: ${_selectedTime!.format(context)}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => _selectedTime = picked);
                  },
                  child: const Text("Pick Time"),
                )
              ]),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_errorText!,
                      style: const TextStyle(color: Colors.red)),
                )
            ],
          ),
        ),
        actions: [
          ElevatedButton(
              onPressed: () => _submitTask(taskProvider),
              child: Text(_editingTaskId == null ? 'Add' : 'Update'))
        ],
      ),
    );
  }

  // Build filter button
  Widget _buildFilterButton(String label, TaskProvider taskProvider) {
    final bool isSelected = taskProvider.filter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.black : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => taskProvider.setFilter(label),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Redirecting...")));
    }

    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Your Tasks", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => Navigator.pushNamed(context, "/userdetails"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.api, color: Colors.blueAccent),
            tooltip: "View API Users",
            onPressed: () => Navigator.pushNamed(context, '/api_product_screen'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              _taskController.clear();
              _titleController.clear();
              _selectedDate = null;
              _selectedTime = null;
              _editingTaskId = null;
              _errorText = null;
              _openTaskModal();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildFilterButton('All', taskProvider),
                _buildFilterButton('Completed', taskProvider),
                _buildFilterButton('Pending', taskProvider),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text("No tasks found"))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final doc = tasks[index];
                      final task = doc['task'] ?? '';
                      final title = doc['title'] ?? '';
                      final date = (doc['date'] as Timestamp?)?.toDate();
                      final completed = doc['completed'] ?? false;
                      final isTimeUp = date != null &&
                          date.isBefore(DateTime.now()) &&
                          !completed;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: isTimeUp ? Colors.red : Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            checkColor: Colors.black,
                            activeColor: Colors.white,
                            value: completed,
                            onChanged: (val) =>
                                taskProvider.toggleCompletion(doc.id, completed),
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : null),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task),
                              if (date != null)
                                Text(
                                  _formatTimeLeft(date),
                                  style: TextStyle(
                                    color: isTimeUp ? Colors.red : Colors.black54,
                                    fontWeight: isTimeUp
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editTask(
                                      doc.id, task, title, doc['date'])),
                              IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      taskProvider.deleteTask(doc.id)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
