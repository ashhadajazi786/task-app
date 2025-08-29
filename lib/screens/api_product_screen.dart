import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse("https://dummyjson.com/users?limit=35"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        users = data["users"];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("User List", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 500 + index * 20),
                  curve: Curves.easeInOut,
                  child: Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user["image"]),
                      ),
                      title: Text(user["firstName"] + " " + user["lastName"],
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(user["email"],
                          style: const TextStyle(color: Colors.white70)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
